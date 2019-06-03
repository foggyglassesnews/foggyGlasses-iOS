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
    
    var paginateLimit: UInt = 15
    
    //Used for paginating HOME Feed, must reset when refreshing
    var homeFeedLastPaginateKey: TimeInterval? {
        didSet {
            print("DEBUG: Home feed pagination key set", homeFeedLastPaginateKey ?? 0)
        }
    }
    
    var foggyUser: FoggyUser? {
        didSet {
            print("DEBUG: Manager updated current user")
            FoggyUserPreferences.shared.user = foggyUser
            NotificationManager.shared.getUserData()
        }
    }
    
    ///Keeps reference to signup/login email for phone verification
    var userEmail: String?
    
    var friends = [FoggyUser]()
    var pendingGroups = [FoggyGroup]() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("New Notification Data Recieved"), object: nil)
        }
    }
    var groups = [FoggyGroup](){
        didSet {
            
            //Caching groups using disctionary to store in user defaults
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let shared = UserDefaults.init(suiteName: "group.posttogroups.foggyglassesnews.com")
            
            var groupUsersDictionary = [String:[String]]()
            var groupNamesDictionary = [String: String]()
            
            for group in groups {
                groupNamesDictionary[group.id] = group.name
                groupUsersDictionary[group.id] = group.membersStringArray
            }

//            print("Group Names", groupNamesDictionary)
//            print("Group Users", groupUsersDictionary)
            
            shared?.set(groupUsersDictionary, forKey: "GroupUsers-"+uid)
            shared?.set(groupNamesDictionary, forKey: "GroupNames-"+uid)
            shared?.synchronize()
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
    
    func persistCredentials(uid:String, facebookToken: String?, email: String?, pass: String?) {
        let shared = UserDefaults.init(suiteName: "group.posttogroups.foggyglassesnews.com")
        if let token = facebookToken {
            shared?.set(true, forKey: "Facebook-"+uid)
            shared?.set(token, forKey: "FBToken-"+uid)
            shared?.synchronize()
            return
        }
        
        if let email = email, let pass = pass {
            shared?.set(false, forKey: "Facebook-"+uid)
            shared?.set(email, forKey: "Email-"+uid)
            shared?.set(pass, forKey: "Pass-"+uid)
            shared?.synchronize()
        }
    }
    
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
    
    ///Delete account friend/group data
    func deleteUser(uid: String, completion: @escaping SucessFailCompletion) {
        //Clear group data
        for group in groups {
            leaveGroup(group: group, uid: uid) { (left) in
                print("Did leave group \(group.id)", left)
            }
        }
        
        //Remove friends
        for friend in friends {
            removeFriends(uid1: friend.uid, uid2: uid)
        }
        
        //Remove username
        Database.database().reference().child("unames").child(foggyUser?.username ?? "").removeValue()
        
        //Remove Friends
        friends.removeAll()
        
        completion(true)
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
            FirebaseManager.global.getCurrentUser()
            FirebaseManager.global.makeFriends(senderId: referId, recieverId: uid) { (success) in
                if let groupId = UserDefaults.standard.string(forKey: "groupId") {
                    self.addGroupToUsersPendingGroups(uid: uid, groupId: groupId) { (complete) in
                        self.clearDefaults()
                        completion(nil)
                    }
                } else {
                    self.clearDefaults()
                    completion(nil)
                }
            }
        } else {
            self.clearDefaults()
            completion(nil)
        }
    }
    
    private func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: "invitedby")
        UserDefaults.standard.removeObject(forKey: "groupId")
    }
    
    ///Fetches user preferences and
    func getUserPreferences(uid:String) {
        Database.database().reference().child("preferences").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let dict = snapshot.value as? [String: Any]  {
                    let groupInvitesEnabled = dict["groupInvites"] as? Bool ?? true
                    FoggyUserPreferences.shared.groupInvites = groupInvitesEnabled
                    
                    let sharedArticleEnabled = dict["sharedArticle"] as? [String: Bool] ?? [:]
                    FoggyUserPreferences.shared.newArticles = sharedArticleEnabled
                    let commentsEnable = dict["newComment"] as? [String: Bool] ?? [:]
                    FoggyUserPreferences.shared.newComment = commentsEnable
                }
                
            }
        }
    }
    
    ///Sets the user preference for notificaitons on Groups, New Invitations and Comments
    func setPreference(uid: String, child: String, value: Bool, groupId: String? = nil) {
        if let groupId = groupId {
            Database.database().reference().child("preferences").child(uid).child(child).child(groupId).setValue(value)
            
            return
        }
        Database.database().reference().child("preferences").child(uid).child(child).setValue(value)
    }
    
    ///Removes the Group Preference when leaving a group
    func removePreference(uid: String, groupId: String) {
        Database.database().reference().child("preferences").child(uid).child("newComment").child(groupId).removeValue()
        Database.database().reference().child("preferences").child(uid).child("sharedArticle").child(groupId).removeValue()
    }
}

