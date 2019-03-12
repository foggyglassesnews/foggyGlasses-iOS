//
//  ArticleController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog

protocol SendCommentDelegate {
    func send(comment: FoggyComment)
}

class ArticleController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    static let postSection = "Post Section"
    static let commentSection = "Comment Section"
    
    var sections = [ArticleController.postSection, ArticleController.commentSection]
    
    var post: SharePost!
    var comments = [FoggyComment]()
    
    let accessory: InputAccessoryView = .loadNib()
    
    override var inputAccessoryView: UIView? {
        return accessory
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .feedBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(SharePostCell.self, forCellWithReuseIdentifier: SharePostCell.id)
        collectionView.register(EmptyCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmptyCellHeader.id)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        
        accessory.delegate = self
        
        fetchComments()
    }
    
    private func fetchComments() {
        comments = FoggyComment.fakeComments()
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentSection = sections[indexPath.section]
        if currentSection == ArticleController.postSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharePostCell.id, for: indexPath) as! SharePostCell
            cell.post = post
            cell.postDelegate = self
            return cell
        } else if currentSection == ArticleController.commentSection {
//            return CGSize(width: view.frame.width, height: 60)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharePostCell.id, for: indexPath)
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[section]
        if currentSection == ArticleController.postSection {
            return 1
        } else if currentSection == ArticleController.commentSection {
            return comments.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentSection = sections[indexPath.section]
        if currentSection == ArticleController.postSection {
            return CGSize(width: view.frame.width, height: 200)
        } else if currentSection == ArticleController.commentSection {
            return CGSize(width: view.frame.width, height: 60)
        }
        return .zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmptyCellHeader.id, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let currentSection = sections[section]
        if currentSection == ArticleController.postSection {
            return CGSize(width: view.frame.width, height: 0)
        } else if currentSection == ArticleController.commentSection {
            return CGSize(width: view.frame.width, height: 16)
        }
        return .zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resignFirstResponder()
    }
}

extension ArticleController: SharePostProtocol {
    func clickedComments(post: SharePost) {
        
    }
    
    func clickedArticle(article: Article) {
        let web = WebController()
        web.article = article
        navigationController?.pushViewController(web, animated: true)
    }
    
    func clickedMore(article: Article) {
        print("Clicked More")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.isSpringLoaded = true
        alert.addAction(UIAlertAction(title: "Save Article", style: .default, handler: { (action) in
            print("Saving article")
            FirebaseManager.global.saveArticle(uid: uid, articleId: article.id, completion: { (success) in
                if !success {
                    let pop = PopupDialog(title: "Error Saving Article", message: "There was an error while trying to save this article.")
                    self.present(pop, animated: true, completion: nil)
                }
            })
            //            globalSavedArticles.append(article)
        }))
        alert.addAction(UIAlertAction(title: "Share Article", style: .default, handler: { (action) in
            print("Sharing Article")
            globalSelectedSavedArticle = article
            self.navigationController?.pushViewController(QuickshareController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Hide Article", style: .destructive, handler: { (action) in
            print("Hiding article")
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func clickedGroup(group: FoggyGroup) {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        
        navigationController?.pushViewController(feed, animated: true)
    }
}

extension ArticleController: SendCommentDelegate {
    func send(comment: FoggyComment) {
        comments.append(comment)
        
        accessory.textView.resignFirstResponder()
        becomeFirstResponder()
        
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}
