//
//  Flashbomb.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.02.2024.
//

import Foundation
import UIKit

struct Flashbomb: Codable {
    let bpm: Int // BPM
    let colors: [NamedColor]
    
    var intensity: Double {
        guard bpm > 0 else { return 0 }
        return Double(60.0 / Double(bpm))
    }

    static var empty: Flashbomb {
        return .init(bpm: 0, colors: [])
    }
}
