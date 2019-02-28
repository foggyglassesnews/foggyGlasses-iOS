//
//  ReviewController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import SwiftLinkPreview

class ReviewController: UIViewController {
    
    var link: String? {
        didSet {
            getArticle()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Review"
        view.backgroundColor = .feedBackground
    }
    
    private func getArticle() {
        guard let link = link else { return }
        let s = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: .main, cache: DisabledCache.instance)
        s.preview(link, onSuccess: { (response) in
            print("Success!", response)
        }) { (err) in
            print("Error!", err)
        }
    }
}
