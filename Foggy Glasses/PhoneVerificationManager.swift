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
    
    private let testMode = false
    
    //Checks if verified in app delegate without making firebase call making app display blank
    func appDelegateVerification(uid: String?)->Bool {
        if testMode {
            return true
        }
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
    
    //Check if current user has their phone verified
    func isPhoneVerified(uid: String?, completion: @escaping (Bool) -> ()){
        if testMode {
            completion(true)
            return
        }
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
    
    //Checks if the number has already been takem
    func isValidPhoneNumber(uid: String?, completion: @escaping (Bool)->()){
        guard let uid = uid else {
            completion(false)
            return
        }
        Database.database().reference().child("takenNumber").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
            return
        }
    }
    
    //Remove the valid number
    func removeisValidNumber(uid: String?, completion: @escaping (Bool)->()){
        guard let uid = uid else {
            completion(false)
            return
        }
        Database.database().reference().child("takenNumber").child(uid).removeValue { (err, ref) in
            if let err = err {
                print("Remove Number Error", err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func deleteAccount(uid: String, completion: @escaping()->()) {
        let uidRef = Database.database().reference().child("phoneVerified").child(uid)
        let phoneRef = Database.database().reference().child("verifyPhone")
        uidRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let phoneNumber = snapshot.value as? String ?? "tmp"
            phoneRef.child(phoneNumber).removeValue(completionBlock: { (err, ref) in
                uidRef.removeValue(completionBlock: { (err, tef) in
                    completion()
                })
            })
            
        })
    }
    
    func uidNumberLookup(number: String, completion: @escaping(String?)->()){
        print("DEBUG: Looking up number", number)
        Database.database().reference().child("verifyPhone").child(number).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                if let value = snapshot.value as? String {
                    completion(value)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func formatNumber(number: String)->String {
        print("DEBUG: Formatting number:", number)
        if number.first == "+" && number[1] == "1" {
            return number
        }
        
        if number[0] == "1" {
            return "+" + number
        }
        
        return "+1" + number
    }
}

