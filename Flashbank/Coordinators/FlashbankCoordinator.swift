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
    private(set) lazy var navigationController = UINavigationController(
        rootViewController: flashbankViewController
    )
    private lazy var flashbankViewController = FlashbankViewController()
    private unowned var menuCoordinator: MenuCoordinator!
    
    private let flashbombRep = FlashbombLocalRepository()
    private let flashbombRepProvider = FlashbombLRActionProvider()
    
    // state
    private var isMenuShown = false
    private var currentFlashbomb: Flashbomb!
    
    override func startCoordinator() {
        initCurrentFlashbomb()
        initMenuCoordinator()
        displayFlashbank()
        addTapGesture()
        setupMenu()
    }
}

private extension FlashbankCoordinator {
    func initMenuCoordinator() {
        let menuCoordinator = MenuCoordinator.init(flashbomb: currentFlashbomb)
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
  
    func showMenu() {
        self.navigationController.present(menuCoordinator.navigationController, animated: true)
    }
    
    func hideMenu() {
        self.menuCoordinator.navigationController.dismiss(animated: true)
    }
    
    func setupMenu() {
        menuCoordinator.navigationController.modalTransitionStyle = .crossDissolve
        menuCoordinator.navigationController.modalPresentationStyle = .overCurrentContext
        menuCoordinator.didClose = { [weak self] currentFlashbomb in
            guard let self = self else { return }
            self.isMenuShown = false
            self.menuCoordinator.navigationController.dismiss(animated: true)
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

