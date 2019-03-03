//
//  ArticleCollectionViewCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ArticleCollectionViewCell: SelectionCell {
    static let id = "Article Collection View Cell id"
    
    var article: Article? {
        didSet {
            articleTitleText.text = article?.title
            articleImage.sd_setImage(with: URL(string: article?.imageUrlString ?? ""), completed: nil)
        }
    }
    
    let articleTitleText = UITextView()
    let articleImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(articleImage)
        articleImage.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: sideSelect.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 100, height: 0)
        articleImage.contentMode = .scaleAspectFill
        articleImage.clipsToBounds = true
        articleImage.isUserInteractionEnabled = true
        articleImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedArticle)))
        
        addSubview(articleTitleText)
        articleTitleText.isUserInteractionEnabled = false

        articleTitleText.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: articleImage.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    @objc func clickedArticle() {
        if let vc = parentViewController {
            let web = WebController()
            web.article = article
            vc.navigationController?.pushViewController(web, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
