//
//  SliderView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit

class SliderView: UIView {
    private let intensityLabel = UILabel()
    private let slider = UISlider()
    private let valueLabel = UILabel()
    
    var sliderValue: Float {
        return slider.value
    }
    
    func setSliderValue(_ value: Float) {
        slider.value = value
        valueLabel.text = String(format: "%.2f", slider.value)
    }
    
    init() {
        super.init(frame: .zero)
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false
        intensityLabel.text = "Intensity"
        
        addSubview(intensityLabel)
        intensityLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        intensityLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        intensityLabel.font = .systemFont(ofSize: 14, weight: .regular)
        intensityLabel.textColor = .white.withAlphaComponent(0.7)
        
        addSubview(valueLabel)
        valueLabel.text = String(format: "%.2f", slider.value)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.topAnchor.constraint(equalTo: intensityLabel.bottomAnchor, constant: 12).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        valueLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        valueLabel.textAlignment = .right
        
        addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor).isActive = true
        slider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        slider.rightAnchor.constraint(equalTo: valueLabel.leftAnchor).isActive = true
        slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        slider.minimumValue = 0.001
        slider.maximumValue = 0.4
    }
    
    @objc private func sliderDidChangeValue() {
        valueLabel.text = String(format: "%.3f", slider.value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

