//
//  CreateGroupController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import PopupDialog

class CreateGroupController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate  {
    
    let groupUsers = 12

    static let createGroupHeaderStr = "Create Group Header"
    static let groupNameStr = "Group Name"
    static let searchBarStr = "Search Bar"
    static let foggyFriendsHeader = "Foggy Friends Header"
    static let foggyFriendCells = "Foggy Friends Cells"
    static let contactsHeader = "Contacts Header"
    static let contactsCell = "Contacts Cells"
    static let addPeopleCell = "Add People To Group Cell"
    
    var sections = //[CreateGroupController.contactsCell]
        [CreateGroupController.createGroupHeaderStr,
                    CreateGroupController.groupNameStr,
                    CreateGroupController.addPeopleCell,
                    CreateGroupController.foggyFriendCells]
//                    CreateGroupController.searchBarStr,
//                    CreateGroupController.foggyFriendsHeader,
//                    CreateGroupController.foggyFriendCells,
//                    CreateGroupController.contactsHeader,
//                    CreateGroupController.contactsCell]
    
    var filteredContacts = [CNContact]()
    var filteredFriends = [FoggyUser]()
    
    ///Datasource for contacts
    var contacts = [SearchMember]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    ///Datasource for friends
    var friends = [SearchMember]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    static let addPeopleNotification = Notification.Name("Add People Notification")
    static let searchNotification = Notification.Name("Search Notification Controller")
    static let searchClicked = Notification.Name("Search Clicked Notification")
    
    var filtered:[String] = []
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        view.backgroundColor = .feedBackground
        collectionView.backgroundColor = .feedBackground
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(CreateGroupHeaderCell.self, forCellWithReuseIdentifier: CreateGroupHeaderCell.id)
        collectionView.register(CreateGroupNameCell.self, forCellWithReuseIdentifier: CreateGroupNameCell.id)
        collectionView.register(CreateGroupAddHeader.self, forCellWithReuseIdentifier: CreateGroupAddHeader.id)
        collectionView.register(CreateGroupSearchCell.self, forCellWithReuseIdentifier: CreateGroupSearchCell.id)
        collectionView.register(CreateGroupContactCell.self, forCellWithReuseIdentifier: CreateGroupContactCell.id)
        collectionView.register(FoggyHeaderTextCell.self, forCellWithReuseIdentifier: FoggyHeaderTextCell.id)
        collectionView.register(CreateGroupFoggyFriendCell.self, forCellWithReuseIdentifier: CreateGroupFoggyFriendCell.id)
        
        collectionView.keyboardDismissMode = .onDrag
        
//        fetchFriends()
//        fetchContacts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addPeopleClicked), name: CreateGroupController.addPeopleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToSearchBar), name: CreateGroupController.searchClicked, object: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.view.backgroundColor = .feedBackground
//        self.searchController.searchResultsUpdater = self
//        self.searchController.delegate = self
//        self.searchController.searchBar.delegate = self
//
//        self.searchController.hidesNavigationBarDuringPresentation = false
//        self.searchController.dimsBackgroundDuringPresentation = true
//        self.searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search Contacts"
////        searchController.searchBar.sizeToFit()
//
//        searchController.searchBar.becomeFirstResponder()
//
//        self.navigationItem.titleView = searchController.searchBar
        
//        setUpSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
        print("ViewWillAppear")
        friends = selectedMembers
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
    
    @objc func addPeopleClicked() {
        navigationController?.pushViewController(FGCCViewController(), animated: true)
    }
    
    @objc func scrollToSearchBar() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
    }
    
    @objc func searchInput(note: Notification) {
        if let data = note.object as? [String: Any] {
            if let text = data["text"] as? String {
                filterContentForSearchText(searchText: text)
            }
        }
    }
    
