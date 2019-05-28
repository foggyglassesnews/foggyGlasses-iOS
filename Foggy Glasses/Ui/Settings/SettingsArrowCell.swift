//
//  SettingsArrowCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class SettingsArrowCell: UICollectionViewCell {
    static let height: CGFloat = 44
    static let id = "Settings Arrow cell Id"
    
    var text: String? {
        didSet {
            titleLabel.text = text
        }
    }
    
    private let notification = UIView()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.textColor = .black//UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return view
    }()
    
    private let button: UIButton = {
        let view = UIButton(type: .system)
        view.setImage(UIImage(named: "Right Detail")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(button)
        button.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 7, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 51, height: 31)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: button.leftAnchor, paddingTop: 12, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        let bottomDiv = UIView()
        bottomDiv.backgroundColor = .lightGray
        bottomDiv.alpha = 0.5
        addSubview(bottomDiv)
        bottomDiv.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0.5)
        
    }
    
    func addNotification() {
        addSubview(notification)
        notification.isHidden = false
        notification.translatesAutoresizingMaskIntoConstraints = false
        notification.withSize(width: 20, height: 20)
        notification.layer.cornerRadius = 10
        notification.clipsToBounds = true
        notification.backgroundColor = .red
        notification.centerVertically(in: self)
        notification.rightAnchor.constraint(equalTo: button.leftAnchor, constant: 8).isActive = true
    }
    
    func removeNotification(){
        notification.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
