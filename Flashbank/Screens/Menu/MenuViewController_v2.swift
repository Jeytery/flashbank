//
//  MenuViewController_v2.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.09.2024.
//

import Foundation
import UIKit
import SwiftUI

class MenuViewController_v2: UIViewController {
    
    // MARK: - public api
    var didTapView: (() -> Void)?
    
    enum OutputEvent {
        case didTapTableView
        case didTapAddColor
        case didTapColorItemCell
        case didTapEditWithIndexPath(IndexPath)
        case didTapSettings
        case didSelectCellWithIndexPath(IndexPath)
    }
    
    var eventOutputHandler: ((OutputEvent) -> Void)?
    
    func getCurrentFlashbomb() -> Flashbomb {
        let selectedColors = zip(colors, isSelectedCells)
        return .init(
            bpm: Int(self.sliderViewState.sliderValue),
            colors: selectedColors
                .map({
                    return .init(name: "", color: $0, isActive: $1)
                })
        )
    }
    
    func updateFlashbomb(_ flashbomb: Flashbomb) {
        self.isSelectedCells.removeAll()
        self.colors = flashbomb.colors.map({ return $0.color })
        self.isSelectedCells = flashbomb.colors.map({ return $0.isActive })
        self.sliderViewState.sliderValue = Float(flashbomb.bpm)
        self.reloadTableView()
    }
    
    func addColor(_ color: UIColor) {
        hideEmptyView()
        tableView.reloadData()
        self.colors.append(color)
        self.isSelectedCells.append(true)
        tableView.insertRows(at: [.init(row: colors.count - 1, section: 0)], with: .fade)
    }
    
    func removeColor(at indexPath: IndexPath) {
        self.colors.remove(at: indexPath.row)
        self.isSelectedCells.remove(at: indexPath.row)
        if colors.isEmpty {
            emptyView.alpha = 1
            self.tableView.reloadData()
            emptyView.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.emptyView.alpha = 1
            })
        }
        else {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func updateColor(_ color: UIColor, at indexPath: IndexPath) {
        self.colors.remove(at: indexPath.row)
        self.colors.insert(color, at: indexPath.row)
        self.isSelectedCells.remove(at: indexPath.row)
        self.isSelectedCells.insert(false, at: indexPath.row)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    //
    
    // state
    private var colors: [UIColor] = []
    private var isSelectedCells: [Bool] = []
    
    // const
    private let bottomToolBarHeight: CGFloat = 90
    private let emptyViewHeaderHeightValue: CGFloat = 80
    
    // ui
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomToolBar = FakeToolBar(
        frame: .zero,
        blurStyle: .systemChromeMaterial,
        style: .native
    )
    private lazy var sliderViewState = BPMSliderViewModel()
    private lazy var sliderView = UIHostingController(rootView: BPMSliderView(viewModel: sliderViewState)).view!
    private lazy var emptyView = UIHostingController(rootView: MenuEmptyView().onTapGesture {
        [weak self] in
        self?.eventOutputHandler?(.didTapAddColor)
    }).view!
    
    init(flashbomb: Flashbomb) {
        super.init(nibName: nil, bundle: nil)
        configureBottomToolBar()
        view.backgroundColor = .black.withAlphaComponent(0.75)
        updateFlashbomb(flashbomb)
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupNavButtons()
    }
    
    @objc private func didTapAddColorButton() {
        eventOutputHandler?(.didTapAddColor)
    }
    
    @objc private func didTapTableView() {
        didTapView?()
    }
    
    @objc private func didTapTableView2() {
        didTapView?()
    }
    
    @objc private func pauseButtonTapped() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ui tools
private extension MenuViewController_v2 {
    func reloadTableView() {
        colors.isEmpty ? showEmptyView() : hideEmptyView()
        tableView.reloadData()
    }
    
    func showEmptyView() {
        emptyView.alpha = 1
    }
    
    func hideEmptyView() {
        emptyView.alpha = 0
    }
}

// MARK: - ui configuration
private extension MenuViewController_v2 {
    func setupNavButtons() {
        let addColorItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .done,
            target: self,
            action: #selector(didTapAddColorButton)
        )
        /*
        let pauseButton = UIBarButtonItem(image: UIImage(systemName: "play.fill"), style: .plain, target: self, action: #selector(pauseButtonTapped))
         */
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsDidTapButton))
        navigationItem.rightBarButtonItems = [addColorItem, settingsButton]
    }
    
    @objc func settingsDidTapButton() {
        self.eventOutputHandler?(.didTapSettings)
    }
    
    func configureTableView() {
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ColorItemTableViewCell.self, forCellReuseIdentifier: "ColorItemTableViewCell")
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: "emptyCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
        let tableViewWidthAnchor: NSLayoutConstraint
        if isIPhone {
            tableViewWidthAnchor = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        } else {
            let width = min(view.bounds.width / 2, 600) // Set a max width (e.g., 400 points) for the table view
            tableViewWidthAnchor = tableView.widthAnchor.constraint(equalToConstant: width)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableViewWidthAnchor,
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
        let tapView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTableView))
        tapView.addGestureRecognizer(tap)
        tableView.backgroundView = tapView
        tableView.allowsSelection = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapTableView2))
        tap2.delegate = self
        self.view.addGestureRecognizer(tap2)
        tableView.contentInset = .init(top: 20, left: 0, bottom: 110, right: 0)
    }
        
    func configureBottomToolBar() {
        view.addSubview(bottomToolBar)
        bottomToolBar.translatesAutoresizingMaskIntoConstraints = false
        let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
        let bottomPaddingValue: CGFloat = 10
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom == 0 ? bottomPaddingValue : 0
        let topSliderPadding: CGFloat = 5
        NSLayoutConstraint.activate([
            bottomToolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomToolBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomToolBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomToolBar.heightAnchor.constraint(equalToConstant: bottomToolBarHeight + bottomPadding)
        ])
        bottomToolBar.addSubview(sliderView)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.backgroundColor = .clear
        let sliderWidthMultiplier: CGFloat = isIPhone ? 0.9 : 0.5
        NSLayoutConstraint.activate([
            sliderView.bottomAnchor.constraint(equalTo: bottomToolBar.bottomAnchor, constant: -bottomPadding),
            sliderView.centerXAnchor.constraint(equalTo: bottomToolBar.centerXAnchor),
            sliderView.widthAnchor.constraint(equalTo: bottomToolBar.widthAnchor, multiplier: sliderWidthMultiplier),
            sliderView.topAnchor.constraint(equalTo: bottomToolBar.topAnchor, constant: topSliderPadding)
        ])
    }
}

