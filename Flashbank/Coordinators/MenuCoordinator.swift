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

    init(flashbomb: Flashbomb) {
        super.init()
        navigationController.pushViewController(__MenuViewController(flashbomb: flashbomb), animated: false)
        
        navigationController.didTapCloseButton = { _ in
            let colorPicker = UIColorPickerViewController()
            self.navigationController.present(colorPicker, animated: true, completion: nil)
            
        }
    }

    override func startCoordinator() {
        navigationController.view.backgroundColor = .clear
        navigationController.overrideUserInterfaceStyle = .dark
    }
    
    func getFlashbomb() -> Flashbomb {
        return .init(intensity: 0, colors: [])
    }
}

private extension MenuCoordinator {
   
}
