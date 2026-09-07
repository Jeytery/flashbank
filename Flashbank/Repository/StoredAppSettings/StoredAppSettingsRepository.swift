//
//  StoredAppSettingsRepository.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 07.04.2025.
//

import Foundation

struct StoredAppSettings: Codable {
    static let defaultBeatSensitivity: Double = 0.6

    var isBetaTestingAlertShown: Bool
    var lastTabbarIndex: Int
    var isDebugMenuEnebled: Bool
    /// 0...1 — how eagerly autoflash reacts to the music. Higher means more flashes.
    var beatSensitivity: Double

    init(
        isBetaTestingAlertShown: Bool,
        lastTabbarIndex: Int,
        isDebugMenuEnebled: Bool,
        beatSensitivity: Double = StoredAppSettings.defaultBeatSensitivity
    ) {
        self.isBetaTestingAlertShown = isBetaTestingAlertShown
        self.lastTabbarIndex = lastTabbarIndex
        self.isDebugMenuEnebled = isDebugMenuEnebled
        self.beatSensitivity = beatSensitivity
    }

    // Settings stored before sensitivity existed must still decode.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isBetaTestingAlertShown = try container.decode(Bool.self, forKey: .isBetaTestingAlertShown)
        lastTabbarIndex = try container.decode(Int.self, forKey: .lastTabbarIndex)
        isDebugMenuEnebled = try container.decode(Bool.self, forKey: .isDebugMenuEnebled)
        beatSensitivity = try container.decodeIfPresent(Double.self, forKey: .beatSensitivity)
            ?? Self.defaultBeatSensitivity
    }

    static var defaultValue: StoredAppSettings {
        .init(
            isBetaTestingAlertShown: false,
            lastTabbarIndex: 0,
            isDebugMenuEnebled: false
        )
    }

    func debugMenuEbenebled(isDebugMenuEnebled: Bool) -> Self {
        var copy = self
        copy.isDebugMenuEnebled = isDebugMenuEnebled
        return copy
    }

    func beatSensitivity(_ beatSensitivity: Double) -> Self {
        var copy = self
        copy.beatSensitivity = beatSensitivity
        return copy
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
    
    @discardableResult
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

