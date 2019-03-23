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
import FirebaseAuth
import SwiftLinkPreview

//MARK: Create User
class FirebaseManager {
    static let global = FirebaseManager()
    
    var paginateLimit: UInt = 5
    
    var foggyUser: FoggyUser?
    
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
            self.linkAdditionalData(completion: completion)
        })
    }
    
    ///Links additional data from Dynamic Link Invation
    private func linkAdditionalData(completion: @escaping CreateUserCompletion){
        if let referId = UserDefaults.standard.string(forKey: "invitedby"), let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.makeFriends(senderId: referId, recieverId: uid) { (success) in
                if let groupId = UserDefaults.standard.string(forKey: "groupId") {
                    self.addGroupToUsersPendingGroups(uid: uid, groupId: groupId) { (complete) in
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
        
        
    }
}

//MARK: Group
extension FirebaseManager {
    ///Gets all groups for user (pending and valid)
    func getGroups(uid: String, completion:@escaping GetGroupsCompletion) {
        print("Getting Groups for userId:", uid)
        getFoggyUser(uid: uid) { (user) in
            self.foggyUser = user
            self.groupData(uid: uid) { (groupData) in
                self.groupData(uid: uid, pending: true, completion: { (pendingData) in
                    self.groups = groupData
                    completion(["groups":groupData, "pending":pendingData])
                })
            }
        }
        
    }
    
    ///Gets data for groups list
    private func groupData(uid: String, pending: Bool = false, completion: @escaping(([FoggyGroup])->())){
        let title = pending ? "userPendingGroups" : "userGroups"
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
            
            if let data = snapshot?.data() {
                let group = FoggyGroup(id: groupId, data: data)
                completion(group)
            } else {
                completion(nil)
            }
        }
    }
    
    //Gets multiple groupData, used for MultiGroupSharePost
    func getGroups(groupIds: [String], completion: @escaping ([FoggyGroup])->()){
        var groups = [FoggyGroup]()
        for groupId in groupIds {
            Firestore.firestore().collection("groups").document(groupId).getDocument { (snapshot, err) in
                if let err = err {
                    print("Error getting group:", err.localizedDescription)
                    completion(groups)
                    return
                }
                
                if let data = snapshot?.data() {
                    let group = FoggyGroup(id: groupId, data: data)
                    groups.append(group)
                    if groups.count == groupIds.count {
                        completion(groups)
                    }
                } else {
                    completion(groups)
                }
            }
        }
        
    }
    
    ///Creates group, adds userId to members, returns new Group Id
    func createGroup(name: String, members: [SearchMember], completion: @escaping CreateGroupCompletion) {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        self.getFoggyUser(uid: uid) { (user) in
            guard let user = user else {
                completion(false, nil)
                return
            }
            //Add the current user to Members
            var memberIds = [String]()
            memberIds.append(uid)
            let data = ["name": name, "members": memberIds, "adminUsername":user.username, "adminId":user.uid] as [String : Any]
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
    
    ///Adds group Id to users pending groups
    func addGroupToUsersPendingGroups(uid: String, groupId: String, completion: @escaping SucessFailCompletion) {
        Database.database().reference().child("userPendingGroups").child(uid).child(groupId).setValue(1) { (err, ref) in
            if let err = err {
                print("Error saving group to users groups", err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func joinGroup(group: FoggyGroup, uid: String, completion: @escaping SucessFailCompletion) {
        //Remove From Pending Groups
        //Add to User Groups
        //Add Member to Group Members
        Database.database().reference().child("userPendingGroups").child(uid).child(group.id).removeValue { (err, ref) in
            if let err = err{
                print("Error removing group from pending groups", err)
                completion(false)
            }
            self.addGroupToUsersGroups(uid: uid, groupId: group.id, completion: { (complete) in
                if !complete {
                    print("Error adding group to users groups")
                    completion(false)
                    return
                }
                var newMember = group.membersStringArray
                newMember.append(uid)
                //TODO: Could be runtime issue adding members?
                let fields = ["members": newMember]
                Firestore.firestore().collection("groups").document(group.id).updateData(fields, completion: { (err) in
                    if let err = err {
                        print("Error adding member to group")
                        completion(false)
                        return
                    }
                    self.makeFriends(senderId: group.adminId, recieverId: uid, completion: completion)
                })
            })
        }
    }
    
    func rejectGroup(group: FoggyGroup, uid: String, completion: @escaping SucessFailCompletion) {
        //Remove From Pending Groups
        //Add to User Groups
        //Add Member to Group Members
        Database.database().reference().child("userPendingGroups").child(uid).child(group.id).removeValue { (err, ref) in
            if let err = err{
                print("Error removing group from pending groups", err)
                completion(false)
            }
            completion(true)
        }
    }
}

///MARK: Articles
extension FirebaseManager {
    ///Swift Link Preview Library Get Article
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
    
    ///Convert Response to Firebase Data
    func convertResponseToFirebaseData(articleText: String?, response: Response)->[String:Any] {
        
        var data: [String: Any] = ["url":response.finalUrl?.absoluteString ?? "",
                                   "description": response.description ?? "",
                                   "shareUserId":Auth.auth().currentUser?.uid ?? "",
                                   "canonicalUrl": response.canonicalUrl ?? ""]
        
        //Get the custom title or article title
        if let text = articleText{
            data["title"] = text
        } else {
            data["title"] = response.title ?? ""
        }
        
        if let imageUrlString = response.image {
            data["imageUrlString"] = imageUrlString
        }
        
        return data
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
    
    func sendArticleToGroups(article: Article, groups: [FoggyGroup], comment: String?, completion: @escaping SendArticleCompletion){
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, nil)
            return
        }
        uploadArticle(article: article) { (uploadArticleSuccess, aid) in
            if uploadArticleSuccess {
                ///Counter for how many groups sent to
                if groups.count == 0 {
                    completion(true, aid)
                    return
                }
                var sentCount = 0
                var commentSentCount = 0
                for group in groups {
                    //Get the comment count if they added one
                    var commentCount = 0
                    if let comment = comment, comment.count > 0 {
                        commentCount = 1
                    }
                    let data: [String: Any] = ["senderId": article.shareUserId ?? "",
                                               "timestamp": Date().timeIntervalSince1970,
                                               "groupId": group.id ?? "",
                                               "commentCount": commentCount,
                                               "articleId":aid ?? ""]
                    
                    //Write to group feed
                    let feedRef = Database.database().reference().child("feeds").child(group.id).childByAutoId()
                    feedRef.setValue(data, withCompletionBlock: { (err, ref) in
                        if let err = err {
                            print("Error Sending Article to Group:", err.localizedDescription)
                            completion(false, nil)
                        }
                        sentCount += 1
                        print("Uploaded Article To Group:", group.id)
                        
                        //If they attached a comment
                        if commentCount == 1 {
                            //Genereate temp data
                            let comment = FoggyComment(id: "tmp", data: ["uid": uid,
                                                                         "text":comment!,
                                                                         "timestamp":Date().timeIntervalSince1970])
                            var post = SharePost(id: feedRef.key ?? "", data: [:])
                            post.groupId = group.id
                            //Upload comment
                            FirebaseManager.global.postComment(comment: comment, post: post, completion: { (success) in
                                if success {
                                    //Implement commentsent var
                                    commentSentCount += 1
                                    //Once all sent, complete
                                    if commentSentCount == groups.count {
                                        if let aid = aid {
                                            completion(true, aid)
                                        } else {
                                            completion(true, "")
                                        }
                                    }
                                }
                            })
                        } else {
                            //No comment attached so check to see if it was sent to all groups
                            if sentCount == groups.count {
                                if let aid = aid {
                                    
                                    completion(true, aid)
                                } else {
                                    completion(true, "")
                                }
                            }
                        }
                        
                    })
                    
                    //Write to group members feeds
                    for userId in group.membersStringArray {
                        
                        let userRef = Database.database().reference().child("homeFeed").child(userId).childByAutoId()
                        
                        if uid == userId && groups.count > 1 {
                            //Do nothing if its current user multiGroup post
                            
                        } else {
                            let homePostData = ["feedId": group.id ?? "", "postId": feedRef.key ?? "", "timestamp": Date().timeIntervalSince1970] as [String : Any]
                            userRef.setValue(homePostData)
                        }
                        
                    }
                }
                
                //If its a multiGroup post write it once to users home feed
                if groups.count > 1 {
                    let userRef = Database.database().reference().child("homeFeed").child(uid).childByAutoId()
                    var groupIds = [String]()
                    for gid in groups {
                        groupIds.append(gid.id)
                    }
                    let multiGroupData = ["senderId":uid, "articleId":aid, "timestamp": Date().timeIntervalSince1970, "groupIds": groupIds, "multiGroup": true] as [String : Any]
                    userRef.setValue(multiGroupData)
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
            print("Fetching Home Feed")
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
        
        query.queryLimited(toLast: paginateLimit).observeSingleEvent(of: .value) { (snapshot) in
            guard var posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            
            if posts.count == 0 {
                completion([])
            }
            
            if let _ = lastPostPaginateKey {
                posts.removeLast()
            }
            
            var postsArray = [SharePost]()
            
            posts.forEach({ (p) in
                
                let post = SharePost(id: p.key, data: p.value as! [String: Any])
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
        
        query.queryLimited(toLast: paginateLimit).observeSingleEvent(of: .value) { (snapshot) in
            guard var posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            
            if posts.count == 0 {
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
                
                let value = p.value as? [String: Any] ?? [:]
                let isMultiGroup = value["multiGroup"] as? Bool ?? false
                if isMultiGroup {
                    //Configure multi-group posts
                    let multiGroupPost = MultiGroupSharePost(id: p.key, data: p.value as! [String : Any])
                    self.getArticle(articleId: multiGroupPost.articleId, completion: { (article) in
                        
                        //Set post to have Article
                        multiGroupPost.article = article
                        postsArray.append(multiGroupPost)
                        
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
                } else {
                    //Configure regular home feed post
                    let homeFeedPost = HomeFeedPost(key: p.key, data: p.value as! [String: Any])
                    self.getSharePost(homeFeedPost: homeFeedPost, completion: { (post) in
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
            })
        }
    }
}

//Friends
extension FirebaseManager {
    func getFoggyFriends(completion: @escaping ([FoggyUser])->()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
            
        }
        Database.database().reference().child("friends").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userIds = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            var friends = [FoggyUser]()
            for userId in userIds {
                self.getFoggyUser(uid: userId.key, completion: { (user) in
                    if let user = user {
                        friends.append(user)
                        if friends.count == userIds.count {
                            completion(friends)
                        }
                    }
                })
            }
        }
    }
    func getFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("friends").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userIds = snapshot.value as? [String: Any] else { return }
            var users = [FoggyUser]()
            for userId in userIds {
                self.getFoggyUser(uid: userId.key, completion: { (user) in
                    if let user = user {
                        users.append(user)
                        
                        if users.count == userIds.count  {
                            self.friends = users
                        }
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
    
    func makeFriends(senderId: String, recieverId: String, completion: @escaping SucessFailCompletion) {
        let senderValue = [recieverId: 1]
        let receiverValue = [senderId: 1]
        Database.database().reference().child("friends").child(senderId).setValue(senderValue) { (err, ref) in
            if let err = err {
                completion(false)
            }
            Database.database().reference().child("friends").child(recieverId).setValue(receiverValue, withCompletionBlock: { (err, ref) in
                if let err = err {
                    completion(false)
                }
                FirebaseManager.global.getFriends()
                completion(true)
            })
        }
    }
}

//Comments
extension FirebaseManager {
    func fetchComments(post: SharePost, completion: @escaping ([FoggyComment])->()){
        guard let groupId = post.groupId else {
            print("No Group Id when fetching comments")
            completion([])
            return
        }
        Database.database().reference().child("Comments").child(groupId).child(post.id).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(), let comments = snapshot.value as? [String: Any] {
                var returnComments = [FoggyComment]()
                for c in comments {
                    if let data = c.value as? [String: Any] {
                        let comment = FoggyComment(id: c.key, data: data)
                        returnComments.append(comment)
                    }
                }
                
                returnComments.sort(by: { (c1, c2) -> Bool in
                    return c1.timestamp < c2.timestamp
                })
                completion(returnComments)
            } else {
                completion([])
            }
        }) { (err) in
            print(err.localizedDescription)
            completion([])
        }
    }
    
    func postComment(comment: FoggyComment, post: SharePost, completion: @escaping SucessFailCompletion) {
        guard let groupId = post.groupId else {
            print("No Group Id when fetching comments")
            completion(false)
            return
        }
        Database.database().reference().child("Comments").child(groupId).child(post.id).childByAutoId().setValue(comment.webData()) { (err, ref) in
            if let err = err {
                print("Failed posting comment", err.localizedDescription)
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    func increaseCommentCount(post: SharePost, completion: @escaping (Bool, Int?)->()) {
        guard let groupId = post.groupId else {
            print("No Group Id when fetching comments")
            completion(false, nil)
            return
        }
        let ref = Database.database().reference().child("feeds").child(groupId).child(post.id).child("commentCount")
        
        ref.runTransactionBlock({ (data) -> TransactionResult in
            var value = data.value as? Int
            
            if value == nil {
                value = 0
            }
            
            data.value = value! + 1
            return TransactionResult.success(withValue: data)
            
        }) { (err, commited, snapshot) in
            if commited {
                if let upvotes = snapshot?.value as? Int{
                    completion(true, upvotes)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    func searchForUser(search: String, completion: @escaping ([SearchMember]) -> ()) {
        var query: Query!
        query = Firestore.firestore().collection("users").whereField("userName", isGreaterThanOrEqualTo: search).limit(to: 10)
        query.getDocuments { (querySnapshot, err) in
            var users = [SearchMember]()
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion(users)
            } else {
                var count = 0
                for document in querySnapshot!.documents {
                    
                    let user = FoggyUser(key: document.documentID, data: document.data())
                    var member = SearchMember()
                    member.id = count
                    member.searchUser = user
                    users.append(member)
                    count += 1
                }
                completion(users)
            }
        }
    }
}

extension FirebaseManager {
    func sendDynamicLinkInvite(dynamicLinkId: String, groupId:String, invitedByUid: String) {
        
        let data: [String: Any] = ["invitedBy": invitedByUid,
                                   "phoneNumber":"+19086357906",
                                   "dynamicLink":dynamicLinkId]
        Database.database().reference().child("newGroup").child(groupId).childByAutoId().setValue(data) { (err, ref) in
            if let err = err {
                print("Err", err)
            }
        }
    }
}
