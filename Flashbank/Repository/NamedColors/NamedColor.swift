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
    
    enum CodingKeys: String, CodingKey {
        case name
        case color
    }
    
    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .color) {
            color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor ?? UIColor.clear
        } else {
            color = UIColor.clear
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .color)
    }
    
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
