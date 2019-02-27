//
//  FoggyGroupCreateController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/25/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Contacts
import PopupDialog

class FGCCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var carsDictionary = [String: [CNContact]]()
    var carSectionTitles = [String]()
    var cars = [CNContact]()
    private var myTableView: UITableView!
    
    var selectedUsers = [CNContact]()
    lazy var horizontalCollection: UICollectionView = {
        let collectin = UICollectionViewFlowLayout()
        collectin.scrollDirection = .horizontal
        let v = UICollectionView(frame: .zero, collectionViewLayout: collectin)
        v.backgroundColor = .feedBackground
        v.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        v.dataSource = self
        v.delegate = self
        v.alwaysBounceHorizontal = true
        v.showsHorizontalScrollIndicator = false
        v.register(HorizontalSelectedUserCell.self, forCellWithReuseIdentifier: HorizontalSelectedUserCell.id)
        return v
    }()
    
    var filtered:[String] = []
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .feedBackground
        navigationController?.view.backgroundColor = .feedBackground
        title = "Select Members"
        
        view.addSubview(horizontalCollection)
        horizontalCollection.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        myTableView = UITableView(frame: .zero)
        myTableView.allowsMultipleSelection = true
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        myTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        fetchContacts()
        setUpSearchController()
    }
    
    private func setUpSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .black
//        searchController.searchBar.scopeButtonTitles = ["Contacts", "Foggy Friends"]
        searchController.searchBar.becomeFirstResponder()
        
        //        navigationItem.searchController = searchController
        let gradient: CAGradientLayer = CAGradientLayer(frame: .zero, colors: [.foggyBlue, .foggyGrey])
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        gradient.frame = searchController.searchBar.bounds
        UIGraphicsBeginImageContext(gradient.bounds.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(patternImage: gradientImage!)
        }
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
                
            }
        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    ///Method for fetching Contacts
    private func fetchContacts() {
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
            }
            contacts.sort { (contact1, contact2) -> Bool in
                if contact1.givenName < contact2.givenName {
                    return true
                }
                return false
            }
            
            var tempCnt = contacts
            for (idx, contact) in tempCnt.enumerated() {
                if contact.givenName == "" || contact.givenName == " " {
                    contacts.remove(at: idx)
                }
            }
            self.cars = contacts
        } catch {
            print("unable to fetch contacts")
        }
        
        for car in cars {
            let carKey = String(car.givenName.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(car)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [car]
            }
        }
        
        carSectionTitles = [String](carsDictionary.keys)
        carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return carSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let carKey = carSectionTitles[section]
        if let carValues = carsDictionary[carKey] {
            return carValues.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let contact = carValues[indexPath.row]
            let name = contact.givenName + " " + contact.familyName
            cell.textLabel?.text = name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return carSectionTitles[section]
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return carSectionTitles
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let contact = carValues[indexPath.row]
            let tmp = selectedUsers
            for (idx, tcontact) in tmp.enumerated() {
                if tcontact.identifier == contact.identifier {
                    selectedUsers.remove(at: idx)
                }
            }
            horizontalCollection.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cells = tableView.indexPathsForSelectedRows {
            if cells.count > 11 {
                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(12) people allowed per Foggy Glasses Group")
                present(foggyGlasses, animated: true) {
                    DispatchQueue.main.async {
                        if let cell = tableView.cellForRow(at: indexPath) {
                            cell.isSelected = false
                        }
                    }
                }
                return
            } else {
                print("cells", cells.debugDescription)
                
                
            }
        }
        
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            let contact = carValues[indexPath.row]
            selectedUsers.append(contact)
            horizontalCollection.reloadData()
        }
    }
}


extension FGCCViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchText = searchController.searchBar.text ?? ""
        
        var tmpContacts = [CNContact]()
        cars.filter { contact in
            let searchSentence = contact.givenName.lowercased()
            var searchRange = searchSentence.startIndex..<searchSentence.endIndex
            var ranges: [Range<String.Index>] = []
            
            let searchTerm = searchText.lowercased()
            
            while let range = searchSentence.range(of: searchTerm, range: searchRange) {
                ranges.append(range)
                searchRange = range.upperBound..<searchRange.upperBound
            }
            
            let matches = ranges.map { ((searchSentence.distance(from: searchSentence.startIndex, to: $0.lowerBound)), (searchSentence.distance(from: searchSentence.startIndex, to: $0.upperBound))) }
            if matches.count > 0 {
                //                var newContact = contact
                //                newContact.formatting = matches
                tmpContacts.append(contact)
                return true
            } else {
                return false
            }
        }
        
//        filteredContacts = tmpContacts
        cars = tmpContacts
        myTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        myTableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        myTableView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            myTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func filterContentForSearchText(searchText: String) {
        
//        if searchText == "" {
//            filteredContacts = contacts
//            filteredFriends = friends
//            collectionView.reloadData()
//            return
//        }
//        
//        var tmpContacts = [CNContact]()
//        filteredContacts = contacts.filter { contact in
//            let searchSentence = contact.givenName.lowercased()
//            var searchRange = searchSentence.startIndex..<searchSentence.endIndex
//            var ranges: [Range<String.Index>] = []
//            
//            let searchTerm = searchText.lowercased()
//            
//            while let range = searchSentence.range(of: searchTerm, range: searchRange) {
//                ranges.append(range)
//                searchRange = range.upperBound..<searchRange.upperBound
//            }
//            
//            let matches = ranges.map { ((searchSentence.distance(from: searchSentence.startIndex, to: $0.lowerBound)), (searchSentence.distance(from: searchSentence.startIndex, to: $0.upperBound))) }
//            if matches.count > 0 {
//                //                var newContact = contact
//                //                newContact.formatting = matches
//                tmpContacts.append(contact)
//                return true
//            } else {
//                return false
//            }
//        }
//        
//        var tmpFriends = [FoggyUser]()
//        filteredFriends = friends.filter { friend in
//            let searchSentence = friend.name.lowercased()
//            var searchRange = searchSentence.startIndex..<searchSentence.endIndex
//            var ranges: [Range<String.Index>] = []
//            
//            let searchTerm = searchText.lowercased()
//            
//            while let range = searchSentence.range(of: searchTerm, range: searchRange) {
//                ranges.append(range)
//                searchRange = range.upperBound..<searchRange.upperBound
//            }
//            
//            let matches = ranges.map { ((searchSentence.distance(from: searchSentence.startIndex, to: $0.lowerBound)), (searchSentence.distance(from: searchSentence.startIndex, to: $0.upperBound))) }
//            if matches.count > 0 {
//                //                var newContact = contact
//                //                newContact.formatting = matches
//                tmpFriends.append(friend)
//                return true
//            } else {
//                return false
//            }
//        }
//        
//        filteredFriends = tmpFriends
//        filteredContacts = tmpContacts
//        
//        let indexSet = IndexSet(arrayLiteral: 4, 6)
//        collectionView.reloadSections(indexSet)
        //        collectionView.reloadData()
    }
}

extension FGCCViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSelectedUserCell.id, for: indexPath) as! HorizontalSelectedUserCell
        
        return cell
    }
    
    
}
