//
//  AutoflashMenuCoordinator.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 23.03.2025.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation
 
final class TapTableViewInmpl: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchedView = touch.view
        var currentView = touchedView
        while let view = currentView {
            if view is UITableViewCell {
                return false
            }
            if view is UICollectionViewCell {
                return false
            }
            if view is UIButton {
                return false
            }
            currentView = view.superview
        }
        return true
    }
}

final class AutoflashCoordinator: Coordinatable {
    var menuBeingShowingStatusHandler: ((Bool) -> Void)?
    
    private let menuNavigationController = UINavigationController()
    private let tapTableViewInmpl = TapTableViewInmpl()
    private let autoflashSUIViewModel = AutflashMenuViewModel()
    private lazy var autoflashSUI: AutflashMenuViewSUI = AutflashMenuViewSUI(viewModel: autoflashSUIViewModel)
    
    private lazy var menuViewController = PluginableHostingViewController(
        rootView: autoflashSUI
    )
    private var isMenuShown = true {
        didSet {
            menuBeingShowingStatusHandler?(isMenuShown)
        }
    }
    
    private let displayerViewController = AutoflashDisplayerViewController()
    private(set) var navigationController = StatusBarHiddenNavigationController()
    private let storedAppSettingsRep = StoredAppSettingsRepository()
    private let storedAppSettingsAP = StoredAppSettingsActionProvider()
    
    override func startCoordinator() {
        super.startCoordinator()
        navigationController.viewControllers = [displayerViewController]
        autoflashSUIViewModel.didTapViewHandler = { [weak self] in
            self?.didTapMenu()
        }
        let settings = storedAppSettingsRep.load()
        let isDebugMenuEnebled = settings.isDebugMenuEnebled
        autoflashSUIViewModel.isDebugMenuEnabled = isDebugMenuEnebled
        
        autoflashSUIViewModel.didChangeIsDebugMenuEnebled = {
            [weak self] newValue in
            guard let self = self else { return }
            self.displayerViewController.isDebugInfoShown(newValue)
            _ = self.storedAppSettingsAP
                .store(
                    storedAppSettingsRep.load().debugMenuEbenebled(isDebugMenuEnebled: newValue)
                )
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        
        autoflashSUIViewModel.shouldPresentBetatestAlert = !settings.isBetaTestingAlertShown
        displayerViewController.view.addGestureRecognizer(tapGesture)
        setupMenu()
        showMenu()
        self.displayerViewController.isDebugInfoShown(isDebugMenuEnebled)
        autoflashSUIViewModel.mirphoneAccessState = isMicrophoneAccessGranted() ? .provided : .notProvided
    }
    
    @objc private func didTapMenu() {
        self.isMenuShown ? self.hideMenu() : self.showMenu()
        self.isMenuShown.toggle()
    }
}

private extension AutoflashCoordinator {
    func isMicrophoneAccessGranted() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func setupMenu() {
        autoflashSUIViewModel.didCloseAlert = {
            [weak self] in
            guard let self = self else { return }
            var settings = self.storedAppSettingsRep.load()
            settings.isBetaTestingAlertShown = true
            _ = storedAppSettingsAP.store(settings)
        }
        autoflashSUIViewModel.didTapMircophoneAccessButtonHandler = {
            [weak self] in
            guard let self = self else { return }
            if self.isMicrophoneAccessGranted() { return }
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.autoflashSUIViewModel.mirphoneAccessState = .provided
                    } else {
                        self.autoflashSUIViewModel.mirphoneAccessState = .notProvided
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                }
            }
        }
        menuNavigationController.overrideUserInterfaceStyle = .dark
        menuNavigationController.viewControllers = [menuViewController]
        menuViewController.view.backgroundColor = .systemGray5.withAlphaComponent(0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMenu))
        tap.delegate = tapTableViewInmpl
        menuViewController.view.addGestureRecognizer(tap)
        menuNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.addSubview(menuNavigationController.view)
        NSLayoutConstraint.activate([
            menuNavigationController.view.topAnchor.constraint(equalTo: navigationController.view.topAnchor),
            menuNavigationController.view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor),
            menuNavigationController.view.rightAnchor.constraint(equalTo: navigationController.view.rightAnchor),
            menuNavigationController.view.leftAnchor.constraint(equalTo: navigationController.view.leftAnchor)
        ])
        menuNavigationController.view.alpha = 0
        let willAppearHandler = ViewWillAppearHandlerPlugin {
            [weak self] in
            guard let self = self else { return }
            self.autoflashSUIViewModel.mirphoneAccessState = self.isMicrophoneAccessGranted() ? .provided : .notProvided
        }
        menuViewController.addPlugin(willAppearHandler)
        let addButtonPlug = AddNavigationButtonsPlugin(viewController: menuViewController)
            .systemImageButton(side: .right, imageName: "gear", action: {
                let settingsViewController = UIHostingController(rootView: SettingsView())
                self.menuNavigationController.pushViewController(settingsViewController, animated: true)
            })
            .close(side: .left, action: {
                [weak self] in
                self?.hideMenu()
                self?.isMenuShown = false
            })
        menuViewController.addPlugin(addButtonPlug)
    }
    
    func showMenu(animated: Bool = true) {
        menuNavigationController.view.alpha = 1
        UIApplication.shared.isIdleTimerDisabled = false
        displayerViewController.stopLoop()
    }
    
    func hideMenu(animated: Bool = true) {
        menuNavigationController.view.alpha = 0
        UIApplication.shared.isIdleTimerDisabled = true
        displayerViewController.startLoop()
    }
}
