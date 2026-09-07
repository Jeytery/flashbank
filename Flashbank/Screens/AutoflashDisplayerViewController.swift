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
    private let bpmLabel: UILabel = {
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
    private var currentHue: CGFloat = .random(in: 0...1)
    
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
        debugStackView.addArrangedSubview(bpmLabel)
        self.bassPowerLabel.text = "bass power: 0.0"
        self.bassSensitivityLevelLabel.text = "onset z: 0.0"
        self.decibelLabel.text = "dbPower: 0.0 db"
        self.bpmLabel.text = "bpm: --"
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
        audioAnalyzer.onBPMUpdate = { [weak self] bpm in
            DispatchQueue.main.async {
                guard let self, !self.debugStackView.isHidden else { return }
                if let bpm {
                    self.bpmLabel.text = String(format: "bpm: %.0f", bpm)
                } else {
                    self.bpmLabel.text = "bpm: --"
                }
            }
        }
        audioAnalyzer.onBeat = { [weak self] beat in
            DispatchQueue.main.async {
                self?.handleBeat(beat)
            }
        }
        radialGradientView = .init(frame: view.bounds)
        view.insertSubview(radialGradientView, at: 0)
        flashView.frame = view.bounds
        flashView.backgroundColor = .clear
        view.insertSubview(flashView, at: 1)
    }
    
    private func handleBeat(_ beat: AudioAnalyzer.Beat) {
        currentHue = (currentHue + 0.618).truncatingRemainder(dividingBy: 1)
        let color = UIColor(hue: currentHue, saturation: 0.85, brightness: 1, alpha: 1)
        screensaverTimer?.invalidate()
        screensaverTimer = nil
        radialGradientView.explode()
        if beat.isPredicted {
            pulse(color: color, intensity: 0.5)
            startScreensaverTimer()
        } else {
            flash(color: beat.intensity > 0.85 ? .white : color, intensity: beat.intensity)
            pulse(color: color, intensity: beat.intensity)
        }
    }

    private func flash(color: UIColor, intensity: Float) {
        self.animator?.stopAnimation(true)
        self.animator = nil
        self.flashView.backgroundColor = color
        self.flashView.alpha = CGFloat(0.35 + 0.65 * intensity)
        self.animator = UIViewPropertyAnimator(
            duration: 0.28 + 0.22 * Double(intensity),
            curve: .easeOut
        ) {
            self.flashView.alpha = 0
        }
        self.animator.addCompletion({ _ in
            self.startScreensaverTimer()
        })
        self.animator.startAnimation()
    }

    private func pulse(color: UIColor, intensity: Float) {
        let size = max(view.bounds.width, view.bounds.height) * 1.2
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.colors = [
            color.withAlphaComponent(0.85).cgColor,
            color.withAlphaComponent(0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        layer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.layer.insertSublayer(layer, above: flashView.layer)
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.25
        scale.toValue = 0.8 + CGFloat(intensity)
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.9
        fade.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 0.45
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        layer.opacity = 0
        layer.add(group, forKey: "pulse")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            layer.removeFromSuperlayer()
        }
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

    func setBeatZThreshold(_ value: Float) {
        audioAnalyzer.setZThreshold(value)
    }
}

