//
//  SelectionCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SelectionCell: UICollectionViewCell {
    
    let sideSelect: UIButton = {
       let v = UIButton()
        return v
    }()
    
    ///Used for highlighting text
    var formatting: [((Int), (Int))]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(sideSelect)
        sideSelect.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 25, height: 25)
        sideSelect.centerVertically(in: self)
        sideSelect.isUserInteractionEnabled = false
        sideSelect.setImage(UIImage(named: "Select Button U")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                sideSelect.setImage(UIImage(named: "Select Button H")?.withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                sideSelect.setImage(UIImage(named: "Select Button U")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
