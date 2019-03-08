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
}

class ShareSelectViewController: UIViewController {
    
    var names = [String]()
    var ids = [String]()
    var delegate: GroupSelectProtocol?
    
    lazy var tableView:UITableView = {
       let t = UITableView(frame: self.view.frame)
        t.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        t.dataSource = self
        t.delegate = self
        t.allowsMultipleSelection = true
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
                groupIdsReturn.append(ids[i.row])
            }
        }
        
        delegate?.selected(groups: groupIdsReturn)
    }
}

extension ShareSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShareSelectTableViewCell.id, for: indexPath) as! ShareSelectTableViewCell
        cell.member = names[indexPath.row]
        return cell
    }
}
