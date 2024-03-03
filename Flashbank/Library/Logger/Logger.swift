//
//  Logger.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 02.12.2023.
//

import Foundation

enum Logger {
    
    static func log(_ item: @autoclosure () -> Any = ()) {
        #if DEBUG
        print(item())
        #endif
    }
    
    static func error(_ error: Error) {
        #if DEBUG
        log("ERROR: \(error.localizedDescription)")
        #endif
    }
    
    static func error(_ error: String) {
        #if DEBUG
        log("ERROR: " + error)
        #endif
    }
}
