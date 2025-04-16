//
//  GradientAnimationView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 12.04.2025.
//

import Foundation
import UIKit

final class GradientAnimationView: UIView {

    private let gradientLayer = CAGradientLayer()
    private var isToggle = false
    private(set) var isRunning = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupGradient()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
        setupGradient()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc private func didTap() {
        isToggle.toggle()
        isToggle ? start() : explode()
    }

    private func setupGradient() {
        gradientLayer.locations = [0.2, 1.0]
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor]
        layer.addSublayer(gradientLayer)
    }

    private func animateGradientSequence(color: UIColor) {
        gradientLayer.opacity = 1
        let cgColor = color.cgColor

        let step1 = CABasicAnimation(keyPath: "colors")
        step1.fromValue = [UIColor.black.cgColor, UIColor.black.cgColor]
        step1.toValue = [UIColor.black.cgColor, cgColor]
        step1.duration = 2.0
        step1.fillMode = .forwards
        step1.isRemovedOnCompletion = false

        let step2 = CABasicAnimation(keyPath: "colors")
        step2.fromValue = [UIColor.black.cgColor, cgColor]
        step2.toValue = [cgColor, cgColor]
        step2.beginTime = step1.beginTime + step1.duration
        step2.duration = 2.0
        step2.fillMode = .forwards
        
        step2.isRemovedOnCompletion = false

        let step3 = CABasicAnimation(keyPath: "colors")
        step3.fromValue = [cgColor, cgColor]
        step3.toValue = [cgColor, UIColor.black.cgColor]
        step3.beginTime = step2.beginTime + step2.duration
        step3.duration = 2.0
        step3.fillMode = .forwards
        step3.isRemovedOnCompletion = false

        let step4 = CABasicAnimation(keyPath: "colors")
        step4.fromValue = [cgColor, UIColor.black.cgColor]
        step4.toValue = [UIColor.black.cgColor, UIColor.black.cgColor]
        step4.beginTime = step3.beginTime + step3.duration
        step4.duration = 2.0
        step4.fillMode = .forwards
        step4.isRemovedOnCompletion = false

        let group = CAAnimationGroup()
        group.animations = [step1, step2, step3, step4]
        group.duration = step1.duration + step2.duration + step3.duration + step4.duration
        group.fillMode = .forwards
        group.repeatCount = .infinity
        gradientLayer.add(group, forKey: "gradualRed")
    }

    func start() {
        isRunning = true
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
        setupGradient()
        let colors: [UIColor] = [.red, .green, .magenta]
        animateGradientSequence(color: colors.randomElement()!)
    }

    func explode() {
        isRunning = false
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
        layer.removeAllAnimations()
        layer.sublayers?.removeAll()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
}
