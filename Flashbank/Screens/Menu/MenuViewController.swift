//
//  MenuViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit
import SwiftUI

class CustomTabBar: UIToolbar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 85
        return sizeThatFits
    }
}

final class __MenuViewController: UIViewController {
    private let data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    private var tableView: UITableView!

    private var activeColors: [NamedColor] = []
    private var passiveColors: [NamedColor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sliderView = SliderView()
        toolbarItems = [
            UIBarButtonItem(customView: sliderView)
        ]
        navigationController?.setToolbarHidden(false, animated: false)
        view.backgroundColor = .black.withAlphaComponent(0.75)
        
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GlassTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}

private extension __MenuViewController {
    
    
    
}

extension __MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hosting = UIHostingController(rootView: ColorPaletteSUI(state: .init()))
        hosting.view.backgroundColor = .clear
        return hosting.view
    }
}

private extension __MenuViewController {
    func moveActPassColor(color: NamedColor) {
        
    }
    
    func movePassActColor(color: NamedColor) {
        
    }
}
