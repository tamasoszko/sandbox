//
//  Settings.swift
//  NetBank
//
//  Created by Oszkó Tamás on 19/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import Foundation


protocol ISettingsController : NSObjectProtocol {
    
    func readSettings(completion: ([SettingsDao]?, NSError?) -> Void)
    func updateSetting(settings: SettingsDao, completion: (NSError?) -> Void)
}


class SettingsController: NSObject, ISettingsController {
    
    var persistency : SettingsPersistency?
    weak var securityController: SecurityController!
    weak var workflow: Workflow!
    
    init(workflow: Workflow, securityController: SecurityController) {
        
        self.securityController = securityController
        self.workflow = workflow
    }
    
    func readSettings(completion: ([SettingsDao]?, NSError?) -> Void) {
        self.securityController.getCredential("user", completion: { (credential: Credential?, error: NSError?) -> Void in
            if credential != nil {
                self.persistency = EncryptedFileSettingsPersistency(credential: credential!)
                
                self.persistency!.read { (daos: [SettingsDao]?, error: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(daos, nil)
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(nil, error)
                }
            }
        })
    }
    
    func updateSetting(setting: SettingsDao, completion: (NSError?) -> Void) {
        self.persistency!.update(setting, completion: { (error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                completion(error)
            }
        })
    }
}