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

protocol FeedCellInteractionsDelegate {
    func didHide(indexPath: IndexPath)
}

class SharePostCell: SwipeableCollectionViewCell {
    static let id = "SharePostCellId"
    
    ///Delegate for sending messages to Feed Controller
    var postDelegate: SharePostProtocol? = nil
    
    var post: SharePost! {
        didSet {
            configCell()
        }
    }
    
    var hideFromFeed: Bool? {
        didSet{
            guard let hideFromFeed = hideFromFeed else { return }
            if hideFromFeed && post != nil {
                configHiddenCell()
            }
        }
    }
    
    var feedDelegate: FeedCellInteractionsDelegate?
    var indexPath: IndexPath!
    
    let groupImage = UIImage(named: "Group Icon Foggy")
    private let personImage = UIImage(named: "Person Icon")
    
    lazy var groupType: UIImageView = {
        let v = UIImageView()
        v.image = groupImage?.withRenderingMode(.alwaysTemplate)
        v.contentMode = .scaleAspectFit
        v.tintColor = .black
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var groupName: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        v.textColor = .black//UIColor(red:0.53, green:0.53, blue:0.54, alpha:1.0)
        v.adjustsFontSizeToFitWidth = true
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var sharedBy: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        v.textColor = .black//UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0)
        v.adjustsFontSizeToFitWidth = true
        
        return v
    }()
    
    var more: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "More Button")?.withRenderingMode(.alwaysTemplate), for: .normal)
        v.tintColor = .black
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var articleText: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.isUserInteractionEnabled = true
        return v
    }()
    
    var articleImage = ArticleImageView()
    
    let divider2 = UIView()
    
    private var commentButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("0 Comments", for: .normal)
        v.setTitleColor(UIColor(red:0.53, green:0.53, blue:0.54, alpha:1.0), for: .normal)
        v.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return v
    }()
    
    lazy var headerBackground: UIView = {
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
    
    let hideArticleLabel = UILabel()
    let deleteBackground = UIView()
    
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
    
    fileprivate func configCell() {
        configTopBar()
        
        deleteBackground.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        hideArticleLabel.text = "Hide Article"
        
        articleText.alpha = 1
        articleImage.alpha = 1
        divider2.alpha = 1
        commentButton.removeFromSuperview()
        
        configBody()
    }
    
    private func configHiddenCell() {
        configTopBar()
        
        deleteBackground.backgroundColor = UIColor(red:0.37, green:0.73, blue:0.49, alpha:1.0)
        hideArticleLabel.text = "Show Article"
        
        //Hide Body
        articleText.alpha = 0
        articleImage.alpha = 0
        divider2.alpha = 0
        
        commentButton.removeFromSuperview()
        visibleContainerView.addSubview(commentButton)
        commentButton.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func configTopBar() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        visibleContainerView.backgroundColor = .white
        visibleContainerView.addSubview(headerBackground)

        //Add group icon
        visibleContainerView.addSubview(groupType)
        groupType.anchor(top: topAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 28.57, height: 32.06)
        
        
        
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
                    
                    //Check if its friend group
                    if group.friendGroup {
                        self.groupType.image = self.personImage
                        
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickedGroupName))
                        self.groupType.isUserInteractionEnabled = true
                        self.groupType.addGestureRecognizer(tap)
                        
                        group.getFriendName(completion: { (friendName) in
                            self.groupName.text = friendName
                        })
                
                    } else {
                        self.groupType.image = self.groupImage
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickedGroupName))
                        self.groupType.isUserInteractionEnabled = true
                        self.groupType.addGestureRecognizer(tap)
                        
                        self.groupName.text = group.name
                        self.groupName.addGestureRecognizer(tap)
                    }
                }
            }
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
    
    func configSharedBy(text: String) {
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
        
        
        deleteBackground.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        deleteBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedHide)))
        hiddenContainerView.addSubview(deleteBackground)
        deleteBackground.anchor(top: hiddenContainerView.topAnchor, left: hiddenContainerView.leftAnchor, bottom: hiddenContainerView.bottomAnchor, right: hiddenContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        hideArticleLabel.textAlignment = .center
        hideArticleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        hiddenContainerView.addSubview(hideArticleLabel)
        hideArticleLabel.adjustsFontSizeToFitWidth = true
        hideArticleLabel.textColor = .white
        hideArticleLabel.anchor(top: hiddenContainerView.topAnchor, left: visibleContainerView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func clickedHide() {
        FeedHideManager.global.hide(id: post.id)
        feedDelegate?.didHide(indexPath: indexPath)
    }
    
    @objc private func clickedComments() {
        postDelegate?.clickedComments(post: post)
    }
    
    @objc func clickedMore() {
        guard let article = post.article else { return }
        postDelegate?.clickedMore(article: article)
    }
    
    
    
    @objc private func clickedGroupName() {
        
    
        if let groupId = post.groupId {
            FirebaseManager.global.getGroup(groupId: groupId) { (group) in
                if let group = group {
                    self.postDelegate?.clickedGroup(group: group)
                }
            }
            
        } else {
            print("Missing Group")
        }
        
    }
    
    @objc func clickedArticle() {
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
