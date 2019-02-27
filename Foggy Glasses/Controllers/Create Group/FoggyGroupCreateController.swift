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
    
    ///Datasource
    var membersDictionary = [String: [SearchMember]]()
    var membersFirstIntialDictionary = [String]()
    
    ///Filtered datasource
    var filteredMembers = [SearchMember]()
    
    ///Selection Datasource
    var searchMembers = [SearchMember]()
    var selectedMembers = [SearchMember]()
    
    ///Search variables
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .feedBackground
        navigationController?.view.backgroundColor = .feedBackground
        title = "Select Members"
        definesPresentationContext = true
        
        view.addSubview(horizontalCollection)
        horizontalCollection.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
//        navigationController?.definesPresentationContext = true
        
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
        
        for member in searchMembers {
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
        if searchActive {
            return 1
        }
        return membersFirstIntialDictionary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredMembers.count
        }
        let memberKey = membersFirstIntialDictionary[section]
        if let members = membersDictionary[memberKey] {
            return members.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ContactTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: ContactTableViewCell.id)//tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.id, for: indexPath) as! ContactTableViewCell
        
        if searchActive {
            let member = filteredMembers[indexPath.row]
            for m in searchMembers {
                if m.id == member.id {
                    cell.member = m
                }
            }
        } else {
            let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
            if let memberValues = membersDictionary[memberKeyLetter] {
                let member = memberValues[indexPath.row]
                for m in searchMembers {
                    if m.id == member.id {
                        cell.member = m
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchActive {
            return nil
        }
        return membersFirstIntialDictionary[section]
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchActive {
            return nil
        }
        return membersFirstIntialDictionary
    }
    
    ///Selects/Deselects person in our SearchMember Datasource
    func select(person: SearchMember, selected: Bool = true) {
        for (idx, member) in searchMembers.enumerated() {
            if person.id == member.id {
                print("Found matching ID:", member.id)
                var newMember = member
                newMember.selected = !member.selected
                searchMembers[idx] = newMember
            }
        }
    }
    
    ///Returns value from searchMembers
    func getMember(id: Int)->SearchMember {
        for member in searchMembers {
            if member.id == id {
                return member
            }
        }
        return SearchMember()
    }
    
    ///Selectes member from dictionary array, fetches SearchMember value, limits if over
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchActive {
            let member = filteredMembers[indexPath.row]
            //Get the correct member value from searchMembers
            let membersMember = getMember(id: member.id)
            if selectedMembers.count > 11 && membersMember.selected == false {
                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(12) people allowed per Foggy Glasses Group")
                present(foggyGlasses, animated: true, completion: nil)
            } else {
                select(person: member)
                tableView.reloadData()
                updateHorizontalCollection()
            }
        } else {
            let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
            if let memberValues = membersDictionary[memberKeyLetter] {
                let member = memberValues[indexPath.row]
                //Get the correct member value from searchMembers
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
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if searchActive {
            let member = filteredMembers[indexPath.row]
            select(person: member, selected: false)
            tableView.reloadData()
            updateHorizontalCollection()
        } else {
            let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
            if let memberValues = membersDictionary[memberKeyLetter] {
                let member = memberValues[indexPath.row]
                select(person: member, selected: false)
                tableView.reloadData()
            }
            updateHorizontalCollection()
        }
    }
    
    ///Horizontal collection update
    func updateHorizontalCollection() {
        selectedMembers = []
        for member in searchMembers {
            if member.selected {
                selectedMembers.append(member)
            }
        }
        horizontalCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension FGCCViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.myTableView.reloadData()
    }
    
    ///Search function
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchText = searchController.searchBar.text ?? ""
        if searchText == "" {
            filteredMembers = searchMembers
            myTableView.reloadData()
            return
        }

        filteredMembers = []
        for contact in searchMembers {
            if contact.name.lowercased().contains(searchText.lowercased()) {
                filteredMembers.append(contact)
            }
        }
        myTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Search active")
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
    
}

extension FGCCViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSelectedUserCell.id, for: indexPath) as! HorizontalSelectedUserCell
        let user = selectedMembers[indexPath.row]
        cell.name = user.firstName//user.givenName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = selectedMembers[indexPath.row]
        let label = UILabel()
        let cell = HorizontalSelectedUserCell(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.text = user.firstName
        cell.addSubview(label)
        cell.sizeToFit()
        return CGSize(width: cell.frame.width + 32, height: 50)
    }
    
}
