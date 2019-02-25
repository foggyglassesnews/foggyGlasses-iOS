//
//  AddPeopleViewController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/24/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class AddPeopleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.delegate = self
        v.dataSource = self
        return v
    }()
//    var searchFooter: SearchFooter!
    
    var candies = [UIView]()
    var filteredCandies = [UIView]()
    let searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.searchBarStyle = .minimal
        sc.searchBar.backgroundImage = UIImage()
        sc.searchBar.barTintColor = .clear
        return sc
    }()// = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .feedBackground
        tableView.backgroundColor = .feedBackground
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for People"
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.backgroundColor = .clear
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Contacts", "Foggy Friends"]
        searchController.searchBar.delegate = self
        
        // Setup the search footer
//        tableView.tableFooterView = searchFooter
        
        candies = []
        
        // Convert CAGradientLayer to UIImage
//        let gradient = Color.blue.gradient
//        gradient.frame = searchController.searchBar.bounds
//        UIGraphicsBeginImageContext(gradient.bounds.size)
//        gradient.render(in: UIGraphicsGetCurrentContext()!)
//        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
//        self.navigationBarGradient(colors: [.foggyBlue, .foggyGrey])
//        if let navigationBar = self.navigationController?.navigationBar {
//            navigationBar.barTintColor = UIColor(patternImage: gradientImage!)
//        }
//        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//            if let backgroundview = textField.subviews.first {
//                backgroundview.backgroundColor = UIColor.white
//                backgroundview.layer.cornerRadius = 10;
//                backgroundview.clipsToBounds = true;
//
//            }
//        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
//    override func viewWillAppear(_ animated: Bool) {
////        if splitViewController!.isCollapsed {
////            if let selectionIndexPath = tableView.indexPathForSelectedRow {
////                tableView.deselectRow(at: selectionIndexPath, animated: animated)
////            }
////        }
//        super.viewWillAppear(animated)
//    }
    
//    private func navigationBarGradient(colors: [UIColor]) {
//        navigationController?.navigationBar.setGradientBackground(colors: colors)
//    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
//            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
            return filteredCandies.count
        }
        
//        searchFooter.setNotFiltering()
        return candies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let candy: Candy
//        if isFiltering() {
//            candy = filteredCandies[indexPath.row]
//        } else {
//            candy = candies[indexPath.row]
//        }
//        cell.textLabel!.text = candy.name
//        cell.detailTextLabel!.text = candy.category
        return cell
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let candy: Candy
//                if isFiltering() {
//                    candy = filteredCandies[indexPath.row]
//                } else {
//                    candy = candies[indexPath.row]
//                }
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailCandy = candy
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        filteredCandies = candies.filter({( candy : Candy) -> Bool in
//            let doesCategoryMatch = (scope == "All") || (candy.category == scope)
//
//            if searchBarIsEmpty() {
//                return doesCategoryMatch
//            } else {
//                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
//            }
//        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

extension AddPeopleViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension AddPeopleViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
