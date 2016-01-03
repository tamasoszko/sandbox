//
//  Workflow.swift
//  NetBank
//
//  Created by Oszkó Tamás on 04/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit



class Workflow: NSObject {
    
    private weak var appDelegate: AppDelegate!
    private var webController: WebController?
    private var settingsController: SettingsController?
    private var settingsEditorController: SettingsEditorController?
    private var securityController: SecurityController?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        super.init()
        self.securityController = SecurityController(workflow: self, view: SecurityView(workflow: self))
        self.settingsController = SettingsController(workflow: self, securityController: self.securityController!)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        guard let webController = self.webController else {
            return
        }
        self.securityController?.reset()
        self.securityController?.authenticateUser("", completion: { (success: Bool, error: NSError?) -> Void in
            if !success {
                webController.logout(nil)
            }
        })
    }
    
    func startWebView() {
        let vc: WebViewController = viewControllerWithIdentifier("webViewController")
        self.webController = WebControllerImpl(settingsController: self.settingsController!, securityController: self.securityController!, view:vc)
        let navController = UINavigationController(rootViewController: vc)
        self.appDelegate.window?.rootViewController = navController;
        self.appDelegate.window?.makeKeyAndVisible()
    }
    
    func startSettingsEdit() {
        let vc: SettingsTableViewController = viewControllerWithIdentifier("settingsTableViewController")
        self.settingsEditorController = SettingsEditorController(workflow: self, settingsController: self.settingsController!, view: vc)
        let navigationController = UINavigationController(rootViewController: vc)
        self.appDelegate.window?.rootViewController?.presentViewController(navigationController, animated: true, completion: { () -> Void in
            
        })
    }
    
    func presentViewController(viewController: UIViewController) {
        if let parentViewController = self.appDelegate.window?.rootViewController {
            parentViewController.presentViewController(viewController, animated: true, completion: { () -> Void in
            })
        }
    }
    
    func finishedSettings() {
        self.appDelegate.window?.rootViewController?.dismissViewControllerAnimated(true){}
    }
    
    func showUserAuthentication() {
        
    }
    
    func hideUserAuthentication() {
        
    }
    
    
    private func storyBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    private func viewControllerWithIdentifier<T>(identifier : String) -> T {
        return storyBoard().instantiateViewControllerWithIdentifier(identifier) as! T
    }
}