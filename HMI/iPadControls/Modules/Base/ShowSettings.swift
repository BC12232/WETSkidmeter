//
//  ShowSettings.swift
//  iPadControls
//
//  Created by Jan Manalo on 6/14/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

var settingsIcon: UIButton?
var quadAIcon: UIButton?
var quadBIcon: UIButton?
var quadCIcon: UIButton?
var quadDIcon: UIButton?
var quadLock: UIButton?

extension UIViewController {

    func addAlertAction(button: UIButton){
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
        recognizer.minimumPressDuration = 3
        button.addGestureRecognizer(recognizer)
    }
    
    func addQuadAlert(button: UIButton){
        var passwordField: UITextField?
        
        let alertController = UIAlertController(title: "Quadrants Control", message: "Enter a password", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            passwordField = textfield
            textfield.isSecureTextEntry = true
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("User Cancel")
        }
        let login = UIAlertAction(title: "Login", style: .default) { (alert) in
            
            quadAIcon = self.view.viewWithTag(QUADA_ICON_TAG) as? UIButton
            quadBIcon = self.view.viewWithTag(QUADB_ICON_TAG) as? UIButton
            quadCIcon = self.view.viewWithTag(QUADC_ICON_TAG) as? UIButton
            quadDIcon = self.view.viewWithTag(QUADD_ICON_TAG) as? UIButton
            quadLock = self.view.viewWithTag(1234) as? UIButton
            
            guard quadAIcon != nil && quadBIcon != nil && quadCIcon != nil && quadDIcon != nil else{ return }
            
            if (passwordField?.text?.count)! > 0 {
                if let password = passwordField?.text {
                    if password == QUAD_PASSWORD {
                         quadAIcon?.isUserInteractionEnabled = true
                         quadBIcon?.isUserInteractionEnabled = true
                         quadCIcon?.isUserInteractionEnabled = true
                         quadDIcon?.isUserInteractionEnabled = true
                         quadLock?.isUserInteractionEnabled = false
                         quadLock?.setBackgroundImage(#imageLiteral(resourceName: "unlockGreen"), for: .normal)
                         quadAIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadAunlock"), for: .normal)
                         quadBIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadBunlock"), for: .normal)
                         quadCIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadCunlock"), for: .normal)
                         quadDIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadDunlock"), for: .normal)
                        
                    }else{
                        let wrongPasswordAlert = UIAlertController(title: "Wrong Password", message: "Please try again.", preferredStyle: .alert)
                        quadAIcon?.isUserInteractionEnabled = false
                        quadBIcon?.isUserInteractionEnabled = false
                        quadCIcon?.isUserInteractionEnabled = false
                        quadDIcon?.isUserInteractionEnabled = false
                        quadLock?.isUserInteractionEnabled = true
                        quadLock?.setBackgroundImage(#imageLiteral(resourceName: "lockRed"), for: .normal)
                        quadAIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadAlock"), for: .normal)
                        quadBIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadBlock"), for: .normal)
                        quadCIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadClock"), for: .normal)
                        quadDIcon?.setBackgroundImage(#imageLiteral(resourceName: "quadDlock"), for: .normal)
                        let dismissAlert = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                            print("User dismiss")
                        })
                        
                        wrongPasswordAlert.addAction(dismissAlert)
                        self.present(wrongPasswordAlert, animated: true, completion: nil)
                    }
                }
                
            }else{
                return
            }
            
        }
        
        alertController.addAction(login)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func longPressHappened(){
        var passwordField: UITextField?
        
        let alertController = UIAlertController(title: "Password", message: "Enter a password", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            passwordField = textfield
            textfield.isSecureTextEntry = true
        }
        
        let login = UIAlertAction(title: "Login", style: .default) { (alert) in
            
            settingsIcon = self.view.viewWithTag(SETTINGS_ICON_TAG) as? UIButton
            
            guard settingsIcon != nil else{ return }
            
            if (passwordField?.text?.count)! > 0 {
                if let password = passwordField?.text {
                    if password == APP_PASSWORD {
                        if settingsIcon!.alpha == 1{
                            
                            settingsIcon!.alpha = 0
                            settingsIcon!.isUserInteractionEnabled = false
                            
                        }else{
                            
                            settingsIcon!.alpha = 1
                            settingsIcon!.isUserInteractionEnabled = true
                            
                        }
                    }else{
                        let wrongPasswordAlert = UIAlertController(title: "Wrong Password", message: "Please try again.", preferredStyle: .alert)
                        
                        let dismissAlert = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                            print("User dismiss")
                        })
                        
                        wrongPasswordAlert.addAction(dismissAlert)
                        self.present(wrongPasswordAlert, animated: true, completion: nil)
                    }
                }
                
            }else{
                return
            }
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("User Cancel")
        }
        
        alertController.addAction(login)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
}
