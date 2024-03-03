//
//  AddSmallTitlePlugin.swift
//  beta_orion
//
//  Created by Dmytro Ostapchenko on 26.10.2023.
//

import Foundation
import UIKit

// IMPORTANT: - add navigationController.navigationBar.prefersLargeTitles = true before presenting ViewControlelr with this plugin
final class AddSmallTitlePlugin: Pluginable {
    
    init(title: String, viewController: UIViewController) {
        self.title = title
        self.viewController = viewController
        self.viewController.title = self.title
        self.viewController.navigationItem.largeTitleDisplayMode = .never
    }
    
    func viewDidLoadEverything() {
        viewController.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private unowned var viewController: UIViewController
    private let title: String
}
