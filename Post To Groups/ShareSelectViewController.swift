//
//  ShareSelectViewController.swift
//  Post To Groups
//
//  Created by Ryan Temple on 3/8/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

protocol GroupSelectProtocol {
    func selected(groups: [String])
    func selectedNewGroup()
}

class ShareSelectViewController: UIViewController {
    
    var names = [String]()
    var ids = [String]()
    var delegate: GroupSelectProtocol?
    
    var mySavedArticlesSection = 0
    
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
        var groupIdsReturn = [String]()
        if let idxPaths = tableView.indexPathsForSelectedRows {
            for i in idxPaths {
                if i.section == mySavedArticlesSection {
                    
                } else {
                    groupIdsReturn.append(ids[i.row])
                }
                
            }
        }
        
        delegate?.selected(groups: groupIdsReturn)
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
        return names.count
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
        cell.member = names[indexPath.row]
        return cell
    }
    
    @objc func selectedCreateGroup() {
        delegate?.selectedNewGroup()
    }
}
