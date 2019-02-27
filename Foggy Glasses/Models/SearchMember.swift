//
//  SearchMember.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/27/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import Contacts

struct SearchMember {
    var contact: CNContact?
    var foggyUser: FoggyUser?
    var selected: Bool = false
    var titleKey: String {
        get {
            if let contact = contact {
                return String(contact.givenName.prefix(1))
            }
            if let user = foggyUser {
                return String(user.name.prefix(1))
            }
            
            return "-"
        }
    }
    var name: String {
        get {
            if let contact = contact {
                return contact.givenName + " " + contact.familyName
            }
            if let user = foggyUser {
                return user.name
            }
            
            return "Foggy User"
        }
    }
    var id = 0

    var detail: String {
        get {
            if let contact = contact {
                if let phoneNumber = contact.phoneNumbers.first {
                    return "\(phoneNumber)"
                }
            }
            if let user = foggyUser {
                return user.username
            }
            
            return "Foggy User"
        }
    }
//    static func get(user: FoggyUser?, contact: CNContact?)->SearchMember {
//        if let contact = contact {
//            return contact.givenName + " " + contact.familyName
//        }
//        if let user = foggyUser {
//            return user.name
//        }
//        
//        return "Foggy User"
//    }
}
