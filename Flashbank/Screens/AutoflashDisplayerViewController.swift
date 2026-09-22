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
    
    /// Flash colors: white plus a couple of bright accents. No red on purpose.
    private let flashColors: [UIColor] = [
        .white,
        UIColor(red: 0, green: 1, blue: 1, alpha: 1),  // cyan
        UIColor(red: 1, green: 0, blue: 1, alpha: 1)   // magenta
    ]

    // effect tuning
    /// Beats weaker than this never trigger a special effect.
    private let strongBeatIntensity: Float = 0.7
    /// Chance a qualifying strong beat turns into an effect instead of a plain flash.
    private let effectProbability: Double = 0.6
    /// Keeps effects occasional even during a long run of strong beats.
    private let effectCooldown: TimeInterval = 6

    // state
    private var currentDBPower: Float = 0
    private var screensaverTimer: Timer!
    private var lastFlashColorIndex: Int?
    private var strobeTimer: Timer?
    private var isPlayingEffect = false
    private var lastEffectTime: CFTimeInterval = 0
    
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
                guard let self = self, !self.isPlayingEffect else { return }
                if self.shouldPlayEffect(for: beat) {
                    self.lastEffectTime = CACurrentMediaTime()
                    Bool.random()
                        ? self.holdFlash(color: self.nextFlashColor())
                        : self.strobeBurst()
                } else {
                    self.flash(color: self.nextFlashColor())
                }
            }
        }
        radialGradientView = .init(frame: view.bounds)
        view.insertSubview(radialGradientView, at: 0)
        flashView.frame = view.bounds
        flashView.backgroundColor = .clear
        view.insertSubview(flashView, at: 1)
    }
    
    /// Random color that never repeats the previous one — two identical flashes
    /// in a row would read as a single long one.
    private func nextFlashColor() -> UIColor {
        var candidates = Array(flashColors.indices)
        if let last = lastFlashColorIndex, candidates.count > 1 {
            candidates.removeAll { $0 == last }
        }
        let index = candidates.randomElement() ?? 0
        lastFlashColorIndex = index
        return flashColors[index]
    }

    private func flash(color: UIColor) {
        prepareForFlash()
        self.flashView.backgroundColor = color
        self.animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeOut) {
            self.flashView.backgroundColor = .clear
        }
        self.animator.startAnimation()
        self.animator.addCompletion({ _ in
            self.startScreensaverTimer()
        })
    }

    /// Stops whatever is on screen right now so a new flash starts from a clean state.
    private func prepareForFlash() {
        self.animator?.stopAnimation(true)
        self.animator = nil
        self.strobeTimer?.invalidate()
        self.strobeTimer = nil
        self.screensaverTimer?.invalidate()
        self.screensaverTimer = nil
        self.radialGradientView.explode()
    }

    private func shouldPlayEffect(for beat: AudioAnalyzer.Beat) -> Bool {
        guard beat.intensity >= strongBeatIntensity else { return false }
        guard CACurrentMediaTime() - lastEffectTime > effectCooldown else { return false }
        return Double.random(in: 0...1) < effectProbability
    }

    /// The light freezes on screen for about a second, then fades away.
    private func holdFlash(color: UIColor) {
        prepareForFlash()
        isPlayingEffect = true
        flashView.backgroundColor = color
        animator = UIViewPropertyAnimator(duration: 0.7, curve: .easeIn) {
            self.flashView.backgroundColor = .clear
        }
        animator.addCompletion({ [weak self] _ in
            guard let self = self else { return }
            self.isPlayingEffect = false
            self.startScreensaverTimer()
        })
        animator.startAnimation(afterDelay: 1.0)
    }

    /// About a second of very fast strobing, switching color on every blink.
    private func strobeBurst() {
        prepareForFlash()
        isPlayingEffect = true
        var ticksLeft = 16          // 16 * 0.06s ≈ 1s, so ~8 blinks
        var isLit = false
        flashView.backgroundColor = .clear
        strobeTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            isLit.toggle()
            self.flashView.backgroundColor = isLit ? self.nextFlashColor() : .clear
            ticksLeft -= 1
            guard ticksLeft <= 0 else { return }
            timer.invalidate()
            self.strobeTimer = nil
            self.flashView.backgroundColor = .clear
            self.isPlayingEffect = false
            self.startScreensaverTimer()
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
        self.strobeTimer?.invalidate()
        self.strobeTimer = nil
        self.animator?.stopAnimation(true)
        self.animator = nil
        self.flashView.backgroundColor = .clear
        self.isPlayingEffect = false
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

