//
//  GroupSettingsController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class GroupSettingsController: UICollectionViewController {
    var group: FoggyGroup? {
        didSet {
            guard let group = group else { return }
            title = group.name + " Settings"
        }
    }
    
    enum GroupSettingsSections {
        case notificationHeader
        case notificationSection
        case membersHeader
        case membersSection
        case leaveGroupSection
    }
    
    var sections: [GroupSettingsSections] = [.notificationHeader, .notificationSection, .membersHeader, .membersSection, .leaveGroupSection]
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        collectionView.backgroundColor = .feedBackground
        collectionView.register(SettingsHeaderCell.self, forCellWithReuseIdentifier: SettingsHeaderCell.id)
        collectionView.register(SettingsSwitchCell.self, forCellWithReuseIdentifier: SettingsSwitchCell.id)
        collectionView.register(CreateGroupFoggyFriendCell.self, forCellWithReuseIdentifier: CreateGroupFoggyFriendCell.id)
        collectionView.register(SettingsLogoutCell.self, forCellWithReuseIdentifier: SettingsLogoutCell.id)
        collectionView.alwaysBounceVertical = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

extension GroupSettingsController: UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        switch currentSection {
        case .notificationHeader, .membersHeader, .leaveGroupSection:
            return 1
        case .notificationSection:
            return 2
        case .membersSection:
            return group?.membersStringArray.count ?? 0
        default:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentSection = sections[indexPath.section]
        switch currentSection {
        case .notificationHeader:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            cell.text = "Notification Settings"
            return cell
        case .notificationSection:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsSwitchCell.id, for: indexPath) as! SettingsSwitchCell
                cell.text = "New Article"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsSwitchCell.id, for: indexPath) as! SettingsSwitchCell
                cell.text = "New Comment"
                return cell
            }
            
        case .membersHeader:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            cell.text = "Group Members"
            return cell
        case .membersSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupFoggyFriendCell.id, for: indexPath) as! CreateGroupFoggyFriendCell
            let uid = group?.membersStringArray[indexPath.row] ?? ""
            cell.uid = uid
            return cell
        case .leaveGroupSection:
            let logout = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsLogoutCell.id, for: indexPath) as! SettingsLogoutCell
            logout.leaveGroup = true
            logout.group = group
            return logout
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentSection = sections[indexPath.section]
        switch currentSection {
        case .notificationHeader, .membersHeader:
            return CGSize(width: view.frame.width, height: SettingsHeaderCell.height)
        case .notificationSection:
            return CGSize(width: view.frame.width, height: SettingsSwitchCell.height)
        case .membersSection:
            return CGSize(width: view.frame.width, height: 60)
        case .leaveGroupSection:
            return CGSize(width: view.frame.width, height: SettingsLogoutCell.height)
        default:
            return CGSize(width: view.frame.width, height: SettingsHeaderCell.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
