//
//  SettingsTableViewController.swift
//  NetBank
//
//  Created by Oszkó Tamás on 03/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsTableViewCellDelegate, SettingsView {
    
    weak var controller: ISettingsEditorController!
    weak var workflow: Workflow!
    private var setting: Setting?
    private weak var activityIndicator: UIActivityIndicatorView?
    private var textFields: [NSIndexPath: UITextField] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem?.enabled = false
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
//        println("SettingsTableViewController.navigationController: \(self.navigationController)")
        self.controller.getSettings()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        setupSettingFromCells()
        self.controller.saveSetting(Setting.daoFromSetting(self.setting!)!)
    }
    
    func setupSettingFromCells() {
        if let loginPage = self.textFields[NSIndexPath(forRow: 0, inSection: 0)] {
            self.setting?.loginPage = loginPage.text!
        }
        if let homeBankId = self.textFields[NSIndexPath(forRow: 0, inSection: 1)] {
            self.setting?.homeBankId.value = homeBankId.text!
        }
        if let accountNumber = self.textFields[NSIndexPath(forRow: 1, inSection: 1)] {
            self.setting?.accountNumber.value = accountNumber.text!
        }
        if let password = self.textFields[NSIndexPath(forRow: 2, inSection: 1)] {
            self.setting?.password.value = password.text!
        }
        if let homeBankTagId = self.textFields[NSIndexPath(forRow: 0, inSection: 2)] {
            self.setting?.homeBankId.elementValue = homeBankTagId.text!
        }
        if let accountTagId = self.textFields[NSIndexPath(forRow: 1, inSection: 2)] {
            self.setting?.accountNumber.elementValue = accountTagId.text!
        }
        if let passwordTagId = self.textFields[NSIndexPath(forRow: 2, inSection: 2)] {
            self.setting?.password.elementValue = passwordTagId.text!
        }
        if let loginButtonTagId = self.textFields[NSIndexPath(forRow: 3, inSection: 2)] {
            self.setting?.loginButton.elementValue = loginButtonTagId.text!
        }
    }
    
    // MARK: - SettingsView
    override func refresh() {
        if let _ = self.controller.settings, let first = self.controller.settings!.first {
            self.setting = Setting.settingFromDao(first)
        } else {
            self.setting = Setting()
        }
        self.tableView.reloadData()
    }
    
    func showError(error: NSError) {
        UIAlertView(title: error.localizedDescription, message: error.localizedRecoverySuggestion, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 4
        default:
            assertionFailure("invalid section=\(section)")
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Web page"
        case 1:
            return "Account"
        case 2:
            return "HTML form mapping"
        default:
            assertionFailure("invalid section=\(section)")
        }
        return ""
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath) as! SettingsTableViewCell
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.setTitle("Home URL", placeHolder: "https://mybank.com/", keyboardType: UIKeyboardType.URL)
            if let loginPage = self.setting?.loginPage {
                cell.setCellText(loginPage)
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.setTitle("Homebank ID", placeHolder: "123456", keyboardType: UIKeyboardType.NumbersAndPunctuation, password: true)
                if let homeBankId = self.setting?.homeBankId.value {
                    cell.setCellText(homeBankId)
                }
            case 1:
                cell.setTitle("Account number", placeHolder: "12345678-90123456", keyboardType: UIKeyboardType.NumbersAndPunctuation)
                if let accountNumber = self.setting?.accountNumber.value {
                    cell.setCellText(accountNumber)
                }
            case 2:
                cell.setTitle("Password", placeHolder: "***", keyboardType: UIKeyboardType.Default, password: true)
                if let password = self.setting?.password.value {
                    cell.setCellText(password)
                }
            default:
                assertionFailure("Invalid indexpath=\(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.setTitle("Homebank tag", placeHolder: "homebank tag id")
                if let homeBankTagId = self.setting?.homeBankId.elementValue {
                    cell.setCellText(homeBankTagId)
                }
            case 1:
                cell.setTitle("Account tag", placeHolder: "account tag id")
                if let accountTagId = self.setting?.accountNumber.elementValue {
                    cell.setCellText(accountTagId)
                }
            case 2:
                cell.setTitle("Password tag", placeHolder: "password-id")
                if let passwordTagId = self.setting?.password.elementValue {
                    cell.setCellText(passwordTagId)
                }
            case 3:
                cell.setTitle("Login button tag", placeHolder: "button tag id")
                if let loginButtonTagId = self.setting?.loginButton.elementValue {
                    cell.setCellText(loginButtonTagId)
                }
            default:
                assertionFailure("Invalid indexpath=\(indexPath)")
            }
        default:
            assertionFailure("Invalid indexpath=\(indexPath)")
        }
        self.textFields[indexPath] = cell.textField
        return cell
    }

    func tableViewCellShouldReturn(tableViewCell: SettingsTableViewCell) -> Bool {
        let indexPath = tableView.indexPathForCell(tableViewCell)!
        switch indexPath.section {
        case 0:
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section+1))! as! SettingsTableViewCell
            cell.textField.becomeFirstResponder()
        case 1:
            switch indexPath.row {
            case 0...1:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section))! as! SettingsTableViewCell
                cell.textField.becomeFirstResponder()
            case 2:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexPath.section+1))! as! SettingsTableViewCell
                cell.textField.becomeFirstResponder()
            default:
                assertionFailure("Invalid indexpath=\(indexPath)")
            }
        case 2:
            switch indexPath.row {
            case 0...2:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section))! as! SettingsTableViewCell
                cell.textField.becomeFirstResponder()
            case 3:
                self.view.endEditing(true)
            default:
                assertionFailure("Invalid indexpath=\(indexPath)")
            }
        default:
            assertionFailure("Invalid indexpath=\(indexPath)")
        }
        return true
    }
    
//    func settingsFromUI() -> SettingsDao {
//        return SettingsDao(
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
}
