//
//  SavedArticlesCollectionController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

var globalSelectedSavedArticle: Article?

var globalSavedArticles = [Article]()

func getGlobalArticles() {
    globalSavedArticles.removeAll()
   let article = Article(id: "1", data: ["title":"Rep. Omar rips GOP",
                                          "imageUrl":""])
    let article1 = Article(id: "2", data: ["title":"Do you article",
                                          "imageUrl":""])
    globalSavedArticles.append(article)
    globalSavedArticles.append(article1)
}

class SavedArticlesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    ///Datasource
    var articles = [Article]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .feedBackground
        collectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: ArticleCollectionViewCell.id)
        view.backgroundColor = .feedBackground
        
        title = "Saved Articles"
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        fetchArticles()
    }
    
    @objc func dismissVC() {
        globalSelectedSavedArticle = nil
        navigationController?.popViewController(animated: true)
    }
    
    private func fetchArticles() {
        articles = globalSavedArticles
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCollectionViewCell.id, for: indexPath) as! ArticleCollectionViewCell
        cell.article = articles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        globalSelectedSavedArticle = articles[indexPath.row]
        navigationController?.popViewController(animated: true)
    }
}
