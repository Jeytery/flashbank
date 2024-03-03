    //
//  FlashbankViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.02.2024.
//

import Foundation
import UIKit
import SwiftUI

class FlashbankViewController: UIViewController {
    private let color: [UIColor] = [
        .red, .blue, .green
    ]
    
    private var timer: Timer!
    
    private func randomColor() -> UIColor {
        return color.shuffled().first!
    }
    
    private func startLoop() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.view.backgroundColor = self.randomColor()
        })
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        startLoop()
        addMenu()
        addTapGesture()
    }
    
    private lazy var hosting = UIHostingController(rootView: MenuView(state: .init(flashbomb: .empty, outputEventHandler: {_ in})))
    
    private var isMenuShown = false
    
    private var hideMenuTimer: Timer!
}

private extension FlashbankViewController {
    func addMenu() {
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        hosting.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        hosting.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hosting.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        hosting.view.alpha = 0
    }
    
    @objc func coreViewDidTap() {
        isMenuShown.toggle()
        isMenuShown ? showMenu() : hideMenu()
    }
    
    func startHideMenuTimer() {
        
    }
    
    func showMenu() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.hosting.view.alpha = 1
        })
        hideMenuTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
            [weak self] _ in
            self?.hideMenu()
            self?.hideMenuTimer = nil
            self?.isMenuShown = false
        })
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.hosting.view.alpha = 0
        })
    }
    
    func addTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coreViewDidTap)))
    }
}


extension FlashbankViewController {
    func displayFlashbomb(_ flashbomb: Flashbomb) {
        
    }
}


class __FlashbankViewController: PluginableViewController {
    private var loopTimer: Timer!
    
    private func startLoop(flashbomb: Flashbomb) {
        if flashbomb.colors.isEmpty {
            view.backgroundColor = .black
            return
        }
        self.loopTimer = .scheduledTimer(withTimeInterval: flashbomb.intensity, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            let randomColor = flashbomb.colors.randomElement() ?? flashbomb.colors.first!
            if randomColor == self.view.backgroundColor {
                let index = flashbomb.colors.firstIndex(of: randomColor)!
                if (index + 1) >= flashbomb.colors.count {
                    self.view.backgroundColor = flashbomb.colors[index - 1]
                }
                else {
                    self.view.backgroundColor = flashbomb.colors[index + 1]
                }
            }
            else {
                self.view.backgroundColor = randomColor
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
