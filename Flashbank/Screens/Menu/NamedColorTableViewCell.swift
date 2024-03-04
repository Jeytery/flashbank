//
//  NamedColorTableViewCell.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 04.03.2024.
//

import Foundation
import UIKit

class NamedColorTableViewCell: GlassTableViewCell {
    var didTapCross: (() -> Void)?
    
    private let colorView = UIView()
    private let nameLabel = UILabel()
    private let removeImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        colorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        colorView.layer.cornerRadius = 15
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: colorView.rightAnchor, constant: 10).isActive = true
        
        addSubview(removeImageView)
        let config = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        removeImageView.image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        removeImageView.translatesAutoresizingMaskIntoConstraints = false
        removeImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        removeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        removeImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        removeImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        removeImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeImageViewDidTap))
        removeImageView.addGestureRecognizer(tap)
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func removeImageViewDidTap() {
        didTapCross?()
    }
    
    func configure(namedColor: NamedColor) {
        colorView.backgroundColor = namedColor.color
        nameLabel.text = namedColor.name
    }
}
