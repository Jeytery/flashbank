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

final class MenuCoordinator: Coordinatable {
    var didClose: ((Flashbomb) -> Void)?
    
    private(set) lazy var navigationController = ClosableNavigationController
        .init(navigationBarClass: nil, toolbarClass: CustomTabBar.self)
        .onlyFirst()
    
    private let flashbomb: Flashbomb
    
    private var menuViewController: MenuViewController_v2
    private lazy var getColorAdapter = GetColorAdapter()
    
    private var pickerCoordinator: CustomPickerCoordinator!
    
    private var isUserSelectedColoInPicker = false

    init(flashbomb: Flashbomb) {
        self.flashbomb = flashbomb
        self.menuViewController = MenuViewController_v2(flashbomb: flashbomb)
        super.init()
        navigationController.pushViewController(menuViewController, animated: false)
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
        menuViewController.eventOutputHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didTapSettings:
                let settingsViewController = UIHostingController(rootView: SettingsView())
                let closeNav = ClosableNavigationController(rootViewController: settingsViewController).onlyFirst()
                closeNav.modalPresentationStyle = .fullScreen
                navigationController.present(closeNav, animated: true)
                
            case .didTapAddColor:
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    self.pickerCoordinator = CustomPickerCoordinator(parentNavigationController: self.navigationController)
                    add(coordinatable: pickerCoordinator)
                    pickerCoordinator.tapDoneWithColorHandler = {
                        [weak self] color in
                        guard let self = self else { return }
                        self.menuViewController.addColor(color)
                        pickerCoordinator.coreNavigationController.dismiss(animated: true)
                        self.remove(coordinatable: pickerCoordinator)
                        self.pickerCoordinator = nil
                    }
                }
                else {
                    let colorPicker = UIColorPickerViewController()
                    colorPicker.delegate = getColorAdapter
                    self.navigationController.present(colorPicker, animated: true, completion: nil)
                    getColorAdapter.didSelectColorHandler = {
                        [weak self] picker in
                        guard let self = self else { return }
                        if ProcessInfo.processInfo.isiOSAppOnMac {
                            startCoordinator()
                            self.menuViewController.addColor(picker.selectedColor)
                            picker.dismiss(animated: true)
                        }
                        else {
                            self.isUserSelectedColoInPicker = true
                        }
                    }
                    getColorAdapter.didFinishHandler = {
                        [weak self] picker in
                        if ProcessInfo.processInfo.isiOSAppOnMac {
                            self?.menuViewController.addColor(picker.selectedColor)
                            picker.dismiss(animated: true)
                        }
                        else {
                            if self?.isUserSelectedColoInPicker ?? false {
                                self?.menuViewController.addColor(picker.selectedColor)
                            }
                            self?.isUserSelectedColoInPicker = false
                        }
                    }
                }

            case .didTapEditWithIndexPath(let indexPath): showColorPickerLogic(indexPath: indexPath)
            case .didSelectCellWithIndexPath(let indexPath): showColorPickerLogic(indexPath: indexPath)
            default: break
            }
        }
    }
    
    private func showColorPickerLogic(indexPath: IndexPath) {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            self.pickerCoordinator = CustomPickerCoordinator(parentNavigationController: self.navigationController)
            add(coordinatable: pickerCoordinator)
            pickerCoordinator.tapDoneWithColorHandler = {
                [weak self] color in
                guard let self = self else { return }
                self.menuViewController.updateColor(color, at: indexPath)
                pickerCoordinator.coreNavigationController.dismiss(animated: true)
                self.remove(coordinatable: pickerCoordinator)
                self.pickerCoordinator = nil
            }
        }
        else {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = getColorAdapter
            self.navigationController.present(colorPicker, animated: true, completion: nil)
            getColorAdapter.didSelectColorHandler = {
                [weak self] picker in
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    self?.menuViewController.updateColor(picker.selectedColor, at: indexPath)
                    picker.dismiss(animated: true)
                }
                else {
                    self?.isUserSelectedColoInPicker = true
                }
            }
            getColorAdapter.didFinishHandler = {
                [weak self] picker in
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    self?.menuViewController.updateColor(picker.selectedColor, at: indexPath)
                    picker.dismiss(animated: true)
                }
                else {
                    if self?.isUserSelectedColoInPicker ?? false {
                        self?.menuViewController.updateColor(picker.selectedColor, at: indexPath)
                    }
                }
                self?.isUserSelectedColoInPicker = false
            }
        }
    }
}

private extension MenuCoordinator {
   
}













































final class __MenuCoordinator: Coordinatable {
    private(set) var tabbarViewController = UITabBarController()
    private let flashbankMenuCoordinator = FlashbankMenuCoordinator()
    
    override func startCoordinator() {
        super.startCoordinator()
        flashbankMenuCoordinator.menuViewController.tabBarItem = .init(title: "Flashbank", image: UIImage(systemName: "01.circle.fill"), tag: 0)
        let autoflashViewController = AutoflashMenuViewController()
        autoflashViewController.tabBarItem = .init(title: "Autoflash", image: UIImage(systemName: "02.circle.fill"), tag: 1)
        add(coordinatable: flashbankMenuCoordinator)
        tabbarViewController.viewControllers = [
            flashbankMenuCoordinator.menuViewController, autoflashViewController
        ]
    }
}


