//
//  SideMenuHeaderCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SideMenuHeaderCell: UICollectionViewCell {
    static let id = "SideMenuHeaderCellId"
    
    var delegate: SideMenuProtocol?
    
    var logo: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "Side Logo")
        return v
    }()
    
    var createGroup: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Create A Group")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var home: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Home Feed")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var saved: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Saved Articles")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logo)
        logo.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 80)
        logo.centerHoriziontally(in: self)
        
        addSubview(createGroup)
        createGroup.anchor(top: logo.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 154, height: 41)
        createGroup.centerHoriziontally(in: self)
        createGroup.addTarget(self, action: #selector(clickedCreateGroup), for: .touchUpInside)
        
        addSubview(home)
        home.anchor(top: createGroup.topAnchor, left: nil, bottom: createGroup.bottomAnchor, right: createGroup.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 41, height: 0)
        home.addTarget(self, action: #selector(clickedHome), for: .touchUpInside)
        
        addSubview(saved)
        saved.anchor(top: createGroup.topAnchor, left: createGroup.rightAnchor, bottom: createGroup.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 41, height: 0)
        saved.addTarget(self, action: #selector(clickedSaved), for: .touchUpInside)
    }
    
    @objc func clickedCreateGroup() {
        delegate?.clickedNewGroup()
    }
    
    @objc func clickedHome() {
        globalSelectedGroup = nil
        delegate?.clickedHome()
    }
    
    @objc func clickedSaved() {
        delegate?.clickedSavedArticles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
