//
//  FlashbombLRActionProvider.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 02.03.2024.
//

import Foundation
 
class FlashbombLRActionProvider {
    enum StoreFlashbombError: Error {
        case encodingFailed
    }
    
    private let key = "FlashbombLRActionProvider.key"
    
    func storeFlashbomb(_ flashbomb: Flashbomb) -> StoreFlashbombError? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(flashbomb)
            UserDefaults.standard.set(jsonData, forKey: key)
        } catch {
            return .encodingFailed
        }
        return nil
    }
}
