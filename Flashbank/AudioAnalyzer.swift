//
//  AudioAnalyzer.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 06.04.2025.
//

import Foundation
import Accelerate
import AVFoundation

/*
    crushes on iOS16 simulator if you connect headphones
 */

final class AudioAnalyzer {
    struct Beat {
        /// 0...1 — how strong the onset is relative to the recent average
        let intensity: Float
    }

    var onBassPowerUpdate: ((Float) -> Void)?
    var onDBPowerUpdate: ((Float) -> Void)?
    /// Fired on a detected musical onset (beat). Called on the audio queue.
    var onBeat: ((Beat) -> Void)?
    /// Debug: current onset z-score vs threshold. Called on the audio queue.
    var onBeatDebugUpdate: ((_ zScore: Float, _ threshold: Float) -> Void)?

    // MARK: FFT / detection constants
    private let chunkSize = 1024                    // ~21ms @ 48kHz
    private let fftLog2n: vDSP_Length = 10
    private lazy var fftSetup = vDSP_create_fftsetup(fftLog2n, FFTRadix(kFFTRadix2))!
    private lazy var window: [Float] = {
        var w = [Float](repeating: 0, count: chunkSize)
        vDSP_hann_window(&w, vDSP_Length(chunkSize), Int32(vDSP_HANN_NORM))
        return w
    }()

    /// Beat fires when onset flux exceeds mean + zThreshold * stddev of recent history
    private let zThreshold: Float = 1.6
    /// Minimum interval between flashes (~250 BPM cap)
    private let refractoryInterval: TimeInterval = 0.16
    /// Ignore everything quieter than this (dB, full-scale mean-square)
    private let silenceFloorDB: Float = -60
    private let fluxHistorySize = 64                // ~1.4s of history

    // MARK: state (audio thread only)
    private var prevMagnitudes = [Float](repeating: 0, count: 512)
    private var fluxHistory: [Float] = []
    private var lastBeatTime: CFTimeInterval = 0

    private let audioEngine = AVAudioEngine()

    func startCapturingAudio() {
        configureSession()
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 else { return }
        prevMagnitudes = [Float](repeating: 0, count: chunkSize / 2)
        fluxHistory.removeAll()
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(chunkSize), format: recordingFormat) {
            [weak self] buffer, _ in
            self?.analyzeAudioBuffer(buffer: buffer)
        }
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func stopCapturingAudio() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .measurement — disables iOS voice processing (AGC, noise suppression)
            // that otherwise filters music out of the mic signal.
            // .mixWithOthers — don't pause music playing on this same device.
            try session.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.mixWithOthers, .defaultToSpeaker]
            )
            try session.setActive(true)
            if session.isInputGainSettable {
                try session.setInputGain(1.0)
            }
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Analysis

    private func analyzeAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        let sampleRate = Float(buffer.format.sampleRate)

        let db = calculateDecibels(from: buffer)
        onDBPowerUpdate?(db)
        onBassPowerUpdate?(bassStrength(samples: channelData, frameCount: frameCount, sampleRate: sampleRate))

        // The tap usually delivers ~100ms buffers regardless of the requested
        // size — walk it in 1024-sample chunks to keep onset resolution ~21ms.
        var offset = 0
        while offset + chunkSize <= frameCount {
            processChunk(samples: channelData + offset, loudEnough: db > silenceFloorDB)
            offset += chunkSize
        }
    }

    /// Spectral flux onset detection with an adaptive (mean + z*stddev) threshold.
    /// Full-spectrum flux works better than bass-band energy on iPhone: the
    /// built-in mic rolls off below ~100Hz, so pure bass energy is unreliable.
    private func processChunk(samples: UnsafePointer<Float>, loudEnough: Bool) {
        let halfN = chunkSize / 2
        var windowed = [Float](repeating: 0, count: chunkSize)
        vDSP_vmul(samples, 1, window, 1, &windowed, 1, vDSP_Length(chunkSize))

        var realOutput = [Float](repeating: 0, count: halfN)
        var imagOutput = [Float](repeating: 0, count: halfN)
        var magnitudes = [Float](repeating: 0, count: halfN)
        realOutput.withUnsafeMutableBufferPointer { realPtr in
            imagOutput.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                windowed.withUnsafeBufferPointer { input in
                    input.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: halfN) {
                        vDSP_ctoz($0, 2, &splitComplex, 1, vDSP_Length(halfN))
                    }
                }
                vDSP_fft_zrip(fftSetup, &splitComplex, 1, fftLog2n, FFTDirection(FFT_FORWARD))
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(halfN))
            }
        }
        var count = Int32(halfN)
        vvsqrtf(&magnitudes, magnitudes, &count)

        // positive spectral flux: how much each bin *grew* since the last chunk
        var flux: Float = 0
        for i in 1..<halfN {
            let diff = magnitudes[i] - prevMagnitudes[i]
            if diff > 0 { flux += diff }
        }
        prevMagnitudes = magnitudes

        fluxHistory.append(flux)
        if fluxHistory.count > fluxHistorySize {
            fluxHistory.removeFirst()
        }
        guard loudEnough, fluxHistory.count >= 16 else { return }

        var mean: Float = 0
        var stddev: Float = 0
        vDSP_normalize(fluxHistory, 1, nil, 1, &mean, &stddev, vDSP_Length(fluxHistory.count))
        guard stddev > 0 else { return }

        let z = (flux - mean) / stddev
        onBeatDebugUpdate?(z, zThreshold)

        let now = CACurrentMediaTime()
        if z > zThreshold, now - lastBeatTime > refractoryInterval {
            lastBeatTime = now
            let intensity = min(1, max(0, (z - zThreshold) / 5 + 0.3))
            onBeat?(Beat(intensity: intensity))
        }
    }

    func calculateDecibels(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return -160.0 }
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return -160.0 }
        var meanSquare: Float = 0
        for channel in 0..<channelCount {
            var channelMS: Float = 0
            vDSP_measqv(channelData[channel], 1, &channelMS, vDSP_Length(frameLength))
            meanSquare += channelMS
        }
        meanSquare /= Float(channelCount)
        return 10.0 * log10f(meanSquare + 0.000001)
    }

    /// Average magnitude in the 20–250Hz band, kept for the debug overlay.
    private func bassStrength(samples: UnsafePointer<Float>, frameCount: Int, sampleRate: Float) -> Float {
        guard frameCount >= chunkSize, sampleRate > 0 else { return 0 }
        let halfN = chunkSize / 2
        let binSize = sampleRate / Float(chunkSize)
        let lowBin = max(Int(20 / binSize), 1)
        let highBin = min(Int(250 / binSize), halfN - 1)
        guard lowBin < highBin else { return 0 }
        var bassSum: Float = 0
        for i in lowBin...highBin {
            bassSum += prevMagnitudes[i]
        }
        return min(bassSum / Float(highBin - lowBin + 1) * 10, 10)
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }
}
