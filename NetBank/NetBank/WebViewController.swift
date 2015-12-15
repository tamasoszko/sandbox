//
//  ViewController.swift
//  NetBank
//
//  Created by Oszkó Tamás on 29/03/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit
import LocalAuthentication

class WebViewController: UIViewController, UIWebViewDelegate, WebView {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    
    weak var appDelegate : AppDelegate!
    weak var delegate : WebViewDelegate!
    weak var controller : WebController!
    
    let loginUrl = NSURL(string:"https://www.otpbank.hu/portal/hu/OTPdirekt/Belepes")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        self.webView.scalesPageToFit = true
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInterface()
        self.delegate.webViewWillAppear(self)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.delegate.webView(self, willStarLoadingWithRequest: request)
        return true
    }
        
    func webViewDidFinishLoad(webView: UIWebView) {
        self.delegate.webViewDidFinishLoading(self)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.delegate.webView(self, didFailLoading: error)
    }
    
//    func isLoginPage() -> Bool {
//        if self.lastRequest?.URL == loginUrl {
//            return true
//        }
//        return false
//    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        self.webView.goBack()
    }
    
    @IBAction func forwardButtonTapped(sender: AnyObject) {
        self.webView.goForward()
    }
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        self.appDelegate.workflow.startSettingsEdit()
    }
    
    @IBAction func reloadButtonTapped(sender: AnyObject) {
        self.webView.reload()
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        self.controller.loadLoginPage()
    }
    
    
    func fillAccountNumber(accountNumber: NSString) {
        dispatch_async(dispatch_get_main_queue()) {
            let ret = self.webView.stringByEvaluatingJavaScriptFromString("document.getElementById('hb_szamlaszam').value='\(accountNumber)'")
            println("JS returned=\(ret)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings" {
            
        }
    }
    
    // MARK: - WebView
    func load(url: NSURL) {
        self.webView.loadRequest(NSURLRequest(URL: url))
    }
    
    func updateUserInterface() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = self.webView.loading
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
        self.refreshButton.enabled = !self.webView.loading
        self.homeButton.enabled = !self.webView.loading
        if self.webView.loading {
            self.title = self.controller.lastRequest?.URL!.absoluteString
        } else {
            if let title = self.webView.stringByEvaluatingJavaScriptFromString("document.title") {
                self.title = title
            } else {
                self.title = ""
            }
        }
    }

    func goBack() {
        self.webView.goBack()
    }
    
    func goForward() {
        self.webView.goForward()
    }
    
    func reload() {
        self.webView.reload()
    }
    
    func showError(error: NSError) {
        UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func executeJavaSrcipt(javaSrcipt: String) -> String? {
        return self.webView.stringByEvaluatingJavaScriptFromString(javaSrcipt)
    }
}

