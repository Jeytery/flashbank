//
//  FlashbankMenuCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit
import SwiftUI

final class FlashbankMenuCoordinator: Coordinatable {
    private(set) var navigationController = UINavigationController()
    private(set) var menuViewController = MenuViewController_v2(flashbomb: .empty)
    
    override func startCoordinator() {
        super.startCoordinator()
        navigationController.viewControllers = [menuViewController]
    }
}

private extension FlashbankMenuCoordinator {
    
}
