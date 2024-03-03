//
//  NavigationBackButtonAction.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 11.11.2023.
//

import Foundation
import UIKit

class NavigationBackButtonAction: Pluginable {
    private let action: () -> Void
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController, action: @escaping () -> Void) {
        self.action = action
        self.viewController = viewController
    }
    
    func viewWillDisappear() {
        if viewController.isMovingFromParent {
            self.action()
        }
    }
}
