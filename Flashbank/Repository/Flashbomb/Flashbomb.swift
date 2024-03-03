//
//  Flashbomb.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit

struct Flashbomb {
    let intensity: Double
    let colors: [UIColor]
    
    static var empty: Flashbomb {
        return .init(intensity: 0, colors: [])
    }
}
