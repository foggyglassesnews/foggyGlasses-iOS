//
//  SafariController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 6/16/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class SafariController: SFSafariViewController {
    init(url URL: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        super.init(url: URL, configuration: config)
    }
    override func viewDidLoad() {
        configuration.entersReaderIfAvailable = true
        delegate = self
    }
}

extension SafariController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
