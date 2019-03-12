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

class SharePostCell: SwipeableCollectionViewCell {
    static let id = "SharePostCellId"
    
    ///Delegate for sending messages to Feed Controller
    var postDelegate: SharePostProtocol? = nil
    
    let groupImage = UIImage(named: "Group Icon Foggy")
    let personImage = UIImage(named: "Person Icon")
    
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
    
    var post: SharePost! {
        didSet {
            configCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    func configCell() {
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
                    self.groupName.text = group.name + " Group"
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickedGroupName))
                    self.groupName.addGestureRecognizer(tap)
                }
            }
        } else {
            groupName.text = "User"
        }
        
        //Config Shared by
        visibleContainerView.addSubview(sharedBy)
        sharedBy.anchor(top: groupName.bottomAnchor, left: groupType.rightAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 100, height: 15)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: <#T##String#>, attributes: <#T##[NSAttributedString.Key : Any]?#>))
        
        if post.senderId == Auth.auth().currentUser?.uid {
            sharedBy.text = "Shared by you"
            
        } else {
            FirebaseManager.global.getFoggyUser(uid: post.senderId) { (foggyUser) in
                if let foggy = foggyUser {
                    self.sharedBy.text = "Shared by \(foggy.username)" + " ∙ " + self.post.timestamp.twoLetterTimestamp()
                }
            }
        }
        
        
        
       
    }
    
    private func configBody() {
        visibleContainerView.addSubview(articleText)
        if let image = post.article?.imageUrlString {
            visibleContainerView.addSubview(articleImage)
            articleImage.anchor(top: headerBackground.bottomAnchor, left: nil, bottom: nil, right: visibleContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width / 4, height: 80)
            articleImage.sd_setImage(with: URL(string: post.article?.imageUrlString ?? ""), completed: nil)
            let tappedArticle = UITapGestureRecognizer(target: self, action: #selector(clickedArticle))
            articleImage.addGestureRecognizer(tappedArticle)
            
            articleText.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: articleImage.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: (frame.width / 4) * 2.8, height: 0)
        } else {
            articleImage.removeFromSuperview()
            articleText.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: visibleContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 80)
        }
        articleText.text = post.article?.title
        let tappedArticle = UITapGestureRecognizer(target: self, action: #selector(clickedArticle))
        articleText.addGestureRecognizer(tappedArticle)
        
        let divider2 = UIView()
        divider2.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.95, alpha:1.0)
        visibleContainerView.addSubview(divider2)
        divider2.anchor(top: articleText.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)
        
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
        let gradient2: CAGradientLayer = CAGradientLayer()
        gradient2.colors = [UIColor.foggyBlue.cgColor, UIColor.foggyGrey.cgColor]
        gradient2.locations = [0.0 , 1.0]
        gradient2.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient2.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient2.frame = gradientView1.layer.frame
        gradientView1.layer.insertSublayer(gradient2, at: 3)
        
        //        hiddenContainerView.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        hiddenContainerView.addSubview(gradientView1)
        //        deleteImageView.translatesAutoresizingMaskIntoConstraints = false
        //        deleteImageView.centerXAnchor.constraint(equalTo: hiddenContainerView.centerXAnchor).isActive = true
        //        deleteImageView.centerYAnchor.constraint(equalTo: hiddenContainerView.centerYAnchor).isActive = true
        //        deleteImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        //        deleteImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func clickedComments() {
        postDelegate?.clickedComments()
    }
    
    @objc func clickedMore() {
        guard let article = post.article else { return }
        postDelegate?.clickedMore(article: article)
    }
    
    @objc func clickedGroupName() {
        if let group = post.group {
            postDelegate?.clickedGroup(group: group)
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
