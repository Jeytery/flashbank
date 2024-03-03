//
//  PluginableHostingViewController.swift
//  beta_orion
//
//  Created by Dmytro Ostapchenko on 15.10.2023.
//

import Foundation
import SwiftUI
import UIKit

class PluginableHostingViewController<Content: View>: UIHostingController<Content> {
    private var isEverythingLoaded = false
    private var plugins: [Pluginable]
    
    init(rootView: Content, plugins: [Pluginable] = []) {
        self.plugins = plugins
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plugins.forEach {
            $0.viewDidLoad()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        plugins.forEach {
            $0.viewDidAppear()
        }
        
        if !isEverythingLoaded {
            isEverythingLoaded = true
            plugins.forEach {
                $0.viewDidLoadEverything()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plugins.forEach {
            $0.viewWillAppear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        plugins.forEach {
            $0.viewWillDisappear()
        }
    }
    
    func addPlugin(_ plugin: Pluginable) {
        self.plugins.append(plugin)
    }
    
    func addPlugins(_ plugins: [Pluginable]) {
        plugins.forEach(addPlugin)
    }
    
    func removePlugin(_ plugin: Pluginable) {
        self.plugins =  self.plugins.filter({
            $0 === plugin
        })
    }
    
    func removePlugin(at index: Int) {
        self.plugins.remove(at: index)
    }
}
