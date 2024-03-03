//
//  NamedColorsRepository.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit

class NamedColorsRepository {
    func getAppNamedColors() -> [NamedColor] {
        return [
            .init(name: "red", color: .red),
            .init(name: "blue", color: .blue),
            .init(name: "green", color: .green),
        ]
    }
}
 
