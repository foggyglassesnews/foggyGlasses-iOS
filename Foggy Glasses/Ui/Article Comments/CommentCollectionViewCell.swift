//
//  CommentCollectionViewCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/12/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CommentCollectionViewCell: UICollectionViewCell {
    static let id = "Comment Collectin View Cell Id"
    
    var comment: FoggyComment! {
        didSet {
            FirebaseManager.global.getFoggyUser(uid: comment.uid) { (user) in
                if let uname = user?.username {
                    if Auth.auth().currentUser?.uid == user?.uid {
                        self.configSharedBy(text: "You")
                    } else {
                        self.configSharedBy(text: uname)
                    }
                }
            }
            commentTextView.text = comment.text
        }
    }
    
    private var headerLabel = UILabel()
    private var commentTextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(headerLabel)
        headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 14)
        
        addSubview(commentTextView)
        commentTextView.anchor(top: headerLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        commentTextView.isUserInteractionEnabled = false
    }
    
    private func configSharedBy(text: String) {
        let attributedText = NSMutableAttributedString()
        let timeAgo = self.comment.timestamp.twoLetterTimestamp()
        attributedText.append(NSAttributedString(string: text + " ∙ ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12, weight: .light)]))
        attributedText.append(NSAttributedString(string: timeAgo, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .light)]))
        self.headerLabel.attributedText = attributedText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
