//
//  SettingsDao.swift
//  NetBank
//
//  Created by Oszkó Tamás on 18/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import Foundation



class SettingsDao : NSObject, NSCoding{
    
    let KeyId = "Id"
    let KeyLoginPage = "LoginPage"
    let KeyFormItems = "FormItems"
    let KeyHomeBankId = "HomeBankId"
    let KeyAccountNumber = "AccountNumber"
    let KeyPassword = "Password"
    let KeyLoginButton = "LoginButton"
    
    class FormItem : NSObject, NSCoding {
        
        let KeyName = "Name"
        let KeyElementIdentifierType = "ElementIdentifierType"
        let KeyElementIndex = "ElementIndex"
        let KeyElementValue = "ElementValue"
        let KeyValue = "Value"
        
        enum ElementIdentifierType : String {
            case Id = "Id"
            case Name = "Name"
            case TagName = "TagName"
            case Class = "Class"
        }
        let name : String
        let elementIdentifierType : ElementIdentifierType
        let elementIndex : Int
        let elementValue : String
        let value: String
        
        //        convenience override init() {
        //            self.init(name: "", elementIdentifierType:ElementIdentifierType.Id, elementIndex: 0, elementValue: 0, value: "")
        //        }
        
        init(name: String, elementIdentifierType : ElementIdentifierType, elementIndex : Int, elementValue : String, value: String) {
            self.name = name
            self.elementIdentifierType = elementIdentifierType
            self.elementValue = elementValue
            self.elementIndex = elementIndex
            self.value = value
        }
        
        required init(coder aDecoder: NSCoder) {
            self.name = aDecoder.decodeObjectForKey(KeyName) as! String
            self.elementIdentifierType = ElementIdentifierType(rawValue: (aDecoder.decodeObjectForKey(KeyElementIdentifierType) as! String))!
            self.elementIndex = aDecoder.decodeIntegerForKey(KeyElementIndex)
            self.elementValue = aDecoder.decodeObjectForKey(KeyElementValue) as! String
            self.value = aDecoder.decodeObjectForKey(KeyValue) as! String
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(self.name, forKey: KeyName)
            aCoder.encodeObject(self.elementIdentifierType.rawValue, forKey: KeyElementIdentifierType)
            aCoder.encodeInteger(self.elementIndex, forKey: KeyElementIndex)
            aCoder.encodeObject(self.elementValue, forKey: KeyElementValue)
            aCoder.encodeObject(self.value, forKey: KeyValue)
        }
    }
    
    
    let id: NSUUID
    let loginPage: String
    let homeBankId: FormItem
    let accountNumber: FormItem
    let password: FormItem
    let loginButton: FormItem
    
    //    override init() {
    //    }
    
    init(id: NSUUID, loginPage: String, homeBankId: FormItem, accountNumber: FormItem, password: FormItem, loginButton: FormItem) {
        self.id = id
        self.loginPage = loginPage
        self.homeBankId = homeBankId
        self.accountNumber = accountNumber
        self.password = password
        self.loginButton = loginButton
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey(KeyId) as! NSUUID
        self.loginPage = aDecoder.decodeObjectForKey(KeyLoginPage)as! String
        self.homeBankId = aDecoder.decodeObjectForKey(KeyHomeBankId)as! FormItem
        self.accountNumber = aDecoder.decodeObjectForKey(KeyAccountNumber) as! FormItem
        self.password = aDecoder.decodeObjectForKey(KeyPassword) as! FormItem
        self.loginButton = aDecoder.decodeObjectForKey(KeyLoginButton) as! FormItem
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: KeyId)
        aCoder.encodeObject(self.loginPage, forKey: KeyLoginPage)
        aCoder.encodeObject(self.homeBankId, forKey: KeyHomeBankId)
        aCoder.encodeObject(self.accountNumber, forKey: KeyAccountNumber)
        aCoder.encodeObject(self.password, forKey: KeyPassword)
        aCoder.encodeObject(self.loginButton, forKey: KeyLoginButton)
    }
}