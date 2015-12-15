//
//  SettingsView.swift
//  NetBank
//
//  Created by Oszkó Tamás on 04/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

struct Setting {
    
    struct FormItem {
        
        enum ElementIdentifierType : String {
            case Id = "Id"
            case Name = "Name"
            case TagName = "TagName"
            case Class = "Class"
        }
        var name : String = ""
        var elementIdentifierType : ElementIdentifierType = .Id
        var elementIndex : Int = 0
        var elementValue : String = ""
        var value : String = ""
        
        init() {
            self.init(name: "", elementIdentifierType: .Id, elementIndex: 0, elementValue: "", value: "")
        }

        init(name: String) {
            self.init(name: name, elementIdentifierType: .Id, elementIndex: 0, elementValue: "", value: "")
        }
        
        init(name: String, value: String) {
            self.init(name: name, elementIdentifierType: .Id, elementIndex: 0, elementValue: "", value: value)
        }
        
        init(name: String, elementIdentifierType : ElementIdentifierType = .Id, elementIndex: Int, elementValue : String,value: String) {
            self.name = name
            self.elementIdentifierType = .Id
            self.value = value
            self.elementIndex = elementIndex
            self.elementValue = elementValue
        }
        
        static func daoFromFormItem(formItem: FormItem) -> SettingsDao.FormItem {
            return SettingsDao.FormItem(name: formItem.name, elementIdentifierType: SettingsDao.FormItem.ElementIdentifierType(rawValue: formItem.elementIdentifierType.rawValue)!, elementIndex: formItem.elementIndex, elementValue: formItem.elementValue, value: formItem.value)
        }
        
        static func formItemFromDao(dao: SettingsDao.FormItem) -> FormItem {
            return FormItem(name: dao.name, elementIdentifierType: FormItem.ElementIdentifierType(rawValue: dao.elementIdentifierType.rawValue)!, elementIndex: dao.elementIndex, elementValue: dao.elementValue, value: dao.value)
        }
    }
    
    var id: NSUUID = NSUUID()
    var loginPage : String = ""
    var homeBankId : FormItem = FormItem(name: "Homebank ID")
    var accountNumber : FormItem = FormItem(name: "Account number")
    var password : FormItem = FormItem(name: "password")
    var loginButton : FormItem = FormItem(name: "Login button")
    
    static func daoFromSetting(setting: Setting) -> SettingsDao? {
        return SettingsDao(id: setting.id, loginPage: setting.loginPage, homeBankId: Setting.FormItem.daoFromFormItem(setting.homeBankId)
            , accountNumber: Setting.FormItem.daoFromFormItem(setting.accountNumber), password: Setting.FormItem.daoFromFormItem(setting.password), loginButton: Setting.FormItem.daoFromFormItem(setting.loginButton))
    }
    
    static func settingFromDao(dao: SettingsDao) -> Setting {
        return Setting(id: dao.id, loginPage: dao.loginPage, homeBankId: Setting.FormItem.formItemFromDao(dao.homeBankId), accountNumber: Setting.FormItem.formItemFromDao(dao.accountNumber), password: Setting.FormItem.formItemFromDao(dao.password), loginButton: Setting.FormItem.formItemFromDao(dao.loginButton))
    }
}

protocol SettingsView: NSObjectProtocol, DataLoadingView, WorkflowView, ErrorShowingView {
    
    weak var controller: ISettingsEditorController! {get set}
    
}
