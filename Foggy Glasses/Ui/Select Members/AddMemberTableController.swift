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
import Firebase

///Global Datasource for members to share between controllers
var globalSearchMembers = [SearchMember]()
var globalSelectedMembers = [SearchMember]()

class AddMemberTableController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    ///Datasource
    var membersDictionary = [String: [SearchMember]]()
    var membersFirstIntialDictionary = [String]()
    
    ///Filtered datasource
    var filteredMembers = [SearchMember]()
    
    ///Search variables
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
    private var myTableView: UITableView!
    
    ///Datasource for searching for foggy users
    var foggySearchUsers = [SearchMember]()
    
    ///Boolean value for Searching For Foggy Users
    var searchConfigBool = false
    
    ///Configuration for searching for Foggy Users
    func searchConfig() {
        title = "Search For People"
        searchConfigBool = true
        navigationItem.rightBarButtonItem = nil
    }
    
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
    
    ///Constraints for showing hiding horizontal collection
    var heightConstraint: NSLayoutConstraint?
    var hiddenHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .feedBackground
        navigationController?.view.backgroundColor = .feedBackground
        
        //Add Plus Button for Searching For Foggy Users if not searchConfigBool
        if searchConfigBool {
            title = "Find Members"
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
            navigationItem.setHidesBackButton(false, animated: false)
        } else {
            title = "Select People"
            navigationItem.rightBarButtonItem = UIBarButtonItem.settingsButton(self, action: #selector(clickedAdd), imageName: "Searcher")
            navigationItem.rightBarButtonItem?.tintColor = .black
            
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(clickedDone))
            navigationItem.leftBarButtonItem?.tintColor = .black
            navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = .black
        }
        
        definesPresentationContext = true
        
        view.addSubview(horizontalCollection)
        horizontalCollection.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //Config constraints for showing and hiding
        heightConstraint = horizontalCollection.heightAnchor.constraint(equalToConstant: 50)
        heightConstraint?.isActive = false
        hiddenHeightConstraint = horizontalCollection.heightAnchor.constraint(equalToConstant: 0)
        hiddenHeightConstraint?.isActive = true
        
        
        myTableView = UITableView(frame: .zero, style: .plain)
        myTableView.allowsMultipleSelection = true
        myTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.id)
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        myTableView.anchor(top: horizontalCollection.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        //Restore previous search
        if globalSearchMembers.count > 0 {
            configDatasource()
        } else {
            fetchContacts()
        }
        
        setUpSearchController()
    }
    
    private func setUpSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
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
    
    ///Presents another instance of this class for Searching for Foggy Users
    @objc func clickedAdd() {
        let add = AddMemberTableController()
        add.searchConfig()
        self.navigationController?.pushViewController(add, animated: true)
    }
    
    @objc func clickedDone() {
        
        navigationController?.popViewController(animated: true)
    }
    
    func generateContentLink() -> URL {
        let baseURL = URL(string: "https://inviteNewUser.page.link")!
        let domain = "https://foggyglassesnews.page.link"
        let linkBuilder = DynamicLinkComponents(link: baseURL, domainURIPrefix: domain)
        
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.FoggyGlassesNews.FG")
        
        // Fall back to the base url if we can't generate a dynamic link.
        return linkBuilder?.link ?? baseURL
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    ///Method for fetching Contacts
    private func fetchContacts() {
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey
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
                
                if contact.givenName.contains("#") {
                    contacts.remove(at: idx)
                }
                if contact.givenName == "" || contact.givenName == " " {
                    contacts.remove(at: idx)
                }
            }
            
            contacts = contacts.filter { (contact) -> Bool in
                return !contact.phoneNumbers.isEmpty
            }
            
            
            var searchMembers = [SearchMember]()
            for (idx, contact) in contacts.enumerated() {
                var member = SearchMember()
                member.contact = contact
                member.id = idx
//                print("Member:", member.id)
                searchMembers.append(member)
            }
            
            globalSearchMembers = searchMembers
        } catch {
            print("unable to fetch contacts")
        }
        
        fetchFriends()
        configDatasource()
    }
    
    
    ///Fetch friends and add to global search members
    func fetchFriends() {
       
        let friends = FirebaseManager.global.friends
        
        for friend in friends {
            var person = SearchMember()
            person.foggyUser = friend
            person.contact = nil
            person.id = globalSearchMembers.count + 1
            globalSearchMembers.append(person)
        }
    }
    
    ///Called when table opened, used for indexing on titles
    func configDatasource() {
        print("Config data source")
        membersFirstIntialDictionary.removeAll()
        membersDictionary.removeAll()
        
        //Index users on title (* for foggy friends) (# for foggy user)
        for member in globalSearchMembers {
            let memberKey = String(member.titleKey)
            if var memberValues = membersDictionary[memberKey] {
                memberValues.append(member)
                membersDictionary[memberKey] = memberValues
            } else {
                membersDictionary[memberKey] = [member]
            }
        }
        
        //Generate key
        membersFirstIntialDictionary = [String](membersDictionary.keys)
        membersFirstIntialDictionary = membersFirstIntialDictionary.sorted(by: { $0 < $1 })
        
        ///Reload table data
        myTableView.reloadData()
        
        ///Only show horizontal collection when not searching for Foggy Users
        if !searchConfigBool {
            updateHorizontalCollection()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///Refresh datasource if we are Pop from VC
        if !searchConfigBool {
            configDatasource()
        }
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        //Search Section for Firestore Foggy user search
        if searchConfigBool {
            return 1
        }
        //Search section for local user search
        if searchActive {
            return 1
        }
        return membersFirstIntialDictionary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Search Datasource for firestore foggy user search
        if searchConfigBool {
            return foggySearchUsers.count
        }
        //Search datasource for local user search
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
        let cell = ContactTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: ContactTableViewCell.id)
        //Configure cell if Firebase foggy user search
        if searchConfigBool {
            let user = foggySearchUsers[indexPath.row]
            cell.member = user
            return cell
        }
        //Config cells for local user search/contacts-friends cell
        if searchActive {
            let member = filteredMembers[indexPath.row]
            for m in globalSearchMembers {
                if m.id == member.id {
                    cell.member = m
                }
            }
        } else {
            let memberKeyLetter = membersFirstIntialDictionary[indexPath.section]
            if let memberValues = membersDictionary[memberKeyLetter] {
                let member = memberValues[indexPath.row]
                for m in globalSearchMembers {
                    if m.id == member.id {
                        cell.member = m
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // No title for either of these guys
        if searchConfigBool || searchActive {
            return nil
        }
        ///Display title headers for these
        var title = membersFirstIntialDictionary[section]
        if title == "*" {
            title = "Foggy Friends"
        } else if title == "#" {
            title = "Foggy Users"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let gradientView1 = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 23))
        let gradient2: CAGradientLayer = CAGradientLayer()
        gradient2.colors = [UIColor.foggyBlue.cgColor, UIColor.foggyGrey.cgColor]
        gradient2.locations = [0.0 , 1.0]
        gradient2.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient2.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient2.frame = gradientView1.layer.frame
        gradientView1.layer.insertSublayer(gradient2, at: 1)
        let label = UILabel()
        let title = sectionIndexTitles(for: tableView)?[section]
        
        ///Configure header title for different data group
        if title == "*" {
            label.text = "Foggy Friends"
        } else if title == "#" {
            label.text = "Foggy Users"
        } else {
            label.text = title
        }
        
        gradientView1.addSubview(label)
        
        label.anchor(top: gradientView1.topAnchor, left: gradientView1.leftAnchor, bottom: gradientView1.bottomAnchor, right: gradientView1.rightAnchor, paddingTop: 2, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        return gradientView1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //No header for these guys
        if searchConfigBool || searchActive {
            return 0
        }
        return 23
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if searchConfigBool || searchActive {
            return 0
        }
        return 23
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchConfigBool || searchActive {
            return nil
        }
        return membersFirstIntialDictionary
    }
    
    ///Selects/Deselects person in our SearchMember Datasource
    func select(person: SearchMember, selected: Bool = true) {
        for (idx, member) in globalSearchMembers.enumerated() {
            if person.id == member.id {
                print("Found matching ID:", member.id)
                var newMember = member
                newMember.selected = !member.selected
                globalSearchMembers[idx] = newMember
            }
        }
    }
    
    ///Returns value from searchMembers
    func getMember(id: Int)->SearchMember {
        for member in globalSearchMembers {
            if member.id == id {
                return member
            }
        }
        return SearchMember()
    }
    
    ///Selectes member from dictionary array, fetches SearchMember value, limits if over
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selected from Firestore foggy user search,
        if searchConfigBool {
            //Get the user
            var person = foggySearchUsers[indexPath.row]
            if globalSelectedMembers.count > 11  {
                let foggyGlasses = PopupDialog(title: "Max Number of People Selected", message: "Only \(12) people allowed per Foggy Glasses Group")
                present(foggyGlasses, animated: true, completion: nil)
            } else {
                ///Set the new search user to have next id in array and append to global search members
                person.id = globalSearchMembers.count + 1
                globalSearchMembers.append(person)
                select(person: person)
                navigationController?.popViewController(animated: true)
            }
            return
        }
        
        ///If not searching from Firestore foggy user search do regular logic
        if searchActive {
            let member = filteredMembers[indexPath.row]
            //Get the correct member value from searchMembers
            let membersMember = getMember(id: member.id)
            if globalSelectedMembers.count > 11 && membersMember.selected == false {
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
                if globalSelectedMembers.count > 11 && membersMember.selected == false {
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
        globalSelectedMembers = []
        for member in globalSearchMembers {
            if member.selected {
                globalSelectedMembers.append(member)
            }
        }
        
        //Toggle hide horizontal collection
        if globalSelectedMembers.count == 0 {
            heightConstraint?.isActive = false
            hiddenHeightConstraint?.isActive = true
        } else {
            heightConstraint?.isActive = true
            hiddenHeightConstraint?.isActive = false
        }
        
        horizontalCollection.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension AddMemberTableController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    //MARK: Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.myTableView.reloadData()
    }
    
    ///Search function
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchText = searchController.searchBar.text ?? ""
        
        ///Firestore Foggy user search call
        if searchConfigBool {
            firestoreFoggyUserSearch(searchText: searchText)
            return
        }
        
        //
        if searchText == "" {
            filteredMembers = globalSearchMembers
            myTableView.reloadData()
            return
        }

        filteredMembers = []
        for contact in globalSearchMembers {
            if contact.name.lowercased().contains(searchText.lowercased()) {
                filteredMembers.append(contact)
            }
        }
        myTableView.reloadData()
    }
    
    ///Method for searching firestore for foggy users
    private func firestoreFoggyUserSearch(searchText: String) {
        print("Searching for foggy users")
        if searchText.isEmpty {
            self.foggySearchUsers.removeAll()
            myTableView.reloadData()
            return
        }
        FirebaseManager.global.searchForUser(search: searchText) { (users) in
            print("Returned \(users.count) users")
            self.foggySearchUsers = users
            self.myTableView.reloadData()
        }
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

extension AddMemberTableController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return globalSelectedMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSelectedUserCell.id, for: indexPath) as! HorizontalSelectedUserCell
        let user = globalSelectedMembers[indexPath.row]
        cell.name = user.firstName//user.givenName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = globalSelectedMembers[indexPath.row]
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.text = user.firstName
        label.sizeToFit()
        return CGSize(width: label.frame.width + 32, height: 50)
    }
    
}
