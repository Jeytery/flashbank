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
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = flashbankCoordinator.navigationController
        window?.makeKeyAndVisible()
        flashbankCoordinator.startCoordinator()
        return true
    }
}

