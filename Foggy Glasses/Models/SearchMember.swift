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
    var id = 0
    //Set either contact or foggyUser
    var contact: CNContact?
    var foggyUser: FoggyUser?
    ///Determine if selected
    var selected: Bool = false
    ///First letter of name
    var titleKey: String {
        get {
            if let contact = contact {
                return String(contact.givenName.prefix(1))
            }
            if let _ = foggyUser {
                return String("*")
            }
            
            return "-"
        }
    }
    ///Return given name for contact or user
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
    ///Return given detail info for contact or user
    var detail: String {
        get {
            if let contact = contact {
                if contact.phoneNumbers.count == 0 {
                    return ""
                }
                let phoneNumber = (contact.phoneNumbers[0].value).value(forKey: "digits") as! String
                return phoneNumber            }
            if let user = foggyUser {
                return user.username
            }
            
            return "Foggy User"
        }
    }
    ///Return given name for contact or user
    var firstName: String {
        get {
            if let contact = contact {
                return contact.givenName
            }
            if let user = foggyUser {
                return user.name
            }
            
            return "Foggy User"
        }
    }
}
