//
//  SettingsHeaderCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class SettingsHeaderCell: UICollectionViewCell {
    static let height: CGFloat = 38
    static let id = "SettingsHeaderCell Id"
    
    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 18)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