//MARK: Group
extension FirebaseManager {
    ///Gets all groups for user (pending and valid)
    func getGroups(uid: String, completion:@escaping GetGroupsCompletion) {
        print("DEBUG: Getting Groups for userId:", uid)
        
        getFoggyUser(uid: uid) { (user) in
            self.foggyUser = user
            self.groupData(uid: uid) { (groupData) in
                self.groupData(uid: uid, pending: true, completion: { (pendingData) in
                    self.groups = groupData
                    self.pendingGroups = pendingData
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
    
    
    func createFriendGroup(id: String, members:[String], completion: @escaping SucessFailCompletion){
        let data = ["name": "Foggy Friend", "members": members, "friendGroup":true] as [String : Any]
        let ref = Firestore.firestore().collection("groups").document(id)
        ref.setData(data) { (err) in
            if let err = err {
                print("Error creating group:", err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
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
    
    func leaveGroup(group: FoggyGroup, uid: String, completion: @escaping SucessFailCompletion) {
        //Remove from user groups
        //Remove uid from firestore group
        //Delete group post data from user homefeed
        //Unsubscribe from notifications
        
        Database.database().reference().child("userGroups").child(uid).child(group.id).removeValue { (err, ref) in
            if let err = err{
                print("Error removing group from pending groups", err)
                completion(false)
            }
            self.removePreference(uid: uid, groupId: group.id)
            NotificationManager.shared.leaveGroup(groupId: group.id)
            let firestoreGroupRef = Firestore.firestore().collection("groups").document(group.id)
            firestoreGroupRef.getDocument(completion: { (snapshot, err) in
                if let err = err {
                    print("error geting group users", err.localizedDescription)
                    completion(false)
                }
                if let data = snapshot?.data(), let members = data["members"] as? [String]{
                    var newMembers = [String]()
                    for member in members{
                        if member != uid {
                            newMembers.append(member)
                        }
                    }
                    let fields = ["members": newMembers]
                    firestoreGroupRef.updateData(fields, completion: { (err) in
                        if let err = err {
                            print("error removin user from firestore group", err.localizedDescription)
                            completion(false)
                        }
                        self.removeFeedFromHomeFeed(feedId: group.id, homeFeedId: uid, completion: completion)
                    })
                } else {
                    print("DEBUG: Error leaving group")
                    completion(false)
                }
            })
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
                
                self.mergeFeedIntoHomeFeed(feedId: group.id, homeFeedId: uid, completion: { (merged) in
                    if merged {
                        print("Successfully merged")
                        var newMember = group.membersStringArray
                        newMember.append(uid)
                        //TODO: Could be runtime issue adding members?
                        let fields = ["members": newMember]
                        Firestore.firestore().collection("groups").document(group.id).updateData(fields, completion: { (err) in
                            if let err = err {
                                print("Error adding member to group", err.localizedDescription)
                                completion(false)
                                return
                            }
                            self.makeFriends(senderId: group.adminId, recieverId: uid, completion: completion)
                        })
                    } else {
                        print("Faieled Merge")
                        completion(false)
                    }
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
    func swiftGetArticle(link: String?, completion: @escaping (Response?)->(), shareExtension: Bool = false){
        guard let link = link else {
            completion(nil)
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5 // seconds
        configuration.timeoutIntervalForResource = 5
        let session: URLSession
        if shareExtension {
            session = .shared
        } else {
            session = URLSession(configuration: configuration)
        }
//        let session = URLSession(configuration: configuration)
        
        let s = SwiftLinkPreview(session: session, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: .main, cache: DisabledCache.instance)
        
        
        var completed = false
        //Only from quickshare in app call below code
        if !shareExtension {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                // Code you want to be delayed
                if !completed {
                    completed = true
                    print("Not completed closing")
                    s.session.invalidateAndCancel()
                    var response1 = Response()
                    completion(response1)
                } else {
                    print("Completed")
                }
            }
        }
        
        s.preview(link, onSuccess: { (response) in
//            if completed {
//                return
//            }
            completed = true
            print("Response", response)
            completion(response)
        }) { (err) in
            if completed {
                return
            }
            completed = true
            print("Error!", err)
            var response1 = Response()
            completion(response1)
        }
        
        
    }
    
    ///Convert Response to Firebase Data
    func convertResponseToFirebaseData(articleText: String?, response: Response, url: String = "")->[String:Any] {
        
        var data: [String: Any] = ["url":response.finalUrl?.absoluteString ?? url,
                                   "description": response.description ?? "",
                                   "shareUserId":Auth.auth().currentUser?.uid ?? "",
                                   "canonicalUrl": response.canonicalUrl ?? url]
        
        //Get the custom title or article title
        if let text = articleText{
            data["title"] = text
        } else {
            if let title = response.title  {
                if title != "" {
                    data["title"] = title
                } else {
                    data["title"] = url
                }
            } else  {
                data["title"] = url
            }
            
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
                let data: [String: Any] = ["senderId": article.shareUserId ?? Auth.auth().currentUser?.uid ?? "",
                            "timestamp": Date().timeIntervalSince1970,
                            "groupId": groupId,
                            "commentCount": 0,
                            "postUpdate": Date().timeIntervalSince1970,
                            "commentUpdate": 0,
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
    
    
    
    ///Uploads all posts to users home feed
    func sendPostsToHomeFeed(posts: [SharePost], homeFeedId: String, completion: @escaping SucessFailCompletion) {
        print("Sending \(posts.count) posts to home feed")
        let feedRef = Database.database().reference().child("homeFeed").child(homeFeedId)
        
        for post in posts {
            let homePostData = ["feedId": post.groupId ?? "", "postId": post.id, "timestamp": post.timestamp.timeIntervalSince1970] as [String : Any]
            feedRef.childByAutoId().setValue(homePostData)
        }
        completion(true)
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
                    
                    var commentUpdate: TimeInterval
                    if commentCount == 1 {
                        commentUpdate = Date().timeIntervalSince1970
                    } else {
                        commentUpdate = 0
                    }
                    let data: [String: Any] = ["senderId": article.shareUserId ?? "",
                                               "timestamp": Date().timeIntervalSince1970,
                                               "groupId": group.id ?? "",
                                               "commentCount": commentCount,
                                               "postUpdate":Date().timeIntervalSince1970,
                                               "commentUpdate": commentUpdate,
                                               "articleId":aid ?? ""]
                    
                    //Write to group feed
                    let feedRef = Database.database().reference().child("feeds").child(group.id).childByAutoId()
                    feedRef.setValue(data, withCompletionBlock: { (err, ref) in
                        if let err = err {
                            print("Error Sending Article to Group:", err.localizedDescription)
                            completion(false, nil)
                        }
                        NotificationManager.shared.updateAterNewPost(groupId: group.id, postId: feedRef.key ?? "", completion: {
                            
                        })
                        sentCount += 1
                        print("Uploaded Article To Group:", group.id)
                        
                        //If they attached a comment
                        if commentCount == 1 {
                            //Genereate temp data
                            let comment = FoggyComment(id: "tmp", data: ["uid": uid,
                                                                         "text":comment!,
                                                                         "timestamp":Date().timeIntervalSince1970])
                            let post = SharePost(id: feedRef.key ?? "", data: [:])
                            post.groupId = group.id
                            //Upload comment
                            FirebaseManager.global.postComment(comment: comment, post: post, group: group, completion: { (success) in
                                if success {
                                    NotificationManager.shared.openedComments(groupId: group.id, postId: feedRef.key ?? "")
                                    NotificationManager.shared.updateAfterNewComment(groupId: group.id, postId: feedRef.key ?? "", completion: {
                                        
                                    })
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
                    let multiGroupData: [String: Any] = ["senderId":uid, "articleId":aid, "timestamp": Date().timeIntervalSince1970, "groupIds": groupIds, "multiGroup": true]
                    userRef.setValue(multiGroupData)
                    
                    
                }
                completion(true, aid)
                
            } else {
                completion(false, nil)
            }
        }
    }
    
    
    func uploadArticle(article: Article, completion: @escaping ArticleUploadCompletion) {
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
        let articleData: [String: Any] = ["articleId": articleId,
                                          "timestamp": Date().timeIntervalSince1970]
        
        Database.database().reference().child("saved").child(uid).childByAutoId().updateChildValues(articleData) { (err, ref) in
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
                for dict in snap {
                    if let articleDict = dict.value as? [String: Any] {
                        let articleId = articleDict["articleId"] as? String ?? ""
                        let timestamp = articleDict["timestamp"] as? Double ?? 0
                        print("DEBUG: Getting article with id:", articleId)
                        self.getArticle(articleId: articleId, completion: { (article) in
                            if var article = article {
                                article.savedTimestamp = Date(timeIntervalSince1970: timestamp)
                                articles.append(article)
                                if articles.count == snapshot.childrenCount {
                                    articles.sort(by: { (one, two) -> Bool in
                                        return one.savedTimestamp > two.savedTimestamp
                                    })
                                    completion(articles)
                                }
                            }
                        })
                    }
                }
//                for articleId in snap {
//                    
//                    self.getArticle(articleId: articleId.key, completion: { (article) in
//                        if let article = article{
//                            articles.append(article)
//                            if articles.count == snapshot.childrenCount {
//                                completion(articles)
//                            }
//                        }
//                    })
//                }
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
    
    ///Helper function for getting a specific post from a group
    func getPost(postId: String, groupId:String, completion: @escaping (SharePost)->()) {
        Database.database().reference().child("feeds").child(groupId).child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            let post = SharePost(id: snapshot.key, data: snapshot.value as! [String: Any])
            
            self.getArticle(articleId: post.articleId, completion: { (article) in
                
                //Set post to have Article
                post.article = article
                completion(post)
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
        var query = ref.queryOrdered(byChild: "timestamp")
        if let key = homeFeedLastPaginateKey {
//            print("Ending at key", key)
            query = query.queryEnding(atValue: key)//(atValue: key)
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
            
            if let _ = self.homeFeedLastPaginateKey {
                posts.removeLast()
            }
            
//            print(posts)
            
            var postsArray = [SharePost]()
            if posts.count == 0 {
                completion([])
            }
            
//            self.homeFeedLastPaginateKey = posts.first?.key
            
            posts.forEach({ (p) in
//                print(p.key)
                let value = p.value as? [String: Any] ?? [:]
                let isMultiGroup = value["multiGroup"] as? Bool ?? false
                if isMultiGroup {
//                    print("MULTI Home Post", p.key)
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
                            
                            self.homeFeedLastPaginateKey = postsArray.last!.timestamp.timeIntervalSince1970
                            //Return
                            completion(postsArray)
                        }
                    })
                }
                else {
//                    print("Regular Home Post", p.key)
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
                                
                                self.homeFeedLastPaginateKey = postsArray.last!.timestamp.timeIntervalSince1970
                                //Return
//                                print("COMPLEtION")
                                completion(postsArray)
                            }
                        })
                    })
                }
            })
        }
    }
    
    ///Method to remove all posts in home feed with corresponding feedId
    func removeFeedFromHomeFeed(feedId:String, homeFeedId: String, completion: @escaping SucessFailCompletion) {
        let homeFeedRef = Database.database().reference().child("homeFeed").child(homeFeedId)
        homeFeedRef.queryOrdered(byChild: "feedId").queryEqual(toValue: feedId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                for post in value {
                    print(post.key)
                    homeFeedRef.child(post.key).removeValue()
                }
                self.removeFeedfromMultiShare(ref: homeFeedRef, feedId: feedId, completion: completion)
            } else {
                self.removeFeedfromMultiShare(ref: homeFeedRef, feedId: feedId, completion: completion)
            }
        })
    }
    
    ///Method to remove feedId from multishare posts on home feed
    func removeFeedfromMultiShare(ref: DatabaseReference, feedId: String, completion: @escaping SucessFailCompletion) {
        ref.queryOrdered(byChild: "multiGroup").queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                print("DEBUG: Remove feed from multishare recieved", value.count)
                for post in value {
                    if let postValue = post.value as? [String: Any] {
                        if var groupIds = postValue["groupIds"] as? [String] {
                            for (idx, groupId) in groupIds.enumerated() {
                                if groupId == feedId {
                                    groupIds.remove(at: idx)
                                    if groupIds.isEmpty {
                                        //Delete entire post
                                        ref.child(post.key).removeValue()
                                    } else {
                                        //Make post a regular post
//                                        if groupIds.count == 1 {
//                                           //Add feed Id
//                                            ref.child(post.key).updateChildValues(["feedId":groupIds.first!])
//                                            //Remove multigroup
//                                            ref.child(post.key).child("multiGroup").removeValue()
//                                            ref.child(post.key).child("articleId").removeValue()
//                                            ref.child(post.key).child("groupIds").removeValue()
//
//                                        } else {
                                            //Update group ids
                                            ref.child(post.key).updateChildValues(["groupIds": groupIds])
//                                        }
                                        
                                        
                                    }
                                }
                            }
                        } else {
                            print("DEBUG: Did not get group ids")
                        }
                    }
                }
            }
            completion(true)
        }) { (err) in
            completion(false)
        }
    }
    
    //Gets all posts from feed and passes to sendPostsToHomeFeed
    func mergeFeedIntoHomeFeed(feedId: String, homeFeedId: String, completion: @escaping SucessFailCompletion) {
        Database.database().reference().child("feeds").child(feedId).observeSingleEvent(of: .value) { (snapshot) in
            guard let posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(false)
                return
            }
            if posts.count == 0 {
                completion(true)
            }
            var sharePosts = [SharePost]()
            posts.forEach({ (p) in
                let post = SharePost(id: p.key, data: p.value as! [String: Any])
                sharePosts.append(post)
            })
            self.sendPostsToHomeFeed(posts: sharePosts, homeFeedId: homeFeedId, completion: completion)
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
    func getCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseManager.global.getFoggyUser(uid: uid) { (use) in
            self.foggyUser = use
        }
    }
    func getFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("friends").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userIds = snapshot.value as? [String: Any] else {
                
                self.friends.removeAll()
                return
                
            }
            if userIds.isEmpty {
                self.friends.removeAll()
                return
            }
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
        if uid == "" {
            completion(nil)
            return
        }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let snap = snapshot?.data(), let s = snapshot {
                completion(FoggyUser(key: s.documentID, data: snap))
            } else {
                completion(nil)
            }
        }
    }
    
    func removeFriends(uid1: String, uid2: String){
        Database.database().reference().child("friends").child(uid1).child(uid2).removeValue()
        Database.database().reference().child("friends").child(uid2).child(uid1).removeValue()
    }
    
    func makeFriends(senderId: String, recieverId: String, completion: @escaping SucessFailCompletion) {
        let senderValue = [recieverId: 1]
        let receiverValue = [senderId: 1]
        Database.database().reference().child("friends").child(senderId).updateChildValues(senderValue) { (err, ref) in
            if let err = err {
                print("Error adding friend", err.localizedDescription)
                completion(false)
            }
            Database.database().reference().child("friends").child(recieverId).updateChildValues(receiverValue, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Error adding friend", err.localizedDescription)
                    completion(false)
                }
                var friendGroup = ""
                if senderId < recieverId {
                    friendGroup = "friend-" + senderId + "-" + recieverId
                } else {
                    friendGroup = "friend-" + recieverId + "-" + senderId
                }
                FirebaseManager.global.getFriends()
                self.createFriendGroup(id: friendGroup, members: [senderId, recieverId], completion: completion)
            })
        }
    }
}

//Comments
extension FirebaseManager {
    ///Method for fetching comments from a post
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
    
    ///Method for posting a comment attached to a post
    func postComment(comment: FoggyComment, post: SharePost, group: FoggyGroup, completion: @escaping SucessFailCompletion) {
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
            self.updateHomeFeedPostTimestamp(group: group, postId: post.id)
            self.commentUpdatePostSyncedAt(feedId: groupId, postId: post.id, completion: completion)
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
    
    ///Update update synced at time for a specific post
    func commentUpdatePostSyncedAt(feedId: String, postId: String, completion: @escaping (SucessFailCompletion)) {
        let date = Date().timeIntervalSince1970
        let data = ["commentUpdate":date,
                    "timestamp": date]
        Database.database().reference().child("feeds").child(feedId).child(postId).updateChildValues(data) { (err, ref) in
            if let err = err {
                print("ERROR UPDATING", err)
                completion(false)
                return
            }
            completion(true)
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
    func sendDynamicLinkInvite(dynamicLinkId: String, groupId:String, invitedByUid: String, number: String) {
        
        let data: [String: Any] = ["invitedBy": invitedByUid,
                                   "phoneNumber":number,
                                   "dynamicLink":dynamicLinkId]
        Database.database().reference().child("newGroup").child(groupId).childByAutoId().setValue(data) { (err, ref) in
            if let err = err {
                print("Err", err)
            }
        }
    }
}

//Mark: Notification Calls Manager
extension FirebaseManager {
    func fetchPostsAfterSyncedAt(feedId: String, syncedAt: Double, completion: @escaping([String: Bool])->()){
        let ref = Database.database().reference().child("feeds").child(feedId)
        var query = ref.queryOrdered(byChild: "postUpdate")
        query = query.queryStarting(atValue: syncedAt)
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            guard let posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([:])
                return
            }
            
            if posts.count == 0 {
                completion([:])
                return
            }

            var completionDict = [String: Bool]()
            for post in posts {
                let value = post.value as? [String: Any] ?? [:]
                if let senderId = value["senderId"] as? String, let uid = Auth.auth().currentUser?.uid {
                    if uid == senderId {
                        completionDict[post.key] = false
                        print("Didn't add Post Notification")
                    } else {
                        completionDict[post.key] = true
                    }
                } else {
                    completionDict[post.key] = true
                }
            }
            print("Got posts for FeedId: \(feedId) returning \(completionDict)")
            completion(completionDict)
        }
    }
    
    func fetchCommentsAfterSyncedAt(feedId: String, syncedAt: Double, completion: @escaping([String: Bool])->()){
        let ref = Database.database().reference().child("feeds").child(feedId)
        var query = ref.queryOrdered(byChild: "commentUpdate")
        query = query.queryStarting(atValue: syncedAt)
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            guard let posts = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([:])
                return
            }
            
            if posts.count == 0 {
                completion([:])
                return
            }
            
            
            var completionDict = [String: Bool]()
            for post in posts {
                let value = post.value as? [String: Any] ?? [:]
                if let senderId = value["senderId"] as? String, let uid = Auth.auth().currentUser?.uid {
                    if uid == senderId {
                        completionDict[post.key] = false
                        print("Didn't add Comment Notification")
                    } else {
                        completionDict[post.key] = true
                    }
                } else {
                    completionDict[post.key] = true
                }
            }
            print("Got comments for FeedId: \(feedId) returning \(completionDict)")
            completion(completionDict)
        }
    }
}

extension FirebaseManager {
    ///For every member in group update timestamp
    func updateHomeFeedPostTimestamp(group: FoggyGroup, postId: String) {
        let homeRef = Database.database().reference().child("homeFeed")
        for id in group.membersStringArray {
            homeRef.child(id).queryOrdered(byChild: "postId").queryEqual(toValue: postId).observeSingleEvent(of: .value) { (snap) in
                if snap.exists() {
                    homeRef.child(id).child(snap.key).removeValue()
                }
            }
        }
    }
}
