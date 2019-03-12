//
//  FirebaseManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/19/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import Firebase
import SwiftLinkPreview

//MARK: Create User
class FirebaseManager {
    static let global = FirebaseManager()
    
    var friends = [FoggyUser]()
    var groups = [FoggyGroup](){
        didSet {
            let shared = UserDefaults.init(suiteName: sharedGroup)
            
            var groupIds = [String]()
            var groupNames = [String]()
            for group in groups {
                groupIds.append(group.id)
                groupNames.append(group.name)
            }
            shared?.set(groupNames, forKey: "Group Names")
            shared?.set(groupIds, forKey: "Group Ids")
//            let data = ["groups": groups]
//            shared?.set(data, forKey: "groups")
//            shared?.synchronize()
        }
    }
    
    typealias UserId = String?
    typealias ArticleId = String?
    typealias GroupId = String?
    
    //Completions
    typealias SucessFailCompletion = (Bool)->()
    typealias CreateUserCompletion = (Error?)->()
    typealias GetGroupsCompletion = ([String: [FoggyGroup]]?)->()
    typealias CreateGroupCompletion = (Bool, GroupId)->()
    typealias SendArticleCompletion = (Bool, ArticleId)->()
    typealias ArticleUploadCompletion = (Bool, ArticleId)->()
    typealias SavedArticlesCompletion = (Bool, [Article]?)->()
    
    ///Create user initally
    func createUser(uid: String, data: [String: Any], completion: @escaping CreateUserCompletion) {
        
        Firestore.firestore().collection("users").document(uid).setData(data) { (err) in
            if let err = err {
                completion(err)
                return
            }
            
            let userName = data["userName"] as? String ?? ""
            self.storeUsername(uid: uid, username: userName, completion: completion)
        }
    }
    
