//
//  FiltrationSettingsViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 2/28/17.
//  Copyright © 2017 WET. All rights reserved.
//

import UIKit

class FiltrationSettingsViewController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var bwDuration: UITextField!
    @IBOutlet weak var valveOpenClose: UITextField!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    private var readSettings = true

    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        constructSaveButton()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func checkSystemStat(){
        let (plcConnection, _) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            readValues()
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    //MARK: - Construct Save bar button item
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }
    
    
    private func readValues() {
        if readSettings {
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(FILTRATION_BW_DURATION_REGISTER), completion: { (success, response) in
                
                guard success == true else { return }
                
                let bwDuration = Int(truncating: response![0] as! NSNumber)
                
                CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT), completion: { (success, response) in
                    
                    guard success == true else { return }
                    
                    let valveOpenCloseValue = Int(truncating: response![0] as! NSNumber)
                    
                    self.bwDuration.text = "\(bwDuration)"
                    self.valveOpenClose.text = "\(valveOpenCloseValue)"
                })
            })
        }
    }
    
    
    
    //MARK: - Save  Setpoints
    
    @objc private func saveSetpoints(){
        guard let backwashDurationText = bwDuration.text,
            let backWashValue = Int(backwashDurationText),
            let valveOpenCloseText = valveOpenClose.text,
            let valveOpenCloseValue = Int(valveOpenCloseText) else { return }
        
        
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_BW_DURATION_REGISTER, value: backWashValue)
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT, value: valveOpenCloseValue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.readSettings = true
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if bwDuration.isEditing || valveOpenClose.isEditing {
            self.readSettings = false
        }
        
    }
    
    @IBAction func popupBtnPushed(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "filtration", bundle:nil)
        let popoverContent = storyBoard.instantiateViewController(withIdentifier: "SetpointsPopUp") as! ReadSetPointsPopUpViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popoverContent.faultTag = sender.tag
        popoverContent.preferredContentSize = CGSize(width: 500, height: 265)
        popover?.sourceRect = CGRect(x: -208, y: -208, width: 500, height: 265)
        popover?.sourceView = sender
        self.present(nav, animated: true, completion: nil)
        
    }
}
