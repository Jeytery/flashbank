//
//  WillAppearHandlerPlugin.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 07.04.2025.
//

import Foundation

final class ViewWillAppearHandlerPlugin: Pluginable {
    private let viewWillAppearHandler: () -> Void
    
    init(viewWillAppearHandler: @escaping () -> Void) {
        self.viewWillAppearHandler = viewWillAppearHandler
    }
    
    func viewWillAppear() {
        viewWillAppearHandler()
    }
}
