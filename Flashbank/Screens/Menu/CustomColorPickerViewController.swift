//
//  CustomColorPickerViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 30.09.2024.
//

import Foundation
import UIKit
import Pikko

class CustomColorPickerViewController: UIViewController {
    private let pikko = Pikko(dimension: 300)
    
    var color: UIColor {
        return pikko.getColor()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(pikko)
        self.view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pikko.center = self.view.center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomPickerCoordinator: Coordinatable {
    private let pickerViewController = CustomColorPickerViewController()
    private let parentNavigationController: UINavigationController
    private(set) var coreNavigationController = ClosableNavigationController().onlyFirst()
    
    init(parentNavigationController: UINavigationController) {
        self.parentNavigationController = parentNavigationController
    }
    
    override func startCoordinator() {
        super.startCoordinator()
        coreNavigationController.pushViewController(pickerViewController, animated: false)
        pickerViewController.navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        if ProcessInfo.processInfo.isiOSAppOnMac {
            coreNavigationController.modalPresentationStyle = .overFullScreen
        }
        parentNavigationController.present(coreNavigationController, animated: true)
    }
    
    var tapDoneWithColorHandler: ((UIColor) -> Void)?
    
    @objc private func didTapDone() {
        tapDoneWithColorHandler?(pickerViewController.color)
    }
}