//    private func getIndex(for cell: SelectionCell) {
//        for visibleCells in collectionView.visibleCells {
//            if visibleCells.isEqual(cell) {
//                return
//            }
//        }
//    }
    
    
    ///Method for fetching Foggy Glasses Friends
    private func fetchFriends() {
        let f = FoggyUser.createMockUsers()
        filteredFriends = f
//        friends = f
        
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
            self.filteredContacts = contacts
//            self.contacts = contacts
        } catch {
            print("unable to fetch contacts")
        }
    }
    
    @objc func openSMSController() {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Join my Foggy Glasses group! www.foggyglassesnews.com"
            controller.recipients = []
            controller.messageComposeDelegate = self
            present(controller, animated: true, completion: nil)
        } else {
            print("Cannot compose message")
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        if currentSection == CreateGroupController.createGroupHeaderStr {
            return 1
        } else if currentSection == CreateGroupController.groupNameStr {
            return 1
        } else if currentSection == CreateGroupController.addPeopleCell{
            return 1
        } else if currentSection == CreateGroupController.createGroupHeaderStr{
            return 1
        } else if currentSection == CreateGroupController.foggyFriendsHeader{
            return 1
        } else if currentSection == CreateGroupController.foggyFriendCells {
            return friends.count
        } else if currentSection == CreateGroupController.contactsHeader{
            return 1
        } else if currentSection == CreateGroupController.contactsCell {
            if searchActive {
                return filteredContacts.count
            }
            else
            {
                return contacts.count
            }
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == CreateGroupController.createGroupHeaderStr {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupHeaderCell.id, for: indexPath)
            return cell
        } else if currentSection == CreateGroupController.groupNameStr {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupNameCell.id, for: indexPath)
            return cell
        } else if currentSection == CreateGroupController.addPeopleCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupAddHeader.id, for: indexPath) as! CreateGroupAddHeader
            cell.members.text = "Group Members (\(friends.count))"
            return cell
        } else if currentSection == CreateGroupController.searchBarStr {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupSearchCell.id, for: indexPath)
            return cell
        } else if currentSection == CreateGroupController.foggyFriendsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoggyHeaderTextCell.id, for: indexPath) as! FoggyHeaderTextCell
            cell.titleText = "Foggy Glasses Friends"
            return cell
        } else if currentSection == CreateGroupController.foggyFriendCells {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupFoggyFriendCell.id, for: indexPath) as! CreateGroupFoggyFriendCell
            cell.member = friends[indexPath.row]
//            cell.foggyUser = friends[indexPath.row]
            return cell
        } else if currentSection == CreateGroupController.contactsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoggyHeaderTextCell.id, for: indexPath) as! FoggyHeaderTextCell
            cell.titleText = "Phone Contacts"
            return cell
        } else if currentSection == CreateGroupController.contactsCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupContactCell.id, for: indexPath) as! CreateGroupContactCell
//            cell.contact = contacts[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupContactCell.id, for: indexPath) as! CreateGroupContactCell
//        cell.contact = contacts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == CreateGroupController.createGroupHeaderStr {
            return CGSize(width: view.frame.width, height: 168)
        } else if currentSection == CreateGroupController.groupNameStr {
            return CGSize(width: view.frame.width, height: 69)
        } else if currentSection == CreateGroupController.addPeopleCell {
            return CGSize(width: view.frame.width, height: 68)
        } else if currentSection == CreateGroupController.createGroupHeaderStr {
            return CGSize(width: view.frame.width, height: 49)
        } else if currentSection == CreateGroupController.foggyFriendsHeader {
            return CGSize(width: view.frame.width, height: 34)
        } else if currentSection == CreateGroupController.foggyFriendCells {
            return CGSize(width: view.frame.width, height: 60)
        } else if currentSection == CreateGroupController.contactsHeader {
            return CGSize(width: view.frame.width, height: 34)
        } else if currentSection == CreateGroupController.contactsCell {
            return CGSize(width: view.frame.width, height: 60)
        }
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cells = collectionView.indexPathsForSelectedItems {
            if cells.count > groupUsers - 1 {
                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(groupUsers) people allowed per Foggy Glasses Group")
                present(foggyGlasses, animated: true) {
                    DispatchQueue.main.async {
                        if let cell = collectionView.cellForItem(at: indexPath) {
                            cell.isSelected = false
                        }
                    }
                }
                return false
            } else {
                return true
            }
        }
        return true
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let cells = collectionView.indexPathsForSelectedItems {
//            if cells.count > 5 {
//
//                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only 5 people allowed per Foggy Glasses Group")
//                present(foggyGlasses, animated: true) {
//                    DispatchQueue.main.async {
//                        if let cell = collectionView.cellForItem(at: indexPath) {
//                            cell.isSelected = false
//                        }
//                    }
//
//                }
//            }
//        }
//
////        let section = indexPath.section
////        let currentSection = sections[section]
////        if currentSection == CreateGroupController.contactsCell || currentSection == CreateGroupController.foggyFriendCells {
////            print("Selected this cell!")
////            openSMSController()
////        }
//    }
}

extension CreateGroupController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == .sent {
            print("Sent Invite")
        } else {
            print("Did not send invite")
        }
        controller.dismiss(animated: true, completion: nil)
//        controller.dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupController {
    
    func filterContentForSearchText(searchText: String) {
        
//        if searchText == "" {
//            filteredContacts = contacts
////            filteredFriends = friends
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
////                var newContact = contact
////                newContact.formatting = matches
//                tmpContacts.append(contact)
//                return true
//            } else {
//                return false
//            }
//        }
        
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
        
//        filteredFriends = tmpFriends
//        filteredContacts = tmpContacts
//
//        let indexSet = IndexSet(arrayLiteral: 4, 6)
//        collectionView.reloadSections(indexSet)
//        collectionView.reloadData()
    }
}

extension CreateGroupController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
}
