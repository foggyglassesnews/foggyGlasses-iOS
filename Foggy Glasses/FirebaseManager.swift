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

//MARK: Create User
class FirebaseManager {
    static let global = FirebaseManager()
    
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
        self.groupData(uid: uid) { (groupData) in
            self.groupData(uid: uid, pending: true, completion: { (pendingData) in
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
    private func getGroup(groupId: String, completion: @escaping (FoggyGroup?)->()){
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
        let data = ["name": name]
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
    
    private func uploadArticle(article: Article, completion: @escaping ArticleUploadCompletion) {
        let ref = Firestore.firestore().collection("articles").document()
        ref.setData(article.webData()) { (err) in
            if let err = err {
                print("Error Uploading Article:", err.localizedDescription)
                completion(false, nil)
                return
            }
            completion(true, ref.documentID)
        }
    }
    
    func getArticle(articleId: String, completion: @escaping (Article?)->()){
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
}

//MARK: Feed
extension FirebaseManager {
    func fetchFeed(feedId: String, lastPostPaginateKey: String?, completion: @escaping([SharePost])->()){
        let ref = Database.database().reference().child("feeds").child(feedId)
        var query = ref.queryOrderedByKey()
        if let key = lastPostPaginateKey {
            query = query.queryEnding(atValue: key)
        }
        
        query.queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
            guard var posts = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if let _ = lastPostPaginateKey {
                posts.removeLast()
            }
            
            var postsArray = [SharePost]()
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
}
