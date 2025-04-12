//
//  AudioAnalyzer.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 06.04.2025.
//

import Foundation
import Accelerate
import AVFoundation

enum BassSensitivityLevel: Int {
    case low
    case medium
    case high
    
    struct RangeValue {
        let low: Float
        let medium: Float
        let high: Float
    }
    
    var rangeValue: RangeValue {
        switch self {
        case .low:
            return .init(
                low: 0.2,
                medium: 0.3,
                high: 0.4
            )
        case .medium:
            return .init(
                low: 2,
                medium: 4,
                high: 6
            )
        case .high:
            return .init(
                low: 6,
                medium: 8,
                high: 10
            )
        }
    }
    
//    var rangeValue: RangeValue {
//        switch self {
//        case .low:
//            return .init(
//                low: 0.2,
//                medium: 0.3,
//                high: 0.4
//            )
//        case .medium:
//            return .init(
//                low: 2,
//                medium: 2,
//                high: 2
//            )
//        case .high:
//            return .init(
//                low: 2,
//                medium: 2,
//                high: 2
//            )
//        }
//    }
}

final class BassPowerSensitivities {
    
    var onSensitivitiesChange: ((BassSensitivityLevel) -> Void)?
    
    func updateDb(_ db: Float) {
        // db -160 to 0
        switch db {
        case -160 ... -25:
            onSensitivitiesChange?(.medium)
        case -25 ... -20:
            onSensitivitiesChange?(.medium)
        case -20 ... 0:
            onSensitivitiesChange?(.high)
        default:
            break
        }
    }
}

final class AudioAnalyzer {
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let recordingFormat: AVAudioFormat

    var onBassPowerUpdate: ((Float) -> Void)?
    var onDBPowerUpdate: ((Float) -> Void)?

    init() {
        inputNode = audioEngine.inputNode
        recordingFormat = inputNode.outputFormat(forBus: 0)
    }

    func startCapturingAudio() {
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.analyzeAudioBuffer(buffer: buffer)
        }
        try? audioEngine.start()
    }

    func stopCapturingAudio() {
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }

    private func analyzeAudioBuffer(buffer: AVAudioPCMBuffer) {
        onBassPowerUpdate?(calculateBassStrength(from: buffer))
        //onDBPowerUpdate?(calculateDecibels(from: buffer))
    }

    func calculateDecibels(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return -160.0 }
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        var rms: Float = 0
        for channel in 0..<channelCount {
            let data = channelData[channel]
            for frame in 0..<frameLength {
                rms += data[frame] * data[frame]
            }
        }
        rms = rms / Float(frameLength * channelCount)
        return 10.0 * log10f(rms + 0.000001)
    }

    func calculateBassStrength(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameCount = Int(buffer.frameLength)
        let sampleRate = Float(buffer.format.sampleRate)
        let log2n = UInt(ceil(log2(Float(frameCount))))
        let n = Int(1 << log2n)
        var realInput = [Float](repeating: 0, count: n)
        for i in 0..<min(frameCount, n) {
            realInput[i] = channelData[i]
        }
        var window = [Float](repeating: 0, count: n)
        vDSP_hann_window(&window, vDSP_Length(n), Int32(vDSP_HANN_NORM))
        vDSP_vmul(realInput, 1, window, 1, &realInput, 1, vDSP_Length(n))
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        let halfN = n / 2
        var realOutput = [Float](repeating: 0, count: halfN)
        var imagOutput = [Float](repeating: 0, count: halfN)
        var splitComplex = DSPSplitComplex(realp: &realOutput, imagp: &imagOutput)
        var tempComplex = [DSPComplex](repeating: DSPComplex(), count: halfN)
        for i in 0..<halfN {
            tempComplex[i].real = realInput[i * 2]
            tempComplex[i].imag = realInput[i * 2 + 1]
        }
        tempComplex.withUnsafeBufferPointer {
            vDSP_ctoz($0.baseAddress!, 2, &splitComplex, 1, vDSP_Length(halfN))
        }
        vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
        var magnitudes = [Float](repeating: 0, count: halfN)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(halfN))
        var normalizedMagnitudes = [Float](repeating: 0, count: halfN)
        var scaleFactor = 1 / Float(n)
        vDSP_vsmul(magnitudes, 1, &scaleFactor, &normalizedMagnitudes, 1, vDSP_Length(halfN))
        vDSP_destroy_fftsetup(fftSetup)
        let binSize = sampleRate / Float(n)
        let lowBin = Int(20 / binSize)
        let highBin = min(Int(250 / binSize), halfN - 1)
        guard lowBin < highBin else { return 0 }
        var bassSum: Float = 0
        for i in lowBin...highBin {
            bassSum += normalizedMagnitudes[i]
        }
        let bassStrength = bassSum / Float(highBin - lowBin + 1)
        return min(bassStrength * 10, 10)
    }
}
