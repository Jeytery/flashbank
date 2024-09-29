//
//  ColorItemTableViewCell.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.09.2024.
//

import Foundation
import UIKit

class ColorItemTableViewCell: GlassTableViewCell {
    var didTapCross: (() -> Void)?
    
    private let colorView = UIView()
    private let removeImageView = UIImageView()
    private let editImageView = UIImageView()
    private let tickImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(removeImageView)
        let config = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        removeImageView.image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        removeImageView.translatesAutoresizingMaskIntoConstraints = false
        removeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        removeImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        removeImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        removeImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        
        removeImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeImageViewDidTap))
        removeImageView.addGestureRecognizer(tap)
      
        contentView.addSubview(editImageView)
        editImageView.translatesAutoresizingMaskIntoConstraints = false
        editImageView.image = UIImage(systemName: "pencil.circle.fill", withConfiguration: config)
        editImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        editImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        editImageView.rightAnchor.constraint(equalTo: removeImageView.leftAnchor, constant: -5).isActive = true
        
        contentView.addSubview(tickImageView)
        tickImageView.translatesAutoresizingMaskIntoConstraints = false
        tickImageView.image = UIImage(systemName: "checkmark")
        tickImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        tickImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tickImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        tickImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //colorView.widthAnchor.constraint(equalToConstant: 200),
            colorView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            colorView.leftAnchor.constraint(equalTo: tickImageView.rightAnchor, constant: 10),
            colorView.rightAnchor.constraint(equalTo: editImageView.leftAnchor, constant: -10)
            //colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            //colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        colorView.layer.cornerRadius = 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func removeImageViewDidTap() {
        didTapCross?()
    }
    
    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
}
