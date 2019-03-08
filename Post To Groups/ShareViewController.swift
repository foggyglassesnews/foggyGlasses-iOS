//
//  ShareViewController.swift
//  Post To Groups
//
//  Created by Ryan Temple on 3/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Social

var sharedGroup = "group.posttogroups.foggyglassesnews.com"

class ShareViewController: SLComposeServiceViewController {
    
    var url: URL?
    
    var groupIds = [String]()
    var groupNames = [String]()
    var selectedIdx = 0

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getUrl()
        let defaults = UserDefaults.init(suiteName: sharedGroup)
        if let groupNames = defaults?.array(forKey: "Group Names") as? [String], let groupIds = defaults?.array(forKey: "Group Ids") as? [String] {
            self.groupNames = groupNames
            self.groupIds = groupIds
        }
    }
    
    func setupUI() {
        configNavigationBar()
        let imageView = UIImageView(image: UIImage(named: "Side Logo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navigationController?.navigationBar.topItem?.titleView = imageView
        navigationController?.navigationBar.tintColor = .black
    }
    
    func getUrl() {
        
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        if let groups = SLComposeSheetConfigurationItem() {
            groups.title = "Choose Group(s)"
            groups.value = "Group Name"
            groups.tapHandler = {
                let vc  = ShareSelectViewController()
                vc.ids = self.groupIds
                vc.names = self.groupNames
                vc.delegate = self
                self.pushConfigurationViewController(vc)
            }
            return [groups]
        }
        return []
    }
    

}

extension ShareViewController: GroupSelectProtocol {
    func selected(groups: [String]) {
        print("Selected groups:", groups)
        reloadConfigurationItems()
        popConfigurationViewController()
    }
    
    
}
