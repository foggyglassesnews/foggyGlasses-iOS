//
//  CurationRatingView.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 6/30/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class CurationRatingCell: UIView {
    var userFeedback = 0
    
    static let buttonHeight:CGFloat = 42
    static let buttonWidth:CGFloat = 120
    static let headerHeight:CGFloat = 42
    
    let headerContainer = UIView()
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.text = "FeedBack"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    let groupImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Group Icon Foggy")
        return image
    }()
    let moreBtn:UIButton = {
        let button = UIButton()
        button.setTitle("Show More 👍", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CGFloat(CurationRatingCell.buttonHeight/2)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 2.5
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(moreBtnPressUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
        return button
    }()
    let lessBtn:UIButton = {
        let button = UIButton()
        button.setTitle("Show Less 👎", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 12.0)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CGFloat(CurationRatingCell.buttonHeight/2)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 2.5
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(lessBtnPressUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(BtnPressDown), for: .touchDown)
        return button
    }()
    let divider:UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configFeedbackCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configFeedbackCell() {
        self.backgroundColor = .white
        
        self.addSubview(headerContainer)
        self.addSubview(moreBtn)
        self.addSubview(lessBtn)
        headerContainer.addSubview(groupImage)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(divider)
        
        headerContainer.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: CurationRatingCell.headerHeight)
        groupImage.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: (10), paddingBottom: 0, paddingRight: 0, width: 28.57, height: 32.06)
        titleLabel.anchor(top: self.topAnchor, left: groupImage.rightAnchor, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        divider.anchor(top: nil, left: headerContainer.leftAnchor, bottom: headerContainer.bottomAnchor, right: headerContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:0, height: 0.5)
        moreBtn.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 40, paddingBottom: 60, paddingRight: 0, width: CurationRatingCell.buttonWidth, height: CurationRatingCell.buttonHeight)
        lessBtn.anchor(top: nil, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 60, paddingRight: 40, width: CurationRatingCell.buttonWidth, height: CurationRatingCell.buttonHeight)
        
    }
    
    @objc func BtnPressDown (sender:UIButton){
        sender.backgroundColor = UIColor.lightGray
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    @objc func lessBtnPressUp (sender:UIButton){
        var backgroundColor:UIColor = UIColor.white
        
        
        if self.userFeedback >= 0 {
            self.userFeedback = -1
            backgroundColor = UIColor.foggyBlue
            moreBtn.backgroundColor = .white
        }
        else {
            self.userFeedback = 0
        }
        
        UIView.animate(withDuration: 0, delay:0.09, animations: {
            sender.backgroundColor = backgroundColor
            sender.transform = CGAffineTransform.identity
        })
        
        print(self.userFeedback)
        
    }
    
    @objc func moreBtnPressUp (sender:UIButton){
        var backgroundColor:UIColor = UIColor.white
        
        
        if self.userFeedback <= 0 {
            self.userFeedback = 1
            backgroundColor = UIColor.foggyBlue
            lessBtn.backgroundColor = .white
        }
        else {
            self.userFeedback = 0
        }
        
        UIView.animate(withDuration: 0, delay:0.09, animations: {
            sender.backgroundColor = backgroundColor
            sender.transform = CGAffineTransform.identity
        })
        
        print(self.userFeedback)
    }
    
}

