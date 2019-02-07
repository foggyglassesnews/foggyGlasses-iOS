//
//  ArticleController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class ArticleController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        let label = UILabel()
        label.text = "Article View"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        label.pin(in: view)
    }
}
