//
//  SettingsSwitchCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseMessaging

class SettingsSwitchCell: UICollectionViewCell {
    static let height: CGFloat = 44
    static let id = "Settings Switch cell Id"
    
    enum CellType {
        case newComment, newArticle, groupInvite
    }
    
    var type: CellType? {
        didSet {
            guard let type = type else { return }
            switch type {
            case .groupInvite:
                titleLabel.text = "New Group Invitations"
                button.isOn = FoggyUserPreferences.shared.groupInvites
                break
            case .newArticle:
                titleLabel.text = "New Article"
                button.isOn = FoggyUserPreferences.shared.newArticles[group!.id] ?? true
                break
            case .newComment:
                titleLabel.text = "New Comment"
                button.isOn = FoggyUserPreferences.shared.newComment[group!.id] ?? true
                break
            default:
                break
            }
        }
    }
    
    var group: FoggyGroup?
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.textColor = .black//UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return view
    }()
    
    lazy var button: UISwitch = {
        let view = UISwitch()
//        view.thumbTintColor = .foggyBlue
        view.addTarget(self, action: #selector(flipSwitch), for: .valueChanged)
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
    
    @objc func flipSwitch() {
        guard let type = type, let uid = Auth.auth().currentUser?.uid else { return }
        switch type {
        case .newArticle:
            let topic = "feed-"+group!.id
            
            if button.isOn {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    print("Subscribed to topic", topic)
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                    print("Unsubscribed from topic", topic)
                }
            }
            FirebaseManager.global.setPreference(uid: uid, child: "sharedArticle", value: button.isOn, groupId: group!.id)
            break
        case .newComment:
            let topic = "comment-"+group!.id
            
            if button.isOn {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    print("Subscribed to topic", topic)
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                    print("Unsubscribed from topic", topic)
                }
            }
            FirebaseManager.global.setPreference(uid: uid, child: "newComment", value: button.isOn, groupId: group!.id)
            break
        case .groupInvite:
            let topic = "userPendingGroups-"+uid
            
            if button.isOn {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    print("Subscribed to topic", topic)
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                    print("Unsubscribed from topic", topic)
                }
            }
            FirebaseManager.global.setPreference(uid: uid, child: "groupInvites", value: button.isOn)
            break
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
