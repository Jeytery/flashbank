//
//  EmptyTableViewCell.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 07.03.2024.
//

import Foundation
import UIKit

struct EmptyTableViewCellConfig {
    let title1: String
    let title2: String
}

final class EmptyTableViewCell: GlassTableViewCell {
    
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18) // Customize the font size for the bigger title
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14) // Customize the font size for the smaller subtitle
        label.textColor = UIColor.gray // Optionally customize subtitle color
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel1)
        addSubview(titleLabel2)
        
        NSLayoutConstraint.activate([
            titleLabel1.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            titleLabel2.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: 2),
            titleLabel2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel2.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(config: EmptyTableViewCellConfig) {
        titleLabel1.text = config.title1
        titleLabel2.text = config.title2
    }
}

