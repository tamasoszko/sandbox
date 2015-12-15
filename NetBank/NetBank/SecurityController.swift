//
//  SecurityController.swift
//  NetBank
//
//  Created by Oszkó Tamás on 18/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import Foundation
import LocalAuthentication

struct Credential {
    
    let userName: String
    let encryptionKey: NSData
}

class SecurityController : NSObject {

    private static let KeyChainIdEncryptionKey = NSBundle.mainBundle().bundleIdentifier! + ".EncryptionKey"
    private static let ErrorDomain = "SecurityController"
    
    enum Error : NSInteger {
        case TouchIdNotAvailable = 1
        case AuthenticationFailed = 2
        case GeneralError = 3
    }
    
    private let keyChain: Keychain
    private weak var workflow: Workflow!
    private var view: SecurityView!
    private var authenticated: Bool = false
    private var credential: Credential?
    
    init(workflow: Workflow, view: SecurityView) {
        self.workflow = workflow
        self.view = view
        self.keyChain = Keychain(name: SecurityController.KeyChainIdEncryptionKey)
    }
    
    func reset() {
        self.authenticated = false
        self.credential = nil
        self.view.reset()
    }
    
    func isAuthenticated() -> Bool {
        return self.authenticated
    }
    
    func requestPasswordUser(user: String, message: String, completion: (Bool, String?) -> Void) {
        
        self.view.requestPasswordUser("Enter password", message: message, completion: completion)
    }
    
    func authenticateUser(user: String, completion: (Bool, NSError?) -> Void) {
        if self.authenticated {
            completion(true, nil)
        } else {
            self.authenticated = false
            if TouchID.touchIdAvailable() {
                TouchID.evaluateTouchIdWithDescription("Authenticate yourself to access settings", completion: { (success: Bool, error: NSError!) -> Void in
                    if success {
                        println("user authenticated")
                        self.authenticated = true
                        completion(true, nil)
                    } else {
                        var retError = Error.GeneralError
                        if(error.domain == "com.apple.LocalAuthentication") {
                            if let errorCode = LAError(rawValue: error.code) {
                                switch errorCode {
                                case .AuthenticationFailed:
                                    println("authentication failed!")
                                    retError = Error.AuthenticationFailed
                                default:
                                    println("authentication error: \(error)")
                                }
                            }
                        }
                        completion(false, SecurityController.error(retError))
                    }
                })
            } else {
                completion(false, SecurityController.error(Error.TouchIdNotAvailable))
            }
        }
    }
    
    func getCredential(user: String, completion: (Credential?, NSError?) -> Void) {
        
        var readCredential = { (completion: (Credential?, NSError?) -> Void) -> Void in
//            self.keyChain.deleteData()
            var key = self.keyChain.loadData()
            if count(key) == 0 {
                if let newKey = Crypto.generateRandomBytes(Crypto.keyLengthAes256()) {
                    self.keyChain.saveData(newKey.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0)))
                    completion(Credential(userName: user, encryptionKey: newKey), nil)
                } else {
                    assertionFailure("key generation failed")
                }
            } else {
                completion(Credential(userName: user, encryptionKey: NSData(base64EncodedString: key, options: NSDataBase64DecodingOptions(0))!), nil)
            }
        }
    
        if !self.authenticated {
            self.authenticateUser(user, completion: { (success: Bool, error: NSError?) -> Void in
                if success {
                    self.getCredential(user, completion: completion)
                } else {
                    readCredential(completion)
                }
            })
        } else {
            readCredential(completion)
        }
    }
    
    private static func error(code: Error) -> NSError {
        return NSError(domain: ErrorDomain, code: Error.TouchIdNotAvailable.rawValue, userInfo: nil)
    }
    
}