//
//  WebController.swift
//  NetBank
//
//  Created by Oszkó Tamás on 04/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

protocol WebController : NSObjectProtocol {
    
    var lastError: NSError? { get }
    var lastRequest: NSURLRequest? { get }
    func loadLoginPage()
    func logout()
}

class WebControllerImpl: NSObject, WebViewDelegate, WebController {
   
    weak var settingsController: ISettingsController!
    weak var view : WebView!
    weak var securityController: SecurityController!
    var lastRequest: NSURLRequest?
    var lastError: NSError?
    var setting : SettingsDao!
    var firstLoad: Bool = true
    
    init(settingsController: ISettingsController, securityController: SecurityController, view: WebView) {
        super.init()
        self.settingsController = settingsController
        self.securityController = securityController
        self.view = view
        self.view.delegate = self
        self.view.controller = self
    }
    
    // MARK: - WebController
    func loadLoginPage() {
        self.settingsController.readSettings({ (settings: [SettingsDao]?, error: NSError?) -> Void in
            if let setting = settings?.first, let url = NSURL(string:setting.loginPage) {
                self.setting = setting
                self.view.load(url)
            }
        })
    }
    
    func logout() {
        if let setting = self.setting {
            if let url = NSURL(string: "/portal/hu/OTPdirekt/Kilepes", relativeToURL: NSURL(string:setting.loginPage)) {
                println("url=\(url.absoluteString)")
                self.view.load(url)
            }
        }
    }
    
    // MARK: - WebViewDelegate
    func webViewWillAppear(webView: WebView) {
        if firstLoad {
            loadLoginPage()
        }
    }
    
    func webView(webView: WebView, willStarLoadingWithRequest request: NSURLRequest) {
        self.lastError = nil
        self.lastRequest = request
        self.view.updateUserInterface()
    }

    func webViewDidFinishLoading(webView: WebView) {
        self.firstLoad = true
        self.lastError = nil
        self.view.updateUserInterface()
        if isLoginPage() {
            self.securityController.authenticateUser("", completion: { (success: Bool, error: NSError?) -> Void in
                if success  {
                    self.securityController.requestPasswordUser("", message: "Enter homebank password to log in", completion: { (success: Bool, password: String?) -> Void in
                        if success && password != nil && count(password!) > 0 {
                            if self.fillForm(self.setting.password.elementValue, value: password!) {
                                self.fillLoginForm()
                                self.submitForm()
                            }
                        }
                    })
                } else {
                    self.view.showError(error!)
                }
            })
        }
    }
    
    func webView(webView: WebView, didFailLoading error: NSError) {
        self.view.updateUserInterface()
        self.lastError = error
        self.view.showError(error)
    }
    
    func webViewShouldRealod(webView: WebView) {
        if self.lastError != nil {
            if let req = self.lastRequest {
                self.view.load(req.URL!)
            } else {
                assertionFailure("self.lastRequest must not be nil")
            }
        } else {
            self.view.reload()
        }
    }
    
    func isLoginPage() -> Bool{
        if self.lastRequest?.URL?.absoluteString == self.setting.loginPage {
            return true
        } else {
            return false
        }
    }

    func fillLoginForm() -> Bool {
        if fillForm(self.setting.accountNumber.elementValue, value: self.setting.accountNumber.value) {
            if fillForm(self.setting.homeBankId.elementValue, value: self.setting.homeBankId.value) {
                return true
            }
        }
        return false
    }
    
    func fillForm(id: String, value: String) -> Bool {
        let hbIdRes = self.view.executeJavaSrcipt("document.getElementById('\(id)').value='\(value)'")
        return hbIdRes == value ? true : false
    }
    
    func submitForm() {
        if TARGET_IPHONE_SIMULATOR == 1 {
            println("skipping login")
        } else {
            let hbIdRes = self.view.executeJavaSrcipt("document.getElementsByName('\(self.setting.loginButton.elementValue)')[0].click()")
            println("hbIdRes=\(hbIdRes)")
        }
    }
}


