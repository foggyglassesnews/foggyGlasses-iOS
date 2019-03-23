//
//  GroupSettingsController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class GroupSettingsController: UICollectionViewController {
    var group: FoggyGroup? {
        didSet {
            guard let group = group else { return }
            title = group.name + " Settings"
        }
    }
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        collectionView.backgroundColor = .red
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
