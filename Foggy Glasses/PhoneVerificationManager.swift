//
//  PhoneVerificationManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/28/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import Firebase

class PhoneVerificationManager {
    static let shared = PhoneVerificationManager()
    
    //Checks if verified in app delegate without making firebase call making app display blank
    func appDelegateVerification(uid: String?)->Bool {
        guard let uid = uid else {
            return false
        }
        
        let standard = UserDefaults.standard
        let userDefaultKey = "verified-"+uid
        //If we have a cached value use this
        if let isVerified = standard.object(forKey: userDefaultKey) as? Bool {
            return isVerified
        } else {
            return false
        }
    }
    
    func isPhoneVerified(uid: String?, completion: @escaping (Bool) -> ()){
        guard let uid = uid else {
            completion(false)
            return
        }
        
        let standard = UserDefaults.standard
        let userDefaultKey = "verified-"+uid
        
//        //If we have a cached value use this
//        if let isVerified = standard.object(forKey: userDefaultKey) as? Bool {
//            completion(isVerified)
//        }
        
        Database.database().reference().child("phoneVerified").child(uid).observe(.value) { (snapshot) in
            //Store in user defaults
            standard.set(snapshot.exists(), forKey: userDefaultKey)
            
            if !snapshot.exists() {
                print("NOT phone verified")
                completion(false)
            }
            
            completion(snapshot.exists())
        }
    }
}

