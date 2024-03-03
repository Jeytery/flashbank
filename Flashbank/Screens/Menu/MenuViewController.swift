//
//  MenuViewController.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import Foundation
import UIKit

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
    private var colorPaletterCell: ColorPaletteTableViewCell!
    
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
        tableView.register(ColorPaletteTableViewCell.self, forCellReuseIdentifier: "colorPaletterCell")
        view.addSubview(tableView)
    }
}

extension __MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return data.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "colorPaletterCell", for: indexPath) as! ColorPaletteTableViewCell
            colorPaletterCell = cell
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = data[indexPath.row]
            return cell
        default: UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

private extension __MenuViewController {
    func moveActPassColor(color: NamedColor) {
        
    }
    
    func movePassActColor(color: NamedColor) {
        
    }
}
