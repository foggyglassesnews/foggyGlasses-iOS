//
//  GroupSettingsController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class GroupSettingsController: UICollectionViewController {
    var selectedCategories:[String] = ["Trending"]
    var selectedFrequency:Int = 3
    
    var group: FoggyGroup? {
        didSet {
            guard let group = group else { return }
            title = group.name
            
        }
    }
    
    
    enum GroupSettingsSections {
        case notificationHeader
        case notificationSection
        case curatedHeader
        case curatedCategorySection
        case curatedFrequencySection
        case curatedSettings
        case membersHeader
        case membersSection
        case leaveGroupSection
    }
    
    var sections: [GroupSettingsSections] = [.notificationHeader, .notificationSection,  .curatedHeader,  .curatedCategorySection, .curatedFrequencySection, .curatedSettings, .membersHeader, .membersSection, .leaveGroupSection]
    
    //popup menu to edit curation settings
    let SettingsPopup: SettingPopUpView = {
        let view = SettingPopUpView(frame: CGRect(x:0, y:100, width: (UIScreen.main.bounds.width ) , height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //blur view for rendering behind popUp
    let blurView: UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0.9
        blurEffectView.isHidden = true
        return blurEffectView
    }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        collectionView.backgroundColor = .feedBackground
        collectionView.register(SettingsHeaderCell.self, forCellWithReuseIdentifier: SettingsHeaderCell.id)
        collectionView.register(SettingsSwitchCell.self, forCellWithReuseIdentifier: SettingsSwitchCell.id)
        collectionView.register(SettingsTextCell.self, forCellWithReuseIdentifier: SettingsTextCell.id)
        collectionView.register(SettingsChangeCell.self, forCellWithReuseIdentifier: SettingsChangeCell.id)
        collectionView.register(CreateGroupFoggyFriendCell.self, forCellWithReuseIdentifier: CreateGroupFoggyFriendCell.id)
        collectionView.register(SettingsLogoutCell.self, forCellWithReuseIdentifier: SettingsLogoutCell.id)
        collectionView.alwaysBounceVertical = true
        
        self.view.addSubview(blurView)
        self.view.addSubview(SettingsPopup)
        SettingsPopup.delegate = self
        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo:self.view.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo:self.view.centerYAnchor),
            blurView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            SettingsPopup.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            SettingsPopup.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            SettingsPopup.widthAnchor.constraint(equalTo: self.view.widthAnchor , multiplier:0.85),
            ])
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
        
        //update current curation settings
        FirebaseManager.global.getGroupCurationSettings(groupId: group?.id ?? "", completion: { categories,frequencies in
//            print("okeyDokey")
            if categories ?? [] == [] {
                self.selectedCategories = ["Trending"]
            }
            else {
                self.selectedCategories = categories ?? []
            }
            self.selectedFrequency = frequencies ?? 3
            self.SettingsPopup.loadPreferences(preCategories: self.selectedCategories, preFrequency: self.selectedFrequency)
            self.collectionView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    override func viewDidLoad() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
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
    
    //show blur that displays behind popup view
    func showBlur (){
        self.blurView.alpha = 0
        self.blurView.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.blurView.alpha = 1
        })
        
    }
    //hide popup blur view
    func hideBlur (){
        UIView.animate(withDuration: 0.1, animations: {
            self.blurView.alpha = 0
        },completion: { _ in
            self.blurView.isHidden = true
        })
    }
}

extension GroupSettingsController: UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        switch currentSection {
        case .notificationHeader, .membersHeader, .leaveGroupSection, .curatedHeader, .curatedCategorySection, .curatedFrequencySection, .curatedSettings:
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
                //must set group before type
                cell.group = group
                cell.type = .newArticle
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsSwitchCell.id, for: indexPath) as! SettingsSwitchCell
                //Must set group before type
                cell.group = group
                cell.type = .newComment
                return cell
            }
        case .curatedHeader:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            cell.text = "Curated Article Settings"
            return cell
        case .curatedCategorySection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsTextCell.id, for: indexPath) as! SettingsTextCell
            cell.titleText = "Article Categories:"
            cell.subText = selectedCategories.joined(separator: ", ")
            cell.lines = 2
            return cell
        case .curatedFrequencySection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsTextCell.id, for: indexPath) as! SettingsTextCell
            cell.titleText = "Daily Curated Articles: " + String(selectedFrequency)
            cell.subText = ""
            cell.lines = 1
            return cell
        case .curatedSettings:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsChangeCell.id, for: indexPath) as! SettingsChangeCell
            cell.delegate = self
            let userID = FirebaseManager.global.foggyUser?.uid
            let adminID = group?.adminId ?? "error"
            
            if userID == adminID {
                cell.allowChange = true
            }
            
            return cell
        case .membersHeader:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsHeaderCell.id, for: indexPath) as! SettingsHeaderCell
            cell.text = "Group Members"
            return cell
        case .membersSection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateGroupFoggyFriendCell.id, for: indexPath) as! CreateGroupFoggyFriendCell
            let uid = group?.membersStringArray[indexPath.row] ?? ""
            cell.uid = uid
            let adminID = group?.adminId ?? "error"
            if uid == adminID{
                cell.additionalText.text = "(Admin)"
            }
            else {
                cell.additionalText.text = ""
            }
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
        case .notificationHeader, .membersHeader, .curatedHeader:
            return CGSize(width: view.frame.width, height: SettingsHeaderCell.height)
        case .notificationSection:
            return CGSize(width: view.frame.width, height: SettingsSwitchCell.height)
        case .membersSection, .curatedCategorySection, .curatedFrequencySection, .curatedSettings:
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

extension GroupSettingsController: SettingsPopupDelegate {
    func closeCancel(){
        hideBlur()
    }
    func closeSave(sentCategories:[String] = [], sentFrequency:Int = 3){
        hideBlur()
        if sentCategories.count > 0{
            selectedCategories = sentCategories
        }
        else {
            selectedCategories = ["Trending"]
        }
        selectedFrequency = sentFrequency
        collectionView.reloadData()
        FirebaseManager.global.setGroupCurationSettings(groupId: group?.id ?? "", curationCategories: self.selectedCategories, curationFrequency: self.selectedFrequency)
    }
}

extension GroupSettingsController: SettingsChangeDelegate{
    func changeSettings() {
        showBlur()
        SettingsPopup.show()
    }
}
