//
//  Pluginable.swift
//  beta_orion
//
//  Created by Dmytro Ostapchenko on 15.10.2023.
//

import Foundation

protocol Pluginable: AnyObject {
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    func viewWillAppear()
    func viewWillDisappear()
    
    func viewDidLoadEverything()
}

extension Pluginable {
    func viewDidLoad() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
    func viewWillAppear() {}
    func viewWillDisappear() {}
    
    func viewDidLoadEverything() {}
}

class FacadePlugin: Pluginable {
    private var plugins: [Pluginable]
    
    init(plugins: [Pluginable]) {
        self.plugins = plugins
    }

    func viewDidLoad() {
        plugins.forEach {
            $0.viewDidLoad()
        }
    }
    
    func viewDidAppear() {
        plugins.forEach {
            $0.viewDidLoad()
        }
    }
}
