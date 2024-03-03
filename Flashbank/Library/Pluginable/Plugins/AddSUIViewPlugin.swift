//
//  AddSUIViewPlugin.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 16.11.2023.
//

import Foundation
import UIKit
import SwiftUI

class AddSUIViewPlugin<Content>: Pluginable where Content: View {
    private(set) var hostingViewController: UIHostingController<Content>!
    
    init(
        rootView: Content,
        parentViewController: UIViewController
    ) {
        hostingViewController = UIHostingController(rootView: rootView)
        parentViewController.view.backgroundColor = .systemBackground
        
        parentViewController.addChild(hostingViewController)
        parentViewController.view.addSubview(hostingViewController.view)
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingViewController.view.topAnchor.constraint(equalTo: parentViewController.view.topAnchor).isActive = true
        hostingViewController.view.leftAnchor.constraint(equalTo: parentViewController.view.leftAnchor).isActive = true
        hostingViewController.view.rightAnchor.constraint(equalTo: parentViewController.view.rightAnchor).isActive = true
        hostingViewController.view.bottomAnchor.constraint(equalTo: parentViewController.view.bottomAnchor).isActive = true
    }
}
