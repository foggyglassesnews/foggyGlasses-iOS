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
        title = "Select Members"
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
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(clickedDone))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
    }
    @objc func clickedDone() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let link = URL(string: "https://foggyglassesnews.page.link/?invitedby=\(uid)")
        guard let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://foggyglassesnews.page.link") else {
            return
        }//DynamicLinkComponents(link: link!, domain: "foggyglassesnews.page.link")
        
        referralLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.FoggyGlassesNews.FG")
//        referralLink.iOSParameters?.minimumAppVersion = "1.0.1"
        referralLink.iOSParameters?.appStoreID = "1453297801"
        
//        referralLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.android")
//        referralLink.androidParameters?.minimumVersion = 125
        
        referralLink.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Short URL", shortURL)
        }
        
        
        
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
        
        //Index users on title (* for foggy friends)
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
        
        updateHorizontalCollection()
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
        if searchActive {
            return nil
        }
        var title = membersFirstIntialDictionary[section]
        if title == "*" {
            title = "Foggy Friends"
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
        if title == "*" {
            label.text = "Foggy Friends"
        } else {
            label.text = title
        }
        
        gradientView1.addSubview(label)
        
        let plusButton = UIButton()
        plusButton.backgroundColor  = .red
        gradientView1.addSubview(plusButton)
        plusButton.anchor(top: gradientView1.topAnchor, left: nil, bottom: gradientView1.bottomAnchor, right: gradientView1.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 50, height: 0)
        
        label.anchor(top: gradientView1.topAnchor, left: gradientView1.leftAnchor, bottom: gradientView1.bottomAnchor, right: gradientView1.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        return gradientView1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if searchActive {
            return 0
        }
        return 23
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchActive {
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
        let label = UILabel()
        let cell = HorizontalSelectedUserCell(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.text = user.firstName
        cell.addSubview(label)
        cell.sizeToFit()
        return CGSize(width: cell.frame.width + 32, height: 50)
    }
    
}
