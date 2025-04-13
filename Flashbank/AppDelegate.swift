//
//  AppDelegate.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.02.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let flashbankCoordinator = FlashbankCoordinator()
    private let mainCoordinator = MainCoordinator()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainCoordinator.tabbarViewController
        window?.makeKeyAndVisible()
        mainCoordinator.startCoordinator()
        UIApplication.shared.isIdleTimerDisabled = true
        return true
    }
}
