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
        rootViewController: flashbankDisplayerViewController
    )
    private lazy var flashbankDisplayerViewController = FlashbankDisplayerViewController()
    private unowned var menuCoordinator: FlashbankMenuCoordinator!
    
    private let flashbombRep = FlashbombLocalRepository()
    private let flashbombRepProvider = FlashbombLRActionProvider()
    private let tapTableViewInmpl = TapTableViewInmpl()
    
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
        self.flashbankDisplayerViewController.stopLoop()
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
        navigationController.viewControllers = [flashbankDisplayerViewController]
        flashbankDisplayerViewController.displayFlashbomb(currentFlashbomb)
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(coreViewDidTap))
        tap.delegate = tapTableViewInmpl
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(coreViewDidTap))
        tap2.delegate = tapTableViewInmpl
        flashbankDisplayerViewController.view.addGestureRecognizer(tap)
        menuCoordinator.menuViewController.view.addGestureRecognizer(tap2)
    }
    
    @objc func coreViewDidTap() {
        isMenuShown ? hideMenu() : showMenu()
        isMenuShown.toggle()
    }
  
    func hideMenu() {
        self.menuCoordinator.navigationController.view.alpha = 0
        self.flashbankDisplayerViewController.startLoop(flashbomb: self.currentFlashbomb)
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
            self.flashbankDisplayerViewController.displayFlashbomb(currentFlashbomb)
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
