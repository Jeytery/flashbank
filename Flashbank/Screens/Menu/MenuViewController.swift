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
    private var tableView: UITableView!
    private let namedColorsRep = NamedColorsRepository()
    
    // late init
    private let colorPaletteState = ColorPaletteSUIState()
    
    // state
    private var activeColors: [NamedColor] = []
    private var passiveColors: [NamedColor] = []
    
    init(flashbomb: Flashbomb) {
        super.init(nibName: nil, bundle: nil)
        let activeColors = flashbomb.colors
        let allPassiveColors = namedColorsRep.getAppNamedColors()
        let availablePassiveColors = allPassiveColors.filter({ passiveColor in
            return activeColors.filter({ activeColor in
                passiveColor.name == activeColor.name
            }).isEmpty
        })
        colorPaletteState.initalizeColors(availablePassiveColors)
        self.activeColors = activeColors
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sliderView = SliderView()
        toolbarItems = [
            UIBarButtonItem(customView: sliderView)
        ]
        navigationController?.setToolbarHidden(false, animated: false)
        view.backgroundColor = .black.withAlphaComponent(0.75)
        configureTableView()
    }
}

private extension __MenuViewController {
    func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NamedColorTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
}

extension __MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeColors.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NamedColorTableViewCell
        let color = activeColors[indexPath.row]
        cell.configure(namedColor: color)
        cell.didTapCross = { [weak self] in
            guard let self = self else { return }
            self.moveActPassColor(color: color)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hosting = UIHostingController(rootView: ColorPaletteSUI(state: colorPaletteState))
        hosting.view.backgroundColor = .clear
        return hosting.view
    }
}

private extension __MenuViewController {
    func removeAct(color: NamedColor) {
        
    }
    
    func removePass(color: NamedColor) {
        
    }
    
    func moveActPassColor(color: NamedColor) {
        colorPaletteState.addColor(color)
        let index = activeColors.firstIndex(of: color) ?? 0
        tableView.deleteRows(at: [.init(row: index, section: 0)], with: .automatic)
        removeAct(color: color)
    }
    
    func movePassActColor(color: NamedColor) {
        
    }
}
