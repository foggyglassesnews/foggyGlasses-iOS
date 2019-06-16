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
import SafariServices

class ArticleCollectionViewCell: SelectionCell {
    static let id = "Article Collection View Cell id"
    
    var isSelecting = false
    
    var article: Article? {
        didSet {
            guard let article = article else { return }
            topBar.article = article
            articleTitleText.text = article.title
            
            if let image = article.imageUrlString {
                //Show Image
                self.configWithImage()
            } else {
                //Hide Image
                self.configWithoutImage()
            }
            
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
        
        articleImage.contentMode = .scaleAspectFill
        articleImage.clipsToBounds = true
        articleImage.isUserInteractionEnabled = true
        articleImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedArticle)))
        
        
//        articleTitleText.numberOfLines = 0
        articleTitleText.isEditable = false
        articleTitleText.isSelectable = true
        articleTitleText.font = .systemFont(ofSize: 14, weight: .semibold)
        articleTitleText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickedArticle)))
    }
    
    func configWithImage() {
        articleImage.removeFromSuperview()
        articleTitleText.removeFromSuperview()
        
        addSubview(articleImage)
        if isSelecting {
            print("SELCTING")
            sideSelect.isHidden = false
            articleImage.isUserInteractionEnabled = false
            articleTitleText.isUserInteractionEnabled = false
        } else {
            sideSelect.isHidden = true
            articleImage.isUserInteractionEnabled = true
            articleTitleText.isUserInteractionEnabled = true
        }
        
        addSubview(articleTitleText)
        articleImage.anchor(top: topBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 3, paddingLeft: 8, paddingBottom: 3, paddingRight: 0, width: 100, height: 0)
        articleTitleText.anchor(top: topBar.bottomAnchor, left: articleImage.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    func configWithoutImage() {
        articleImage.removeFromSuperview()
        articleTitleText.removeFromSuperview()
        
        if isSelecting {
            print("SELECITNG")
            sideSelect.isHidden = false
            articleImage.isUserInteractionEnabled = false
            articleTitleText.isUserInteractionEnabled = false
        } else {
            sideSelect.isHidden = true
            articleImage.isUserInteractionEnabled = true
            articleTitleText.isUserInteractionEnabled = true
        }
        
        
        addSubview(articleTitleText)
        
        articleTitleText.anchor(top: topBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    override func prepareForReuse() {
//        articleImage.removeFromSuperview()
        articleImage.setImage(nil, for: .normal)
    }
    
    private func addTopBar(){
        addSubview(topBar)
        topBar.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 42)
        
        
    }
    
    @objc func clickedArticle() {
        if let vc = parentViewController, let article = article {
//            let web = WebController()
//            web.article = article
//            web.navigationItem.backBarButtonItem?.tintColor = .black
//
//            vc.navigationController?.pushViewController(web, animated: true)
            
            guard let url = URL(string: article.link) else { return }
            let safari = SafariController(url: url)
            vc.present(safari, animated: true, completion: nil)
        }
    }
    
}