//MARK: - table view del
extension MenuViewController_v2: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorItemTableViewCell", for: indexPath) as! ColorItemTableViewCell
        cell.configure(color: colors[indexPath.row])
        cell.didChangeToggleValue = {
            [weak self] value in
            self?.isSelectedCells[indexPath.row] = value
        }
        isSelectedCells[indexPath.row] ? cell.turnOnToggle() : cell.turnOffToggle()
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let actionProvider: UIContextMenuActionProvider = { _ in
            return UIMenu(title: "", children: [
                UIAction(
                    title: "Edit",
                    image: UIImage(systemName: "pencil"),
                    handler: { _ in
                       
                    }),
                UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash.fill"),
                    attributes: .destructive,
                    handler: { [weak self] _ in
                        
                    })
            ])
        }
        return UIContextMenuConfiguration(
            identifier: "unique-ID" as NSCopying,
            previewProvider: nil,
            actionProvider: actionProvider
        )
    }
    */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let _header = emptyView
            emptyView.backgroundColor = .clear
            let headerView = UIView()
            headerView.addSubview(_header)
            _header.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _header.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
                _header.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 0),
                _header.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: 0),
                _header.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            ])
            return headerView
        }
        else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return emptyView.alpha == 0 ? 0 : 100
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventOutputHandler?(.didSelectCellWithIndexPath(indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .normal, title: "Edit") { 
            [weak self] (action, view, handler) in
            let cell = tableView.cellForRow(at: indexPath)
            tableView.isEditing = false
            self?.eventOutputHandler?(.didTapEditWithIndexPath(indexPath))
        }
        action1.backgroundColor = .systemBlue
        let action2 = UIContextualAction(style: .destructive, title: "Delete") { 
            [weak self] (action, view, handler) in
            self?.removeColor(at: indexPath)
        }
        action2.backgroundColor = .systemRed
        let swipeActions = UISwipeActionsConfiguration(actions: [action2, action1])
        swipeActions.performsFirstActionWithFullSwipe = false
        return swipeActions
    }
}

extension MenuViewController_v2: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tableView) == true {
            return false
        }
        return true
    }
}
