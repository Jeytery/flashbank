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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class MenuViewController: UIViewController {
    var didTapView: (() -> Void)?
    
    func getCurrentFlashbomb() -> Flashbomb {
        return .init(intensity: Double(self.sliderView.sliderValue), colors: self.activeColors)
    }
    
    func updateFlashbomb(_ flashbomb: Flashbomb) {
        self.currentFlashbomb = flashbomb
        let activeColors = flashbomb.colors
        let allPassiveColors = namedColorsRep.getAppNamedColors()
        let availablePassiveColors = allPassiveColors.filter({ passiveColor in
            return activeColors.filter({ activeColor in
                passiveColor.name == activeColor.name
            }).isEmpty
        })
        colorPaletteState.initalizeColors(availablePassiveColors)
        self.passiveColors = availablePassiveColors
        self.activeColors = activeColors
      
    }
    
    private var tableView: UITableView!
    private let namedColorsRep = NamedColorsRepository()
    
    // late init
    private let colorPaletteState = ColorPaletteSUIState()
    private lazy var sliderView = SliderView()
    
    private var currentFlashbomb: Flashbomb!
    
    // state
    private var activeColors: [NamedColor] = []
    private var passiveColors: [NamedColor] = []
    
    init(flashbomb: Flashbomb) {
        super.init(nibName: nil, bundle: nil)
        self.updateFlashbomb(flashbomb)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapTableView() {
        didTapView?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPaletteState.didTapColor = { [weak self] color in
            self?.movePassActColor(color: color)
        }
        self.sliderView = SliderView()
        toolbarItems = [
            UIBarButtonItem(customView: sliderView)
        ]
        
        navigationController?.setToolbarHidden(false, animated: false)
        view.backgroundColor = .black.withAlphaComponent(0.75)
        configureTableView()
        
        self.sliderView.setSliderValue(Float(currentFlashbomb.intensity))
    }
}

private extension MenuViewController {
    func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NamedColorTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "emptyCell")
        view.addSubview(tableView)
        let tapView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTableView))
        tapView.addGestureRecognizer(tap)
        tableView.backgroundView = tapView
        tableView.allowsSelection = false
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Active colors"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeColors.isEmpty ? 1 : activeColors.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if activeColors.isEmpty {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyTableViewCell
            emptyCell.configure(config: .init(title1: "No active colors", title2: "Tap on colors above to add"))
            return emptyCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NamedColorTableViewCell
        let color = activeColors[indexPath.row]
        cell.configure(namedColor: color)
        cell.didTapCross = { [weak self] in
            guard let self = self else { return }
            self.moveActPassColor(color: color)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hosting = UIHostingController(rootView: ColorPaletteSUI(state: colorPaletteState))
        hosting.view.backgroundColor = .clear
        return hosting.view
    }
}

private extension MenuViewController {
    func removeAct(color: NamedColor) {
        if let index = activeColors.firstIndex(of: color) {
            activeColors.remove(at: index)
        }
        else {
            print("removeAct: hasn't found index")
        }
    }
    
    func removePass(color: NamedColor) {
        if let index = passiveColors.firstIndex(of: color) {
            passiveColors.remove(at: index)
        }
        else {
            print("removeAct: hasn't found index")
        }
    }
    
    func moveActPassColor(color: NamedColor) {
        colorPaletteState.addColor(color)
        let index = activeColors.firstIndex(of: color) ?? 0
        removeAct(color: color)
        passiveColors.append(color)
        if !activeColors.isEmpty {
            tableView.deleteRows(at: [.init(row: index, section: 0)], with: .fade)
        }
        else {
            UIView.transition(
                with: tableView,
                duration: 0.35,
                options: .transitionCrossDissolve
            ) {
                self.tableView.reloadData()
            }
        }
    }
    
    func movePassActColor(color: NamedColor) {
        colorPaletteState.removeColor(color)
        removePass(color: color)
        activeColors.append(color)
        
        if activeColors.count == 1 {
            UIView.transition(
                with: tableView,
                duration: 0.35,
                options: .transitionCrossDissolve
            ) {
                self.tableView.reloadData()
            }
        }
        else {
            tableView.insertRows(at: [.init(row: activeColors.count - 1, section: 0)], with: .fade)
        }
    }
}
