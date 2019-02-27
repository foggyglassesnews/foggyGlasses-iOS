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
    
    var membersDictionary = [String: [SearchMember]]()
    var membersFirstIntialDictionary = [String]()
    var searchMembers = [SearchMember]()
    var selectedMembers = [SearchMember]()
    private var myTableView: UITableView!
    
    
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
        
        navigationController?.definesPresentationContext = true
        
        myTableView = UITableView(frame: .zero, style: .plain)
        myTableView.allowsMultipleSelection = true
        myTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.id)
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
        
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.dimsBackgroundDuringPresentation = false
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
            
            let tempCnt = contacts
            for (idx, contact) in tempCnt.enumerated() {
                if contact.givenName == "" || contact.givenName == " " {
                    contacts.remove(at: idx)
                }
            }
            
            var searchMembers = [SearchMember]()
            for (idx, contact) in contacts.enumerated() {
                var member = SearchMember()
                member.contact = contact
                member.id = idx
                print("Member:", member.id)
                searchMembers.append(member)
            }
            
            self.searchMembers = searchMembers
        } catch {
            print("unable to fetch contacts")
        }
        
        for (idx, member) in searchMembers.enumerated() {
            let memberKey = String(member.titleKey)
            if var memberValues = membersDictionary[memberKey] {
                print("Adding member with id:", member.id )
                memberValues.append(member)
                membersDictionary[memberKey] = memberValues
            } else {
                membersDictionary[memberKey] = [member]
            }
        }
        
        membersFirstIntialDictionary = [String](membersDictionary.keys)
        membersFirstIntialDictionary = membersFirstIntialDictionary.sorted(by: { $0 < $1 })
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return membersFirstIntialDictionary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let carKey = membersFirstIntialDictionary[section]
        if let carValues = membersDictionary[carKey] {
            return carValues.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.id, for: indexPath) as! ContactTableViewCell
        
//        cell.isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false

        // Configure the cell...
        let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
        if let memberValues = membersDictionary[memberKeyLetter] {
            let member = memberValues[indexPath.row]
//            cell.member = member
            for m in searchMembers {
                if m.id == member.id {
                    cell.member = m
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return membersFirstIntialDictionary[section]
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return membersFirstIntialDictionary
    }
    
    func updateHorizontalCollection() {
        selectedMembers = []
        for member in searchMembers {
            if member.selected {
                selectedMembers.append(member)
            }
        }
        horizontalCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
        if let memberValues = membersDictionary[memberKeyLetter] {
            let member = memberValues[indexPath.row]
            print("Selected Member:", member.id)
            select(person: member, selected: false)
            tableView.reloadData()
        }
        updateHorizontalCollection()
//            if let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell {
//                self.select(person: cell.member, selected: false)
//
//            }
        
//        let carKey = membersFirstIntialDictionary[indexPath.section]
//        if let carValues = membersDictionary[carKey] {
//            let contact = carValues[indexPath.row]
//            let tmp = selectedUsers
//            for (idx, tcontact) in tmp.enumerated() {
//                if tcontact.identifier == contact.identifier {
//                    selectedUsers.remove(at: idx)
//                }
//            }
//            horizontalCollection.reloadData()
//        }
    }
    
    func select(person: SearchMember, selected: Bool = true) {
        for (idx, member) in searchMembers.enumerated() {
            if person.id == member.id {
                print("Found matching ID:", member.id)
                var newMember = member
                newMember.selected = !member.selected
                searchMembers[idx] = newMember
            }
//            var member = member
//            if let foggyUser = member.foggyUser, let user = person.foggyUser {
//                if foggyUser.username == user.username {
//                    member.selected = selected
//                }
//            }
//            if let foggyContact = member.contact, let contact = person.contact {
//                if let phoneNumber = foggyContact.phoneNumbers.first, let contactPhoneNumber = contact.phoneNumbers.first {
//                    if phoneNumber == contactPhoneNumber {
//                        member.selected = selected
//                    }
//                }
//            }
//            searchMembers[idx] = member
            
        }
    }
    
    func getMember(id: Int)->SearchMember {
        for member in searchMembers {
            if member.id == id {
                return member
            }
        }
        return SearchMember()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
        if let memberValues = membersDictionary[memberKeyLetter] {
            let member = memberValues[indexPath.row]
            //Get the correct member value
            let membersMember = getMember(id: member.id)
            if selectedMembers.count > 11 && membersMember.selected == false {
                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(12) people allowed per Foggy Glasses Group")
                present(foggyGlasses, animated: true, completion: nil)
            } else {
                
                select(person: member)
                tableView.reloadData()
                updateHorizontalCollection()
            }
        }
        return
        if selectedMembers.count > 11 {
            let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(12) people allowed per Foggy Glasses Group")
            present(foggyGlasses, animated: true, completion: nil)
        } else {
            let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
            if let memberValues = membersDictionary[memberKeyLetter] {
                let member = memberValues[indexPath.row]
                
                print("Selected Member:", member.id)
                select(person: member)
                tableView.reloadData()
            }
            updateHorizontalCollection()
            
//             let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.id, for: indexPath) as! ContactTableViewCell
//            select(person: cell.member)
//            print("Selected Cell:", cell.member.id)
//            cell.select
//            tableView.reloadData()
            
//            tableView.reloadData()
            //dequeueReusableCell(withIdentifier: ContactTableViewCell.id, for: indexPath)(at: indexPath) as! ContactTableViewCell
            
//                cel
//                self.select(person: cell.member)
//                tableView.reloadData()
//                selectedMembers.append(cell.member)
//                tableView.reloadData()
//            }
        }
//        if let cells = tableView.indexPathsForSelectedRows {
//            if cells.count > 11 {
//                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(12) people allowed per Foggy Glasses Group")
//                present(foggyGlasses, animated: true) {
//                    if let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell {
//                        cell.
//                    }
////                    DispatchQueue.main.async {
////                        if let cell = tableView.cellForRow(at: indexPath) {
////                            cell.isSelected = false
////                        }
////                    }
//                }
//                return
//            } else {
//                print("cells", cells.debugDescription)
//
//
//            }
//        }
        
//        let carKey = membersFirstIntialDictionary[indexPath.section]
//        if let carValues = membersDictionary[carKey] {
//            let contact = carValues[indexPath.row]
//
//            selectedMembers.append(contact)
//            horizontalCollection.reloadData()
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension FGCCViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
//        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
//        let searchText = searchController.searchBar.text ?? ""
//
//        var tmpContacts = [CNContact]()
//        searchMember.filter { contact in
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
////        filteredContacts = tmpContacts
//        searchMember = tmpContacts
        myTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
//        myTableView.reloadData()
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
        return selectedMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSelectedUserCell.id, for: indexPath) as! HorizontalSelectedUserCell
        let user = selectedMembers[indexPath.row]
        cell.name = user.name//user.givenName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = selectedMembers[indexPath.row]
        let label = UILabel()
        let cell = HorizontalSelectedUserCell(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.text = user.name
        cell.addSubview(label)
        cell.sizeToFit()
        return CGSize(width: cell.frame.width + 32, height: 50)
    }
    
}
