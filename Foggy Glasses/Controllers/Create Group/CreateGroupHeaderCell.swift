//
//  CreateGroupHeaderCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/8/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class CreateGroupHeaderCell: UICollectionViewCell {
    static let id = "CreateGroupHeaderCellId"
    
    //MARK: UI Elements
    var headerImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "Create Group Header")
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerImage)
        headerImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
