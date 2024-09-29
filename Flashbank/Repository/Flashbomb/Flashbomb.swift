//
//  Flashbomb.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit

struct Flashbomb: Codable {
    let intensity: Double // BPM
    let colors: [NamedColor]
    let isPaused: Bool
    
    static var empty: Flashbomb {
        return .init(intensity: 0, colors: [], isPaused: false)
    }
}
