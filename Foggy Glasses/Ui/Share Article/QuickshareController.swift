//
//  QuickshareController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Contacts
import PopupDialog
import Firebase
import FirebaseAuth

class QuickshareController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    static let createGroupHeaderStr = "Create Group Header"
    static let groupNameStr = "Group Name"
    static let selectSavedArticles = "Select From Saved Articles"
    static let groupsHeader = "Groups Header"
    static let groupsSection = "Groups Section"
    static let friendsHeader = "Friends Header"
    static let friendsSection = "Friends Section"
    
    var isSkipEnabled = false
    
    ///The user inputted link for article!
    var link:String?
    
    var sections = [QuickshareController.createGroupHeaderStr,
                    QuickshareController.groupNameStr,
                    QuickshareController.selectSavedArticles,
                    QuickshareController.groupsHeader,
                    QuickshareController.groupsSection,
                    QuickshareController.friendsHeader,
                    QuickshareController.friendsSection]
    
    ///Datasource for friends
    var friends = [FoggyUser]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var groups = [FoggyGroup]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    static let articleLinkNotification = Notification.Name("Article Link NOtification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Share Article"
        globalSearchMembers = []
        globalSelectedMembers = []
        
        collectionView.backgroundColor = .feedBackground
        
        collectionView.register(CreateGroupHeaderCell.self, forCellWithReuseIdentifier: CreateGroupHeaderCell.id)
        collectionView.register(SavedArticleSelectCell.self, forCellWithReuseIdentifier: SavedArticleSelectCell.id)
        collectionView.register(CreateGroupNameCell.self, forCellWithReuseIdentifier: CreateGroupNameCell.id)
        collectionView.register(FoggyHeaderTextCell.self, forCellWithReuseIdentifier: FoggyHeaderTextCell.id)
        collectionView.register(CreateGroupAddHeader.self, forCellWithReuseIdentifier: CreateGroupAddHeader.id)
        collectionView.register(GroupSelectionCell.self, forCellWithReuseIdentifier: GroupSelectionCell.id)
        collectionView.register(GroupFriendsTitleCell.self, forCellWithReuseIdentifier: GroupFriendsTitleCell.id)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsMultipleSelection = true
        
        let rightButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(clickedNext))
        rightButton.tintColor = .black
        navigationItem.rightBarButtonItem = rightButton
        
        //Flow for enabling skip on beginning walkthrough
        if !isSkipEnabled {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = .black
        } else {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .done, target: self, action: #selector(skipClicked))
            navigationItem.leftBarButtonItem?.tintColor = .black
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLink(note:)), name: QuickshareController.articleLinkNotification, object: nil)
        
        fetchGroups()
        fetchFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
//        if let selectedArticle = globalSelectedSavedArticle {
        fetchGroups()
