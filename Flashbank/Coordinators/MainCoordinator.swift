//
//  MainCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit

final class OldStyleTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 17.0, *) {
            traitOverrides.horizontalSizeClass = .compact
        }
    }
}

fileprivate final class NoAnimationTabbarImpl: NSObject, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {
    private let settingsAP = StoredAppSettingsActionProvider()
    private let settingsRep = StoredAppSettingsRepository()
    
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        var settings = settingsRep.load()
        settings.lastTabbarIndex = tabBarController.selectedIndex
        _ = settingsAP.store(settings)
    }
}

final class MainCoordinator: Coordinatable {
    private(set) var tabbarViewController: OldStyleTabBarController = OldStyleTabBarController()
    
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
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
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
            self.tabbarViewController.tabBar.alpha = status ? 1 : 0
            
        }
        autoflashCoordinator.menuBeingShowingStatusHandler = {
            [weak self] status in
            guard let self = self else { return }
            self.tabbarViewController.tabBar.isHidden = !status
            self.tabbarViewController.tabBar.alpha = status ? 1 : 0
           
        }
        if #available(iOS 18.0, *) {
            autoflashCoordinator.navigationController.tabBarItem = .init(title: "Autoflash", image: UIImage(systemName: "microphone.fill"), tag: 1)
        } else {
            autoflashCoordinator.navigationController.tabBarItem = .init(title: "Autoflash", image: UIImage(systemName: "speaker.wave.3.fill"), tag: 1)
        }
        tabbarViewController.viewControllers = [
            flashbankMenuCoordinator.navigationController, autoflashCoordinator.navigationController
        ]
        add(coordinatable: flashbankMenuCoordinator)
        add(coordinatable: autoflashCoordinator)
        let settings = StoredAppSettingsRepository().load()
        tabbarViewController.selectedIndex = settings.lastTabbarIndex
    }
}

