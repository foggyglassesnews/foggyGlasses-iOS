//
//  SharePostCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SharePostCell: UICollectionViewCell{
    static let id = "SharePostCellId"
    
    ///Delegate for sending messages to Feed Controller
    var delegate: SharePostProtocol?
    
    var groupType: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "Group Icon")
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var groupName: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        v.textColor = UIColor(red:0.53, green:0.53, blue:0.54, alpha:1.0)
        v.adjustsFontSizeToFitWidth = true
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var sharedBy: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        v.textColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0)
        v.adjustsFontSizeToFitWidth = true
        return v
    }()
    
    var more: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "More Button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var articleText: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var articleImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var commentButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("0 Comments", for: .normal)
        v.setTitleColor(UIColor(red:0.53, green:0.53, blue:0.54, alpha:1.0), for: .normal)
        v.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return v
    }()
    
    var post: SharePost! {
        didSet {
            configTopBar()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    func configTopBar() {
        addSubview(groupType)
        groupType.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 26.91, height: 22.18)
        if post.group != nil {
            groupType.image = UIImage(named: "Group Icon")
            let tap = UITapGestureRecognizer(target: self, action: #selector(clickedGroupName))
            groupType.addGestureRecognizer(tap)
        } else {
            groupType.image = UIImage(named: "Person Icon")
        }
        
        addSubview(groupName)
        groupName.anchor(top: topAnchor, left: groupType.rightAnchor, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
        if let name = post.group?.name {
            groupName.text = name
            let tap = UITapGestureRecognizer(target: self, action: #selector(clickedGroupName))
            groupName.addGestureRecognizer(tap)
        } else {
            groupName.text = post.sender?.name
        }
        
        addSubview(sharedBy)
        sharedBy.anchor(top: groupName.bottomAnchor, left: groupType.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 100, height: 15)
        sharedBy.text = "Shared by \(post.sender!.name)"
        
        let divider = UIView()
        divider.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.95, alpha:1.0)
        addSubview(divider)
        divider.anchor(top: sharedBy.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 6, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)
        
        let container = UIView()
        container.backgroundColor = .white
        addSubview(container)
        container.anchor(top: topAnchor, left: nil, bottom: divider.topAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 16, width: 20, height: 0)

        container.addSubview(more)
        more.pin(in: container)
        more.addTarget(self, action: #selector(clickedMore), for: .touchUpInside)
        
        addSubview(articleText)
        if let image = post.article?.thumbnail {
            addSubview(articleImage)
            articleImage.anchor(top: divider.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width / 4, height: 80)
            articleImage.image = image
            let tappedArticle = UITapGestureRecognizer(target: self, action: #selector(clickedArticle))
            articleImage.addGestureRecognizer(tappedArticle)
            
            articleText.anchor(top: divider.bottomAnchor, left: leftAnchor, bottom: articleImage.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: (frame.width / 4) * 2.8, height: 0)
        } else {
            articleImage.removeFromSuperview()
            articleText.anchor(top: divider.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 80)
        }
        articleText.text = post.article?.title
        let tappedArticle = UITapGestureRecognizer(target: self, action: #selector(clickedArticle))
        articleText.addGestureRecognizer(tappedArticle)
        
        let divider2 = UIView()
        divider2.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.95, alpha:1.0)
        addSubview(divider2)
        divider2.anchor(top: articleText.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)
        
        addSubview(commentButton)
        commentButton.anchor(top: divider2.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 16, width: 0, height: 0)
        var commentCount = ""
        if post.comments > 1 {
            commentCount = "\(post.comments) Comments"
        } else if post.comments == 1 {
            commentCount = "1 Comment"
        } else {
            commentCount = "No Comments Yet"
        }
        commentButton.setTitle(commentCount, for: .normal)
        commentButton.addTarget(self, action: #selector(clickedComments), for: .touchUpInside)
    }
    
    @objc func clickedComments() {
        delegate?.clickedComments()
    }
    
    @objc func clickedMore() {
        delegate?.clickedMore()
    }
    
    @objc func clickedGroupName() {
        delegate?.clickedGroup()
    }
    
    @objc func clickedArticle() {
        guard let article = post.article else { return }
        delegate?.clickedArticle(article: article)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
