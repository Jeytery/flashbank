//
//  AddLargeTitlePlugin.swift
//  beta_orion
//
//  Created by Dmytro Ostapchenko on 20.10.2023.
//

import Foundation
import UIKit

// IMPORTANT: - add navigationController.navigationBar.prefersLargeTitles = true before presenting ViewControlelr with this plugin
final class AddLargeTitlePlugin: Pluginable {
    
    init(title: String, viewController: UIViewController) {
        self.title = title
        self.viewController = viewController
        self.viewController.title = self.title
        self.viewController.navigationItem.largeTitleDisplayMode = .always
    }
    
    func viewDidLoadEverything() {
        viewController.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private unowned var viewController: UIViewController
    private let title: String
}
