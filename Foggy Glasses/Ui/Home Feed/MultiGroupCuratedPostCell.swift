//
//  MultiGroupSharePostCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class MultiGroupCuratedSharePostCell: SharePostCell{
    static let id2 = "Multi Group Curated Share Post Cell Id"
    
    //    override var deleteBackground = CurationRatingCell()
    
    //    override var deleteBackground: UIView { get { return CurationRatingCell() } }
    
    
    //    override var deleteBackground:UIView = {
    //        return CurationRatingCell()
    //    }()
    
    var groups: [FoggyGroup] = [] {
        didSet {
            bottomHorizontalGroup.reloadData()
        }
    }
    
    var groupData = [String: String]() {
        didSet {
            print("Set group data", groupData)
            bottomHorizontalGroup.reloadData()
        }
        
    }
    
    var multiGroupPost: MultiGroupSharePost? {
        didSet{
            guard let multiGroupPost = multiGroupPost else { return }
            self.configCell()
            FirebaseManager.global.getGroups(groupIds: multiGroupPost.groupIds) { (groups) in
                self.groups = groups
                self.groupData = multiGroupPost.groupData
            }
        }
    }
    
    override var hideFromFeed: Bool?{
        didSet {
            guard let hideFromFeed = hideFromFeed else { return }
            if hideFromFeed {
                configHiddenCell()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        multiGroupPost = nil
    }
    
    lazy var bottomHorizontalGroup: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        let v = UICollectionView(frame: .zero, collectionViewLayout: flow)
        v.dataSource = self
        v.delegate = self
        v.alwaysBounceHorizontal = true
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = .white
        v.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        v.register(HorizontalGroupCell.self, forCellWithReuseIdentifier: HorizontalGroupCell.id)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    fileprivate func configCell() {
        configTopBar()
        deleteBackground = CurationRatingCell()
        
        articleText.alpha = 1
        articleImage.alpha = 1
        divider2.alpha = 1
        bottomHorizontalGroup.removeFromSuperview()
        
        configBody()
    }
    
    private func configHiddenCell() {
        configTopBar()
        
        //Hide Body
        articleText.alpha = 0
        articleImage.alpha = 0
        divider2.alpha = 0
        
        bottomHorizontalGroup.removeFromSuperview()
        visibleContainerView.addSubview(bottomHorizontalGroup)
        bottomHorizontalGroup.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 0)
    }
    
    private func configTopBar() {
        visibleContainerView.backgroundColor = .white
        visibleContainerView.addSubview(headerBackground)
        
        //Add group icon
        visibleContainerView.addSubview(groupType)
//        groupType.anchor(top: topAnchor, left: visibleContainerView.centerXAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: (-28.57/2), paddingBottom: 0, paddingRight: 0, width: 28.57, height: 32.06)
        groupType.anchor(top: topAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 28.57, height: 32.06)
        
        //Config group icon
        groupType.image = UIImage(named: "Group Icon Foggy")
        
        //Add More icon
        let moreContainer = UIView()
        visibleContainerView.addSubview(moreContainer)
        moreContainer.anchor(top: topAnchor, left: nil, bottom: headerBackground.bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 16, width: 20, height: 0)
        moreContainer.addSubview(more)
        more.pin(in: moreContainer)
        more.addTarget(self, action: #selector(clickedMore), for: .touchUpInside)
        
        //Add group name
        visibleContainerView.addSubview(groupName)
//        groupName.anchor(top: topAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 6, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 15)
         groupName.anchor(top: topAnchor, left: groupType.rightAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 6, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 15)
        
        //Config Group Name
        groupName.text = "Shared to \(multiGroupPost!.groupIds.count) Groups"
        
        //Config Shared by
        visibleContainerView.addSubview(sharedBy)
//        sharedBy.anchor(top: groupName.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 15)
        sharedBy.anchor(top: groupName.bottomAnchor, left: groupType.rightAnchor, bottom: nil, right: moreContainer.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 15)
        
        configSharedBy(text: "Curated for you")
    }
    
    override func configSharedBy(text: String) {
        let attributedText = NSMutableAttributedString()
        let timeAgo = self.multiGroupPost!.timestamp.twoLetterTimestamp()
        attributedText.append(NSAttributedString(string: text + " ∙ ", attributes: [:]))
        attributedText.append(NSAttributedString(string: timeAgo, attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 12)]))
        self.sharedBy.attributedText = attributedText
    }
    
    private func configBody() {
        guard let article = multiGroupPost?.article else { return }
        
        
        if let urlString = article.imageUrlString {
            articleImage.removeFromSuperview()
            articleText.removeFromSuperview()
            
            visibleContainerView.addSubview(articleText)
            visibleContainerView.addSubview(articleImage)
            
            articleImage.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: frame.width / 3.2, height: 104)
            
            articleImage.config(title: article.canonicalUrl, url: URL(string: urlString))
            articleImage.addTarget(self, action: #selector(clickedArticle), for: .touchUpInside)
            
            articleText.anchor(top: headerBackground.bottomAnchor, left: articleImage.rightAnchor, bottom: articleImage.bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        } else {
            articleImage.removeFromSuperview()
            articleText.removeFromSuperview()
            
            visibleContainerView.addSubview(articleText)
            articleText.anchor(top: headerBackground.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: nil, right: visibleContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 80)
        }
        
        articleText.text = article.title
        let tappedArticle = UITapGestureRecognizer(target: self, action: #selector(clickedArticle))
        articleText.addGestureRecognizer(tappedArticle)
        
        
        divider2.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.95, alpha:1.0)
        visibleContainerView.addSubview(divider2)
        divider2.anchor(top: articleText.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)
        
        visibleContainerView.addSubview(bottomHorizontalGroup)
        bottomHorizontalGroup.anchor(top: divider2.bottomAnchor, left: visibleContainerView.leftAnchor, bottom: bottomAnchor, right: visibleContainerView.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 34)
        
        //        deleteBackground.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
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
    
    override func clickedHide() {
        FeedHideManager.global.hide(id: multiGroupPost!.id)
        feedDelegate?.didHide(indexPath: indexPath)
    }
    
    override func clickedMore() {
        guard let article = multiGroupPost?.article else { return }
        postDelegate?.clickedMore(article: article)
    }
    
    override func clickedArticle() {
        guard let article = multiGroupPost?.article else { return }
        postDelegate?.clickedArticle(article: article, post: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

extension MultiGroupCuratedSharePostCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalGroupCell.id, for: indexPath) as! HorizontalGroupCell
        cell.postId = groupData[groups[indexPath.row].id]
        cell.group = groups[indexPath.row]
        //multiGroupPost?.id
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        label.text = groups[indexPath.row].name
        label.sizeToFit()
        
        return CGSize(width: label.frame.width + 16, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tappo")
        let group = groups[indexPath.row]
        let postId = groupData[group.id]
        
        globalSelectedGroup = group
        postDelegate?.clickedGroup(group: group)
        
//        print("xyc", postId)
//        print("xyc2", group.id)
        
        FirebaseManager.global.findArticleInGroup(articleId: postId ?? "", groupId: group.id) { (pst) in
            let article = ArticleController(collectionViewLayout: UICollectionViewFlowLayout())
            article.post = pst

            //Clears the notification for this post comments
            NotificationManager.shared.openedComments(groupId: pst.groupId ?? "", postId: pst.id)

            DispatchQueue.main.async {
                if let parent = self.parentViewController?.navigationController {
                    parent.pushViewController(article, animated: true)
                }

            }
        }
//        FirebaseManager.global.getPost(postId: postId ?? "", groupId: group.id) { (pst) in
//            let article = ArticleController(collectionViewLayout: UICollectionViewFlowLayout())
//            article.post = pst
//
//            //Clears the notification for this post comments
//            NotificationManager.shared.openedComments(groupId: pst.groupId ?? "", postId: pst.id)
//
//            DispatchQueue.main.async {
//                if let parent = self.parentViewController?.navigationController {
//                    parent.pushViewController(article, animated: true)
//                }
//
//            }
//        }
    }
}
