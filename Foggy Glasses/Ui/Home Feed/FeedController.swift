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
import FirebaseAuth
import UserNotifications
import Instructions
import SafariServices

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
    
    let coachMarksController = CoachMarksController()
    let floaty = Floaty()
    
    var homeFeed = true
    
    var groupFeed: FoggyGroup? {
        didSet {
            guard let groupFeed = groupFeed else { return }
            homeFeed = false
            if groupFeed.friendGroup {
                groupFeed.getFriendName { (friendName) in
                    self.title = friendName
                }
                self.navigationItem.rightBarButtonItem = nil
            } else {
                self.title = groupFeed.name
            }
            
        }
    }
    
    static let openGroupCreate = Notification.Name("Open Group Create From Share Extension")
    static let newNotificationData = Notification.Name("New Notification Data Recieved")
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeepLinkManager.shared.present(nav: self.navigationController, returnVC: self)
        
        if let user = Auth.auth().currentUser {
            storeUidToPersistentContainer(uid: user.uid)
        }
        
        //Config Collection view
        collectionView.backgroundColor = .feedBackground
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.register(SharePostCell.self, forCellWithReuseIdentifier: SharePostCell.id)
        collectionView.register(MultiGroupSharePostCell.self, forCellWithReuseIdentifier: MultiGroupSharePostCell.id2)
        collectionView.register(CuratedSharePostCell.self, forCellWithReuseIdentifier: CuratedSharePostCell.id)
        collectionView.register(MultiGroupCuratedSharePostCell.self, forCellWithReuseIdentifier: MultiGroupCuratedSharePostCell.id2)
        
        configRefreshControl()
        configSideBar()
        configNav()
        configUI()
        configFloaty()
        
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
//        refreshFeed()
//        fetchFeed()
    }
    
    private func configFloaty(){
        
        floaty.addItem("Share Article", icon: UIImage(named:"Share Button")) { (item) in
            let quickshare = QuickshareController(collectionViewLayout: UICollectionViewFlowLayout())
            self.navigationController?.pushViewController(quickshare, animated: true)
        }
        floaty.addItem("Create Group", icon: UIImage(named:"Group Icon")) { (item) in
            if self.checkForContactPermission() {
                let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
                self.navigationController?.pushViewController(create, animated: true)
            } else {
                let enable = ContactPermissionController()
                self.navigationController?.pushViewController(enable, animated: true)
            }
            
        }
        floaty.buttonColor = .foggyBlue
        floaty.itemImageColor = .white
        floaty.fabDelegate = self
        self.view.addSubview(floaty)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (success, error) in
            print("Success", success)
            if success {
                //Do not show walkthrough if pushing compose controller
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.refreshNotificationListeners()
                }
                
            }
            DispatchQueue.main.async {
                if self.pushCompose {
                    self.pushCompose = false
                } else {
                    if !WalkthroughManager.shared.hasShownSideHint() {
                        self.coachMarksController.start(in: .window(over: self))
                        return
                    } else if !WalkthroughManager.shared.hasShownShareHint() {
                        self.coachMarksController.start(in: .window(over: self))
                        return
                    }
                }
            }
            
        })
        
        
        
    }
    
    func refreshNotificationListeners() {
        print("Refreshing")
        FoggyUserPreferences.shared.groupInvites = true
        
        let refreshArticles = FoggyUserPreferences.shared.newArticles
        let refreshComments = FoggyUserPreferences.shared.newComment
        
        FoggyUserPreferences.shared.newArticles = refreshArticles
        FoggyUserPreferences.shared.newComment = refreshComments
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: FeedController.newNotificationData, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
        NotificationCenter.default.removeObserver(self, name: FeedController.newNotificationData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
        if pushCompose {
            globalReturnVC = self
            let quickshare = QuickshareController(collectionViewLayout: UICollectionViewFlowLayout())
            navigationController?.pushViewController(quickshare, animated: true)
        }
        FirebaseManager.global.getFriends()
        refreshFeed()
        configNav()
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
    
    @objc func notificationsNotify() {
        NotificationManager.shared.refreshData()
        let button = UIBarButtonItem.menuButton(self, action: #selector(openMenu), imageName: "Menu Hamburger", notifications: NotificationManager.shared.tabBarHasNotifications)
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func refreshFeed() {
        //Reset pagintate
        
        notificationsNotify()
        
        NotificationManager.shared.update()
        self.readOffset = FirebaseManager.global.paginateLimit
        
        //Must reset paginate key
        FirebaseManager.global.homeFeedLastPaginateKey = nil
        
//        NotificationManager.shared.update()
        
        posts.removeAll()
        collectionView.reloadSections(IndexSet(integer: 0))
        fetchFeed()
    }
    
    //Called when recieved new Notification Data
    @objc func updateData() {
        notificationsNotify()
        collectionView.reloadSections(IndexSet(integer: 0))
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
            print("Got feed", sharePosts)
//            self.posts.append(contentsOf: sharePosts)
//            self.posts = sharePosts
//            self.collectionView.reloadSections(IndexSet(integer: 0))
            FoggyUserPreferences.shared.update(groupId: feedId, count: sharePosts.count)
            
            // finally update the collection view
            DispatchQueue.main.async {
                self.append(sharePosts)
            }
            self.refresh.endRefreshing()
        }
    }
    
    //Add the cells cleanly
    private func append(_ objectsToAdd: [SharePost]) {
        for i in 0 ..< objectsToAdd.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.025) {
                self.posts.append(objectsToAdd[i])
                self.collectionView?.insertItems(at: [IndexPath(item: self.posts.count - 1, section: 0)])
            }
        }
    }
    
    func configNav() {
        configNavigationBar()
//        [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
//        [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 17)]
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Lato-Black", size: 17)!]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
        
        
        
        if let group = groupFeed, group.friendGroup {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem.settingsButton(self, action: #selector(openSettings), imageName: "Settings Wheel", notifications: !WalkthroughManager.shared.hasShownQS())
        }
        
        //UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func openSettings() {
        if let _ = groupFeed?.id {
            let group = GroupSettingsController(collectionViewLayout: UICollectionViewFlowLayout())
            group.group = groupFeed
            navigationController?.pushViewController(group, animated: true)
        } else {
            navigationController?.pushViewController(MainSettingsController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        }
    }
    
    @objc func openMenu(){
        coachMarksController.stop()
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
            FirebaseManager.global.friends.removeAll()
            FeedHideManager.global.refreshUser()
            
            let welcome = WelcomeController()
            let nav = UINavigationController(rootViewController: welcome)
            present(nav, animated: true, completion: nil)
                    }
    }
    
    ///Method called when selecting create new group
    @objc func createGroupFromQuickshareExtension() {
        return
    }

}

//MARK: UICollectionView Methods
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (posts.count == 0) {
            let feedId = groupFeed?.id ?? "Home"
            if FoggyUserPreferences.shared.shouldShowEmptyGroupLoading(id: feedId){
                self.collectionView.setEmptyMessage("Share an article with a Group or a Friend to get started!")
            } else {
                self.collectionView.setLoadingScreen()
            }
            
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
            let currentPost = posts[indexPath.row]
            
            //Clear the posts for this comment
            NotificationManager.shared.seen(groupId: currentPost.groupId ?? "", postId: currentPost.id)
            if currentPost.comments == 0 {
                NotificationManager.shared.openedComments(groupId: currentPost.groupId ?? "", postId: currentPost.id)
            }
            //Configure for MultiGroupPosts
            if currentPost is MultiGroupSharePost {
//                print("MultiGroup share post found")
                if currentPost.curated {
                    let multi = currentPost as! MultiGroupSharePost
                    let multiGroupCell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiGroupCuratedSharePostCell.id2, for: indexPath) as!  MultiGroupCuratedSharePostCell
                    multiGroupCell.multiGroupPost = posts[indexPath.row] as? MultiGroupSharePost
                    multiGroupCell.postDelegate = self
                    multiGroupCell.feedDelegate = self
                    multiGroupCell.indexPath = indexPath
                    multiGroupCell.hideFromFeed = FeedHideManager.global.isHidden(id: multi.id)
                    return multiGroupCell
                } else {
                    let multi = currentPost as! MultiGroupSharePost
                    let multiGroupCell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiGroupSharePostCell.id2, for: indexPath) as! MultiGroupSharePostCell
                    multiGroupCell.multiGroupPost = posts[indexPath.row] as? MultiGroupSharePost
                    multiGroupCell.postDelegate = self
                    multiGroupCell.feedDelegate = self
                    multiGroupCell.indexPath = indexPath
                    multiGroupCell.hideFromFeed = FeedHideManager.global.isHidden(id: multi.id)
                    return multiGroupCell
                }
                
            } else if currentPost.curated {
                print("Curated")
                let curatedCell = collectionView.dequeueReusableCell(withReuseIdentifier: CuratedSharePostCell.id, for: indexPath) as! CuratedSharePostCell
                
                curatedCell.post = posts[indexPath.row]
                curatedCell.postDelegate = self
                curatedCell.feedDelegate = self
                curatedCell.indexPath = indexPath
                curatedCell.hideFromFeed = FeedHideManager.global.isHidden(id: curatedCell.post.id)
                
                return curatedCell
            } else {
                cell.post = posts[indexPath.row]
                cell.postDelegate = self
                cell.feedDelegate = self
                cell.indexPath = indexPath
                cell.hideFromFeed = FeedHideManager.global.isHidden(id: cell.post.id)
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = posts[indexPath.row]
        
        
        if FeedHideManager.global.isHidden(id: post.id) {
            if post.curated && !(post is MultiGroupSharePost) {
                return CGSize(width: view.frame.width, height: 80)
            }
            return CGSize(width: view.frame.width, height: 80)
        }
        if post.curated && !(post is MultiGroupSharePost)  {
            return CGSize(width: view.frame.width, height: 200 - 40)
        }
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

extension FeedController: FeedCellInteractionsDelegate {
    func didHide(indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
}

extension FeedController: FloatyDelegate {
    func emptyFloatySelected(_ floaty: Floaty) {
//        let data = ["inviter":"Ryan Temple",
//                    "phone":"+19086359706"]
//        Database.database().reference().child("newGroup").childByAutoId().child("uid1234").updateChildValues(data)
        globalReturnVC = self
        let quickshare = QuickshareController(collectionViewLayout: UICollectionViewFlowLayout())
        
        navigationController?.pushViewController(quickshare, animated: true)
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        print("Did Close")
        if let parent = parent as? UINavigationController  {
            if parent.viewControllers.count == 1 {
                if !WalkthroughManager.shared.hasShownSideHint() {
                    print("Show Next")
                    coachMarksController.start(in: .window(over: self))
                    //            coachMarksController.restoreAfterChangeDidComplete()
                }
            }
        }
    }
    
    func floatyOpened(_ floaty: Floaty) {
        coachMarksController.stop()
    }
}

extension FeedController: SharePostProtocol {
    
    func clickedComments(post: SharePost) {
        print("Clicked Comments")
        let article = ArticleController(collectionViewLayout: UICollectionViewFlowLayout())
        article.post = post
        
        //Clears the notification for this post comments
        NotificationManager.shared.openedComments(groupId: post.groupId ?? "", postId: post.id)
        navigationController?.pushViewController(article, animated: true)
    }
    
    func clickedArticle(article: Article, post: SharePost?) {
//        let web = WebController()
        guard let url = URL(string: article.link) else { return }
        FirebaseManager.global.userArticleEngagement(articleId: article.id, userId: Auth.auth().currentUser?.uid ?? "", groupId: post?.groupId ?? "", shareUserId: article.shareUserId ?? "", curated: false)
        let safari = SafariController(url: url)
        present(safari, animated: true, completion: nil)
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
        
//        alert.addAction(UIAlertAction(title: "Curate", style: .default, handler: { (action) in
//            Functions.functions().httpsCallable("testRecommend").call { (result, err) in
//                print("", result)
//            }
//        }))
        
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
//            self.dismiss(animated: true, completion: nil)
            if self.checkForContactPermission() {
                let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
                self.navigationController?.pushViewController(create, animated: false)
                
                SideMenuManager.default.menuLeftNavigationController!.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.pushViewController(ContactPermissionController(), animated: false)
                
                SideMenuManager.default.menuLeftNavigationController!.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func clickedPendingGroup(group: FoggyGroup) {
        DispatchQueue.main.async {
            //            self.dismiss(animated: true, completion: nil)
            let feed = PendingGroupController()
            feed.groupFeed = group
            self.navigationController?.pushViewController(feed, animated: false)
            SideMenuManager.default.menuLeftNavigationController!.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func clickedGroup(group: FoggyGroup) {
        DispatchQueue.main.async {
//            self.dismiss(animated: true, completion: nil)
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            feed.groupFeed = group
            
            //Check if current VC is the selected group
            if let top = self.navigationController?.topViewController as? FeedController {
                if top.groupFeed?.id == group.id {
                    print("DEBUG: Showing this feed already!")
                    return
                }
            }
            
            self.navigationController?.pushViewController(feed, animated: false)
            SideMenuManager.default.menuLeftNavigationController!.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func clickedSavedArticles() {
        DispatchQueue.main.async {
//            self.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(SavedArticlesCollectionController(collectionViewLayout: UICollectionViewFlowLayout()), animated: false)
            
            SideMenuManager.default.menuLeftNavigationController!.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func clickedHome() {
        
        DispatchQueue.main.async {
//            self.dismiss(animated: true, completion: nil)
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            self.navigationController?.pushViewController(feed, animated: false)
            
            SideMenuManager.default.menuLeftNavigationController!.dismiss(animated: true, completion: nil)
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

extension FeedController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if !WalkthroughManager.shared.hasShownShareHint() {
            return 2
        } else if !WalkthroughManager.shared.hasShownSideHint() {
            return 1
        }
        return 0
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        if !WalkthroughManager.shared.hasShownShareHint() {
            if index == 0 {
                return coachMarksController.helper.makeCoachMark(for: self.floaty)
            } else {
                return coachMarksController.helper.makeCoachMark(for: self.navigationItem.leftBarButtonItem?.customView ?? self.view)
            }
        } else if !WalkthroughManager.shared.hasShownSideHint() {
            return coachMarksController.helper.makeCoachMark(for: self.navigationItem.leftBarButtonItem?.customView ?? self.view)
        }
        return coachMarksController.helper.makeCoachMark()
        
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        if !WalkthroughManager.shared.hasShownShareHint() {
            if index == 0 {
                let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                coachViews.bodyView.hintLabel.text = "Create New Group or Share Article!"
                coachViews.bodyView.nextLabel.text = "Next"
                
                WalkthroughManager.shared.showShareHint()
                return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
            }  else if index == 1 {
                let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                coachViews.bodyView.hintLabel.text = "View your Groups and Saved Articles"
                coachViews.bodyView.nextLabel.text = "Done"
                
                WalkthroughManager.shared.showSideHint()
                return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
            }
        } else if !WalkthroughManager.shared.hasShownSideHint() {
            let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
            
            coachViews.bodyView.hintLabel.text = "View your Groups and Saved Articles"
            coachViews.bodyView.nextLabel.text = "Done"
            
            WalkthroughManager.shared.showSideHint()
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        }
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.hintLabel.text = "Create New Group or Share Article!"
        coachViews.bodyView.nextLabel.text = "Done"
        
        WalkthroughManager.shared.showShareHint()
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: inout CoachMark, beforeChanging change: ConfigurationChange, at index: Int) {
        print("Will show")
//        if index == 1 {
        coachMark.allowTouchInsideCutoutPath = true
//        if index == 0 {
//            coachMarksController.flow.pause()
//            present(SideMenuManager.default.menuLeftNavigationController!, animated: true) {
//                self.coachMarksController.helper.updateCurrentCoachMark()
//                self.coachMarksController.flow.resume()
//            }
//        }
        
//        }
    }
    
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool {
//        if index == 0 {
//            print("Hello")
//            return false
//        }
//        if index == 0 {
//            return false
//        }
        return true
    }
    
}
