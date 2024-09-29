//
//  FakeToolBar.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.09.2024.
//

import Foundation
import UIKit
import SwiftUI

class FakeToolBar: UIView {
    private var blurView: UIVisualEffectView!
    private let lineView = UIView()
    
    enum FakeToolBarStyle {
        case native
        case flyingCapsule
    }
    
    init(frame: CGRect = .zero, blurStyle: UIBlurEffect.Style = .systemMaterialDark, style: FakeToolBarStyle = .native) {
        super.init(frame: frame)
        let blurEffect = UIBlurEffect(style: blurStyle)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        addSubview(blurView)
        backgroundColor = .clear
        switch style {
        case .native:
            addLineView()
        case .flyingCapsule:
            layer.borderColor = UIColor.separator.cgColor
            layer.borderWidth = 0.4
            let cornerRadius: CGFloat = 25
            layer.cornerRadius = cornerRadius
            blurView.layer.cornerRadius = cornerRadius
            blurView.clipsToBounds = true
        }
    }
    
    private func addLineView() {
        lineView.backgroundColor = .separator
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.widthAnchor.constraint(equalTo: widthAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.4),
            lineView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = self.bounds
    }
    
    static func suiRepresentable(blurStyle: UIBlurEffect.Style) -> FakeToolBarRepresentable {
        return FakeToolBarRepresentable(blurStyle: blurStyle)
    }
}

struct FakeToolBarRepresentable: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style = .systemMaterialDark
    
    func makeUIView(context: Context) -> FakeToolBar {
        return FakeToolBar(blurStyle: blurStyle)
    }
    
    func updateUIView(_ uiView: FakeToolBar, context: Context) {
        // Update the view if needed
    }
}

