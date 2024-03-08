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
    
    private func startLoop(flashbomb: Flashbomb) {
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
    
    private func nextColor(flashbomb: Flashbomb) {
        currentIndex += 1
        if currentIndex >= flashbomb.colors.count {
            currentIndex = 0
        }
        view.backgroundColor = flashbomb.colors[currentIndex].color
    }
    
    private func stopLoop() {
        loopTimer.invalidate()
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
        self.view.backgroundColor = flashbomb.colors.first!.color
        startLoop(flashbomb: flashbomb)
    }
}
