//
//  SettingsController.swift
//  NetBank
//
//  Created by Oszkó Tamás on 04/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

protocol ISettingsEditorController : NSObjectProtocol {
    
    var settings : [SettingsDao]? { get }
    
    func getSettings()
    func saveSetting(setting: SettingsDao)
}

class SettingsEditorController: NSObject, ISettingsEditorController {

    var settings : [SettingsDao]?
    weak var settingsController: SettingsController!
    weak var view : SettingsView!
    weak var workflow: Workflow!
    
    init(workflow: Workflow, settingsController: SettingsController, view: SettingsView) {
        super.init()
        self.settingsController = settingsController
        self.settings = []
        self.workflow = workflow
        self.view = view
        self.view.workflow = workflow
        self.view.controller = self
    }
    
    func getSettings() {
        self.view.startLoading()
        self.settingsController.readSettings { (settings: [SettingsDao]?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.view.stopLoading()
                if settings != nil {
                    self.settings = settings!
                    self.view.refresh()
                } else {
                    self.view.showError(error!)
                }
            }
        }
    }
    
    func saveSetting(setting: SettingsDao) {
        self.view.startLoading()
        self.settingsController.updateSetting(setting, completion: { (error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                
                self.view.stopLoading()
                //
                
                
                if error == nil {
                    self.workflow.finishedSettings()
                
                } else {
                    self.view.showError(error!)
                }
            }
        })
    }

}
