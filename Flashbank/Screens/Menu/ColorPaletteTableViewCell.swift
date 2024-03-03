//
//  ColorPaletteTableViewCell.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit

class ColorPaletteTableViewCell: GlassTableViewCell {
    private let stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getCircleView(color: UIColor) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = color
        return view
    }
    
    func removeNamedColor(_ namedColor: NamedColor) {
        
    }
    
    func addNamedColor(_ namedColor: NamedColor) {
        
    }
    
    func initalizeNamedColors(_ namedColors: [NamedColor]) {
        
    }
}
