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
    
    var headerTitle: UILabel = {
        let v = UILabel()
        v.text = "Placeholder"
        v.font = UIFont.systemFont(ofSize: 16)
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
        
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        setNeedsLayout()
        layoutIfNeeded()
        print(frame.height)
    }
    
    @objc func changed() {
        print("Changed")
        setNeedsLayout()
        layoutIfNeeded()
        print(frame.height)
    }
    
    
    ///MARK: Live search functionality
    func noRight() {
        rightIcon(nil)
    }
    
    func validUsername() {
        rightIcon(#imageLiteral(resourceName: "checked"))
    }
    
    func takenUsername() {
        rightIcon(#imageLiteral(resourceName: "close"))
    }
    
    func loading() {
        rightIcon(nil, loading: true)
    }
    
    private func rightIcon(_ icon: UIImage?, loading: Bool = false) {
        
        let padding = 16
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        
        if loading {
            let loading = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            loading.style = .gray
            loading.startAnimating()
            outerView.addSubview(loading)
        } else {
            let iconView  = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            iconView.image = icon
            iconView.contentMode = .scaleAspectFit
            outerView.addSubview(iconView)
        }
        
        rightView = outerView
        rightViewMode = .always
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

extension InsetTextField {
    
    override open var intrinsicContentSize: CGSize {
        
        if isEditing {
            let string = (text ?? "") as NSString
            let stringSize:CGSize = string.size(withAttributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize:
                    19.0)])
            if self.frame.minX > 71.0 {
                return stringSize
            }
        }
        
        return super.intrinsicContentSize
    }
    
    
}
