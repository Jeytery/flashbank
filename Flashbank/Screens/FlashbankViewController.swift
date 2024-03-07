    //
//  FlashbankViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.02.2024.
//

import Foundation
import UIKit
import SwiftUI

class __FlashbankViewController: PluginableViewController {
    private var loopTimer: Timer!
    
    private func startLoop(flashbomb: Flashbomb) {
        self.loopTimer?.invalidate()
        self.loopTimer = nil
        if flashbomb.colors.isEmpty {
            view.backgroundColor = .black
            return
        }
        self.loopTimer = .scheduledTimer(withTimeInterval: flashbomb.intensity, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            let randomColor = flashbomb.colors.randomElement() ?? flashbomb.colors.first!
            if randomColor.color == self.view.backgroundColor {
                let index = flashbomb.colors.firstIndex(of: randomColor)!
                if (index + 1) >= flashbomb.colors.count, flashbomb.colors.count != 1 {
                    self.view.backgroundColor = flashbomb.colors[index - 1].color
                }
                else {
                    if  flashbomb.colors.count != 1 {
                        self.view.backgroundColor = flashbomb.colors[index + 1].color
                    }
                }
            }
            else {
                self.view.backgroundColor = randomColor.color
            }
        }
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


extension __FlashbankViewController {
    func displayFlashbomb(_ flashbomb: Flashbomb) {
        startLoop(flashbomb: flashbomb)
    }
    
    func pause() {
        
    }
    
    func play() {
        
    }
}
