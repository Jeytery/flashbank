//
//  ClosableNavigationController.swift
//  ProjectQ-iOS
//
//  Created by Jeytery on 20.02.2023.
//

import Foundation
import UIKit

class ClosableNavigationController: UINavigationController {
    var didTapCloseButton: ((UIViewController) -> Void)?
    
    override func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        super.pushViewController(viewController, animated: animated)
        if self.isOnlyFirst {
            if viewControllers.count > 1 { return }
            return addCloseToViewController(viewController)
        }
        addCloseToViewController(viewController)
    }
    
    private func addCloseToViewController(_ viewController: UIViewController) {
        let item = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { [weak self] _ in
                if let closure = self?.didTapCloseButton {
                    closure(viewController)
                }
                else {
                    self?.dismiss(animated: true)
                }
            }),
            menu: nil)
        if viewController.navigationItem.leftBarButtonItems == nil {
            viewController.navigationItem.leftBarButtonItems = []
        }
        viewController.navigationItem.leftBarButtonItems?.insert(item, at: 0)
    }
    
    func pushViewController<T: UIViewController>(
        _ viewController: T,
        animated: Bool,
        configurator: (T) -> Void
    ) {
        self.pushViewController(viewController, animated: animated)
        configurator(viewController)
    }
    
    func onlyFirst() -> ClosableNavigationController {
        self.isOnlyFirst = true
        return self
    }
      
    func all() -> ClosableNavigationController {
        self.isOnlyFirst = false
        return self
    }
    
    private var isOnlyFirst: Bool = false
}
