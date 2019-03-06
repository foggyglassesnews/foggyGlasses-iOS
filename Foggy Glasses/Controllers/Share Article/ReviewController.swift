//
//  ReviewController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import SwiftLinkPreview
import SDWebImage
import PopupDialog
import Firebase

class ReviewController: UIViewController {
    
    let loading = UIActivityIndicatorView(style: .whiteLarge)
    
    ///Link to article
    var link: String? {
        didSet {
            getArticle()
        }
    }
    
    var selectedReciepients: [SearchMember]! {
        didSet {
            
        }
    }
    
    ///Article Response Data
    var articleResponse: Response?
    
    var articleImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    var articleTitle: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Title"
        v.headerString = "Article Title"
        v.headerTitle.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return v
    }()
    
    var addComment: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Add Comment..."
        v.headerString = "Add Comment (Optional)"
        v.headerTitle.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Review"
        view.backgroundColor = .feedBackground
        
        view.addSubview(loading)
        loading.color = .black
        loading.tintColor = .black
        loading.withSize(width: 50, height: 50)
        loading.center(in: view)
        loading.startAnimating()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendArticle))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    @objc func sendArticle() {
        guard let response = articleResponse else{
            let pop = PopupDialog(title: "Article Error", message: "Could not find article from given url.")
            present(pop, animated: true, completion: nil)
            return
        }
        
        let articleData: [String: Any] = ["title":response.title,
                                          "url":response.finalUrl?.absoluteString,
                                          "description": response.description,
                                          "imageUrlString": response.image,
                                          "shareUserId":Auth.auth().currentUser?.uid ?? "",
                                          ]
        
        let article = Article(id: "localArticle", data: articleData)
        FirebaseManager.global.sendArticleToGroup(article: article, groupId: "b7A4wrDNuiUXNvdAbXmR") { (success, articleId) in
            if success {
                print("Success!", articleId)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                print("Failure", articleId)
                let pop = PopupDialog(title: "Article Error", message: "Error Sending Article to Group!")
                self.present(pop, animated: true, completion: nil)
            }
        }
        

//        let groupOne = FoggyGroup(id: "b7A4wrDNuiUXNvdAbXmR", data: ["name":"Group"])
//
//        let senderOne = FoggyUser(data: ["name":"you", "username":"emma123"])
//        let oneData: [String: Any] = ["groupId":"1",
//                                      "article":articleOne,
//                                      "group":groupOne,
//                                      "sender":senderOne,
//                                      "comments":0]
//        let one = SharePost(id: "\(globalArticles.count + 1)", data: oneData)
//        globalArticles.append(one)
//
//        globalSelectedSavedArticle = nil
        
//        navigationController?.popToRootViewController(animated: true)
    }
    
    func showDetails() {
        loading.isHidden = true
        let scroll = UIScrollView(frame: view.frame)
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        scroll.addSubview(articleImage)
        articleImage.backgroundColor = .red
        articleImage.anchor(top: scroll.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        
        scroll.addSubview(articleTitle)
        articleTitle.anchor(top: articleImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        scroll.addSubview(addComment)
        addComment.anchor(top: articleTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    private func getArticle() {
        guard let link = link else { return }
        let s = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: .main, cache: DisabledCache.instance)
        s.preview(link, onSuccess: { (response) in
            self.articleResponse = response
            //Show Title
            self.showDetails()
            
            //Set Image
            let imageUrl = URL(string: response.image ?? "")
            self.articleImage.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
            
            //Set Title
            let articleTitle = response.title
            self.articleTitle.text = articleTitle
            
            print("Success!", response)
        }) { (err) in
            print("Error!", err)
        }
    }
    
//    func config(image: UIImage?, )
}
