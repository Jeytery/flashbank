//
//  NamedColor.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit

struct NamedColor: Equatable {
    let name: String
    let color: UIColor
    
    static var red: NamedColor {
        return .init(name: "red", color: .systemRed)
    }
    
    static var green: NamedColor {
        return .init(name: "green", color: .systemGreen)
    }
    
    static var blue: NamedColor {
        return .init(name: UIColor.systemBlue.accessibilityName, color: .systemBlue)
    }
}
