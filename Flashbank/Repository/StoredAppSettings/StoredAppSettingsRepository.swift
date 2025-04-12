//
//  StoredAppSettingsRepository.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 07.04.2025.
//

import Foundation

struct StoredAppSettings: Codable {
    var isBetaTestingAlertShown: Bool
    var lastTabbarIndex: Int
    var isDebugMenuEnebled: Bool
    
    static var defaultValue: StoredAppSettings {
        .init(
            isBetaTestingAlertShown: false,
            lastTabbarIndex: 0,
            isDebugMenuEnebled: false
        )
    }
    
    func debugMenuEbenebled(isDebugMenuEnebled: Bool) -> Self {
        return .init(isBetaTestingAlertShown: self.isBetaTestingAlertShown, lastTabbarIndex: self.lastTabbarIndex, isDebugMenuEnebled: isDebugMenuEnebled)
    }
}

final class StoredAppSettingsRepository {
    enum LoadError: Error {
        case dataNotFound(key: String)
        case decodingFailed(underlyingError: Error)
    }
    
    private let key = "StoredAppSettingsRepository.key"
    
    func load() -> StoredAppSettings {
        guard let jsonData = UserDefaults.standard.data(forKey: key) else {
            return .defaultValue
        }
        let decoder = JSONDecoder()
        do {
            let flashbomb = try decoder.decode(StoredAppSettings.self, from: jsonData)
            return flashbomb
        } catch {
            return .defaultValue
        }
    }
}

final class StoredAppSettingsActionProvider {
    enum StoreError: Error {
        case encodingFailed
    }
    
    private let key = "StoredAppSettingsRepository.key"
    
    func store(_ settings: StoredAppSettings) -> StoreError? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(settings)
            UserDefaults.standard.set(jsonData, forKey: key)
        } catch {
            return .encodingFailed
        }
        return nil
    }
}