//            collectionView.reloadData()
        
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        globalSelectedSavedArticle = nil
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    ///Method called when selecting create new group
    @objc func createGroupFromQuickshareExtension() {
//        DeepLinkManager.shared.present(nav: self.navigationController, returnVC: nil)
        return
        //        globalReturnVC = self
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if self.checkForContactPermission() {
                let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
                create.isFromQuickshare = true
                self.navigationController?.pushViewController(create, animated: true)
            } else {
                let contact = ContactPermissionController()
                contact.isFromQuickshare = true
                self.navigationController?.pushViewController(contact, animated: true)
            }
        }
    }
    
    private func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
    }
    
    @objc func skipClicked() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav = UINavigationController(rootViewController: feed)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func updateLink(note: Notification){
        if let object = note.object as? [String: Any] {
            if let link = object["link"] as? String {
                self.link = link
            }
        }
    }
    
    @objc func clickedNext() {
        if let text = self.link {
            if text == "" {
                let popup = PopupDialog(title: "Missing Link", message: "Please enter a link to an article.")
                present(popup, animated: true, completion: nil)
                return
            }
        } else {
            let popup = PopupDialog(title: "Missing Link", message: "Please enter a link to an article.")
            present(popup, animated: true, completion: nil)
            navigationItem.rightBarButtonItem?.isEnabled = true
            return
        }
        
        getSelectedGroups { (selectedGroups) in
            if selectedGroups.count == 0 {
                let popup = PopupDialog(title: "Missing Group", message: "Please select a group or groups to share Article with.")
                self.present(popup, animated: true, completion: nil)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            let review = ReviewController()
            print("Self.link", self.link)
            review.link = self.link
            review.selectedGroups = selectedGroups
            review.savedArticle = globalSelectedSavedArticle
            self.navigationController?.pushViewController(review, animated: true)
        }
        
        
       
    }
    
    private func getSelectedGroups(completion: @escaping ([FoggyGroup])->()){
        guard let selected = collectionView.indexPathsForSelectedItems else {
            completion([])
            return
        }
        if selected.isEmpty {
            completion([])
        }
        
        var selectedGroups = [FoggyGroup]()
        for s in selected {
            if sections[s.section] == QuickshareController.groupsSection {
                selectedGroups.append(groups[s.row])
                if selectedGroups.count == selected.count {
                    completion(selectedGroups)
                }
            } else if sections[s.section] == QuickshareController.friendsSection {
                if let uid = Auth.auth().currentUser?.uid {
                    let fid = friends[s.row].uid
                    var friendGroup = ""
                    if uid < fid {
                        friendGroup = "friend-" + uid + "-" + fid
                    } else {
                        friendGroup = "friend-" + fid + "-" + uid
                    }
                    print(friendGroup)
                    FirebaseManager.global.getGroup(groupId: friendGroup) { (group) in
                        if let gro = group {
                            selectedGroups.append(gro)
                            if selectedGroups.count == selected.count {
                                completion(selectedGroups)
                            }
                        } else {
                            completion(selectedGroups)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.global.getGroups(uid: uid) { (dict) in
            if let data = dict {
                if let groups = data["groups"] {
                    self.groups = groups
                }
            }
        }
    }
    
    ///Method for fetching Foggy Glasses Friends
    private func fetchFriends() {
        friends = FirebaseManager.global.friends
//        friends = FoggyUser.createMockUsers()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        if currentSection == QuickshareController.createGroupHeaderStr {
            return 1
        } else if currentSection == QuickshareController.groupNameStr {
            return 1
        } else if currentSection == QuickshareController.selectSavedArticles {
            return 1
        } else if currentSection == QuickshareController.groupsSection {
            return groups.count
        } else if currentSection == QuickshareController.friendsSection {
            return friends.count
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == QuickshareController.createGroupHeaderStr {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupHeaderCell.id, for: indexPath) as! CreateGroupHeaderCell
            cell.headerImage.image = UIImage(named: "Compose Article Header")
            return cell
        } else if currentSection == QuickshareController.groupNameStr {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupNameCell.id, for: indexPath) as! CreateGroupNameCell
            cell.groupName.headerString = "Link To Article"
            cell.groupName.placeholder = "https://"
            if let g = globalSelectedSavedArticle {
                cell.groupName.text = g.link
                self.link = g.link
            }
            return cell
        } else if currentSection == QuickshareController.selectSavedArticles {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedArticleSelectCell.id, for: indexPath) as! SavedArticleSelectCell
            return cell
        } else if currentSection == QuickshareController.groupsSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupSelectionCell.id, for: indexPath) as! GroupSelectionCell
            cell.group = groups[indexPath.row]
            return cell
        } else if currentSection == QuickshareController.friendsSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupSelectionCell.id, for: indexPath) as! GroupSelectionCell
            cell.friend = friends[indexPath.row]
            return cell
        } else if currentSection == QuickshareController.groupsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupFriendsTitleCell.id, for: indexPath) as! GroupFriendsTitleCell
            cell.titleString = "My Groups"
            cell.myGroupsHeaderConfig()
            return cell
        } else if currentSection == QuickshareController.friendsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupFriendsTitleCell.id, for: indexPath) as! GroupFriendsTitleCell
//            cell.myFriendsHeaderConfig()
            cell.titleString = "My Friends"
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupHeaderCell.id, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == QuickshareController.createGroupHeaderStr {
            return CGSize(width: view.frame.width, height: 168)
        } else if currentSection == QuickshareController.groupNameStr {
            return CGSize(width: view.frame.width, height: 77)
        } else if currentSection == QuickshareController.selectSavedArticles {
            return CGSize(width: view.frame.width, height: 60)
        } else if currentSection == QuickshareController.groupsSection || currentSection == QuickshareController.friendsSection {
            return CGSize(width: view.frame.width, height: 60)
        } else if currentSection == QuickshareController.groupsHeader || currentSection == QuickshareController.friendsHeader {
            return CGSize(width: view.frame.width, height: 50)
        }
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == QuickshareController.selectSavedArticles {
            let articles = SavedArticlesCollectionController(collectionViewLayout: UICollectionViewFlowLayout())
            articles.isSelecting = true
            navigationController?.pushViewController(articles, animated: true)
        }
    }
}
