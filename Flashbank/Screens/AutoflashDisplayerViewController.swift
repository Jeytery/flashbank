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
    
    // anylizars
    private let audioAnalyzer = AudioAnalyzer()
    private let bassPowerSensitivities = BassPowerSensitivities()
    private var bassSensitivityLevel: BassSensitivityLevel = .medium
    
    // state
    private var currentDBPower: Float = 0
    
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
                self.animator?.stopAnimation(true)
                self.animator = nil
                if bassPower >= self.bassSensitivityLevel.rangeValue.medium {
                    self.view.backgroundColor = UIColor.init(red: 45/255, green: 255/255, blue: 79/255, alpha: 1)
                }
                if bassPower >= self.bassSensitivityLevel.rangeValue.high {
                    self.view.backgroundColor = .white
                }
                DispatchQueue.main.async {
                    self.animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeOut) {
                        self.view.backgroundColor = .black
                    }
                    self.animator.startAnimation()
                }
            }
        }
    }
}

extension AutoflashDisplayerViewController {
    func startLoop() {
        audioAnalyzer.startCapturingAudio()
    }
    
    func stopLoop() {
        audioAnalyzer.stopCapturingAudio()
    }
}
