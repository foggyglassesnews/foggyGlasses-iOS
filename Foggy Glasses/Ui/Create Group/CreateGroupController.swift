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
import FirebaseDynamicLinks
import FirebaseAuth
import Firebase

class CreateGroupController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate  {
    
    static let createGroupHeaderStr = "Create Group Header"
    static let groupNameStr = "Group Name"
    static let foggyFriendCells = "Foggy Friends Cells"
    static let addPeopleCell = "Add People To Group Cell"
    
    ///Bool variable for enabling skip button on beginning walkthrough
    var isSkipEnabled = false
    
    var groupName: String?
    
    var sections = [CreateGroupController.createGroupHeaderStr,
                    CreateGroupController.groupNameStr,
                    CreateGroupController.addPeopleCell,
                    CreateGroupController.foggyFriendCells]
    
    ///Datasource for searchMembers
    var friends = [SearchMember]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    ///Notification listening for addpeople button clicked
    static let addPeopleNotification = Notification.Name("Add People Notification")
    static let groupNameNotification = Notification.Name("Group Name Update Notification")
    
    override func viewDidLoad() {
        globalSearchMembers = []
        globalSelectedMembers = []
        
        title = "Create Group"
        
        view.backgroundColor = .feedBackground
        collectionView.backgroundColor = .feedBackground
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(CreateGroupHeaderCell.self, forCellWithReuseIdentifier: CreateGroupHeaderCell.id)
        collectionView.register(CreateGroupNameCell.self, forCellWithReuseIdentifier: CreateGroupNameCell.id)
        collectionView.register(CreateGroupAddHeader.self, forCellWithReuseIdentifier: CreateGroupAddHeader.id)
        collectionView.register(FoggyHeaderTextCell.self, forCellWithReuseIdentifier: FoggyHeaderTextCell.id)
        collectionView.register(CreateGroupFoggyFriendCell.self, forCellWithReuseIdentifier: CreateGroupFoggyFriendCell.id)
        
        collectionView.keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(self, selector: #selector(addPeopleClicked), name: CreateGroupController.addPeopleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupName(note:)), name: CreateGroupController.groupNameNotification, object: nil)
        
        //Flow for enabling skip on beginning walkthrough
        if !isSkipEnabled {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = .black
        } else {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Skip", style: .done, target: self, action: #selector(skipClicked))
            navigationItem.leftBarButtonItem?.tintColor = .black
        }
        
        navigationController?.view.backgroundColor = .feedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(generateGroup))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    ///Method called when skip button clicked
    @objc func skipClicked() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav = UINavigationController(rootViewController: feed)
        present(nav, animated: true, completion: nil)
    }
    
    ///Notification reciever for Group name input text field
    @objc func updateGroupName(note:Notification) {
        if let object = note.object as? [String: Any] {
            if let name = object["name"] as? String {
                self.groupName = name
            }
        }
    }
    
    ///Method for creating a group
    @objc func generateGroup() {
        if groupName == nil || groupName ?? "" == ""{
            let err = PopupDialog(title: "Create Group Error", message: "Please give group a name.")
            present(err, animated: true, completion: nil)
            return
        }
        
        if groupName!.containsBadWords() {
            let err = PopupDialog(title: "Create Group Error", message: "Group Name contains foul language.")
            present(err, animated: true, completion: nil)
            return
        }
        
        if globalSelectedMembers.count == 0 {
            let err = PopupDialog(title: "Create Group Error", message: "You must add other members to the group!")
            present(err, animated: true, completion: nil)
            
        }
        
        guard let uid = Auth.auth().currentUser?.uid, let groupName = groupName else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        //Create the group
        FirebaseManager.global.createGroup(name: groupName, members: globalSelectedMembers) { (success, groupId) in
            if success {
                
                
                
                //Add to your groups
                FirebaseManager.global.addGroupToUsersGroups(uid: uid, groupId: groupId!, completion: { (success) in
                    if success {
                        print("Successfully added group to users groups!")
                        NotificationCenter.default.post(name: SideMenuController.updateGroupsNotification, object: nil)
                        self.createdGroupSuccess()
//                        self.navigationController?.popViewController(animated: true)
                    }
                })
                
                ///Add to all other Foggy users pending groups
                for member in globalSelectedMembers {
                    if let fId = member.getUser()?.uid, let groupId = groupId {
                        FirebaseManager.global.addGroupToUsersPendingGroups(uid: fId, groupId: groupId, completion: { (success) in
                            print("Success")
                        })
                    } else {
                        self.generateShareLink(groupId: groupId!, uid: uid, completion: { (dynamicShareLink) in
                            if dynamicShareLink != "" {
                                FirebaseManager.global.sendDynamicLinkInvite(dynamicLinkId: dynamicShareLink, groupId: groupId!, invitedByUid: uid)
                                print("Could not send to contact", member.contact)
                            }
                            
                        })
                        
                    }
                }
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    private func createdGroupSuccess() {
        
        let success = SuccessCreateGroupController()
        success.isFromWalkthrough = isSkipEnabled
        navigationController?.pushViewController(success, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friends = globalSelectedMembers
    }
    
    @objc func addPeopleClicked() {
        navigationController?.pushViewController(AddMemberTableController(), animated: true)
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
        } else if currentSection == CreateGroupController.foggyFriendCells {
            return friends.count
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
        }  else if currentSection == CreateGroupController.foggyFriendCells {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupFoggyFriendCell.id, for: indexPath) as! CreateGroupFoggyFriendCell
            cell.member = friends[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupNameCell.id, for: indexPath)
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
        } else if currentSection == CreateGroupController.foggyFriendCells {
            return CGSize(width: view.frame.width, height: 60)
        }
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func generateShareLink(groupId: String, uid: String, completion: @escaping (String)->()) {
        let link = URL(string: "https://foggyglassesnews.page.link/?invitedByIdGroupId=\(uid + "-" + groupId)")
        guard let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://foggyglassesnews.page.link") else {
            completion("")
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
            if let path = shortURL?.lastPathComponent {
                print("Dynamic Id", path)
                completion(path)
            } else {
                completion("")
            }
            
        }
    }
}



