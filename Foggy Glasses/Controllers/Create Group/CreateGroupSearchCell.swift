//
//  CreateGroupSearchCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/9/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class CreateGroupSearchCell: UICollectionViewCell, UISearchBarDelegate {
    static let id = "CreateGroupSearchCellId"
    
    //MARK: UI Elements
    lazy var search: UISearchBar = {
        let v = UISearchBar()
        v.placeholder = "Search For People"
        v.barTintColor = .white
//        v.searchBarStyle = .prominent
        v.backgroundColor = .white
        v.backgroundImage = UIImage()
        v.delegate = self
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        addSubview(search)
        search.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search Text:", searchText)
        let data = ["text": searchText]
        NotificationCenter.default.post(name: CreateGroupController.searchNotification, object: data)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("Should begin editing")
        NotificationCenter.default.post(name: CreateGroupController.searchClicked, object: nil)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

