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

class CreateGroupController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate  {

    static let createGroupHeaderStr = "Create Group Header"
    static let groupNameStr = "Group Name"
    static let searchBarStr = "Search Bar"
    static let foggyFriendsHeader = "Foggy Friends Header"
    static let foggyFriendCells = "Foggy Friends Cells"
    static let contactsHeader = "Contacts Header"
    static let contactsCell = "Contacts Cells"
    
    var sections = [CreateGroupController.createGroupHeaderStr,
                    CreateGroupController.groupNameStr,
                    CreateGroupController.searchBarStr,
                    CreateGroupController.foggyFriendsHeader,
                    CreateGroupController.foggyFriendCells,
                    CreateGroupController.contactsHeader,
                    CreateGroupController.contactsCell]
    
    
    ///Datasource for contacts
    var contacts = [CNContact]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    ///Datasource for friends
    var friends = [FoggyUser]()
    
    override func viewDidLoad() {
        collectionView.backgroundColor = .feedBackground
        
        collectionView.register(CreateGroupHeaderCell.self, forCellWithReuseIdentifier: CreateGroupHeaderCell.id)
        collectionView.register(CreateGroupNameCell.self, forCellWithReuseIdentifier: CreateGroupNameCell.id)
        collectionView.register(CreateGroupSearchCell.self, forCellWithReuseIdentifier: CreateGroupSearchCell.id)
        collectionView.register(CreateGroupContactCell.self, forCellWithReuseIdentifier: CreateGroupContactCell.id)
        collectionView.register(FoggyHeaderTextCell.self, forCellWithReuseIdentifier: FoggyHeaderTextCell.id)
        
        collectionView.keyboardDismissMode = .onDrag
        
        friends.append(FoggyUser())
        fetchContacts()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(resignAllKeyboards))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(tap)
    }
    
    @objc func resignAllKeyboards() {
        resignFirstResponder()
    }
    
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
                if contact1.givenName < contact2.familyName {
                    return true
                }
                return false
            }
            self.contacts = contacts
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
        } else if currentSection == CreateGroupController.createGroupHeaderStr{
            return 1
        } else if currentSection == CreateGroupController.foggyFriendsHeader{
            return 1
        } else if currentSection == CreateGroupController.foggyFriendCells {
            return friends.count
        } else if currentSection == CreateGroupController.contactsHeader{
            return 1
        } else if currentSection == CreateGroupController.contactsCell {
            return contacts.count
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
        } else if currentSection == CreateGroupController.searchBarStr {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupSearchCell.id, for: indexPath)
            return cell
        } else if currentSection == CreateGroupController.foggyFriendsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoggyHeaderTextCell.id, for: indexPath) as! FoggyHeaderTextCell
            cell.titleText = "Foggy Glasses Friends"
            return cell
        } else if currentSection == CreateGroupController.foggyFriendCells {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupContactCell.id, for: indexPath) as! CreateGroupContactCell
            return cell
        } else if currentSection == CreateGroupController.contactsHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoggyHeaderTextCell.id, for: indexPath) as! FoggyHeaderTextCell
            cell.titleText = "Phone Contacts"
            return cell
        } else if currentSection == CreateGroupController.contactsCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupContactCell.id, for: indexPath) as! CreateGroupContactCell
            cell.contact = contacts[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupContactCell.id, for: indexPath) as! CreateGroupContactCell
        cell.contact = contacts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == CreateGroupController.createGroupHeaderStr {
            return CGSize(width: view.frame.width, height: 168)
        } else if currentSection == CreateGroupController.groupNameStr {
            return CGSize(width: view.frame.width, height: 69)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let currentSection = sections[section]
        if currentSection == CreateGroupController.contactsCell || currentSection == CreateGroupController.foggyFriendCells {
            print("Selected this cell!")
            openSMSController()
        }
    }
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
