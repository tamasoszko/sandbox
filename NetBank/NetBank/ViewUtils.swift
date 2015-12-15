//
//  ViewUtils.swift
//  NetBank
//
//  Created by Oszkó Tamás on 05/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

protocol DataLoadingView: NSObjectProtocol {
    
    func refresh()
    func startLoading()
    func stopLoading()
}

protocol WorkflowView: NSObjectProtocol {
    
    weak var workflow: Workflow! {get set}
}

protocol ErrorShowingView: NSObjectProtocol {
    
    func showError(error: NSError)
}

extension UIViewController : DataLoadingView {

    func refresh() {
        assertionFailure("Must be overridden")
    }
    
    func startLoading() {
        self.view.userInteractionEnabled = false
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem?.enabled = false
        if self.navigationItem.rightBarButtonItems?.count == 2 {
            self.navigationItem.rightBarButtonItems?.removeLast()
        }
        let activityIndicdator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicdator.startAnimating()
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: activityIndicdator))
    }
    
    func stopLoading() {
        self.view.userInteractionEnabled = true
        if self.navigationItem.rightBarButtonItems?.count == 2 {
            self.navigationItem.rightBarButtonItems?.removeLast()
        }
        self.navigationItem.leftBarButtonItem?.enabled = true
        self.navigationItem.rightBarButtonItem?.enabled = true
    }

}