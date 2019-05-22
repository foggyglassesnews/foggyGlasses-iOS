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
            if let g = globalSelectedSavedArticle {
                self.showDetails()
                
                //Set Image
                if let imageIUrlString = g.imageUrlString {
                    let imageUrl = URL(string: imageIUrlString)
                    self.articleImage.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
                } else {
                    //hide the image view
                    self.hideImageView()
                }
                
                
                //Set Title
                let articleTitle = g.title
                self.articleTitle.text = articleTitle
            } else {
                getArticle()
            }
            
        }
    }
    
    var selectedGroups: [FoggyGroup]! {
        didSet {
            
        }
    }
    
    ///Article Response Data
    var articleResponse: Response?
    
    var articleImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
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
        
        if let d = globalSelectedSavedArticle {
            if let _ = d.imageUrlString {
                
            } else {
                articleImage.image = UIImage(named: "NoImageFound")
            }
        } else {
            view.addSubview(loading)
            loading.color = .black
            loading.tintColor = .black
            loading.withSize(width: 50, height: 50)
            loading.center(in: view)
            loading.startAnimating()
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendArticle))
        navigationItem.rightBarButtonItem?.tintColor = .black
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @objc func sendArticle() {
        guard let response = articleResponse else{
            let pop = PopupDialog(title: "Article Error", message: "Could not find article from given url.")
            present(pop, animated: true, completion: nil)
            return
        }
        
        let articleData = FirebaseManager.global.convertResponseToFirebaseData(articleText: articleTitle.text, response: response)
        print("Article Data", articleData)
        let article = Article(id: "localArticle", data: articleData)
        FirebaseManager.global.sendArticleToGroups(article: article, groups: selectedGroups, comment: addComment.text) { (success, articleId) in
            if success {
                
                NotificationCenter.default.post(name: FeedController.newNotificationData, object: nil)
                self.uploadSuccess(articleId: articleId)
            } else {
                print("Failure", articleId as Any)
                let pop = PopupDialog(title: "Article Error", message: "Error Sending Article to Group(s)")
                self.present(pop, animated: true, completion: nil)
            }
        }
    }
    
    func hideImageView() {
        articleImage.image = UIImage(named: "NoImageFound")
    }
    
    
    func uploadSuccess(articleId: String?) {
//        if let text = addComment.text, text.count > 0, let uid = Auth.auth().currentUser?.uid {
//            let comment = FoggyComment(id: "tmp", data: ["uid":uid,
//                                                         "text":text,
//                                                         "timestamp":Date().timeIntervalSince1970])
//            let post = SharePost(id: , data: <#T##[String : Any]#>)
//            FirebaseManager.global.postComment(comment: comment, post: <#T##SharePost#>, completion: <#T##FirebaseManager.SucessFailCompletion##FirebaseManager.SucessFailCompletion##(Bool) -> ()#>)
//        }
        
        for group in self.selectedGroups {
            
            NotificationManager.shared.updateAfterNewComment(groupId: group.id, postId: articleId ?? "", completion: {
                NotificationCenter.default.post(name: FeedController.newNotificationData, object: nil)
            })
        }
        
        globalSelectedSavedArticle = nil
        DispatchQueue.main.async {
            if let vc = globalReturnVC {
                print("Return to point")
                self.navigationController?.popToViewController(vc, animated: true)
                NotificationCenter.default.post(name: FeedController.newNotificationData, object: nil)
                globalReturnVC = nil
            } else {
                NotificationCenter.default.post(name: FeedController.newNotificationData, object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func showDetails() {
        loading.isHidden = true
        let scroll = UIScrollView(frame: view.frame)
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        scroll.addSubview(articleImage)
        scroll.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        articleImage.backgroundColor = .white
        articleImage.anchor(top: scroll.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        
        scroll.addSubview(articleTitle)
        articleTitle.anchor(top: articleImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        scroll.addSubview(addComment)
        addComment.anchor(top: articleTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    private func getArticle() {
        FirebaseManager.global.swiftGetArticle(link: link, completion: { (response) in
            if let response = response {
                self.articleResponse = response
                
                //Show Title
                self.showDetails()
                
                //Set Image
                if let imageUrl = response.image {
                    let imageUrl = URL(string: imageUrl)
                    self.articleImage.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
                } else {
                    self.hideImageView()
                }
                
                
                //Set Title
                let articleTitle = response.title
                self.articleTitle.text = articleTitle
            }
        }, shareExtension: false)
    }
}
