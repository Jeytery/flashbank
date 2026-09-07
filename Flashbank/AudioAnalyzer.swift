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

final class TempoTracker {
    private(set) var period: Double = 0
    private(set) var isLocked = false
    private var onsetTimes: [Double] = []

    func addOnset(at time: Double) {
        onsetTimes.append(time)
        onsetTimes.removeAll { time - $0 > 6 }
        estimate()
    }

    func reset() {
        onsetTimes.removeAll()
        period = 0
        isLocked = false
    }

    private func estimate() {
        guard onsetTimes.count >= 4 else {
            isLocked = false
            return
        }
        var intervals: [Double] = []
        for i in 1..<onsetTimes.count {
            for j in max(0, i - 3)..<i {
                var d = onsetTimes[i] - onsetTimes[j]
                while d > 1.0 { d /= 2 }
                if d >= 0.24 { intervals.append(d) }
            }
        }
        guard intervals.count >= 6 else {
            isLocked = false
            return
        }
        let binWidth = 0.02
        var bins: [Int: [Double]] = [:]
        for d in intervals {
            bins[Int(d / binWidth), default: []].append(d)
        }
        var bestBin = -1
        var bestCount = 0
        for bin in bins.keys {
            let count = (bins[bin]?.count ?? 0) + (bins[bin - 1]?.count ?? 0) + (bins[bin + 1]?.count ?? 0)
            if count > bestCount {
                bestCount = count
                bestBin = bin
            }
        }
        guard bestCount >= 5, bestBin >= 0 else {
            isLocked = false
            return
        }
        let cluster = (bins[bestBin] ?? []) + (bins[bestBin - 1] ?? []) + (bins[bestBin + 1] ?? [])
        period = cluster.reduce(0, +) / Double(cluster.count)
        isLocked = period > 0.2
    }
}

final class AudioAnalyzer {
    struct Beat {
        let intensity: Float
        let isPredicted: Bool
    }

    var onBassPowerUpdate: ((Float) -> Void)?
    var onDBPowerUpdate: ((Float) -> Void)?
    /// Fired on a detected musical onset (beat). Called on the detection queue.
    var onBeat: ((Beat) -> Void)?
    /// Debug: current onset z-score vs threshold. Called on the detection queue.
    var onBeatDebugUpdate: ((_ zScore: Float, _ threshold: Float) -> Void)?
    var onBPMUpdate: ((Double?) -> Void)?

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
    private var zThresholdValue: Float = 1.6
    /// Minimum interval between flashes (~250 BPM cap)
    private let refractoryInterval: TimeInterval = 0.16
    /// Ignore everything quieter than this (dB, full-scale mean-square)
    private let silenceFloorDB: Float = -60
    private let fluxHistorySize = 64                // ~1.4s of history

    // MARK: state (detection queue only)
    private let detectionQueue = DispatchQueue(label: "AudioAnalyzer.detection")
    private var prevMagnitudes = [Float](repeating: 0, count: 512)
    private var fluxHistory: [Float] = []
    private var lastBeatTime: CFTimeInterval = 0
    private var lastLoudTime: CFTimeInterval = 0
    private var lastRealOnsetTime: CFTimeInterval = 0
    private let tempoTracker = TempoTracker()
    private var beatAnchor: CFTimeInterval = 0
    private var predictionTimer: DispatchSourceTimer?

    private let audioEngine = AVAudioEngine()

    func setZThreshold(_ value: Float) {
        detectionQueue.async {
            self.zThresholdValue = min(max(value, 1.0), 3.0)
        }
    }

    func startCapturingAudio() {
        configureSession()
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        guard recordingFormat.sampleRate > 0 else { return }
        detectionQueue.async {
            self.prevMagnitudes = [Float](repeating: 0, count: self.chunkSize / 2)
            self.fluxHistory.removeAll()
            self.tempoTracker.reset()
            self.predictionTimer?.cancel()
            self.predictionTimer = nil
        }
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(chunkSize), format: recordingFormat) {
            [weak self] buffer, time in
            guard let self = self else { return }
            self.detectionQueue.async {
                self.analyzeAudioBuffer(buffer: buffer, time: time)
            }
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
        detectionQueue.async {
            self.predictionTimer?.cancel()
            self.predictionTimer = nil
            self.tempoTracker.reset()
        }
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

    private func analyzeAudioBuffer(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        let sampleRate = buffer.format.sampleRate
        guard sampleRate > 0 else { return }

        let db = calculateDecibels(from: buffer)
        onDBPowerUpdate?(db)
        onBassPowerUpdate?(bassStrength(sampleRate: Float(sampleRate)))

        let loudEnough = db > silenceFloorDB
        if loudEnough {
            lastLoudTime = CACurrentMediaTime()
        }

        let bufferStart = time.isHostTimeValid
            ? AVAudioTime.seconds(forHostTime: time.hostTime)
            : CACurrentMediaTime()

        // The tap usually delivers ~100ms buffers regardless of the requested
        // size — walk it in 1024-sample chunks to keep onset resolution ~21ms.
        var offset = 0
        while offset + chunkSize <= frameCount {
            let chunkTime = bufferStart + Double(offset) / sampleRate
            processChunk(samples: channelData + offset, at: chunkTime, loudEnough: loudEnough)
            offset += chunkSize
        }
    }

    /// Spectral flux onset detection with an adaptive (mean + z*stddev) threshold.
    /// Full-spectrum flux works better than bass-band energy on iPhone: the
    /// built-in mic rolls off below ~100Hz, so pure bass energy is unreliable.
    private func processChunk(samples: UnsafePointer<Float>, at chunkTime: Double, loudEnough: Bool) {
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
        onBeatDebugUpdate?(z, zThresholdValue)

        if z > zThresholdValue, chunkTime - lastBeatTime > refractoryInterval {
            registerOnset(at: chunkTime, z: z)
        }
    }

    private func registerOnset(at time: Double, z: Float) {
        lastBeatTime = time
        lastRealOnsetTime = time
        beatAnchor = time
        tempoTracker.addOnset(at: time)
        let intensity = min(1, max(0, (z - zThresholdValue) / 5 + 0.3))
        onBeat?(Beat(intensity: intensity, isPredicted: false))
        onBPMUpdate?(tempoTracker.isLocked ? 60.0 / tempoTracker.period : nil)
        schedulePrediction()
    }

    private func schedulePrediction() {
        predictionTimer?.cancel()
        predictionTimer = nil
        guard tempoTracker.isLocked else { return }
        let now = CACurrentMediaTime()
        guard now - lastRealOnsetTime < 6 else {
            onBPMUpdate?(nil)
            return
        }
        let period = tempoTracker.period
        var next = beatAnchor + period
        while next <= now + 0.02 { next += period }
        let timer = DispatchSource.makeTimerSource(queue: detectionQueue)
        timer.schedule(deadline: .now() + (next - now), leeway: .milliseconds(5))
        timer.setEventHandler { [weak self] in
            self?.firePredictedBeat(at: next)
        }
        timer.resume()
        predictionTimer = timer
    }

    private func firePredictedBeat(at time: Double) {
        beatAnchor = time
        let now = CACurrentMediaTime()
        if now - lastLoudTime < 2.0, now - lastBeatTime > refractoryInterval {
            lastBeatTime = now
            onBeat?(Beat(intensity: 0.3, isPredicted: true))
        }
        schedulePrediction()
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
    private func bassStrength(sampleRate: Float) -> Float {
        guard sampleRate > 0 else { return 0 }
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
        predictionTimer?.cancel()
        vDSP_destroy_fftsetup(fftSetup)
    }
}
