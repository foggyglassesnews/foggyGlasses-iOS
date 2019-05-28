//
//  ArticleController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import PopupDialog
import Contacts
import SafariServices

protocol SendCommentDelegate {
    func send(comment: FoggyComment)
}

///Necessary class for display input on bottom container
class SafeView: UIView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = window {
                bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
    }
}

class ArticleController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UITextFieldDelegate {
    
    static let postSection = "Post Section"
    static let commentSection = "Comment Section"
    
    var sections = [ArticleController.postSection, ArticleController.commentSection]
    
    var post: SharePost!
    var comments = [FoggyComment]() {
        didSet {
            collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    lazy var containerView: SafeView = {
        let containerView = SafeView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Send", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .buttonBlue
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        submitButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        submitButton.layer.cornerRadius = 8.5
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 12, width: 50, height: 0)
        
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.textAlignment = .left
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = .lightGray//UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.2)
        
        return containerView
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        textField.becomeFirstResponder()
        //        textField.isFocused = true
        textField.updateFocusIfNeeded()
        textField.keyboardType = .twitter
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 12)
        return textField
    }()
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    let accessory: InputAccessoryView = .loadNib()
    
//    override var inputAccessoryView: UIView? {
//        return accessory
//    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
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
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: CommentCollectionViewCell.id)
        collectionView.register(EmptyCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmptyCellHeader.id)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        collectionView.isUserInteractionEnabled = true
        
//        accessory.delegate = self
        
        fetchComments()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    ///Method called when selecting create new group
    @objc func createGroupFromQuickshareExtension() {
        //DeepLinkManager.shared.present(nav: self.navigationController, returnVC: nil)
        return
        //        globalReturnVC = self
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if self.checkForContactPermission() {
                let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
                create.isFromQuickshare = true
                self.navigationController?.pushViewController(create, animated: true)
            } else {
                let contact = ContactPermissionController()
                contact.isFromQuickshare = true
                self.navigationController?.pushViewController(contact, animated: true)
            }
        }
    }
    
    private func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
    }
    
    @objc func dismissKeyboard() {
        commentTextField.resignFirstResponder()
    }
    
    private func fetchComments() {
        FirebaseManager.global.fetchComments(post: post) { (comments) in
            self.comments = comments
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentSection = sections[indexPath.section]
        if currentSection == ArticleController.postSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharePostCell.id, for: indexPath) as! SharePostCell
            cell.post = post
            cell.postDelegate = self
            return cell
        } else if currentSection == ArticleController.commentSection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.id, for: indexPath) as! CommentCollectionViewCell
            cell.comment = comments[indexPath.row]
            return cell
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
            let label = UITextView(frame: CGRect(x: 10, y: 0, width: view.frame.width - 18, height: 1000))
            label.text = comments[indexPath.row].text
            label.sizeToFit()
            return CGSize(width: view.frame.width, height: label.frame.size.height + 30)
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

extension ArticleController: SharePostProtocol, SFSafariViewControllerDelegate {
    func clickedComments(post: SharePost) {
        
    }
    
    func clickedArticle(article: Article) {
//        let web = WebController()
//        web.article = article
//        navigationController?.pushViewController(web, animated: true)
        
        guard let url = URL(string: article.link) else { return }
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
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

extension ArticleController {
    @objc func sendComment() {
        //
        if commentTextField.text == "" {
            return
        }
        if let uid = Auth.auth().currentUser?.uid{
            let comment = FoggyComment(id: "newComment", data: ["uid":uid,
                                                                "text":commentTextField.text,
                                                                "timestamp":Date().timeIntervalSince1970])
            self.send(comment: comment)
        }
        commentTextField.text = ""
    }
    private func send(comment: FoggyComment) {
        FirebaseManager.global.getGroup(groupId: post.groupId ?? "") { (group) in
            guard let group = group else { return }
            FirebaseManager.global.postComment(comment: comment, post: self.post, group: group) { (success) in
                if success {
                    self.comments.append(comment)//insert(comment, at: 0)
                    FirebaseManager.global.increaseCommentCount(post: self.post, completion: { (success, count) in
                        if success {
                            self.post.comments = count!
                            self.updateNotifications()
                            self.collectionView.reloadSections(IndexSet(integer: 0))
                            
                        }
                    })
                }
            }
        }
        
        
        commentTextField.resignFirstResponder()
        becomeFirstResponder()
    }
    
    private func updateNotifications() {
        NotificationManager.shared.updateAfterNewComment(groupId: post.groupId ?? "", postId: post.id) {
            print("Updated!")
        }
    }
}
