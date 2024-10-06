//
//  NamedColor.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit


struct NamedColor: Equatable, Codable {
    let name: String
    let color: UIColor
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case color
        case isActive
    }
    
    init(name: String, color: UIColor, isActive: Bool = false) {
        self.name = name
        self.color = color
        self.isActive = isActive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .color) {
            color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor ?? UIColor.clear
        } else {
            color = UIColor.clear
        }
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .color)
        try container.encode(isActive, forKey: .isActive)
    }
    
    static var red: NamedColor {
        return .init(name: "red", color: .systemRed, isActive: true)
    }
    
    static var green: NamedColor {
        return .init(name: "green", color: .systemGreen, isActive: true)
    }
    
    static var blue: NamedColor {
        return .init(name: "blue", color: .systemBlue, isActive: true)
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
