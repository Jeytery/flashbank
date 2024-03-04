//
//  NativeHeaderCollectionView.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 02.02.2024.
//

import Foundation
import UIKit

struct NativeHeaderCollectionViewContent {
    let topTitle: String
    let bottomTitle: String
    let contentView: UIView
    let contentHeight: CGFloat
}

class NativeHeaderView: UIView {
    private(set) var cells: [NativeHeaderCellView] = []
    
    init(frame: CGRect = .zero, contents: () -> [NativeHeaderCollectionViewContent]) {
        super.init(frame: frame)
        contents().forEach(addContent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContent(_ content: NativeHeaderCollectionViewContent) {
        let cell = NativeHeaderCellView(content: content)
        cell.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cell)
        if cells.isEmpty {
            cell.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        else {
            cell.topAnchor.constraint(equalTo: cells.last!.bottomAnchor).isActive = true
        }
        cell.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        cell.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        cell.heightAnchor.constraint(equalToConstant: cell.cellHeight).isActive = true
        self.cells.append(cell)
    }
    
    var dynamicHeight: CGFloat {
        return cells.reduce(0, {
            $0 + $1.cellHeight
        }) //+ 16
    }
}
