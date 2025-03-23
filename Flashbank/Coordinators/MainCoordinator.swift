//
//  MainCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit

final class MainCoordinator: Coordinatable {
    private(set) var navigationController = UINavigationController()
    private let flashbankDispalyerViewController = FlashbankDisplayerViewController()
    private let menuCoordinator = __MenuCoordinator()
    
    override func startCoordinator() {
        super.startCoordinator()
        setupMenu()
        showMenu(animated: false)
    }
    
    private func showMenu(animated: Bool = true) {
        self.navigationController.present(
            menuCoordinator.tabbarViewController,
            animated: animated
        )
        self.flashbankDispalyerViewController.stopLoop()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupMenu() {
        add(coordinatable: menuCoordinator)
        menuCoordinator.tabbarViewController.modalTransitionStyle = .crossDissolve
        menuCoordinator.tabbarViewController.modalPresentationStyle = .overCurrentContext
        let tabBar = menuCoordinator.tabbarViewController.tabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // adds blur by default
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial) // You can change the style
        appearance.backgroundColor = .clear // Keep it transparent so blur shows
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func presentAutoflashDisplayer() {
        
    }
    
    private func presentFlashbankDisplayer() {
        
    }
    
}
