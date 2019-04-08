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
    
    var isSelecting = false
    
    var article: Article? {
        didSet {
            guard let article = article else { return }
            topBar.article = article
            articleTitleText.text = article.title
            
            if let imageUrlString = article.imageUrlString{
                articleImage.config(title: article.canonicalUrl, url: URL(string: imageUrlString))
            }
            
//            articleImage.sd_setImage(with: URL(string: article?.imageUrlString ?? ""), completed: nil)
        }
    }
    
    lazy var topBar = ArticleTopBar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 42))
    let articleTitleText = UITextView()
    let articleImage = ArticleImageView()
    
    override func create() {
        backgroundColor = .white
        
        addTopBar()
        
        addSubview(articleImage)
        if isSelecting {
            sideSelect.isHidden = false
            articleImage.anchor(top: topBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 16, width: 100, height: 0)
        } else {
            sideSelect.isHidden = true
            articleImage.anchor(top: topBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 0, width: 100, height: 0)
        }
        
        articleImage.contentMode = .scaleAspectFill
        articleImage.clipsToBounds = true
        articleImage.isUserInteractionEnabled = true
        articleImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedArticle)))
        
        addSubview(articleTitleText)
        articleTitleText.isUserInteractionEnabled = false
        articleTitleText.font = .systemFont(ofSize: 14, weight: .semibold)
        
        articleTitleText.anchor(top: topBar.bottomAnchor, left: articleImage.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    private func addTopBar(){
        addSubview(topBar)
        topBar.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 42)
        
        
    }
    
    @objc func clickedArticle() {
        if let vc = parentViewController {
            let web = WebController()
            web.article = article
            web.navigationItem.backBarButtonItem?.tintColor = .black
            
            vc.navigationController?.pushViewController(web, animated: true)
        }
    }
}
