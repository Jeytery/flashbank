//
//  FlashbombLocalRepository.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 02.03.2024.
//

import Foundation

class FlashbombLocalRepository {
    enum GetFlashbombError: Error {
        case error1
    }
    
    func getFlashbomb() -> Result<Flashbomb, GetFlashbombError> {
        return .failure(.error1)
    }
    
    var standardFlashbomb: Flashbomb {
        return .init(
            intensity: 0,
            colors: []
        )
    }
}
