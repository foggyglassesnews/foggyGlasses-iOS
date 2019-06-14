//
//  DeepLinkManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 4/19/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class DeepLinkManager {
    static let shared = DeepLinkManager()
    var openCreateGroupFromExtension = false
    
    func present(nav: UINavigationController?, returnVC: FeedController?) {
        globalReturnVC = returnVC
        DispatchQueue.main.async {
            if self.openCreateGroupFromExtension {
                self.openCreateGroupFromExtension = false
                
                globalReturnVC = returnVC
                let quickshare = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
                quickshare.isFromExtensionQuickshare = true
                nav?.pushViewController(quickshare, animated: true)
            } else {
                globalReturnVC = nil
            }
        }
    }
    
    func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
    }
}
