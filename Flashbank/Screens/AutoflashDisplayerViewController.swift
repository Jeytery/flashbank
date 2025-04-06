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
    private let audioAnalyzer = AudioAnalyzer()
    private var animator: UIViewPropertyAnimator!
    private let debugStackView = UIStackView()
    private let bassPowerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
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
        debugStackView.layer.borderColor = UIColor.systemBlue.cgColor
        debugStackView.layer.borderWidth = 1
        debugStackView.addArrangedSubview(bassPowerLabel)
        view.backgroundColor = .black
        audioAnalyzer.onBassPowerUpdate = { [weak self] bassPower in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.bassPowerLabel.text = String(format: "bass power: %.2f", bassPower)
                let strangeLevelToLight: Float = 7
                self.animator?.stopAnimation(true)
                self.animator = nil
//                if bassPower >= self.bassSensitivityLevel.rangeValue.low {
//                    self.view.backgroundColor = .red
//                }
//                if bassPower >= self.bassSensitivityLevel.rangeValue.medium {
//                    self.view.backgroundColor = .green
//                }
//                if bassPower >= self.bassSensitivityLevel.rangeValue.high {
//                    self.view.backgroundColor = .white
//                }
                if bassPower >= strangeLevelToLight {
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