    ///Stores username in DB
    private func storeUsername(uid:String, username: String, completion:@escaping CreateUserCompletion) {
        let data = [username:uid]
        Database.database().reference().child("unames").updateChildValues(data, withCompletionBlock: { (err, ref) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
}

//MARK: Group
extension FirebaseManager {
    ///Gets all groups for user (pending and valid)
    func getGroups(uid: String, completion:@escaping GetGroupsCompletion) {
        print("Getting Groups for userId:", uid)
        self.groupData(uid: uid) { (groupData) in
            self.groupData(uid: uid, pending: true, completion: { (pendingData) in
                self.groups = groupData
                completion(["groups":groupData, "pending":pendingData])
            })
        }
    }
    
    ///Gets data for groups list
    private func groupData(uid: String, pending: Bool = false, completion: @escaping(([FoggyGroup])->())){
        let title = pending ? "pendingGroups" : "userGroups"
        var returnGroup = [FoggyGroup]()
        Database.database().reference().child(title).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let groups = snapshot.value as? [String: Any] {
                    for groupData in groups {
                        self.getGroup(groupId: groupData.key, completion: { (optionalGroup) in
                            if let group = optionalGroup {
                                returnGroup.append(group)
                            }
                            
                            if returnGroup.count == groups.count {
                                returnGroup.sort(by: { (f1, f2) -> Bool in
                                    return f1.name < f2.name
                                })
                                completion(returnGroup)
                            }
                        })
                    }
                }
            } else {
                completion(returnGroup)
            }
        }
    }
    
    ///Get data for group
    func getGroup(groupId: String, completion: @escaping (FoggyGroup?)->()){
        Firestore.firestore().collection("groups").document(groupId).getDocument { (snapshot, err) in
            if let err = err {
                print("Error getting group:", err.localizedDescription)
                completion(nil)
                return
            }
            if let snap = snapshot {
                if snap.exists {
                    print(snap, snap.exists.description)
                }
            }
            
            if let data = snapshot?.data() {
                let group = FoggyGroup(id: groupId, data: data)
                completion(group)
            } else {
                completion(nil)
            }
        }
    }
    
    ///Create group
    func createGroup(name: String, members: [SearchMember], completion: @escaping CreateGroupCompletion) {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        var memberIds = [String]()
        for member in members {
            if let data = member.foggyUser?.uid {
                memberIds.append(data)
            }
        }
        memberIds.append(uid)
        let data = ["name": name, "members": memberIds] as [String : Any]
        let ref = Firestore.firestore().collection("groups").document()
        ref.setData(data) { (err) in
            if let err = err {
                print("Error creating group:", err.localizedDescription)
                completion(false, nil)
                return
            }
            completion(true, ref.documentID)
        }
    }
    
    ///Adds group Id to users groups
    func addGroupToUsersGroups(uid: String, groupId: String, completion: @escaping SucessFailCompletion) {
        Database.database().reference().child("userGroups").child(uid).child(groupId).setValue(1) { (err, ref) in
            if let err = err {
                print("Error saving group to users groups", err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
}

///MARK: Articles
extension FirebaseManager {
    
    func swiftGetArticle(link: String?, completion: @escaping (Response?)->()){
        guard let link = link else {
            completion(nil)
            return
        }
        let s = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: .main, cache: DisabledCache.instance)
        s.preview(link, onSuccess: { (response) in
            completion(response)
        }) { (err) in
            print("Error!", err)
            completion(nil)
        }
    }
    
    ///Send Article to Group Feed
    func sendArticleToGroup(article: Article, groupId: String, completion: @escaping SendArticleCompletion){
        uploadArticle(article: article) { (uploadArticleSuccess, articleId) in
            if uploadArticleSuccess {
                let data: [String: Any] = ["senderId": article.shareUserId ?? "",
                            "timestamp": Date().timeIntervalSince1970,
                            "groupId": groupId,
                            "commentCount": 0,
                            "articleId":articleId!]
                let feedRef = Database.database().reference().child("feeds").child(groupId).childByAutoId()
                feedRef.setValue(data, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("Error Sending Article to Group:", err.localizedDescription)
                        completion(false, nil)
                    }
                    print("Uploaded Article To Group:", feedRef.parent?.description() ?? "")
                    completion(true, feedRef.parent?.description())
                })
            } else {
                completion(false, nil)
            }
        }
    }
    
    func sendArticleToGroups(article: Article, groups: [FoggyGroup], completion: @escaping SendArticleCompletion){
        uploadArticle(article: article) { (uploadArticleSuccess, aid) in
            if uploadArticleSuccess {
                ///Counter for how many groups sent to
                if groups.count == 0 {
                    completion(true, aid)
                    return
                }
                var sentCount = 0
                for group in groups {
                    
                    let data: [String: Any] = ["senderId": article.shareUserId ?? "",
                                               "timestamp": Date().timeIntervalSince1970,
                                               "groupId": group.id,
                                               "commentCount": 0,
                                               "articleId":aid]
                    
                    //Write to group feed
                    let feedRef = Database.database().reference().child("feeds").child(group.id).childByAutoId()
                    feedRef.setValue(data, withCompletionBlock: { (err, ref) in
                        if let err = err {
                            print("Error Sending Article to Group:", err.localizedDescription)
                            completion(false, nil)
                        }
                        sentCount += 1
                        print("Uploaded Article To Group:", feedRef.parent?.description() ?? "")
                        if sentCount == groups.count {
                            if let aid = aid {
                                completion(true, aid)
                            } else {
                                completion(true, "")
                            }
                            
                        }
                    })
                    
                    //Write to group members feeds
                    for userId in group.membersStringArray {
                        let userRef = Database.database().reference().child("homeFeed").child(userId).childByAutoId()
                        let homePostData = ["feedId": group.id, "postId": feedRef.key, "timestamp": Date().timeIntervalSince1970] as [String : Any]
                        userRef.setValue(homePostData)
                    }
                }
                
            } else {
                completion(false, nil)
            }
        }
    }
    
    private func uploadArticle(article: Article, completion: @escaping ArticleUploadCompletion) {
        let ref = Firestore.firestore().collection("articles").document()
        
        ref.setData(article.webData()) { (err) in
            if let err = err {
                print("Error Uploading Article:", err.localizedDescription)
                completion(false, nil)
                return
            }
            print("Uploaded Article to ", ref.documentID)
            
            completion(true, ref.documentID)
        }
    }
    
    private func getArticle(articleId: String, completion: @escaping (Article?)->()){
        Firestore.firestore().collection("articles").document(articleId).getDocument { (snapshot, err) in
            if let err = err {
                print("Error getting article:", err.localizedDescription)
                completion(nil)
                return
            }
            if let data = snapshot?.data() {
                let article = Article(id: articleId, data: data)
                completion(article)
            } else {
                completion(nil)
            }
            
        }
    }
    
    func saveArticle(uid: String, articleId: String, completion: @escaping SucessFailCompletion) {
        Database.database().reference().child("saved").child(uid).updateChildValues([articleId:1]) { (err, ref) in
            if let err = err {
                print("Error saving article:", err.localizedDescription)
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    func getSavedArticles(uid: String, completion: @escaping ([Article])->()){
        Database.database().reference().child("saved").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            print("Saved Article Count:", snapshot.childrenCount)
            var articles = [Article]()
            if let snap = snapshot.value as? [String: Any] {
                for articleId in snap {
                    self.getArticle(articleId: articleId.key, completion: { (article) in
                        if let article = article{
                            articles.append(article)
                            if articles.count == snapshot.childrenCount {
                                completion(articles)
                            }
                        }
                    })
                }
            } else {
                completion(articles)
            }
        }
    }
}

//MARK: Feed
extension FirebaseManager {
    func fetchFeed(feedId: String, lastPostPaginateKey: String?, completion: @escaping([SharePost])->()){
        if feedId == "Home" {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion([])
                return
            }
            fetchHomeFeed(feedId: uid, lastPostPaginateKey: lastPostPaginateKey, completion: completion)
            return
        }
        let ref = Database.database().reference().child("feeds").child(feedId)
        var query = ref.queryOrderedByKey()
        if let key = lastPostPaginateKey {
            query = query.queryEnding(atValue: key)
        }
        
        query.queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
            guard var posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            if let _ = lastPostPaginateKey {
                posts.removeLast()
            }
            
            var postsArray = [SharePost]()
            if posts.count == 0 {
                completion([])
            }
            posts.forEach({ (p) in
                
                var post = SharePost(id: p.key, data: p.value as! [String: Any])
                self.getArticle(articleId: post.articleId, completion: { (article) in
                    
                    //Set post to have Article
                    post.article = article
                    postsArray.append(post)
                    
                    //Once we get all SharePost articles fetched
                    if postsArray.count == posts.count {
                        
                        //Sort Array
                        postsArray.sort(by: { (p1, p2) -> Bool in
                            return p1.timestamp.compare(p2.timestamp) == .orderedDescending
                        })
                        
                        //Return
                        completion(postsArray)
                    }
                })
            })
        }
    }
    
    private func getSharePost(homeFeedPost: HomeFeedPost, completion: @escaping (SharePost)->()){
        Database.database().reference().child("feeds").child(homeFeedPost.feedId).child(homeFeedPost.postId).observeSingleEvent(of: .value) { (snapshot) in
            completion(SharePost(id: snapshot.key, data: snapshot.value as! [String: Any]))
        }
    }
    
    func fetchHomeFeed(feedId: String, lastPostPaginateKey: String?, completion: @escaping([SharePost])->()){
        let ref = Database.database().reference().child("homeFeed").child(feedId)
        var query = ref.queryOrderedByKey()
        if let key = lastPostPaginateKey {
            query = query.queryEnding(atValue: key)
        }
        
        query.queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
            guard var posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            if let _ = lastPostPaginateKey {
                posts.removeLast()
            }
            
            var postsArray = [SharePost]()
            if posts.count == 0 {
                completion([])
            }
            posts.forEach({ (p) in
                print("P value", p.key, p.value)
                let homeFeedPost = HomeFeedPost(key: p.key, data: p.value as! [String: Any])
                self.getSharePost(homeFeedPost: homeFeedPost, completion: { (post) in
                    var post = post
                    self.getArticle(articleId: post.articleId, completion: { (article) in
                        
                        //Set post to have Article
                        post.article = article
                        postsArray.append(post)
                        
                        //Once we get all SharePost articles fetched
                        if postsArray.count == posts.count {
                            
                            //Sort Array
                            postsArray.sort(by: { (p1, p2) -> Bool in
                                return p1.timestamp.compare(p2.timestamp) == .orderedDescending
                            })
                            
                            //Return
                            completion(postsArray)
                        }
                    })
                })
            })
        }
    }
}

extension FirebaseManager {
    func getFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("friends").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userIds = snapshot.value as? [String: Any] else { return }
            for userId in userIds {
                self.getFoggyUser(uid: userId.key, completion: { (user) in
                    if let user = user {
                        self.friends.append(user)
                    }
                })
            }
        }
    }
    
    func getFoggyUser(uid: String, completion: @escaping(FoggyUser?)->()){
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let snap = snapshot?.data(), let s = snapshot {
                completion(FoggyUser(key: s.documentID, data: snap))
            }
        }
    }
}
