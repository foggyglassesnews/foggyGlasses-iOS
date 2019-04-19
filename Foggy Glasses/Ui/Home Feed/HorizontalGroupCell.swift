//
//  HorizontalGroupCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class HorizontalGroupCell: UICollectionViewCell {
    static let id = "horizontal Group Cell Id"
    private let image = UIImageView()
    private let title = UILabel()
    var postId: String?
    var group: FoggyGroup! {
        didSet {
            
            if group.friendGroup {
//                image.image = UIImage(named:"Person Icon")
                group.getFriendName { (text) in
                    self.title.text = text
                }
            } else {
                title.text = group.name
            }
            
            if NotificationManager.shared.hasNotification(groupId: group.id, postId: postId ?? "") {
                backgroundColor = .foggyBlue
            } else {
                backgroundColor = .white
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        layer.borderWidth = 0.3
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 8
        clipsToBounds = true
        contentMode = .scaleAspectFit
        
//        addSubview(image)
//        image.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 0, width: 30, height: 0)
//        image.contentMode = .scaleAspectFit
//        image.image = UIImage(named:"Group Icon Foggy")
        
        addSubview(title)
        title.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.text = "Foggy Group"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
