//
//  AddSearchPlugin.swift
//  role-cards
//
//  Created by Dmytro Ostapchenko on 03.11.2023.
//

import Foundation
import UIKit

final class AddSearchPlugin: Pluginable {
    private unowned var resultsUpdater: UISearchResultsUpdating!
    private unowned var navigationItem: UINavigationItem!
    private unowned var searchBarDelegate: UISearchBarDelegate?
    private let hidesSearchBarWhenScrolling: Bool
    
    private var isPerformedAction: Bool = false
    
    init(
        navigationItem: UINavigationItem,
        resultsUpdater: UISearchResultsUpdating,
        searchBarDelegate: UISearchBarDelegate? = nil,
        hidesSearchBarWhenScrolling: Bool = true
    ) {
        self.navigationItem = navigationItem
        self.resultsUpdater = resultsUpdater
        self.searchBarDelegate = searchBarDelegate
        self.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
    }

    func viewWillAppear() {
        if isPerformedAction {
            return
        }
        isPerformedAction = true
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = resultsUpdater
        navigationItem.searchController = search
        navigationItem.searchController?.searchBar.delegate = searchBarDelegate
        navigationItem.hidesSearchBarWhenScrolling = self.hidesSearchBarWhenScrolling
        self.resultsUpdater = nil
        self.navigationItem = nil
        self.searchBarDelegate = nil
    }
}

