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
        activityIndicator.style = .white
        
        navigationItem.titleView = activityIndicator
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
