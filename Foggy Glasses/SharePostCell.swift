//
//  SharePostCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SharePostCell: UICollectionViewCell{
    static let id = "SharePostCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
