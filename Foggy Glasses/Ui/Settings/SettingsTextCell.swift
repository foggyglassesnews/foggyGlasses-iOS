//
//  SettingsTextCell.swift
//  Foggy Glasses
//
//  Created by Alec Barton on 6/25/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

//displays information about group curation settings
//has two labels, a title and sub title
class SettingsTextCell: UICollectionViewCell {
    static let height: CGFloat = 70
    static let id = "Settings Text cell Id"
    
    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    var subText: String? {
        didSet {
            subtitleLabel.text = subText
        }
    }
    var lines: Int = 1{
        didSet{
            if lines == 1 {
                titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,  paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
            }
            else if lines == 2{
                titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,  paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
                subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,  paddingTop: 4, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
            }
        }
    }
    
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.textColor = .black//UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return view
    }()
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        view.textColor = .darkGray//UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(subtitleLabel)
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
