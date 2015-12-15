//
//  WebView.swift
//  NetBank
//
//  Created by Oszkó Tamás on 04/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

protocol WebView: NSObjectProtocol {
    
    weak var delegate : WebViewDelegate! {get set}
    weak var controller: WebController! {get set}
    
    func load(url: NSURL)
    func updateUserInterface()
    func goBack()
    func goForward()
    func reload()
    func showError(error: NSError)
    func executeJavaSrcipt(javaSrcipt: String) -> String?
}

protocol WebViewDelegate: NSObjectProtocol {
    
    func webViewWillAppear(webView: WebView)
    func webView(webView: WebView, willStarLoadingWithRequest request: NSURLRequest)
    func webViewDidFinishLoading(webView: WebView)
    func webView(webView: WebView, didFailLoading error: NSError)
    func webViewShouldRealod(webView: WebView)
    
}

