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

class CreateGroupController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate  {
    
    static let createGroupHeaderStr = "Create Group Header"
    static let groupNameStr = "Group Name"
    static let foggyFriendCells = "Foggy Friends Cells"
    static let addPeopleCell = "Add People To Group Cell"
    
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
    
    override func viewDidLoad() {
        globalSearchMembers = []
        globalSelectedMembers = []
        
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
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationController?.view.backgroundColor = .feedBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(generateGroup))
    }
    
    @objc func generateGroup() {
        guard let link = URL(string: "https://www.example.com/my-page") else { return }
        let dynamicLinksDomainURIPrefix = "https://example.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.foggyglassesnew.fg")
//        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.android")
        
        guard let longDynamicLink = linkBuilder?.url else { return }
        print("The long URL is: \(longDynamicLink)")
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
    
    
}



