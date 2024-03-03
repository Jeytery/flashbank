//
//  SearchLogicPlugin.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 02.12.2023.
//

import Foundation

class SearchLogicPlugin<ContentType>: Pluginable {
    struct UIRealization {
        var reloadContent: ([ContentType]) -> Void
    }
    
    private let uiRealization: UIRealization
    private let compareLogic: (ContentType, String) -> Bool
    
    private var initialValue: [ContentType]
    private var temporalValue: [ContentType]
    
    init(
        uiRealization: UIRealization,
        initalValue: [ContentType],
        compareLogic: @escaping (ContentType, String) -> Bool
    ) {
        self.uiRealization = uiRealization
        self.initialValue = initalValue
        self.temporalValue = initalValue
        self.compareLogic = compareLogic
    }
    
    func didEnterSearch(text: String) {
        if text.isEmpty {
            uiRealization.reloadContent(initialValue)
            return
        }
        let filteredContent = self.initialValue.filter({
            return compareLogic($0, text)
        })
        self.uiRealization.reloadContent(filteredContent)
    }
    
    func didCancel() {
        uiRealization.reloadContent(initialValue)
    }
    
    func updateInitialValue(value: [ContentType]) {
        self.initialValue = value
    }
    
    static func filter(name: String, text: String) -> Bool {
        return name
            .lowercased()
            .contains(
                text.lowercased()
            )
    }
}
