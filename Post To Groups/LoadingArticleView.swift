//
//  LoadingArticleView.swift
//  Post To Groups
//
//  Created by Ryan Temple on 6/20/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class LoadingArticleView: UIView {
    
    var loader = UIActivityIndicatorView()
    var text = "" {
        didSet {
            loader.hidesWhenStopped = true
            loader.stopAnimating()
            label.text = text
            label.isHidden = false
        }
    }
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loader.color = .black
        
        addSubview(loader)
        loader.pin(in: self)
        loader.startAnimating()
        backgroundColor = .white
        
        layer.cornerRadius = 19
        
        addSubview(label)
        label.isHidden = true
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
