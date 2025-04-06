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
    private let tapTableViewInmpl = TapTableViewInmpl()
    private let autoflashSUIViewModel = AutflashMenuViewModel()
    private lazy var autoflashSUI: AutflashMenuViewSUI = AutflashMenuViewSUI(viewModel: autoflashSUIViewModel)
//    private let menuViewController = AutoflashMenuViewController()
    
    private lazy var menuViewController = PluginableHostingViewController(
        rootView: autoflashSUI
    )
    private var isMenuShown = true {
        didSet {
            menuBeingShowingStatusHandler?(isMenuShown)
        }
    }
    
    //AutoflashMenuViewController()
    private let displayerViewController = AutoflashDisplayerViewController()
    private(set) var navigationController = StatusBarHiddenNavigationController()
    
    override func startCoordinator() {
        super.startCoordinator()
        navigationController.viewControllers = [displayerViewController]
        autoflashSUIViewModel.didTapViewHandler = {
            [weak self] in
            self?.didTapMenu()
        }
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
        menuNavigationController.viewControllers = [menuViewController]
        menuViewController.view.backgroundColor = .black.withAlphaComponent(0.8)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        tap.delegate = tapTableViewInmpl
        menuViewController.view.addGestureRecognizer(tap)
        menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.addSubview(menuNavigationController.view)
        NSLayoutConstraint.activate([
            menuNavigationController.view.topAnchor.constraint(equalTo: navigationController.view.topAnchor),
            menuNavigationController.view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor),
            menuNavigationController.view.rightAnchor.constraint(equalTo: navigationController.view.safeAreaLayoutGuide.rightAnchor),
            menuNavigationController.view.leftAnchor.constraint(equalTo: navigationController.view.safeAreaLayoutGuide.leftAnchor)
        ])
        menuNavigationController.view.alpha = 0
        let addButtonPlug = AddNavigationButtonsPlugin(viewController: menuViewController)
            .systemImageButton(side: .right, imageName: "gear", action: {
                let settingsViewController = UIHostingController(rootView: SettingsView())
                self.menuNavigationController.pushViewController(settingsViewController, animated: true)
            })
            .close(side: .left, action: {
                [weak self] in
                self?.hideMenu()
                self?.isMenuShown = false
            })
            
        menuViewController.addPlugin(addButtonPlug)
    }
    
    func showMenu(animated: Bool = true) {
        menuNavigationController.view.alpha = 1
    }
    
    func hideMenu(animated: Bool = true) {
        menuNavigationController.view.alpha = 0
    }
}

final class TapTableViewInmpl: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchedView = touch.view
        var currentView = touchedView
        while let view = currentView {
            if view is UITableViewCell {
                return false
            }
            if view is UICollectionViewCell {
                return false
            }
            if view is UIButton {
                return false
            }
            currentView = view.superview
        }
        return true
    }
}

