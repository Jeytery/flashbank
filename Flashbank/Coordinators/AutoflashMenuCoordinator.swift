//
//  AutoflashMenuCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit
import SwiftUI

final class AutoflashCoordinator: Coordinatable {
    var menuBeingShowingStatusHandler: ((Bool) -> Void)?
    
    private let menuNavigationController = UINavigationController()
    private let menuViewController = UIHostingController(
        rootView: AutflashMenuViewSUI()
    )
    private var isMenuShown = true {
        didSet {
            menuBeingShowingStatusHandler?(isMenuShown)
        }
    }
    
    //AutoflashMenuViewController()
    private let displayerViewController = AutoflashDisplayerViewController()
    private(set) var navigationController = UINavigationController()
    
    override func startCoordinator() {
        super.startCoordinator()
        navigationController.viewControllers = [displayerViewController]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        displayerViewController.view.addGestureRecognizer(tapGesture)
        setupMenu()
        showMenu()
    }
    
    @objc private func didTapMenu() {
        self.isMenuShown ? self.hideMenu() : self.showMenu()
        self.isMenuShown.toggle()
    }
}

private extension AutoflashCoordinator {
    func setupMenu() {
        menuNavigationController.overrideUserInterfaceStyle = .dark
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        menuViewController.view.addGestureRecognizer(tapGesture)
        menuNavigationController.viewControllers = [menuViewController]
        menuViewController.view.backgroundColor = .clear
        menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.addSubview(menuNavigationController.view)
        NSLayoutConstraint.activate([
            menuNavigationController.view.topAnchor.constraint(equalTo: navigationController.view.topAnchor),
            menuNavigationController.view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor),
            menuNavigationController.view.rightAnchor.constraint(equalTo: navigationController.view.safeAreaLayoutGuide.rightAnchor),
            menuNavigationController.view.leftAnchor.constraint(equalTo: navigationController.view.safeAreaLayoutGuide.leftAnchor)
        ])
        menuNavigationController.view.alpha = 0
    }
    
    func showMenu(animated: Bool = true) {
        menuNavigationController.view.alpha = 1
    }
    
    func hideMenu(animated: Bool = true) {
        menuNavigationController.view.alpha = 0
    }
}
