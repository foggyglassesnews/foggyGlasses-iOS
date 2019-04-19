//
//  SavedArticlesCollectionController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Contacts

var globalSelectedSavedArticle: Article?

var globalSavedArticles = [Article]()

class SavedArticlesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    ///Datasource
    var articles = [Article]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var refreshControl = UIRefreshControl()
    
    var isSelecting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .feedBackground
        collectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: ArticleCollectionViewCell.id)
        view.backgroundColor = .feedBackground
        collectionView.alwaysBounceVertical = true
        
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        title = "Saved Articles"
        
        
        
        if isSelecting {
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissVC))
            navigationItem.leftBarButtonItem?.tintColor = .black
        } else {
            navigationItem.hidesBackButton = false
            refreshControl.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
            collectionView.refreshControl = refreshControl
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        fetchArticles()
    }
    
    @objc func dismissVC() {
        globalSelectedSavedArticle = nil
        navigationController?.popViewController(animated: true)
    }
    @objc func refreshArticles() {
//        self.articles.removeAll()
//        collectionView.reloadData()
        fetchArticles()
    }
    private func fetchArticles() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.global.getSavedArticles(uid: uid) { (articles) in
            print("DEBUG: Recieved articles ", articles.enumerated())
            self.articles = articles
            self.refreshControl.endRefreshing()
        }
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if articles.isEmpty {
            self.collectionView.setEmptyMessage("No Saved Articles Yet!")
        } else {
            self.collectionView.restore()
        }
        return articles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCollectionViewCell.id, for: indexPath) as! ArticleCollectionViewCell
        cell.article = articles[indexPath.row]
        cell.isSelecting = isSelecting
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 142)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSelecting{
            globalSelectedSavedArticle = articles[indexPath.row]
            navigationController?.popViewController(animated: true)
        } else {
            
        }
        
    }
}
