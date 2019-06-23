//
//  GroupSelectionController.swift
//  Post To Groups
//
//  Created by Ryan Temple on 6/20/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Social
import MobileCoreServices
import Firebase

class SharingViewController: UIViewController {
    
    var isLoading = false
    var url: URL? {
        didSet {
            guard let text = url?.absoluteString else { return }
            if text == "" {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                urlLoad.text = text
            }
        }
    }
    
    ///Dictionary that stores [GroupId: Name], used for looking up name for specific group id
    var userGroups = [String: String]() {
        didSet {
            tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    ///Dictionary that stores [GroupId:[UserId]], used for looking up group userIds from GroupId
    var groupUsers = [String: [String]]()
    ///Array of selected Group Ids
    var selectedGroups = [String]()
    ///Bool determining if we should save article too
    var saveArticle = true
    
    let label = UILabel()
    let sendLabel = UILabel()
    let urlLoad = LoadingArticleView()
    
    var mySavedArticlesSection = 0
    
    lazy var tableView:UITableView = {
        let t = UITableView(frame: self.view.frame)
        t.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        t.layer.cornerRadius = 16
        t.dataSource = self
        t.delegate = self
        t.allowsMultipleSelection = true
        t.backgroundColor = .clear
        t.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Create Group Header")
        t.register(ShareSelectTableViewCell.self, forCellReuseIdentifier: ShareSelectTableViewCell.id)
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .feedBackground
        
        if let app = FirebaseApp.app() {
            
        } else {
            FirebaseApp.configure()
        }
        
        
        checkUserStatus()
        setupUI()
        
        view.addSubview(label)
        label.text = "Article URL"
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 30)
        
        view.addSubview(urlLoad)
        urlLoad.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 38)
        
        view.addSubview(sendLabel)
        sendLabel.text = "Send Article to..."
        sendLabel.anchor(top: urlLoad.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 30)
        
        view.addSubview(tableView)
        tableView.anchor(top: sendLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
    }
    
    private func setupUI() {
        configNavigationBar()
        let imageView = UIImageView(image: UIImage(named: "Side Logo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navigationController?.navigationBar.topItem?.titleView = imageView
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendArticle))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeExtension))
    }
    
    var sent = false
    @objc func sendArticle() {
        if sent {
            return
        }
        sent = true
        showLoading()
        selectedGroups.removeAll()
        if let idxPaths = tableView.indexPathsForSelectedRows {
            for i in idxPaths {
                print("SELECTED", i)
                if i.section == mySavedArticlesSection {
                    saveArticle = true
                } else {
                    for (idx, g) in userGroups.enumerated() {
                        if i.row == idx {
                            selectedGroups.append(g.key)
                        }
                    }
                }
            }
        }
        print("Selected Groups", selectedGroups)
        
        FirebaseManager.global.getArticleData(link: self.url?.absoluteString) { (response) in
            guard let response = response, let uid = Auth.auth().currentUser?.uid else {
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                return
            }
            let articleData = FirebaseManager.global.convertResponseToFirebaseData(articleText: nil, response: response, url: self.url?.absoluteString ?? "")
            let article = Article(id: "localArticle", data: articleData)
            
            var generatedGroups = [FoggyGroup]()
            for i in self.selectedGroups {
                let members = self.groupUsers[i] ?? []
                let g = FoggyGroup(id: i, data: ["members":members])
                generatedGroups.append(g)
            }
            
            print("Genereated Groups", generatedGroups.count)
            if self.saveArticle {
                FirebaseManager.global.uploadArticle(article: article) { (success, aid) in
                    if success {
                        FirebaseManager.global.saveArticle(uid: uid, articleId: aid!) { (success) in
                            if generatedGroups.isEmpty {
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            }
                        }
                    }
                }
            }
            
            if !generatedGroups.isEmpty {
                FirebaseManager.global.sendArticleToGroups(article: article, groups: generatedGroups, comment: nil) { (success, articleId) in
                    if success {
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    } else {
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func showLoading() {
        let loaderView = UIView()
        loaderView.backgroundColor = .feedBackground
        loaderView.alpha = 0.5
        view.addSubview(loaderView)
        loaderView.pin(in: view)
        let loading = UIActivityIndicatorView()
        loading.color = .black
        loading.startAnimating()
        view.addSubview(loading)
        loading.withSize(width: 50, height: 50)
        loading.center(in: view)
    }
    
    @objc func closeExtension(){
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    ///Gets current user, check shared group for UID, if it matches Auth.currentUser then get Groups
    ///If UID != Auth.currentUser go to keychain, get credentials for UID, reautheticate with Fierbase ****
    ///Reautheticate with firebase not implemented since it seems Firebase is storing auth token in keychain already
    private func checkUserStatus() {
        let shared = UserDefaults.init(suiteName: sharedGroup)
        ///Get UID from shared group, if none then they signed out
        guard let sharedFirebaseUid = UserDefaults.init(suiteName: sharedGroup)?.string(forKey: "Firebase User Id") else {
            print("No shared user Id, signing out and closing")
            do {
                try? Auth.auth().signOut()
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
            return
        }
        print("SharedId", sharedFirebaseUid)
        
        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            print(uid)
            if sharedFirebaseUid != uid {
                print("Not the same signing out and back in")
                do {
                    try? Auth.auth().signOut()
                    self.signInGetGroups(sharedFirebaseUid: sharedFirebaseUid)
                }
            } else {
                self.getUserGroups(uid: uid)
                self.getGroupUser(uid: uid)
            }
        }
        else {
            signInGetGroups(sharedFirebaseUid: sharedFirebaseUid)
        }
    }
    
    func getUserGroups(uid: String) {
        let shared = UserDefaults.init(suiteName: sharedGroup)
        if let groupNames = shared?.dictionary(forKey: "GroupNames-"+uid) as? [String: String] {
            print("Group Names Unsorted:", groupNames)
            let sorted = groupNames.sorted { (dict1, dict2) -> Bool in
                return dict1.value < dict2.value
            }
            print("Group Names Sorted:", sorted)
            var sortedDictArray = [String: String]()
            for dict in sorted {
                sortedDictArray[dict.key] = dict.value
            }
            self.userGroups = sortedDictArray
        }
    }
    
    func getGroupUser(uid: String) {
        let shared = UserDefaults.init(suiteName: sharedGroup)
        if let groupUsers = shared?.dictionary(forKey: "GroupUsers-"+uid) as? [String: [String]] {
            self.groupUsers = groupUsers
        }
    }
    
    func signInGetGroups(sharedFirebaseUid: String) {
        let shared = UserDefaults.init(suiteName: sharedGroup)
        self.getUserGroups(uid: sharedFirebaseUid)
        self.getGroupUser(uid: sharedFirebaseUid)
        
        if let facebook = shared?.bool(forKey: "Facebook-"+sharedFirebaseUid) {
            print("Got Facebook", facebook)
            if facebook {
                if let token = shared?.string(forKey: "FBToken-"+sharedFirebaseUid) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: token)
                    Auth.auth().signInAndRetrieveData(with: credential) { (result, err) in
                        if let err = err {
                            print("err", err)
                            return
                        }
                        
                        print("Successfully signed in facebook ")
                        
                    }
                }
            }
            else {
                if let email = shared?.string(forKey: "Email-"+sharedFirebaseUid), let pass = shared?.string(forKey: "Pass-"+sharedFirebaseUid) {
                    print("Got email and pword", email, pass)
                    Auth.auth().signIn(withEmail: email, password: pass) { (result, err) in
                        if let err = err {
                            print("Err", err)
                            return
                        }
                        print("Successfully signed in with email")
                    }
                }
            }
        }
        
    }
}

extension SharingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == mySavedArticlesSection {
            return 1
        }
        return userGroups.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == mySavedArticlesSection {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Create Group Header") as! UITableViewHeaderFooterView
        cell.textLabel?.text = "Create New Group"
        cell.layer.cornerRadius = 10
        let createNewGroupButton = UIButton()
        createNewGroupButton.setTitle("Add +", for: .normal)
        createNewGroupButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        createNewGroupButton.backgroundColor = .foggyBlue
        createNewGroupButton.setTitleColor(.black, for: .normal)
        createNewGroupButton.clipsToBounds = true
        createNewGroupButton.layer.cornerRadius = 10
        createNewGroupButton.addTarget(self, action: #selector(openFG), for: .touchUpInside)
        cell.addSubview(createNewGroupButton)
        createNewGroupButton.anchor(top: cell.topAnchor, left: nil, bottom: cell.bottomAnchor, right: cell.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 16, width: 50, height: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == mySavedArticlesSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: ShareSelectTableViewCell.id, for: indexPath) as! ShareSelectTableViewCell
            cell.member = "My Saved Articles"
            if saveArticle {
                cell.isSelected = true
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ShareSelectTableViewCell.id, for: indexPath) as! ShareSelectTableViewCell
        let row = indexPath.row
        for (i, g) in userGroups.enumerated() {
            if row == i {
                cell.member = g.value
            }
        }
        
        return cell
    }
    
    @objc func openFG() {
        //        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        let selectedUrl = self.url ?? URL(string: "")!
        if let url = URL(string: "createGroup://createGroup?link=\(selectedUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"){
            if openURL(url) {
                print("Opened URL")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                print("Error opening URL")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                //                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil  )
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
