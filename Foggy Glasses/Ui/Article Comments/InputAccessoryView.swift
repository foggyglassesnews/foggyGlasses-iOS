//
//  InputAccessoryView.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/12/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class InputAccessoryView: UIView {
    @IBOutlet weak var textView: CustomUITextView!
    @IBOutlet private weak var sendButton: UIButton!
    
    var delegate: SendCommentDelegate?
    
    var placeholder: String = "" {
        didSet {
            textView.placeholder = placeholder
        }
    }
    
    var maxTextViewHeight: CGFloat = 150 {
        didSet {
            // Re-calculate intrinsicContentSize when maxHeight changes
            invalidateIntrinsicContentSize()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.cornerRadius = 4
        textView.layer.masksToBounds = true
        textView.delegate = self
        // autoresizingMask allow the height to be flexible in order accomodate the safe area inset
        self.autoresizingMask = [.flexibleHeight]
    }
    
    @IBAction private func sendButtonPressed(_ sender: Any) {
        if let uid = Auth.auth().currentUser?.uid{
            let comment = FoggyComment(id: "newComment", data: ["uid":uid,
                                                                "text":textView.text,
                                                                "timestamp":Date().timeIntervalSince1970])
            delegate?.send(comment: comment)
        }
        
        textView.text.removeAll()
        textViewDidChange(textView)
    }
    
    override var intrinsicContentSize: CGSize {
        // maximum size for the textView
        let maxSize = CGSize(width: textView.bounds.width, height: .infinity)
        // newSize is the size in which textView can fit perfectly
        let newSize = textView.sizeThatFits(maxSize)
        
        // if the newSize height is greater than allocated height then enable scrolling
        if newSize.height >= maxTextViewHeight {
            textView.isScrollEnabled = true
            return CGSize(width: self.bounds.width, height: maxTextViewHeight)
        } else {
            // else grow the textView height by growing InputAccessoryView height
            textView.isScrollEnabled = false
            return CGSize(width: self.bounds.width, height: newSize.height)
        }
    }
}

extension InputAccessoryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // enable send Button depending upon text in textView
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        sendButton.isEnabled = !text.isEmpty
        
        // Re-calculate intrinsicContentSize when text changes
        invalidateIntrinsicContentSize()
    }
}
