//
//  ArticleTopBar.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 4/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import PopupDialog

class ArticleTopBar: UIView {
    
    var article: Article! {
        didSet {
            timestamp.text = article.savedTimestamp.timeAgoDisplay()
        }
    }
    
    lazy var topBar: UIView = {
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
    let timestamp = UILabel()
    lazy var more: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "More Button")?.withRenderingMode(.alwaysTemplate), for: .normal)
        v.tintColor = .black
        v.contentMode = .scaleAspectFit
        v.addTarget(self, action: #selector(clickedMore), for: .touchUpInside)
        return v
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(topBar)
        topBar.pin(in: self)
        
        addSubview(more)
        more.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 20)
        more.centerVertically(in: self)
        
        addSubview(timestamp)
        timestamp.font = UIFont.systemFont(ofSize: 14)
        timestamp.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: more.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    @objc func clickedMore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let article = self.article
        guard let parent = parentViewController else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.isSpringLoaded = true
//        alert.addAction(UIAlertAction(title: "Save Article", style: .default, handler: { (action) in
//            print("Saving article")
//            FirebaseManager.global.saveArticle(uid: uid, articleId: article.id, completion: { (success) in
//                if !success {
//                    let pop = PopupDialog(title: "Error Saving Article", message: "There was an error while trying to save this article.")
//                    parent.present(pop, animated: true, completion: nil)
//                }
//            })
//            //            globalSavedArticles.append(article)
//        }))
        alert.addAction(UIAlertAction(title: "Share Article", style: .default, handler: { (action) in
            print("Sharing Article")
            globalSelectedSavedArticle = article
            parent.navigationController?.pushViewController(QuickshareController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        }))
        
        
        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parent.present(alert, animated: true, completion: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
