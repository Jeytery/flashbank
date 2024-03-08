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
        return .init(name: "blue", color: .systemBlue)
    }
    
    static var white: NamedColor {
        return .init(name: "white", color: .white)
    }
    
    static var brightRed: NamedColor {
        return .init(name: "bright red", color: .red)
    }
    
    static var black: NamedColor {
        return .init(name: "black", color: .black)
    }
    
    static var allColors: [NamedColor] {
        return [
            .red, .blue, .green, .brightRed, .white, .black
        ]
    }
}
