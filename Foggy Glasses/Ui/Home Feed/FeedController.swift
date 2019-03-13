//
//  FeedController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple and Princess on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import Floaty
import Contacts
import ContactsUI
import PopupDialog

var globalArticles = [SharePost]()
var globalReturnVC: FeedController?

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    //MARK: Source Data
    var posts = [SharePost]()
    
    let readLimit:UInt = FirebaseManager.global.paginateLimit - 1
    var readOffset:UInt = FirebaseManager.global.paginateLimit
    
    //MARK: UI Elements
    let refresh = UIRefreshControl()
    
    ///Bool for displaying compose after creating a group. Set true before popping create group to root.
    var pushCompose = false
    
    var groupFeed: FoggyGroup? {
        didSet {
            self.title = groupFeed?.name
        }
    }
    
    static let openGroupCreate = Notification.Name("Open Group Create From Share Extension")
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
//        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    ///Stores UID to persistent container (NSUserDefaults) to be accessed from share extension
    func storeUidToPersistentContainer(uid: String){
        let shared = UserDefaults.init(suiteName: sharedGroup)
        
        shared?.set(uid, forKey: "Firebase User Id")
    }
    
    func removeUidFromPersistentContainer(){
        let shared = UserDefaults.init(suiteName: sharedGroup)
        shared?.removeObject(forKey: "Firebase User Id")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let user = Auth.auth().currentUser {
            storeUidToPersistentContainer(uid: user.uid)
        }
        
        //Config Collection view
        collectionView.backgroundColor = .feedBackground
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
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
        
//        fetchFeed()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
        if pushCompose {
            pushCompose = false
            globalReturnVC = self
            let quickshare = QuickshareController(collectionViewLayout: UICollectionViewFlowLayout())
            navigationController?.pushViewController(quickshare, animated: true)
        }
        refreshFeed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()
    }
    
    private func configRefreshControl() {
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    
    @objc func refreshFeed() {
        //Reset pagintate
        self.readOffset = FirebaseManager.global.paginateLimit
        
        posts.removeAll()
        fetchFeed()
    }
    
    private func configSideBar(){
        let side = SideMenuController(collectionViewLayout: UICollectionViewFlowLayout())
        side.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: side)
        menuLeftNavigationController.leftSide = true
        menuLeftNavigationController.menuWidth = view.frame.width - 80
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    private func fetchFeed(){
        var lastKey: String?
        if posts.count > 0 {
            lastKey = posts.last?.id
        }
        let feedId = groupFeed?.id ?? "Home"
        FirebaseManager.global.fetchFeed(feedId: feedId, lastPostPaginateKey: lastKey) { (sharePosts) in
            self.posts.append(contentsOf: sharePosts)
//            self.posts = sharePosts
            self.collectionView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    func configNav() {
        configNavigationBar()
//        [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
//        [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 17)]
        for font in UIFont.familyNames {
            print(font)
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Lato-Black", size: 17)!]
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
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    private func configUI() {
    }
    
    
    
    @objc func signoutClicked() {
        do {
            try? Auth.auth().signOut()
            
//            iterateKeychainItems(log: true, delete: true)
            
            let welcome = WelcomeController()
            let nav = UINavigationController(rootViewController: welcome)
            present(nav, animated: true, completion: nil)
            
            removeUidFromPersistentContainer()
        }
    }
    
    ///Method called when selecting create new group
    @objc func createGroupFromQuickshareExtension() {
        clickedNewGroup()
    }

}

//MARK: UICollectionView Methods
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (posts.count == 0) {
            self.collectionView.setEmptyMessage("Share an article with a Group or a Friend to get started!")
        } else {
            self.collectionView.restore()
        }
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item + 1) == readOffset {
            // Yes, scrolled to last row
            // Increase limit to load more from database
            readOffset += readLimit
            
            // Call function which loads data from database
            self.fetchFeed()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharePostCell.id, for: indexPath) as! SharePostCell
        if posts.count > 0 {
            cell.post = posts[indexPath.row]
            cell.postDelegate = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
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
//        let data = ["inviter":"Ryan Temple",
//                    "phone":"+19086359706"]
//        Database.database().reference().child("newGroup").childByAutoId().child("uid1234").updateChildValues(data)
        globalReturnVC = self
        navigationController?.pushViewController(QuickshareController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
    }
}

extension FeedController: SharePostProtocol {
    
    func clickedComments(post: SharePost) {
        print("Clicked Comments")
        let article = ArticleController(collectionViewLayout: UICollectionViewFlowLayout())
        article.post = post
        navigationController?.pushViewController(article, animated: true)
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
    
    func clickedGroup() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        
        navigationController?.pushViewController(feed, animated: true)
    }
    
    
}

extension FeedController: SideMenuProtocol {
    private func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
    }
    
    
    func clickedNewGroup() {
        globalReturnVC = self
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if self.checkForContactPermission() {
                self.navigationController?.pushViewController(CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
            } else {
                self.navigationController?.pushViewController(ContactPermissionController(), animated: true)
            }
        }
        
    }
    
    func clickedPendingGroup(group: FoggyGroup) {
    }
    
    func clickedGroup(group: FoggyGroup) {
        DispatchQueue.main.async {
//            self.dismiss(animated: true, completion: nil)
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            feed.groupFeed = group
            self.navigationController?.pushViewController(feed, animated: true)
        }
        
    }
    
    func clickedSavedArticles() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(SavedArticlesCollectionController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        }
        
    }
    
    func clickedHome() {
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            self.navigationController?.pushViewController(feed, animated: true)
        }
        
    }
}

extension FeedController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        print("Selected Contacts:", contacts)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("Selected contact", contact)
    }
}
