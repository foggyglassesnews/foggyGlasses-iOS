//
//  SuccessCreateGroupController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class SuccessCreateGroupController: UIViewController {
    
    ///True if we are presenting from inital walkthrough
    ///False if we are presenting from feed
    var isFromWalkthrough = false
    
    let logo = UIImageView(image: UIImage(named: "Group Success Created"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Success"
        view.backgroundColor = .feedBackground
        logo.contentMode = .scaleAspectFit
        
        view.addSubview(logo)
        logo.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 32, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 252, height: 171)
        logo.centerHoriziontally(in: view)
        
        navigationItem.hidesBackButton = true
        
        let shareArticle = UIButton(type: .system)
        view.addSubview(shareArticle)
        shareArticle.anchor(top: logo.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 191, height: 50)
        shareArticle.setImage(UIImage(named: "Share Article")?.withRenderingMode(.alwaysOriginal), for: .normal)
        shareArticle.centerHoriziontally(in: view)
        shareArticle.addTarget(self, action: #selector(shareArticleClicked), for: .touchUpInside)
        
        let skip = UIButton(type: .system)
        view.addSubview(skip)
        skip.anchor(top: shareArticle.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 141, height: 37)
        skip.setImage(UIImage(named: "Skip Button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        skip.centerHoriziontally(in: view)
        skip.addTarget(self, action: #selector(skipClicked), for: .touchUpInside)
    }
    
    @objc func shareArticleClicked() {
        if isFromWalkthrough {
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            let nav = UINavigationController(rootViewController: feed)
            present(nav, animated: true) {
                let quickshare = QuickshareController(collectionViewLayout: UICollectionViewFlowLayout())
                nav.pushViewController(quickshare, animated: true)
            }
        } else {
            
            if let globalvc = globalReturnVC {
                globalvc.pushCompose = true
                navigationController?.popToViewController(globalvc, animated: true)
                globalReturnVC = nil
            } else{
                if let rooot = navigationController?.viewControllers[0] as? FeedController {
                    rooot.pushCompose = true
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
            
//            navigationController?.pushViewController(quickshare, animated: true)
        }
        
//        present(nav, animated: true, completion: nil)
    }
    
    @objc func skipClicked() {
        if isFromWalkthrough {
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            let nav = UINavigationController(rootViewController: feed)
            present(nav, animated: true) {
                
            }
        } else {
            if let globalvc = globalReturnVC {
                navigationController?.popToViewController(globalvc, animated: true)
                globalReturnVC = nil
            } else{
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }
        
    }
}
