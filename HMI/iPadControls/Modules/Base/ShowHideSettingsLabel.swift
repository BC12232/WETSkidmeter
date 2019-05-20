//=================================== ABOUT ===================================

/*
 *  @FILE:          ShowHideSettingsLabel.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This UILabel Child module is responsible for showing and hiding the hidden settings button
 *  @VERSION:       2.0.0
 *
 */


//========================== CONFIGURATION PARAMETERS =========================

//NOTE: Following configuration parameters are not project dependent. They can be changed if necessary.

import UIKit

class ShowHideSettingsLabel: UILabel,UIAlertViewDelegate{

    var touchTimer:Timer?
    var settingsIcon:UIButton?

    
    /***************************************************************************
     * Function :  touchesBegan
     * Input    :  UI Touch Event
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        touchTimer = Timer.scheduledTimer(timeInterval: SETTINGS_SHOW_DELAY, target:self, selector:(#selector(ShowHideSettingsLabel.showAlert)) , userInfo: nil, repeats: false)
        
    }
    
    /***************************************************************************
     * Function :  touchesEnded
     * Input    :  UI Touch Event
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        
        self.invalidateTimer()
        
    }

    /***************************************************************************
     * Function :  invalidateTimer
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func invalidateTimer(){
    
        guard touchTimer != nil else{
            return
        }
        
        touchTimer!.invalidate()
        
    }
    
    /***************************************************************************
     * Function :  showAlert
     * Input    :  none
     * Output   :  none
     * Comment  :  Construct and Show the alert view that asks for password from user
     ***************************************************************************/
    
    @objc func showAlert(){
    
        self.invalidateTimer()
        
        let alertView = UIAlertView(title: "Password", message: "Enter Password", delegate: self, cancelButtonTitle: "Cancel")
        alertView.alertViewStyle = .secureTextInput
        alertView.addButton(withTitle: "Login")
        alertView.show()
        
    }
    
    /***************************************************************************
     * Function :  alertView
     * Input    :  alertView 
     * Output   :  none
     * Comment  :  Construct and Show the alert view that asks for password from user
     ***************************************************************************/
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        
        settingsIcon = self.superview!.viewWithTag(SETTINGS_ICON_TAG) as? UIButton

        //Make sure settings icon is not empty
        
        guard settingsIcon != nil else{
            return
        }
        
        //Make sure the icon we want is the hidden loging icon
        
        if buttonIndex == LOGIN_BTN_INDEX{
        
            let passwordTextField = alertView.textField(at: 0)
            
            //Make sure the text field is not empty
            
            guard passwordTextField != nil else{
                return
            }
            
            if passwordTextField!.text == APP_PASSWORD{
                
                if settingsIcon!.alpha == 1{
                    
                    settingsIcon!.alpha = 0
                    settingsIcon!.isUserInteractionEnabled = false
                    
                }else{
                    
                    settingsIcon!.alpha = 1
                    settingsIcon!.isUserInteractionEnabled = true
                    
                }
            }
        }
    }
}
