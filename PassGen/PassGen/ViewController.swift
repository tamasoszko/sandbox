//
//  ViewController.swift
//  PassGen
//
//  Created by Oszkó Tamás on 06/12/15.
//  Copyright © 2015 Oszi. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var passwordLabel: UILabel!
    
    var passwdLength: Int?
    var passwd: String?
    var passwdGenerator = SimplePasswdGenerator()
    var displayPasswd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwdLength = getPasswdLength()
        generatePasswd()
        
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("passwdLabelTapped"))
        passwordLabel.addGestureRecognizer(recognizer)
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            generatePasswd()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderChanged(sender: AnyObject) {
        let len = getPasswdLength()
        if(len != passwdLength && len % 2 == 0) {
            generatePasswd()
        }
    }
    
    func passwdLabelTapped() {
        displayPasswd = !displayPasswd
        updateUI()
    }
    
    private func generatePasswd() {
        passwdLength = getPasswdLength()
        passwd = passwdGenerator.generate(passwdLength!)
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = passwd
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        updateUI()
    }
    
    private func getPasswdLength() -> Int {
        return Int(lengthSlider.value)
    }
    
    private func updateUI() {
        lengthLabel.text = "\(passwdLength!)"
        passwordLabel.text = passwdDisplayText()
    }
    
    private func passwdDisplayText() -> String {
        guard passwd != nil else {
            return "-"
        }
        if displayPasswd {
            return passwd!
        }
        return passwd!.sensitiveString()
    }

}

