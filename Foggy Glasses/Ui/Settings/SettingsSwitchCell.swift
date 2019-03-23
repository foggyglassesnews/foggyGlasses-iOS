//
//  SettingsSwitchCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class SettingsSwitchCell: UICollectionViewCell {
    static let height: CGFloat = 44
    static let id = "Settings Switch cell Id"
    
    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.textColor = .black//UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return view
    }()
    
    private let button: UISwitch = {
        let view = UISwitch()
//        view.thumbTintColor = .foggyBlue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(button)
        button.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 7, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 51, height: 31)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: button.leftAnchor, paddingTop: 12, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        let bottomDiv = UIView()
        bottomDiv.backgroundColor = .lightGray
        bottomDiv.alpha = 0.5
        addSubview(bottomDiv)
        bottomDiv.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
