//
//  FlashbankCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit
import SwiftUI

class FlashbankCoordinator: Coordinatable {
    private(set) lazy var navigationController = UINavigationController(
        rootViewController: flashbankViewController
    )
    private lazy var flashbankViewController = __FlashbankViewController()
    private unowned var menuCoordinator: MenuCoordinator!
    
    private let flashbombRep = FlashbombLocalRepository()
    
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
        switch flashbombRep.getFlashbomb() {
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
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.menuCoordinator.navigationController.view.alpha = 1
        })
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.menuCoordinator.navigationController.view.alpha = 0
        })
    }
    
    func setupMenu() {
        navigationController.view.addSubview(menuCoordinator.navigationController.view)
        menuCoordinator.navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        menuCoordinator.navigationController.view.backgroundColor = .clear
        menuCoordinator.navigationController.view.topAnchor.constraint(equalTo:       navigationController.view.topAnchor).isActive = true
        menuCoordinator.navigationController.view.bottomAnchor.constraint(equalTo:    navigationController.view.bottomAnchor).isActive = true
        menuCoordinator.navigationController.view.leftAnchor.constraint(equalTo:      navigationController.view.leftAnchor).isActive = true
        menuCoordinator.navigationController.view.rightAnchor.constraint(equalTo:     navigationController.view.rightAnchor).isActive = true
        menuCoordinator.navigationController.view.alpha = 0
       
    }
}

