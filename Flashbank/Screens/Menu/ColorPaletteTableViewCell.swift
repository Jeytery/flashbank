//
//  ColorPaletteTableViewCell.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit

class ColorPaletteTableViewCell: UIView {
    private let stackView = UIStackView()
    private var namedColors: [NamedColor] = []
    
    init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.backgroundColor = .black.withAlphaComponent(0.2)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 13
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func CircleView(color: UIColor) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = color
        return view
    }
    
    func removeNamedColor(_ namedColor: NamedColor) {
        
    }
    
    func addNamedColor(_ namedColor: NamedColor) {
        namedColors.append(namedColor)
//        UIView.animate(withDuration: 0.4, animations: {
//            stackView.arrangedSubviews.append(
//                CircleView(color: namedColor.color)
//            )
//        })
    }
    
    func initalizeNamedColors(_ namedColors: [NamedColor]) {
        
    }
}
