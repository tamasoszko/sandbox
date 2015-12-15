//
//  SettingsTableViewCell.swift
//  NetBank
//
//  Created by Oszkó Tamás on 03/04/15.
//  Copyright (c) 2015 TamasO. All rights reserved.
//

import UIKit


class SettingsTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate : SettingsTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setTitle(title: String, placeHolder: String, keyboardType: UIKeyboardType = UIKeyboardType.Default, password: Bool = false) {
        label.text = title
        textField.placeholder = placeHolder
        textField.keyboardType = keyboardType
        textField.secureTextEntry = password
    }
    
    func setCellText(text: String) {
        textField.text = text
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return self.delegate!.tableViewCellShouldReturn(self)
    }
}


protocol SettingsTableViewCellDelegate : NSObjectProtocol {
    
    func tableViewCellShouldReturn(tableViewCell: SettingsTableViewCell) -> Bool
    
}
