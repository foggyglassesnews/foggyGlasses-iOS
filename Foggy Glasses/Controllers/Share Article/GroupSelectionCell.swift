//
//  GroupSelectionCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class GroupSelectionCell: SelectionCell {
    static let id = "Group Selection Cell Id"
    var group: FoggyGroup? {
        didSet{
            titleLabel.text = group?.name
        }
    }
    var friend: FoggyUser? {
        didSet {
            titleLabel.text = friend?.name
        }
    }
    var titleLabel = UILabel()
    override func create() {
        backgroundColor = .white
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 66, width: 0, height: 0)
    }
}
