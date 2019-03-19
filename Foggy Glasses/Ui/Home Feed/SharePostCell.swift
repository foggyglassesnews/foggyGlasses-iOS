//
//  SharePostCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseAuth

class SharePostCell: SwipeableCollectionViewCell {
    static let id = "SharePostCellId"
    
    ///Delegate for sending messages to Feed Controller
    var postDelegate: SharePostProtocol? = nil
    
    var post: SharePost! {
        didSet {
            configCell()
        }
    }
    
    private let groupImage = UIImage(named: "Group Icon Foggy")
    private let personImage = UIImage(named: "Person Icon")
    
    lazy private var groupType: UIImageView = {
        let v = UIImageView()
        v.image = groupImage?.withRenderingMode(.alwaysTemplate)
        v.contentMode = .scaleAspectFit
        v.tintColor = .black
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private var groupName: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        v.textColor = .black//UIColor(red:0.53, green:0.53, blue:0.54, alpha:1.0)
        v.adjustsFontSizeToFitWidth = true
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private var sharedBy: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        v.textColor = .black//UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0)
        v.adjustsFontSizeToFitWidth = true
        
        return v
    }()
    
    private var more: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "More Button")?.withRenderingMode(.alwaysTemplate), for: .normal)
        v.tintColor = .black
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    private var articleText: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.isUserInteractionEnabled = true
        return v
    }()
    
    private var articleImage = ArticleImageView()
    
    private var commentButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("0 Comments", for: .normal)
        v.setTitleColor(UIColor(red:0.53, green:0.53, blue:0.54, alpha:1.0), for: .normal)
        v.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return v
    }()
    
    lazy private var headerBackground: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 42))
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.foggyBlue.cgColor, UIColor.foggyGrey.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = v.layer.frame
        v.layer.insertSublayer(gradient, at: 0)
        return v
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    private func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    private func configCell() {
        configTopBar()
        configBody()
    }
    
    private func configTopBar() {
        
        visibleContainerView.backgroundColor = .white
        
        visibleContainerView.addSubview(headerBackground)

        //Add group icon
        visibleContainerView.addSubview(groupType)
        groupType.anchor(top: topAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 28.57, height: 32.06)
        
        //Config group icon
        if post.groupId != nil {
            groupType.image = groupImage
            let tap = UITapGestureRecognizer(target: self, action: #selector(clickedGroupName))
            groupType.addGestureRecognizer(tap)
        } else {
            groupType.image = personImage
        }
        
        //Add More icon
        let moreContainer = UIView()
        visibleContainerView.addSubview(moreContainer)
        moreContainer.anchor(top: topAnchor, left: nil, bottom: headerBackground.bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 16, width: 20, height: 0)
        moreContainer.addSubview(more)
        more.pin(in: moreContainer)
        more.addTarget(self, action: #selector(clickedMore), for: .touchUpInside)
        
        //Add group name
        visibleContainerView.addSubview(groupName)
        groupName.anchor(top: topAnchor, left: groupType.rightAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 6, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 15)
        
        //Config Group Name
        if post.groupId != nil {
            FirebaseManager.global.getGroup(groupId: post.groupId!) { (group) in
                if let group = group {
                    self.groupName.text = group.name
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickedGroupName))
                    self.groupName.addGestureRecognizer(tap)
                }
            }
        } else {
            groupName.text = "User"
        }
        
        //Config Shared by
        visibleContainerView.addSubview(sharedBy)
        sharedBy.anchor(top: groupName.bottomAnchor, left: groupType.rightAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 15)
        
        if post.senderId == Auth.auth().currentUser?.uid {
            configSharedBy(text: "Shared by you")
        } else {
            FirebaseManager.global.getFoggyUser(uid: post.senderId) { (foggyUser) in
                if let foggy = foggyUser {
                    self.configSharedBy(text: "Shared by \(foggy.username)")
                }
            }
        }
    }
    
    private func configSharedBy(text: String) {
        let attributedText = NSMutableAttributedString()
        let timeAgo = self.post.timestamp.twoLetterTimestamp()
        attributedText.append(NSAttributedString(string: text + " ∙ ", attributes: [:]))
        attributedText.append(NSAttributedString(string: timeAgo, attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 12)]))
        self.sharedBy.attributedText = attributedText
    }
    
    private func configBody() {
        guard let article = post.article else { return }
        visibleContainerView.addSubview(articleText)
        
        if let urlString = article.imageUrlString {
            visibleContainerView.addSubview(articleImage)
            articleImage.anchor(top: headerBackground.bottomAnchor, left: nil, bottom: nil, right: visibleContainerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: frame.width / 3.2, height: 104)
            
            articleImage.config(title: article.canonicalUrl, url: URL(string: urlString))
            articleImage.addTarget(self, action: #selector(clickedArticle), for: .touchUpInside)
            
            articleText.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: articleImage.bottomAnchor, right: articleImage.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        } else {
            articleImage.removeFromSuperview()
            articleText.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: visibleContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 80)
        }
        
        articleText.text = article.title
        let tappedArticle = UITapGestureRecognizer(target: self, action: #selector(clickedArticle))
        articleText.addGestureRecognizer(tappedArticle)
        
        let divider2 = UIView()
        divider2.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.95, alpha:1.0)
        visibleContainerView.addSubview(divider2)
        divider2.anchor(top: articleText.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)
        
        visibleContainerView.addSubview(commentButton)
        commentButton.anchor(top: divider2.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 16, width: 0, height: 0)
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
        
        
        //        addSubview(gradient)
        let gradientView1 = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
//        let gradient2: CAGradientLayer = CAGradientLayer()
//        gradient2.colors = [UIColor.foggyBlue.cgColor, UIColor.foggyGrey.cgColor]
//        gradient2.locations = [0.0 , 1.0]
//        gradient2.startPoint = CGPoint(x: 0.0, y: 1.0)
//        gradient2.endPoint = CGPoint(x: 1.0, y: 1.0)
//        gradient2.frame = gradientView1.layer.frame
//        gradientView1.layer.insertSublayer(gradient2, at: 3)
//        
        gradientView1.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        gradientView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedHide)))
        hiddenContainerView.addSubview(gradientView1)
        //        deleteImageView.translatesAutoresizingMaskIntoConstraints = false
        //        deleteImageView.centerXAnchor.constraint(equalTo: hiddenContainerView.centerXAnchor).isActive = true
        //        deleteImageView.centerYAnchor.constraint(equalTo: hiddenContainerView.centerYAnchor).isActive = true
        //        deleteImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        //        deleteImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func clickedHide() {
        
    }
    
    @objc private func clickedComments() {
        postDelegate?.clickedComments(post: post)
    }
    
    @objc private func clickedMore() {
        guard let article = post.article else { return }
        postDelegate?.clickedMore(article: article)
    }
    
    @objc private func clickedGroupName() {
        if let group = post.group {
            postDelegate?.clickedGroup(group: group)
        } else {
            print("Missing Group")
        }
        
    }
    
    @objc private func clickedArticle() {
        guard let article = post.article else { return }
        postDelegate?.clickedArticle(article: article)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

//extension {
//    class ItemCollectionViewCell: SwipeableCollectionViewCell {
//
//        let itemNameLabel: UILabel = {
//            let label = UILabel()
//            label.font = UIFont.systemFont(ofSize: 20)
//            label.textColor = UIColor(white: 0.2, alpha: 1)
//            label.textAlignment = .center
//            return label
//        }()
//
//        let deleteImageView: UIImageView = {
//            let image = UIImage(named: "delete")?.withRenderingMode(.alwaysTemplate)
//            let imageView = UIImageView(image: image)
//            imageView.tintColor = .white
//            return imageView
//        }()
//
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            setupSubviews()
//        }
//
//        required init?(coder aDecoder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//
//        private func setupSubviews() {
//            visibleContainerView.backgroundColor = .white
//            visibleContainerView.addSubview(itemNameLabel)
//            itemNameLabel.pinEdgesToSuperView()
//
//            hiddenContainerView.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
//            hiddenContainerView.addSubview(deleteImageView)
//            deleteImageView.translatesAutoresizingMaskIntoConstraints = false
//            deleteImageView.centerXAnchor.constraint(equalTo: hiddenContainerView.centerXAnchor).isActive = true
//            deleteImageView.centerYAnchor.constraint(equalTo: hiddenContainerView.centerYAnchor).isActive = true
//            deleteImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
//            deleteImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        }
//    }
//}
