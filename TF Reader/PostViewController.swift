//
//  PostViewController.swift
//  TF Reader
//
//  Created by Parker Madel on 8/27/16.
//  Copyright © 2016 Parker Madel. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var postLink: String = String()
    var postHTML: String = String()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        webView.loadHTMLString(postHTML, baseURL: nil)
        webView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
