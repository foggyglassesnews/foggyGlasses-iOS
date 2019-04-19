//
//  ShareSelectViewController.swift
//  Post To Groups
//
//  Created by Ryan Temple on 3/8/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

protocol GroupSelectProtocol {
    func selected(groups: [String], save: Bool)
    func selectedNewGroup()
}

class ShareSelectViewController: UIViewController {
    
    ///Dictionary of [GroupIds: Name]
    var groups = [String: String]()
    var names = [String]()
    var ids = [String]()
    var delegate: GroupSelectProtocol?
    
    var mySavedArticlesSection = 0
    
    var context: NSExtensionContext?
    var url: URL?
    
    lazy var tableView:UITableView = {
       let t = UITableView(frame: self.view.frame)
        t.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        t.dataSource = self
        t.delegate = self
        t.allowsMultipleSelection = true
        t.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Create Group Header")
        t.register(ShareSelectTableViewCell.self, forCellReuseIdentifier: ShareSelectTableViewCell.id)
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "My Groups"
        view.addSubview(tableView)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
    }
    
    @objc func doneClicked() {
        var returnGroups = [String]()
        var save = false
        if let idxPaths = tableView.indexPathsForSelectedRows {
            for i in idxPaths {
                if i.section == mySavedArticlesSection {
                    save = true
                } else {
                    for (idx, g) in groups.enumerated() {
                        if i.row == idx {
                            returnGroups.append(g.key)
                        }
                    }
                    
                }
                
            }
        }
        
        delegate?.selected(groups: returnGroups, save: save)
    }
}

extension ShareSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == mySavedArticlesSection {
            return 1
        }
        return groups.count
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
        let createNewGroupButton = UIButton()
        createNewGroupButton.setTitle("Add +", for: .normal)
        createNewGroupButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        createNewGroupButton.backgroundColor = .foggyBlue
        createNewGroupButton.setTitleColor(.black, for: .normal)
        createNewGroupButton.clipsToBounds = true
        createNewGroupButton.layer.cornerRadius = 10
        createNewGroupButton.addTarget(self, action: #selector(selectedCreateGroup), for: .touchUpInside)
        cell.addSubview(createNewGroupButton)
        createNewGroupButton.anchor(top: cell.topAnchor, left: nil, bottom: cell.bottomAnchor, right: cell.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 16, width: 50, height: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == mySavedArticlesSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: ShareSelectTableViewCell.id, for: indexPath) as! ShareSelectTableViewCell
            cell.member = "My Saved Articles"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ShareSelectTableViewCell.id, for: indexPath) as! ShareSelectTableViewCell
        let row = indexPath.row
        for (i, g) in groups.enumerated() {
            if row == i {
                cell.member = g.value
            }
        }
        
        return cell
    }
    
    @objc func selectedCreateGroup() {
        delegate?.selectedNewGroup()
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//        self.openFG()
    }
    func openFG() {
//        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        let selectedUrl = self.url ?? URL(string: "")!
        if let url = URL(string: "createGroup://createGroup?link=\(selectedUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"){
            if openURL(url) {
                print("Opened URL")
                self.context!.completeRequest(returningItems: [], completionHandler: nil)
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                //                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                print("Error opening URL")
                self.context!.completeRequest(returningItems: [], completionHandler: nil)
                //                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                
            }
        }
        self.context!.completeRequest(returningItems: [], completionHandler: nil)
        //        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
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
