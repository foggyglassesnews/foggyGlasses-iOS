//
//  SettingsChangeCell.swift
//  Foggy Glasses
//
//  Created by Alec Barton on 6/26/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import PopupDialog

protocol SettingsChangeDelegate: AnyObject {
    func changeSettings()
}


//cell to edit curation settings
//determines if user is admin or not
class SettingsChangeCell: UICollectionViewCell {
    var delegate: SettingsChangeDelegate?
    
    static let height: CGFloat = 82
    static let id = "Settings Change cell Id"
    var group:FoggyGroup?
    
    //bool determines if user is allowed to change settings
    var allowChange = false {
        didSet {
            if allowChange {
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .foggyBlue
                button.setTitle("Edit Curation Settings", for: .normal)
                button.addTarget(self, action: #selector(settingChangeClicked), for: .touchUpInside)
            }
        }
    }
    
    private lazy var button: UIButton = {
        //user cannot edit settings by default
        let view = UIButton(type: .system)
        view.backgroundColor = UIColor(red: 145 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1)
        view.setTitleColor(.black, for: .normal)
        view.setTitle("🔒 only an admin can edit curation settings", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        view.addTarget(self, action: #selector(settingChangeClicked), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func settingChangeClicked() {
        if allowChange{
            delegate?.changeSettings()
            print("admin")
        }
        else {
            print("notAdmin")
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

