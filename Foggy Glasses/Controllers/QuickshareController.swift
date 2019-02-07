//
//  QuickshareController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class QuickshareController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "Article Post"
//        navigationController?.navigationBar.prefersLargeTitles = true
        
        let label = UILabel()
        label.text = "Quickshare"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        label.pin(in: view)
    }
}
