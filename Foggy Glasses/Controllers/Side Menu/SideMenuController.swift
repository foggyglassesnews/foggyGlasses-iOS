//
//  SideMenuController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Contacts
import Firebase

class SideMenuController: UICollectionViewController {
    
    static let headerSection = "Header Section"
    static let pendingHeaderSection = "Pending Header Section"
    static let pendingGroupsSection = "Pending Groups Section"
    static let myGroupsHeader = "My Groups Header"
    static let groupsSection = "Groups Section"
    
    var sections = [SideMenuController.headerSection, SideMenuController.pendingHeaderSection, SideMenuController.pendingGroupsSection, SideMenuController.myGroupsHeader, SideMenuController.groupsSection]
    
    var pendingGroups = [FoggyGroup]()
    var groups = [FoggyGroup]()
    
    var delegate: SideMenuProtocol?
    
    //MARK: UI Elements
    var bg: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "Welcome BG")
        return v
    }()
    
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = true
        
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(SideMenuHeaderCell.self, forCellWithReuseIdentifier: SideMenuHeaderCell.id)
        collectionView.register(SideMenuTextCell.self, forCellWithReuseIdentifier: SideMenuTextCell.id)
        collectionView.register(SideMenuGroupCell.self, forCellWithReuseIdentifier: SideMenuGroupCell.id)
        
        //BG
        view.insertSubview(bg, belowSubview: collectionView)
        bg.pin(in: view)
        
        fetchMyGroups()
//        fetchPendingGroups()
    }
    
    func fetchPendingGroups() {
        pendingGroups = FoggyGroup.mockGroups()
        collectionView.reloadData()
    }
    
    func fetchMyGroups() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No UID for fetching group!")
            return
        }
        FirebaseManager.global.getGroups(uid: uid) { (g) in
            if let groups = g {
                self.groups = groups
                self.collectionView.reloadData()
            }
        }
//        groups = FoggyGroup.mockGroups()
//        collectionView.reloadData()
    }
    
}

extension SideMenuController: UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        if currentSection == SideMenuController.headerSection {
            return 1
        } else if currentSection == SideMenuController.pendingHeaderSection {
            return 1
        } else if currentSection == SideMenuController.pendingGroupsSection {
            return pendingGroups.count
        } else if currentSection == SideMenuController.myGroupsHeader {
            return 1
        } else if currentSection == SideMenuController.groupsSection {
            return groups.count
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == SideMenuController.headerSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuHeaderCell.id, for: indexPath) as! SideMenuHeaderCell
            cell.delegate = delegate
            return cell
        } else if currentSection == SideMenuController.pendingHeaderSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuTextCell.id, for: indexPath) as! SideMenuTextCell
            cell.text = "Pending Groups (\(pendingGroups.count))"
            return cell
        } else if currentSection == SideMenuController.pendingGroupsSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuGroupCell.id, for: indexPath) as! SideMenuGroupCell
            cell.group = pendingGroups[indexPath.row]
            return cell
        } else if currentSection == SideMenuController.myGroupsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuTextCell.id, for: indexPath) as! SideMenuTextCell
            cell.text = "My Groups (\(groups.count))"
            return cell
        } else if currentSection == SideMenuController.groupsSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuGroupCell.id, for: indexPath) as! SideMenuGroupCell
            cell.group = groups[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuHeaderCell.id, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == SideMenuController.headerSection {
            return CGSize(width: view.frame.width, height: 57 + 88)
        } else if currentSection == SideMenuController.pendingHeaderSection {
            return CGSize(width: view.frame.width, height: 50)
        } else if currentSection == SideMenuController.pendingGroupsSection {
            return CGSize(width: view.frame.width, height: 50)
        } else if currentSection == SideMenuController.myGroupsHeader {
            return CGSize(width: view.frame.width, height: 50)
        } else if currentSection == SideMenuController.groupsSection {
            return CGSize(width: view.frame.width, height: 50)
        }
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let section = indexPath.section
//        let currentSection = sections[section]
//        if currentSection == CreateGroupController.contactsCell || currentSection == CreateGroupController.foggyFriendCells {
//            print("Selected this cell!")
////            openSMSController()/
//        }
    }
}
