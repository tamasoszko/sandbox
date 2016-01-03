//
//  SettingsPersistency.swift
//  NetBank
//
//  Created by Oszkó Tamás on 04/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit


// MARK: - ISettingsPersistency

protocol ISettingsPersistency : NSObjectProtocol {
    
    func read(completion: ([SettingsDao]?, NSError?) -> Void)
    func update(dao: SettingsDao, completion: (NSError?) -> Void)
}


// MARK: - ISettingsCryptor

protocol ISettingsCryptor : NSObjectProtocol {
    func encypt(dao: SettingsDao) -> SettingsDao?
    func decypt(dao: SettingsDao) -> SettingsDao?
}


// MARK: - SettingsFilePersistency

private class SettingsFilePersistency: NSObject, ISettingsPersistency {
    
    private func absolutePathWithName(name: String) -> String {
        let path = FileUtils.documentsDirectory() + "/settings/\(name)"
        print(path)
        return path
    }
    
    func read(completion: ([SettingsDao]?, NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            var daos : [SettingsDao] = []

            if NSFileManager.defaultManager().fileExistsAtPath(self.absolutePathWithName("/")) {
                do {
                    let fileNames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.absolutePathWithName("/")) as [String]?
                    print("\(fileNames)")
                    for fileName in fileNames! {
                        if let dao = NSKeyedUnarchiver.unarchiveObjectWithFile(self.absolutePathWithName(fileName)) as! SettingsDao? {
                            daos.append(dao)
                        }
                    }
                    completion(daos, nil)
                } catch let error as NSError {
                    completion(nil, error)
                }
            } else {
                completion(daos, nil)
            }
        }
    }

    func update(dao: SettingsDao, completion: (NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            print("update: id=\(dao.id.UUIDString), dao=\(dao)")
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(self.absolutePathWithName(self.absolutePathWithName("/")), withIntermediateDirectories: true, attributes: nil)
                if NSKeyedArchiver.archiveRootObject(dao, toFile: self.absolutePathWithName(dao.id.UUIDString)) {
                    completion(nil)
                } else {
                    completion(NSError(domain: NSStringFromClass(SettingsFilePersistency), code: 1, userInfo: nil))
                }
            } catch let error as NSError {
                completion(error)
            }
        }
    }
}

// MARK: - SettingsCryptor

private class SettingsCryptor : NSObject, ISettingsCryptor {

    private let key: NSData
    
    init(key: NSData) {
        self.key = key
    }
    
    func encypt(dao: SettingsDao) -> SettingsDao? {
        
        return SettingsDao(id: dao.id,
            loginPage: dao.loginPage,
            homeBankId: SettingsDao.FormItem(name: dao.homeBankId.name,
                elementIdentifierType: dao.homeBankId.elementIdentifierType,
                elementIndex: dao.homeBankId.elementIndex,
                elementValue: dao.homeBankId.elementValue,
                value: encrypt(dao.homeBankId.value)),
            accountNumber: dao.accountNumber,
            password: SettingsDao.FormItem(name: dao.password.name,
                elementIdentifierType: dao.password.elementIdentifierType,
                elementIndex: dao.password.elementIndex,
                elementValue: dao.password.elementValue,
//                value: encrypt(dao.password.value)),
                value: ""),
            loginButton: dao.loginButton)
    }

    func decypt(dao: SettingsDao) -> SettingsDao? {
        return SettingsDao(id: dao.id,
            loginPage: dao.loginPage,
            homeBankId: SettingsDao.FormItem(name: dao.homeBankId.name,
                elementIdentifierType: dao.homeBankId.elementIdentifierType,
                elementIndex: dao.homeBankId.elementIndex,
                elementValue: dao.homeBankId.elementValue,
                value: decrypt(dao.homeBankId.value)),
            accountNumber: dao.accountNumber,
            password: SettingsDao.FormItem(name: dao.password.name,
                elementIdentifierType: dao.password.elementIdentifierType,
                elementIndex: dao.password.elementIndex,
                elementValue: dao.password.elementValue,
                value: decrypt(dao.password.value)),
            loginButton: dao.loginButton)
    }
    
    private func encrypt(string: String) -> String {
        let enc = Crypto.encryptData(string.dataUsingEncoding(NSUTF8StringEncoding), withKey: self.key).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//        println("encrypt: in=\(string), out=\(enc)")
        return enc
    }
    
    private func decrypt(string: String) -> String {
        let plain = NSString(data: Crypto.decryptData(NSData(base64EncodedString: string, options: NSDataBase64DecodingOptions(rawValue: 0)), withKey: self.key), encoding: NSUTF8StringEncoding) as! String
//        println("decrypt: in=\(string), out=\(plain)")
        return plain
    }
}

// MARK: - SettingsNoOpCryptor

private class SettingsNoOpCryptor : NSObject, ISettingsCryptor {
    
    func encypt(dao: SettingsDao) -> SettingsDao? {
        return dao
    }
    
    func decypt(dao: SettingsDao) -> SettingsDao? {
        return dao
    }
}

// MARK: - SettingsPersistency

class SettingsPersistency : NSObject {
    
    let persistency: ISettingsPersistency
    let cryptor: ISettingsCryptor
    
    init(persistency: ISettingsPersistency, cryptor: ISettingsCryptor) {
        self.persistency = persistency
        self.cryptor = cryptor
    }
    
    func read(completion: ([SettingsDao]?, NSError?) -> Void) {
        self.persistency.read { (daos: [SettingsDao]?, error: NSError?) -> Void in
            if(daos != nil) {
                var decryptedDaos : [SettingsDao] = []
                for dao in daos! {
                    if let decryptedDao = self.cryptor.decypt(dao) as SettingsDao? {
                        decryptedDaos.append(decryptedDao)
                    } else {
                        completion(nil, NSError(domain: NSStringFromClass(SettingsFilePersistency), code: 3, userInfo: nil))
                    }
                }
                completion(decryptedDaos, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func update(dao: SettingsDao, completion: (NSError?) -> Void) {
        if let encryptedDao = self.cryptor.encypt(dao) {
            self.persistency.update(encryptedDao, completion: completion)
        } else {
            completion(NSError(domain: NSStringFromClass(SettingsFilePersistency), code: 2, userInfo: nil))
        }
    }
}

// MARK: - EncryptedFileSettingsPersistency

class EncryptedFileSettingsPersistency : SettingsPersistency {
    
    init(credential: Credential) {
        super.init(persistency: SettingsFilePersistency(), cryptor: SettingsCryptor(key: credential.encryptionKey))
    }
}

// MARK: - UnsafeFileSettingsPersistency

class UnsafeFileSettingsPersistency : SettingsPersistency {
    
    init() {
        super.init(persistency: SettingsFilePersistency(), cryptor: SettingsNoOpCryptor())
    }
}


