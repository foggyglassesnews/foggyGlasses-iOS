//
//  ArticleImageView.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/12/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ArticleImageView: UIButton {
    
    let container = UIView()
    let label = UILabel()
    let share = UIImageView(image: UIImage(named: "Article Share Arrow")?.withRenderingMode(.alwaysOriginal))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        
        addSubview(container)
        container.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        container.backgroundColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0)
        
        container.addSubview(share)
        share.anchor(top: container.topAnchor, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 8, width: 10, height: 0)
        share.contentMode = .scaleAspectFit
        
        container.addSubview(label)
        label.text = ""
        label.anchor(top: container.topAnchor, left: leftAnchor, bottom: container.bottomAnchor, right: share.leftAnchor, paddingTop: 2, paddingLeft: 8, paddingBottom: 2, paddingRight: 8, width: 0, height: 0)
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = false
    }
    
    func config(title: String?, url: URL?) {
        label.text = title ?? url?.absoluteString
        sd_setImage(with: url, for: .normal, completed: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
