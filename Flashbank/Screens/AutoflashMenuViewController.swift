//
//  AutoflashMenuViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit
import SwiftUI

final class AutoflashMenuViewController: UIViewController {
    private let hostingViewController = UIHostingController(rootView: AutflashMenuViewSUI())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(hostingViewController)
        hostingViewController.view.frame = view.bounds
        view.addSubview(hostingViewController.view)
        hostingViewController.didMove(toParent: self)
        self.view.backgroundColor = .clear
        hostingViewController.view.backgroundColor = .clear
    }
}
