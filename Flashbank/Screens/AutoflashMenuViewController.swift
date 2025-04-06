//
//  AutoflashMenuViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit
import SwiftUI

final class AutoflashMenuViewController: PluginableViewController {
    init() {
        super.init()
        addPlugin(AddSUIViewPlugin(rootView: AutflashMenuViewSUI(), parentViewController: self))
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
    }
}
