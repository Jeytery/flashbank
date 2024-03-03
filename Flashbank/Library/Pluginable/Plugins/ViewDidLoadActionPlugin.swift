//
//  ViewDidLoadActionPlugin.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit

final class ViewDidLoadActionPlugin: Pluginable {
    
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func viewDidLoad() {
        self.action()
    }
}
