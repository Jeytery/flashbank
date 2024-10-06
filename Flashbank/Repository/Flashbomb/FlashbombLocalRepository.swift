//
//  FlashbombLocalRepository.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 02.03.2024.
//

import Foundation

class FlashbombLocalRepository {
    enum LoadFlashBombError: Error {
        case dataNotFound(key: String)
        case decodingFailed(underlyingError: Error)
    }
    
    private let key = "FlashbombLRActionProvider.key"
    
    func loadFlashbomb() -> Result<Flashbomb, LoadFlashBombError> {
        guard let jsonData = UserDefaults.standard.data(forKey: key) else {
            return .failure(.dataNotFound(key: key))
        }
        let decoder = JSONDecoder()
        do {
            let flashbomb = try decoder.decode(Flashbomb.self, from: jsonData)
            return .success(flashbomb)
        } catch {
            return .failure(.decodingFailed(underlyingError: error))
        }
    }
    
    var standardFlashbomb: Flashbomb {
        return .init(
            bpm: 120,
            colors: [.red, .blue, .green]
        )
    }
}
