//
//  SettingsVersionCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class SettingsVersionCell: UICollectionViewCell {
    static let height: CGFloat = 44
    static let id = "Settings Version cell Id"
    
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.0"
        titleLabel.text = "Version: " + appVersion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
