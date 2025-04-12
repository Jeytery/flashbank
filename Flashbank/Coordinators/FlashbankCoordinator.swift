//
//  FlashbankCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit
import SwiftUI
import AlertKit

class FlashbankCoordinator: Coordinatable {
    var menuBeingShowingStatusHandler: ((Bool) -> Void)?
    
    private(set) lazy var navigationController = StatusBarHiddenNavigationController(
        rootViewController: flashbankViewController
    )
    private lazy var flashbankViewController = FlashbankDisplayerViewController()
    private unowned var menuCoordinator: FlashbankMenuCoordinator!
    
    private let flashbombRep = FlashbombLocalRepository()
    private let flashbombRepProvider = FlashbombLRActionProvider()
    
    // state
    private var isMenuShown = false {
        didSet {
            menuBeingShowingStatusHandler?(isMenuShown)
        }
    }
    private var currentFlashbomb: Flashbomb!
    
    override func startCoordinator() {
        initCurrentFlashbomb()
        initMenuCoordinator()
        displayFlashbank()
        addTapGesture()
        setupMenu()
        
        showMenu(animated: false)
        isMenuShown = true
    }
    
    func showMenu(animated: Bool = true) {
        self.menuCoordinator.navigationController.view.alpha = 1
        self.flashbankViewController.stopLoop()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

private extension FlashbankCoordinator {
    func initMenuCoordinator() {
        let menuCoordinator = FlashbankMenuCoordinator.init(flashbomb: currentFlashbomb)
        self.menuCoordinator = menuCoordinator
        add(coordinatable: menuCoordinator)
    }
    
    func initCurrentFlashbomb() {
        switch flashbombRep.loadFlashbomb() {
        case .success(let flashbomb):
            self.currentFlashbomb = flashbomb
        case .failure(_):
            self.currentFlashbomb = flashbombRep.standardFlashbomb
        }
    }
    
    func displayFlashbank() {
        navigationController.viewControllers = [flashbankViewController]
        flashbankViewController.displayFlashbomb(currentFlashbomb)
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(coreViewDidTap))
        navigationController.view.addGestureRecognizer(tap)
    }
    
    @objc func coreViewDidTap() {
        isMenuShown ? hideMenu() : showMenu()
        isMenuShown.toggle()
    }
  
    func hideMenu() {
        self.menuCoordinator.navigationController.view.alpha = 0
        self.flashbankViewController.startLoop(flashbomb: self.currentFlashbomb)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func setupMenu() {
        menuCoordinator.navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.addSubview(menuCoordinator.navigationController.view)
        NSLayoutConstraint.activate([
            menuCoordinator.navigationController.view.topAnchor.constraint(equalTo: navigationController.view.topAnchor),
            menuCoordinator.navigationController.view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor),
            menuCoordinator.navigationController.view.rightAnchor.constraint(equalTo: navigationController.view.rightAnchor),
            menuCoordinator.navigationController.view.leftAnchor.constraint(equalTo: navigationController.view.leftAnchor)
        ])
        menuCoordinator.navigationController.view.alpha = 1
        menuCoordinator.didClose = { [weak self] currentFlashbomb in
            guard let self = self else { return }
            self.isMenuShown = false
            self.menuCoordinator.navigationController.view.alpha = 0
            self.flashbankViewController.displayFlashbomb(currentFlashbomb)
            if let error = self.flashbombRepProvider.storeFlashbomb(currentFlashbomb) {
                AlertKitAPI.present(
                    title: error.localizedDescription,
                    subtitle: nil,
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
            }
        }
    }
}

