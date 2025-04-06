//
//  MainCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit

fileprivate final class NoAnimationTabbarImpl: NSObject, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return .zero
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let view = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        let container = transitionContext.containerView
        container.addSubview(view)
        
        transitionContext.completeTransition(true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

final class MainCoordinator: Coordinatable {
    private(set) var tabbarViewController: UITabBarController = UITabBarController()
    
    private func setupTabbar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        tabBarAppearance.backgroundColor = .clear
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().overrideUserInterfaceStyle = .dark
   }
    
    private let noAnimationTabbarImpl = NoAnimationTabbarImpl()
    
    override func startCoordinator() {
        super.startCoordinator()
        if #available(iOS 18.0, *) {
            tabbarViewController.delegate = noAnimationTabbarImpl
        }
        let flashbankMenuCoordinator = FlashbankCoordinator()
        let autoflashCoordinator = AutoflashCoordinator()
        setupTabbar()
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
        autoflashCoordinator.menuBeingShowingStatusHandler = {
            [weak self] status in
            guard let self = self else { return }
            self.tabbarViewController.tabBar.isHidden = !status
        }
        if #available(iOS 18.0, *) {
            autoflashCoordinator.navigationController.tabBarItem = .init(title: "Autoflash", image: UIImage(systemName: "microphone.fill"), tag: 1)
        } else {
            autoflashCoordinator.navigationController.tabBarItem = .init(title: "Autoflash", image: UIImage(systemName: "camera.filters"), tag: 1)
        }
        tabbarViewController.viewControllers = [
            flashbankMenuCoordinator.navigationController, autoflashCoordinator.navigationController
        ]
        add(coordinatable: flashbankMenuCoordinator)
        add(coordinatable: autoflashCoordinator)
    }
}

