//
//  MenuCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit
import SwiftUI

fileprivate class GetColorAdapter: NSObject, UIColorPickerViewControllerDelegate {
    var didSelectColorHandler: ((UIColorPickerViewController) -> Void)?
    var didFinishHandler: ((UIColorPickerViewController) -> Void)?
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        didSelectColorHandler?(viewController)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        didFinishHandler?(viewController)
    }
}

class MenuCoordinator: Coordinatable {
    var didClose: ((Flashbomb) -> Void)?
    
    private(set) lazy var navigationController = ClosableNavigationController
        .init(navigationBarClass: nil, toolbarClass: CustomTabBar.self)
        .onlyFirst()
    
    private let flashbomb: Flashbomb
    
    private var menuViewController: __MenuViewController

    init(flashbomb: Flashbomb) {
        self.flashbomb = flashbomb
        self.menuViewController = __MenuViewController(flashbomb: flashbomb)
        super.init()
        navigationController.pushViewController(menuViewController, animated: false)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMenuView))
//        menuViewController.view.addGestureRecognizer(tap)
    }
    
    @objc private func didTapMenuView() {
        //didClose?()
    }

    override func startCoordinator() {
        navigationController.view.backgroundColor = .clear
        navigationController.overrideUserInterfaceStyle = .dark
        navigationController.didTapCloseButton = {
            [weak self] _ in
            guard let self = self else { return }
            self.didClose?(self.menuViewController.getCurrentFlashbomb())
        }
        menuViewController.didTapView = {
            [weak self] in
            guard let self = self else { return }
            self.didClose?(self.menuViewController.getCurrentFlashbomb())
        }
    }
    
    func getFlashbomb() -> Flashbomb {
        return .init(intensity: 0, colors: [])
    }
}

private extension MenuCoordinator {
   
}
