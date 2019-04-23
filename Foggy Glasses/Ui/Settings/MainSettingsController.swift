//
//  MainSettingsController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import StoreKit
import PopupDialog
import Contacts

class MainSettingsController: UICollectionViewController {
    
    enum SettingsSections {
        case notificationHeader
        case notificationSection
        case aboutHeader
        case aboutSection
        case accountHeader
        case accountSection
        case logout
        case delete
        case version
    }
    
    var sections: [SettingsSections] = [.notificationHeader, .notificationSection, .aboutHeader, .aboutSection, .accountHeader, .accountSection, .logout, .delete, .version]
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        collectionView.backgroundColor = .feedBackground
        collectionView.register(SettingsHeaderCell.self, forCellWithReuseIdentifier: SettingsHeaderCell.id)
        collectionView.register(SettingsSwitchCell.self, forCellWithReuseIdentifier: SettingsSwitchCell.id)
        collectionView.register(SettingsArrowCell.self, forCellWithReuseIdentifier: SettingsArrowCell.id)
        collectionView.register(CreateGroupFoggyFriendCell.self, forCellWithReuseIdentifier: CreateGroupFoggyFriendCell.id)
        collectionView.register(SettingsLogoutCell.self, forCellWithReuseIdentifier: SettingsLogoutCell.id)
        collectionView.register(SettingsDeleteCell.self, forCellWithReuseIdentifier: SettingsDeleteCell.id)
        collectionView.register(SettingsVersionCell.self, forCellWithReuseIdentifier: SettingsVersionCell.id)
        collectionView.alwaysBounceVertical = true
        title = "Settings"
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
    }
    
    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    ///Method called when selecting create new group
    @objc func createGroupFromQuickshareExtension() {
        //DeepLinkManager.shared.present(nav: self.navigationController, returnVC: nil)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

extension MainSettingsController: UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        switch currentSection {
        case .notificationHeader, .aboutHeader, .accountHeader, .logout, .delete, .version:
            return 1
        case .notificationSection:
            return 1
        case .aboutSection:
            return 3
        case .accountSection:
            return 1
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsSwitchCell.id, for: indexPath) as! SettingsSwitchCell
            cell.type = .groupInvite
//            cell.text = "New Group Invitations"
//            cell.button.isOn = FoggyUserPreferences.shared.groupInvites
            return cell
        case .aboutHeader:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            cell.text = "About Us"
            return cell
        case .aboutSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsArrowCell.id, for: indexPath) as! SettingsArrowCell
            if indexPath.row == 0 {
                cell.text = "Terms and Conditions"
            } else if indexPath.row == 1 {
                cell.text = "Send Feedback"
            } else {
                cell.text = "Rate Us"
            }
            return cell
        case .accountHeader:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            cell.text = "Account Details"
            return cell
        case .accountSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupFoggyFriendCell.id, for: indexPath) as! CreateGroupFoggyFriendCell
            var member = SearchMember()
            member.foggyUser = FirebaseManager.global.foggyUser
            cell.member = member
            return cell
        case .logout:
            return collectionView.dequeueReusableCell(withReuseIdentifier: SettingsLogoutCell.id, for: indexPath)
        case .delete:
            return collectionView.dequeueReusableCell(withReuseIdentifier: SettingsDeleteCell.id, for: indexPath)
        case .version:
            return collectionView.dequeueReusableCell(withReuseIdentifier: SettingsVersionCell.id, for: indexPath)
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentSection = sections[indexPath.section]
        switch currentSection {
        case .notificationHeader, .aboutHeader, .accountHeader:
            return CGSize(width: view.frame.width, height: SettingsHeaderCell.height)
        case .notificationSection:
            return CGSize(width: view.frame.width, height: SettingsSwitchCell.height)
        case .aboutSection:
            return CGSize(width: view.frame.width, height: SettingsArrowCell.height)
        case .accountSection:
            return CGSize(width: view.frame.width, height: 60)
        case .logout:
            return CGSize(width: view.frame.width, height: SettingsLogoutCell.height)
        case .delete:
            return CGSize(width: view.frame.width, height: SettingsDeleteCell.height)
        case .version:
            return CGSize(width: view.frame.width, height: SettingsVersionCell.height)
        default:
            return CGSize(width: view.frame.width, height: SettingsHeaderCell.height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentSectoin = sections[indexPath.section]
        if currentSectoin == .aboutSection {
            let row = indexPath.row
            if row == 1 {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.setToRecipients(["foggyglassesnews@gmail.com"])
                composeVC.setSubject("Foggy Glasses Feedback")
//                composeVC.setMessageBody("Message content.", isHTML: false)
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            } else if row == 2 {
                SKStoreReviewController.requestReview()
            } else {
                
                let popup = PopupDialog(title: "Terms and Conditions", message: "This feature has not been implemented yet :)")
                present(popup, animated: true, completion: nil)
                
            }
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension MainSettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
