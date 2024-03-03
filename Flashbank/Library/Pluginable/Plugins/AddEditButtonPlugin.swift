//
//  AddEditButtonPlugin.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 16.11.2023.
//

import Foundation
import UIKit
import SwiftUI

protocol AddEditButtonPluginEditableView {
    func startEdit()
    func stopEdit()
}

class AddEditButtonPlugin : Pluginable {
    enum Side {
        case left
        case right
    }
    enum Action {
        case insert(Int)
        case append
    }
    
    private let callback: (Bool) -> Void
    private let editableView: AddEditButtonPluginEditableView?
    private let viewController: UIViewController
    private let side: Side
    private let action: Action
    
    private var isEdit: Bool = false
    
    private var itemIndex: Int = 0
    
    init(
        side: Side = .right,
        action: Action = .append,
        viewController: UIViewController,
        editableView: AddEditButtonPluginEditableView? = nil,
        callback: ((Bool) -> Void)? = nil
    ) {
        if let callback = callback {
            self.callback = callback
        }
        else {
            self.callback = { isEdit in
                isEdit ? editableView?.startEdit() : editableView?.stopEdit()
            }
        }
        self.editableView = editableView
        self.viewController = viewController
        self.side = side
        self.action = action
    
        switch side {
        case .left:
            if viewController.navigationItem.leftBarButtonItems == nil {
                viewController.navigationItem.leftBarButtonItems = []
            }
            
            switch action {
            case .append:
                self.itemIndex = viewController.navigationItem.leftBarButtonItems!.count
                viewController.navigationItem.leftBarButtonItems?.append(getEditItem())
            case .insert(let index):
                self.itemIndex = index
                viewController.navigationItem.leftBarButtonItems?.insert(getEditItem(), at: index)
            }
          
        case .right:
            if viewController.navigationItem.rightBarButtonItems == nil {
                viewController.navigationItem.rightBarButtonItems = []
            }
            switch action {
            case .append:
                self.itemIndex = viewController.navigationItem.rightBarButtonItems!.count
                viewController.navigationItem.rightBarButtonItems?.append(getEditItem())
            case .insert(let index):
                self.itemIndex = index
                viewController.navigationItem.rightBarButtonItems?.insert(getEditItem(), at: index)
            }
        }
    }
    
    private func getEditItem() -> UIBarButtonItem {
        return .init(
            title: isEdit ? "Done" : "Edit",
            style: isEdit ? .done : .plain,
            target: self,
            action: #selector(editButtonDidTap)
        )
    }
    
    @objc func editButtonDidTap() {
        isEdit.toggle()
        callback(isEdit)
        
        switch side {
        case .left:
            viewController.navigationItem.leftBarButtonItems?.remove(at: itemIndex)
            viewController.navigationItem.leftBarButtonItems?.insert(getEditItem(), at: itemIndex)
            
        case .right:
            
            viewController.navigationItem.rightBarButtonItems?.remove(at: itemIndex)
            viewController.navigationItem.rightBarButtonItems?.insert(getEditItem(), at: itemIndex)
        }
    }
}

