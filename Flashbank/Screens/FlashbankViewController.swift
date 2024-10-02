    //
//  FlashbankViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.02.2024.
//

import Foundation
import UIKit
import SwiftUI

class FlashbankViewController: PluginableViewController {
    private var loopTimer: Timer!
    private var currentIndex: Int = 0
    
    private func nextColor(flashbomb: Flashbomb) {
        currentIndex += 1
        if currentIndex >= currentActiveColors.count {
            currentIndex = 0
        }
        view.backgroundColor = currentActiveColors[currentIndex]
    }
    
    private var currentFlashbomb: Flashbomb = .empty
    private var currentActiveColors: [UIColor] = []
    
    func startLoop(flashbomb: Flashbomb) {
        self.loopTimer?.invalidate()
        self.loopTimer = nil
        self.currentIndex = 0
        if flashbomb.colors.isEmpty {
            view.backgroundColor = .black
            return
        }
        self.loopTimer = .scheduledTimer(
            withTimeInterval: flashbomb.intensity,
            repeats: true
        ) { [unowned self] _ in
            self.nextColor(flashbomb: flashbomb)
        }
    }
    
    func stopLoop() {
        loopTimer?.invalidate()
        loopTimer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

extension FlashbankViewController {
    func displayFlashbomb(_ flashbomb: Flashbomb) {
        if flashbomb.colors.isEmpty {
            return
        }
        currentFlashbomb = flashbomb
        currentActiveColors = flashbomb.colors
            .filter({ $0.isActive })
            .map({ $0.color })
        self.view.backgroundColor = currentActiveColors.first ?? .white
        if flashbomb.bpm == 0 {
            return
        }
        startLoop(flashbomb: flashbomb)
    }
}
