//
//  AutoflashDisplayerViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import UIKit

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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.addSubview(debugStackView)
        debugStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            debugStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            debugStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5)
        ])
        debugStackView.axis = .vertical
        debugStackView.layer.borderColor = UIColor.systemBlue.cgColor
        debugStackView.layer.borderWidth = 1
        debugStackView.addArrangedSubview(bassPowerLabel)
        debugStackView.addArrangedSubview(decibelLabel)
        debugStackView.addArrangedSubview(bassSensitivityLevelLabel)
        self.bassPowerLabel.text = "bass power: 0.0"
        self.bassSensitivityLevelLabel.text = "onset z: 0.0"
        self.decibelLabel.text = "dbPower: 0.0 db"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        audioAnalyzer.onDBPowerUpdate = { [weak self] dbPower in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.currentDBPower = dbPower
                self.decibelLabel.text = String(format: "dbPower: %.2f", dbPower) + " db"
            }
        }
        audioAnalyzer.onBassPowerUpdate = { [weak self] bassPower in
            DispatchQueue.main.async {
                self?.bassPowerLabel.text = String(format: "bass power: %.2f", bassPower)
            }
        }
        audioAnalyzer.onBeatDebugUpdate = { [weak self] z, threshold in
            DispatchQueue.main.async {
                guard let self, !self.debugStackView.isHidden else { return }
                self.bassSensitivityLevelLabel.text = String(format: "onset z: %.2f / %.1f", z, threshold)
            }
        }
        audioAnalyzer.onBeat = { [weak self] beat in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let color: UIColor
                switch beat.intensity {
                case ..<0.4:
                    color = .green
                case ..<0.75:
                    color = .red
                default:
                    color = .white
                }
                self.flash(color: color)
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
        self.radialGradientView.explode()
        self.screensaverTimer?.invalidate()
        self.screensaverTimer = nil
        audioAnalyzer.stopCapturingAudio()
    }
    
    func isDebugInfoShown(_ value: Bool) {
        self.debugStackView.isHidden = !value
    }

    /// - Parameter value: 0...1, higher flashes more often.
    func setSensitivity(_ value: Double) {
        audioAnalyzer.sensitivity = Float(value)
    }
}

