//
//  FeedController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import Floaty

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    //MARK: Source Data
    var posts = [SharePost]()
    
    //MARK: UI Elements
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        //Config Collection view
        collectionView.backgroundColor = .feedBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(SharePostCell.self, forCellWithReuseIdentifier: SharePostCell.id)
        
        configRefreshControl()
        configSideBar()
        configNav()
        configUI()
        
        let floaty = Floaty()
        floaty.buttonColor = .foggyBlue
        floaty.itemImageColor = .white
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
        
        fetchFeed()
    }
    
    private func configRefreshControl() {
        refresh.tintColor = .foggyGrey
        refresh.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    
    @objc func refreshFeed() {
        refresh.endRefreshing()
    }
    
    private func configSideBar(){
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SideMenuController())
        menuLeftNavigationController.leftSide = true
        menuLeftNavigationController.menuWidth = view.frame.width - 80
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    private func fetchFeed(){
        posts = SharePost.mockFeed()
        collectionView.reloadData()
    }
    
    func configNav() {
        configNavigationBar()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu Hamburger")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(openMenu))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Settings Wheel")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(openSettings))//UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func openSettings() {
        signoutClicked()
    }
    
    @objc func openMenu(){
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func dismissVC() {
//        let modalVC = ModalVC.instantiateFromStoryboard(self.storyboard!)
//        self.present(modalVC, animated: true, completion: nil)
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
//        dismiss(animated: true, completion: nil)
    }
    
    private func configUI() {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.text = "Firebase account created! Account ID\n\(Auth.auth().currentUser!.uid)"
//        view.addSubview(label)
//        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 100)
//        label.textAlignment = .center
//
//        let signOUt = UIButton(type: .system)
//        signOUt.setTitle("Sign Out", for: .normal)
//        signOUt.addTarget(self, action: #selector(signoutClicked), for: .touchUpInside)
//        view.addSubview(signOUt)
//        signOUt.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    
    @objc func signoutClicked() {
        do {
            try? Auth.auth().signOut()
            let welcome = WelcomeController()
            let nav = UINavigationController(rootViewController: welcome)
            present(nav, animated: true, completion: nil)
        }
    }

}

//MARK: UICollectionView Methods
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharePostCell.id, for: indexPath) as! SharePostCell
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension FeedController: FloatyDelegate {
    func emptyFloatySelected(_ floaty: Floaty) {
        navigationController?.pushViewController(QuickshareController(), animated: true)
    }
}

extension FeedController: SharePostProtocol {
    func clickedComments() {
        print("Clicked Comments")
        navigationController?.pushViewController(ArticleController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
    }
    
    func clickedArticle(article: Article) {
        let web = WebController()
        web.article = article
        navigationController?.pushViewController(web, animated: true)
    }
    
    func clickedMore() {
        print("Clicked More")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.isSpringLoaded = true
        alert.addAction(UIAlertAction(title: "Hide Article", style: .destructive, handler: { (action) in
            print("Hiding article")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func clickedGroup() {
        navigationController?.pushViewController(FeedController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
    }
    
    
}
