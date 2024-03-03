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
    private(set) lazy var navigationController = ClosableNavigationController
        .init(navigationBarClass: nil, toolbarClass: CustomTabBar.self)
        .onlyFirst()
    
    private var menuViewState: MenuViewState!
    
    private var menuViewHosting: UIHostingController<MenuView>!

    init(flashbomb: Flashbomb) {
        self.menuViewState = .init(flashbomb: flashbomb)
        super.init()
        initMenuViewController()
        navigationController.pushViewController(__MenuViewController(), animated: false)
        
        navigationController.didTapCloseButton = { _ in
            let colorPicker = UIColorPickerViewController()
            self.navigationController.present(colorPicker, animated: true, completion: nil)
            
        }
    }

    override func startCoordinator() {
        navigationController.view.backgroundColor = .clear
        navigationController.overrideUserInterfaceStyle = .dark
        menuViewHosting.overrideUserInterfaceStyle = .dark
    }
    
    func getFlashbomb() -> Flashbomb {
        return .init(intensity: 0, colors: [])
    }
}

private extension MenuCoordinator {
    func initMenuViewController() {
        self.menuViewState.outputEventHandler = { [weak self] event in
            switch event {
            case .tapAddColor:
                let colorPicker = UIColorPickerViewController()
                let adapter = GetColorAdapter()
                adapter.didSelectColorHandler = { _ in
                    self?.menuViewState.addColor(colorPicker.selectedColor)
                }
                adapter.didFinishHandler = { _ in
                    colorPicker.dismiss(animated: true)
                }
                colorPicker.delegate = adapter
                self?.navigationController.present(colorPicker, animated: true, completion: nil)
                
            case .tapAddColorPreset: break
            case .tapRemoveAllColors: break 
            }
        }
        let menuView = MenuView(state: self.menuViewState)
        menuViewHosting = UIHostingController(rootView: menuView)
        menuViewHosting.view.backgroundColor = .clear
    }
}
