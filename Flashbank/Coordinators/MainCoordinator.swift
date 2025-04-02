//
//  MainCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit

//final class MainCoordinator: Coordinatable {
//    private(set) var navigationController = UINavigationController()
//    private let flashbankDispalyerViewController = FlashbankDisplayerViewController()
//    private let menuCoordinator = __MenuCoordinator()
//    
//    override func startCoordinator() {
//        super.startCoordinator()
//        setupMenu()
//        
//        let testVC = UIViewController()
//        testVC.view.backgroundColor = .systemBlue
//        self.navigationController.setViewControllers([testVC], animated: false)
//        
//        showMenu(animated: false)
//    }
//    
//    private func showMenu(animated: Bool = true) {
//        self.navigationController.present(
//            menuCoordinator.tabbarViewController,
//            animated: animated
//        )
//        //self.flashbankDispalyerViewController.stopLoop()
//        UIApplication.shared.isIdleTimerDisabled = false
//    }
//    
//    private func setupMenu() {
//        add(coordinatable: menuCoordinator)
//        menuCoordinator.tabbarViewController.modalTransitionStyle = .crossDissolve
//        menuCoordinator.tabbarViewController.view.backgroundColor = .clear
//        menuCoordinator.tabbarViewController.modalPresentationStyle = .overCurrentContext
//        //let tabBar = menuCoordinator.tabbarViewController.tabBar
//        //tabBar.standardAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
//        //let appearance = UITabBarAppearance()
//        //appearance.configureWithDefaultBackground() // adds blur by default
//        //appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial) // You can change the style
//        //appearance.backgroundColor = .clear // Keep it transparent so blur shows
//        //tabBar.standardAppearance = appearance
//        
//        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.configureWithTransparentBackground()
//        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
//        tabBarAppearance.backgroundColor = .clear
//        UITabBar.appearance().standardAppearance = tabBarAppearance
//        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//    }
//    
//    private func presentAutoflashDisplayer() {
//        
//    }
//    
//    private func presentFlashbankDisplayer() {
//        
//    }
//    
//}

final class MainCoordinator: Coordinatable {
    private(set) var tabbarViewController: UITabBarController = UITabBarController()
    
    private func setupTabbar() {
       let tabBarAppearance = UITabBarAppearance()
       tabBarAppearance.configureWithTransparentBackground()
       tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
       tabBarAppearance.backgroundColor = .clear
       UITabBar.appearance().standardAppearance = tabBarAppearance
       UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
   }
    
    override func startCoordinator() {
        super.startCoordinator()
        let flashbankMenuCoordinator = FlashbankCoordinator()
        setupTabbar()
        let autoflashViewController = UIViewController()
        autoflashViewController.view.backgroundColor = .cyan
        flashbankMenuCoordinator.navigationController.tabBarItem = .init(
            title: "Flashbank",
            image: UIImage(systemName: "flashlight.on.fill"),
            tag: 0
        )
        flashbankMenuCoordinator.menuBeingShowingStatusHandler = {
            [weak self] status in
            guard let self = self else { return }
            self.tabbarViewController.tabBar.isHidden = !status
        }
        autoflashViewController.tabBarItem = .init(title: "Autoflash", image: UIImage(systemName: "microphone.fill"), tag: 1)
        tabbarViewController.viewControllers = [
            flashbankMenuCoordinator.navigationController, autoflashViewController
        ]
        add(coordinatable: flashbankMenuCoordinator)
        //flashbankMenuCoordinator.showMenu(animated: true)
        
    }
}
