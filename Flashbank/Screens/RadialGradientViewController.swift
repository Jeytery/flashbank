//
//  RadialGradientViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 10.04.2025.
//

import Foundation
import UIKit

class RadialGradientViewController: UIViewController {

    private var gradientView: RadialGradientView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        view.backgroundColor = .black
        addExplodeButton()
    }
    
    private func addGradient() {
        gradientView?.removeFromSuperview()
        let gradient = RadialGradientView(frame: view.bounds)
        view.insertSubview(gradient, at: 0)
        gradientView = gradient
    }
    
    private func addExplodeButton() {
        let button = UIButton(type: .system)
        button.setTitle("💥 Explode", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.tintColor = .white
        button.addTarget(self, action: #selector(explode), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func explode() {
        gradientView?.explode()
    }
}

class RadialGradientView: UIView {
    
    private let layerCount = 10
    private let minScale: CGFloat = 0.6
    private let maxScale: CGFloat = 1.2
    private var radialLayers: [RadialGradientLayer] = []
    
    private(set) var isRunning = false
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func start() {
        isRunning = true
        radialLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        radialLayers.removeAll()
        
        for _ in 0 ..< layerCount {
            let layerSize: CGFloat = 400
            let origin = CGPoint(
                x: bounds.midX - layerSize / 2 + CGFloat.random(in: -40...40),
                y: bounds.midY - layerSize / 2 + CGFloat.random(in: -40...40)
            )
            let gradientLayer = RadialGradientLayer()
            gradientLayer.frame = CGRect(origin: origin, size: CGSize(width: layerSize, height: layerSize))
            layer.addSublayer(gradientLayer)
            radialLayers.append(gradientLayer)
            animateInit(on: gradientLayer)
            animateMovement(on: gradientLayer)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { [self] in
            for gradientLayer in radialLayers {
                animateGradient(on: gradientLayer)
            }
        })
    }
    
    private func animateInit(on gradientLayer: RadialGradientLayer) {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0]
        animation.toValue = [0.0, 0.2]
        animation.duration = Double.random(in: 5...5)
        animation.isRemovedOnCompletion = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.locations = [0.0, NSNumber(value: Float(0.2))]
        gradientLayer.add(animation, forKey: "locationsAnimation2")
    }
    
    private func animateGradient(on gradientLayer: RadialGradientLayer) {
        let animation = CABasicAnimation(keyPath: "locations")
        let localMaxScale = CGFloat.random(in: 0.6 ... 1)
        let localMinScale = CGFloat.random(in: 0.2 ... 0.2)
        animation.fromValue = [0.0, localMinScale]
        animation.toValue = [0.0, localMaxScale]
        animation.duration = Double.random(in: 4 ... 8)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.locations = [0.0, NSNumber(value: Float(localMaxScale))]
        gradientLayer.add(animation, forKey: "locationsAnimation")
    }
    
    private func animateMovement(on gradientLayer: RadialGradientLayer) {
        let move = CABasicAnimation(keyPath: "position")
        move.duration = Double.random(in: 3 ... 6)
        move.autoreverses = true
        move.repeatCount = .infinity
        move.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        let maxOffset: CGFloat = 60
        let newPosition = CGPoint(
            x: gradientLayer.position.x + CGFloat.random(in: -maxOffset...maxOffset),
            y: gradientLayer.position.y + CGFloat.random(in: -maxOffset...maxOffset)
        )
        move.fromValue = gradientLayer.position
        move.toValue = newPosition
        gradientLayer.add(move, forKey: "positionAnimation")
    }
    
    func explode() {
        isRunning = false 
        radialLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        radialLayers.removeAll()
    }
}

class RadialGradientLayer: CAGradientLayer {

    override init() {
        super.init()
        type = .radial
        colors = [UIColor.green.cgColor, UIColor.clear]
        locations = [0, 1]
        startPoint = CGPoint(x: 0.5, y: 0.5)
        endPoint = CGPoint(x: 1, y: 1)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
