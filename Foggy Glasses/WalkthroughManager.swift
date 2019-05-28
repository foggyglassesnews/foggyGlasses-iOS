//
//  WalkthroughManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 5/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import Firebase

class WalkthroughManager {
    static let shared = WalkthroughManager()
    
    private var sideHint = false
    private var shareHint = false
    private var notiHint = false
    
    private var sideKey = ""
    private var shareKey = ""
    private var notiKey = ""
    
    init() {
        let standard = UserDefaults.standard
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        self.sideKey = uid + "-SideKey"
        self.shareKey = uid + "-ShareKey"
        self.notiKey = uid + "-NotiKey"
        
        sideHint = standard.bool(forKey: self.sideKey)
        shareHint = standard.bool(forKey: self.shareKey)
        notiHint = standard.bool(forKey: self.notiKey)
    }
    
    func hasShownSideHint()->Bool {
        let standard = UserDefaults.standard
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        self.sideKey = uid + "-SideKey"
        
        return standard.bool(forKey: self.sideKey)
    }
    
    func hasShownShareHint()->Bool {
        let standard = UserDefaults.standard
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        self.shareKey = uid + "-ShareKey"
        
        return standard.bool(forKey: self.shareKey)
    }
    
    func hasShownQS()->Bool {
        let standard = UserDefaults.standard
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        
        self.notiKey = uid + "-NotiKey"
        
        return standard.bool(forKey: self.notiKey)
    }
    
    func showSideHint() {
        self.sideHint = true
        UserDefaults.standard.set(true, forKey: self.sideKey)
        UserDefaults.standard.synchronize()
    }
    
    func showShareHint() {
        self.shareHint = true
        UserDefaults.standard.set(true, forKey: self.shareKey)
        UserDefaults.standard.synchronize()
    }
    
    func clickedQuickshare() {
        self.notiHint = true
        UserDefaults.standard.set(true, forKey: self.notiKey)
        UserDefaults.standard.synchronize()
    }
    
    func reset() {
        self.shareHint = false
        self.sideHint = false
        self.notiHint = false
    }
}
