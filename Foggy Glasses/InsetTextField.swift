//
//  InsetTextField.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

///Custom Textfield with Inset from left
class InsetTextField: UITextField {
    
    ///Custom Header title for UILabel
    var headerString: String = "Placeholder" {
        didSet {
            headerTitle.text = headerString
        }
    }
    
    private var headerTitle: UILabel = {
        let v = UILabel()
        v.text = "Placeholder"
        v.font = UIFont.boldSystemFont(ofSize: 18)
        return v
    }()
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: 16, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        return bounds.insetBy(dx: 16, dy: 0);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        
        backgroundColor = .white
        
        addSubview(headerTitle)
        headerTitle.anchor(top: nil, left: leftAnchor, bottom: topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 11, paddingBottom: 7, paddingRight: 0, width: 0, height: 18)
        
        tintColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

extension InsetTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
