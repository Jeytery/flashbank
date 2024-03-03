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
    
    init() {
        super.init(frame: .zero)
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false
        intensityLabel.text = "Intensity"
        
        addSubview(intensityLabel)
        intensityLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        intensityLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        
        addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.topAnchor.constraint(equalTo: intensityLabel.bottomAnchor, constant: 8).isActive = true
        slider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
        addSubview(valueLabel)
        valueLabel.text = "0"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        valueLabel.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 8).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

