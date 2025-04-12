//
//  AutoflashDisplayerViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit
import AVFoundation

final class AutoflashDisplayerViewController: UIViewController {
    // ui
    private var animator: UIViewPropertyAnimator!
    private let debugStackView = UIStackView()
    private let bassPowerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    private let decibelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    private let bassSensitivityLevelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    private var radialGradientView: GradientAnimationView!
    
    // anylizars
    private let audioAnalyzer = AudioAnalyzer()
    private let bassPowerSensitivities = BassPowerSensitivities()
    private var bassSensitivityLevel: BassSensitivityLevel = .medium
    private let flashView = UIView()
    
    // state
    private var currentDBPower: Float = 0
    private var screensaverTimer: Timer!
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(debugStackView)
        debugStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            debugStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            debugStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5),
            debugStackView.widthAnchor.constraint(equalToConstant: 220)
        ])
        debugStackView.axis = .vertical
        debugStackView.layer.borderColor = UIColor.systemBlue.cgColor
        debugStackView.layer.borderWidth = 1
        debugStackView.addArrangedSubview(bassPowerLabel)
        debugStackView.addArrangedSubview(decibelLabel)
        debugStackView.addArrangedSubview(bassSensitivityLevelLabel)
        view.backgroundColor = .black
        bassPowerSensitivities.onSensitivitiesChange = {
            [weak self] bassSensitivityLevel in
            guard let self = self else { return }
            self.bassSensitivityLevel = bassSensitivityLevel
            self.bassSensitivityLevelLabel.text = "sensitivities: \(bassSensitivityLevel)"
        }
        audioAnalyzer.onDBPowerUpdate = { [weak self] dbPower in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.currentDBPower = dbPower
                self.decibelLabel.text = String(format: "dbPower: %.2f", dbPower) + " db"
                self.bassPowerSensitivities.updateDb(self.currentDBPower)
            }
        }
        audioAnalyzer.onBassPowerUpdate = { [weak self] bassPower in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.bassPowerLabel.text = String(format: "bass power: %.2f", bassPower)
                if bassPower >= self.bassSensitivityLevel.rangeValue.medium {
                    self.flash(color: .green)
                }
                if bassPower >= self.bassSensitivityLevel.rangeValue.medium {
                    self.flash(color: .red)
                    
                }
                if bassPower >= self.bassSensitivityLevel.rangeValue.high {
                    self.flash(color: .white)
                }
            }
        }
        radialGradientView = .init(frame: view.bounds)
        view.insertSubview(radialGradientView, at: 0)
        flashView.frame = view.bounds
        flashView.backgroundColor = .clear
        view.insertSubview(flashView, at: 1)
    }
    
    private func flash(color: UIColor) {
        self.animator?.stopAnimation(true)
        self.animator = nil
        self.flashView.backgroundColor = color
        self.screensaverTimer?.invalidate()
        self.screensaverTimer = nil
        self.radialGradientView.explode()
        self.animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeOut) {
            self.flashView.backgroundColor = .clear
        }
        self.animator.startAnimation()
        self.animator.addCompletion({ _ in
            self.startScreensaverTimer()
        })
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        radialGradientView.frame = view.bounds
        flashView.frame = view.bounds
    }
    
    private func startScreensaverTimer() {
        screensaverTimer?.invalidate()
        screensaverTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {
            [weak self] _ in
            self?.radialGradientView.start()
            self?.screensaverTimer?.invalidate()
            self?.screensaverTimer = nil
        }
    }
}

extension AutoflashDisplayerViewController {
    func startLoop() {
        audioAnalyzer.startCapturingAudio()
        startScreensaverTimer()
    }
    
    func stopLoop() {
        audioAnalyzer.stopCapturingAudio()
        self.radialGradientView.explode()
        self.screensaverTimer = nil
    }
}

