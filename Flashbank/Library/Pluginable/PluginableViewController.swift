//
//  PluginableViewController.swift
//  beta_orion
//
//  Created by Dmytro Ostapchenko on 15.10.2023.
//

import Foundation
import UIKit

class PluginableViewController: UIViewController {
    private var isEverythingLoaded = false
    private var plugins: [Pluginable]
    
    init(plugins: [Pluginable] = []) {
        self.plugins = plugins
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
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
    
    func addPlugin(_ plugin: Pluginable) {
        self.plugins.append(plugin)
    }
    
    func removePlugin(_ plugin: Pluginable) {
        self.plugins.filter({
            $0 === plugin
        })
    }
    
    func removePlugin(at index: Int) {
        self.plugins.remove(at: index)
    }
}

