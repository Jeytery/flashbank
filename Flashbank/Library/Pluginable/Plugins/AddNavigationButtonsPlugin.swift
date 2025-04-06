//
//  AddNavigationButtonsPlugin.swift
//  beta_orion
//
//  Created by Dmytro Ostapchenko on 20.10.2023.
//

import Foundation
import UIKit

final class AddNavigationButtonsPlugin: Pluginable {
    enum ButtonType {
        case imageButton(UIImage, () -> Void)
        case title(String, () -> Void)
        case systemImageButton(String, () -> Void)
        case boldTitle(String, () -> Void)
    }
    
    enum ButtonInformation {
        case left(ButtonType, InsertType = .append)
        case right(ButtonType, InsertType = .append)
    }
    
    enum InsertType {
        case append
        case insert(Int)
    }
    
    init(buttons: [ButtonInformation], viewController: UIViewController) {
        self.buttons = buttons
        self.viewController = viewController
        if viewController.navigationItem.leftBarButtonItems == nil {
            viewController.navigationItem.leftBarButtonItems = []
        }
        if viewController.navigationItem.rightBarButtonItems == nil {
            viewController.navigationItem.rightBarButtonItems = []
        }
        addButtons(buttons: buttons, viewController: viewController)
    }
    
    convenience init(viewController: UIViewController) {
        self.init(buttons: [], viewController: viewController)
    }
    
    private unowned var viewController: UIViewController
    private let buttons: [ButtonInformation]
}

// MARK: - modificators
extension AddNavigationButtonsPlugin {
    func right(_ buttonType: ButtonType) -> Self {
        viewController.navigationItem.rightBarButtonItems?.append(
            getNavigationButton(buttonType)
        )
        return self
    }
    
    func left(_ buttonType: ButtonType) -> Self {
        viewController.navigationItem.leftBarButtonItems?.append(
            getNavigationButton(buttonType)
        )
        return self
    }
    
    func rightTitle(title: String, action: @escaping () -> Void) -> Self {
        viewController.navigationItem.rightBarButtonItems?.append(
            getNavigationButton(.title(title, action))
        )
        return self
    }
    
    func rightBoldTitle(title: String, action: @escaping () -> Void) -> Self {
        viewController.navigationItem.rightBarButtonItems?.append(
            getNavigationButton(.boldTitle(title, action))
        )
        return self
    }
    
    func navigationClose(side: ButtonSideArgless = .left) -> Self {
        let navButton = getNavigationButton(
            .systemImageButton(
                "xmark.circle.fill", {
                    [weak viewController] in
                    viewController?.dismiss(animated: true)
                }
            ))
        switch side {
        case .left:
            viewController.navigationItem.leftBarButtonItems?.append(navButton)
        case .right:
            viewController.navigationItem.rightBarButtonItems?.append(navButton)
        }
        return self
    }
    
    enum ButtonSideArgless {
        case left
        case right
    }
    
    func systemImageButton(
        side: ButtonSideArgless,
        insertType: InsertType = .append,
        imageName: String,
        action: @escaping () -> Void
    ) -> Self {
        switch side {
        case .left:
            switch insertType {
            case .append:
                viewController.navigationItem.leftBarButtonItems?.append(
                    getNavigationButton(.systemImageButton(imageName, action))
                )
            case .insert(let index):
                viewController.navigationItem.leftBarButtonItems?.insert(
                    getNavigationButton(.systemImageButton(imageName, action)),
                    at: index)
            }
        case .right:
            switch insertType {
            case .append:
                viewController.navigationItem.rightBarButtonItems?.append(
                    getNavigationButton(.systemImageButton(imageName, action))
                )
            case .insert(let index):
                viewController.navigationItem.rightBarButtonItems?.insert(
                    getNavigationButton(.systemImageButton(imageName, action)),
                    at: index)
            }
        }
        return self
    }
    
    func close(
        side: ButtonSideArgless,
        insertType: InsertType = .append,
        action: @escaping () -> Void
    ) -> Self {
        let item = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { _ in action() }),
            menu: nil)
        switch side {
        case .left:
            switch insertType {
            case .append:
                viewController.navigationItem.leftBarButtonItems?.append(
                    item
                )
            case .insert(let index):
                viewController.navigationItem.leftBarButtonItems?.insert(
                    item,
                    at: index)
            }
        case .right:
            switch insertType {
            case .append:
                viewController.navigationItem.rightBarButtonItems?.append(
                    item
                )
            case .insert(let index):
                viewController.navigationItem.rightBarButtonItems?.insert(
                    item,
                    at: index)
            }
        }
        return self
    }
}

// MARK: - internal funcs
private extension AddNavigationButtonsPlugin {
    func addButtons(buttons: [ButtonInformation], viewController: UIViewController) {
        buttons.forEach {
            switch $0 {
            case .left(let buttonType, let insertType):
                switch insertType {
                case .append:
                    viewController.navigationItem.leftBarButtonItems?.append(
                        getNavigationButton(buttonType)
                    )
                case .insert(let index):
                    viewController.navigationItem.leftBarButtonItems?.insert(
                        getNavigationButton(buttonType),
                        at: index)
                }
               
            case .right(let buttonType, let insertType):
                switch insertType {
                case .append:
                    viewController.navigationItem.rightBarButtonItems?.append(
                        getNavigationButton(buttonType)
                    )
                case .insert(let index):
                    viewController.navigationItem.rightBarButtonItems?.insert(
                        getNavigationButton(buttonType),
                        at: index)
                }
            }
        }
    }
    
    func getNavigationButton(_ buttonType: ButtonType) -> UIBarButtonItem {
        switch buttonType {
        case .imageButton(let image, let action):
            return .init(
                title: nil,
                image: image,
                primaryAction: UIAction(handler: {_ in
                    action()
                }),
                menu: nil)
            
        case .title(let titleString, let action):
            return .init(
                title: titleString,
                image: nil,
                primaryAction: UIAction(handler: {_ in
                    action()
                }),
                menu: nil)
            
        case .systemImageButton(let imageName, let action):
            return .init(
                title: nil,
                image: UIImage(systemName: imageName) ?? UIImage(),
                primaryAction: UIAction(handler: {_ in
                    action()
                }),
                menu: nil)
        
        case .boldTitle(let titleString, let action) :
            let value = UIBarButtonItem(
                title: titleString,
                image: nil,
                primaryAction: UIAction(handler: {_ in
                    action()
                }),
                menu: nil)
            value.style = .done
            return value
        }
    }
}
