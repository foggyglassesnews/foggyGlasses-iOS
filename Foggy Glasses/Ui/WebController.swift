//
//  WebController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Contacts

class WebController: UIViewController {
    var article: Article! {
        didSet {
            guard let url = URL(string: article.link) else { return }
            webView.load(URLRequest(url: url))
        }
    }
    
    lazy var webView: WKWebView = {
        let v = WKWebView()
        return v
    }()
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareClicked))
        share.tintColor = .black
        navigationItem.rightBarButtonItem = share
        view.addSubview(webView)
        webView.pin(in: view)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        activityIndicator = UIActivityIndicatorView()
//        activityIndicator.center = self.navigationItem.titleView!.center
        activityIndicator.hidesWhenStopped = true
//        activityIndicator.style = .white
        activityIndicator.tintColor = .black
        activityIndicator.color = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.titleView = activityIndicator
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupFromQuickshareExtension), name: FeedController.openGroupCreate, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: FeedController.openGroupCreate, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    ///Method called when selecting create new group
    @objc func createGroupFromQuickshareExtension() {
        //DeepLinkManager.shared.present(nav: self.navigationController, returnVC: nil)
        return
        //        globalReturnVC = self
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if self.checkForContactPermission() {
                let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
                create.isFromQuickshare = true
                self.navigationController?.pushViewController(create, animated: true)
            } else {
                let contact = ContactPermissionController()
                contact.isFromQuickshare = true
                self.navigationController?.pushViewController(contact, animated: true)
            }
        }
    }
    
    private func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
    }
    
    @objc func shareClicked() {
        let activityItems = [Any]()
//        let applicationAcitivies = []
        if let url = URL(string: article.link) {
            let alert = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            title = URL(string: article.link)!.host
        }
    }
}

extension WebController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }}
