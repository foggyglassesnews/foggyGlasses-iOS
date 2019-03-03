//
//  SavedArticleSelectCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class SavedArticleSelectCell: UICollectionViewCell {
    static let id = "Saved Article Select Cell Id"
    
    var savedButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Saved Articles Button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(savedButton)
        savedButton.withSize(width: 298, height: 31)
        savedButton.center(in: self)
        savedButton.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
