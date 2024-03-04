//
//  NativeHeaderCellView.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 02.02.2024.
//

import Foundation
import UIKit

final class NativeHeaderCellView: UIView {
    private(set) var content: NativeHeaderCollectionViewContent
    
    private let topTitleLabel = UILabel()
    private let bottomTitleLabel = UILabel()
    private let contentView = UIView()
    
    init(frame: CGRect = .zero, content: NativeHeaderCollectionViewContent) {
        self.content = content
        super.init(frame: frame)
        configure(with: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with content: NativeHeaderCollectionViewContent) {
        topTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topTitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        topTitleLabel.textColor = .secondaryLabel
        topTitleLabel.text = content.topTitle.uppercased()
        topTitleLabel.numberOfLines = 0
        
        addSubview(topTitleLabel)
        topTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 41).isActive = true
        topTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        topTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -41).isActive = true
        
        let contentView = content.contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 21).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -21).isActive = true
        contentView.topAnchor.constraint(equalTo: topTitleLabel.bottomAnchor, constant: 6).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: content.contentHeight).isActive = true
        
        bottomTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomTitleLabel.text = content.bottomTitle
        bottomTitleLabel.textColor = .secondaryLabel
        bottomTitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        bottomTitleLabel.numberOfLines = 0
        
        addSubview(bottomTitleLabel)
        bottomTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 41).isActive = true
        bottomTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -41).isActive = true
        bottomTitleLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 6).isActive = true
    }
    
    private enum Constants {
        static let topСonstantPadding: CGFloat = 16
        static let bottomСonstantPadding: CGFloat = 8
    }
    
    var cellHeight: CGFloat {
        let topTitleHeight = calculateLabelHeight(label: topTitleLabel)
        let bottomTitleHeight = calculateLabelHeight(label: bottomTitleLabel)
        
        var totalHeight = Constants.topСonstantPadding + topTitleHeight
        if !content.topTitle.isEmpty, content.contentHeight > 0 {
            totalHeight += 6
        }
        totalHeight += content.contentHeight
        if !content.bottomTitle.isEmpty, content.contentHeight > 0 {
            totalHeight += 6
        }
        totalHeight += bottomTitleHeight
        totalHeight += Constants.bottomСonstantPadding
        return totalHeight
    }

    private func calculateLabelHeight(label: UILabel) -> CGFloat {
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 82, height: .greatestFiniteMagnitude)
        let textRect = label.textRect(forBounds: CGRect(origin: .zero, size: maxSize), limitedToNumberOfLines: 0)
        return ceil(textRect.size.height)
    }
}



