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
    }
    
    var eventOutputHandler: ((OutputEvent) -> Void)?
    
    func getCurrentFlashbomb() -> Flashbomb {
        return .init(intensity: 0, colors: [])
    }
    
    func updateFlashbomb(_ flashbomb: Flashbomb) {
        
    }
    //
    
    private let bottomToolBarHeight: CGFloat = 100
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomToolBar = FakeToolBar(
        frame: .zero,
        blurStyle: .systemChromeMaterial,
        style: .native
    )
    //private let sliderView = SliderView()
    private lazy var sliderViewState = BPMSliderViewModel()
    private lazy var sliderView = UIHostingController(rootView: BPMSliderView(viewModel: sliderViewState)).view!
    
    
    init(flashbomb: Flashbomb) {
        super.init(nibName: nil, bundle: nil)
        configureBottomToolBar()
        view.backgroundColor = .black.withAlphaComponent(0.75)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        navigationItem.setRightBarButton(.init(title: "Add Color", style: .done, target: self, action: #selector(didTapAddColorButton)), animated: false)
    }
    
    @objc private func didTapAddColorButton() {}
    
    @objc private func didTapTableView() {
        didTapView?()
    }
    
    @objc private func didTapTableView2() {
        didTapView?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ui configuration
private extension MenuViewController_v2 {
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
        tableView.allowsSelection = false
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapTableView2))
        self.view.addGestureRecognizer(tap2)
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

extension MenuViewController_v2: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorItemTableViewCell", for: indexPath) as! ColorItemTableViewCell
        cell.configure(color: .systemRed)
        cell.selectionStyle = .blue
        return cell
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            print("Action 1 tapped from swipe")
            handler(true)
        }
        action1.backgroundColor = .systemBlue
        
        let action2 = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            print("Action 2 tapped from swipe")
            handler(true)
        }
        action2.backgroundColor = .systemRed
        
        let swipeActions = UISwipeActionsConfiguration(actions: [action2, action1])
        swipeActions.performsFirstActionWithFullSwipe = false
        return swipeActions
    }
}

