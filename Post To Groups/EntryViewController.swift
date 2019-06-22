//
//  EntryViewController.swift
//  Post To Groups
//
//  Created by Ryan Temple on 6/20/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Social
import MobileCoreServices

@objc(EntryViewController)

class EntryViewController : UINavigationController {
    let share = SharingViewController()
    var url: URL? {
        didSet {
            share.url = url
        }
    }
    
    override func viewDidLoad() {
        
        pushViewController(share, animated: false)
        getUrl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.transform = CGAffineTransform().translatedBy(x: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 0.25) {
            self.view.transform = .identity
        }
    }

    private func getUrl() {
        let count = extensionContext?.inputItems.count ?? 0
        if count == 0 {
            let alert = UIAlertController(title: "Invalid Share Type", message: "Foggy Glasses Quickshare only supports sending URLs currently 😢", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
                let cancelError = CancelErorr()
                self.extensionContext?.cancelRequest(withError: cancelError)
            }
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            return
        }
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        guard let attachments = extensionItem.attachments else { return }
        
        var foundUrl = false
        for attachment in attachments {
            print("Attachment", attachment)
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                foundUrl = true
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil) { (results, error) in
                    self.url = results as! URL?
                }
            }
        }
        if foundUrl {
            return
        }
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                    if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                    guard let dictionary = decoder as? NSDictionary else {
                        self.logErrorAndCompleteRequest(error: error); return }
                    guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else {
                        self.logErrorAndCompleteRequest(error: error); return }
                    self.url = URL(string: results.value(forKey: "URL") as? String ?? "")
                    return
                })
            } else {
                let alert = UIAlertController(title: "Invalid Share Type", message: "Foggy Glasses Quickshare only supports sending URLs currently 😢", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
                    let cancelError = CancelErorr()
                    self.extensionContext?.cancelRequest(withError: cancelError)
                }
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
}

class CancelErorr: Error {
    
}
