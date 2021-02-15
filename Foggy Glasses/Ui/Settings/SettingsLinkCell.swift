//
//  SettingsLinkCell.swift
//  Foggy Glasses
//
//  Created by Alec Barton on 7/25/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth

class SettingsLinkCell: UICollectionViewCell {
    static let height: CGFloat = 44
    static let id = "Settings Link cell Id"
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        view.textAlignment = .center
        
        view.isUserInteractionEnabled = true

        
        return view
    }()
    
    @objc func labelClicked(){
        UIApplication.shared.open(URL(string:"newsAPI.org")!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        
        addSubview(titleLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(labelClicked))
        titleLabel.addGestureRecognizer(gesture)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
     
        titleLabel.text = "- Article Curation Powered by NewsAPI.org -"
//        cellLink = URL(string:"newsAPI.org")!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
}
