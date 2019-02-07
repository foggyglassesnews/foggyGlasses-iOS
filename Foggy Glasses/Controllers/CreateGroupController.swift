//
//  CreateGroupController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class CreateGroupController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "Create Group"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        label.pin(in: view)
    }
}
