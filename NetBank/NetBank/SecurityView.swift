//
//  SecurityView.swift
//  NetBank
//
//  Created by Oszkó Tamás on 18/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import Foundation
import UIKit

protocol ISecurityView: NSObjectProtocol, WorkflowView, ErrorShowingView {
    
    func reset()
    func requestPasswordUser(title: String, message: String, completion: (Bool, String?) -> Void)
}

class SecurityView : NSObject, ISecurityView {
    
    weak var alertViewController: UIAlertController?
    weak var workflow: Workflow!
    
    init(workflow: Workflow) {
        self.workflow = workflow
    }
    
    func reset() {
        if let alertViewController = self.alertViewController {
            alertViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
            })
        }
    }
    
    func requestPasswordUser(title: String, message: String, completion: (Bool, String?) -> Void) {
        
        var alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        self.alertViewController = alertViewController
        alertViewController.addTextFieldWithConfigurationHandler({ (textField: UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
//            textField.keyboardType = UIKeyboardType.NumberPad
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> Void in
            completion(false, nil)
        })
        let okButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
            if let textField = alertViewController.textFields?.first as? UITextField {
                if count(textField.text) > 0 {
                    completion(true, textField.text)
                } else {
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        })
        alertViewController.addAction(cancelButton)
        alertViewController.addAction(okButton)
        self.workflow.presentViewController(alertViewController)
    }
    
    func showError(error: NSError) {
        UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: "OK").show()
    }
}