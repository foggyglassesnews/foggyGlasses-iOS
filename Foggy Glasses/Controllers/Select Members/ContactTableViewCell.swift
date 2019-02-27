//
//  ContactTableViewCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/26/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class ContactTableViewCell: UITableViewCell {
    static let id = "Contact Table View Cell Id"
    
    var member = SearchMember() {
        didSet {
            self.textLabel?.text = member.name
            self.detailTextLabel?.text = member.detail
            if member.selected {
                backgroundColor = .white
                sideSelect.setImage(UIImage(named: "Select Button H")?.withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                sideSelect.setImage(UIImage(named: "Select Button U")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    private let sideSelect: UIButton = {
        let v = UIButton()
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(sideSelect)
        sideSelect.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 25, height: 25)
        sideSelect.centerVertically(in: self)
        sideSelect.isUserInteractionEnabled = false
        sideSelect.setImage(UIImage(named: "Select Button U")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

