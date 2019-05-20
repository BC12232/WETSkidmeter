//
//  CascadeSettingsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 10/15/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class CascadeSettingsViewController: UIViewController {

 
    @IBOutlet weak var filtrationRuntime: UITextField!
    @IBOutlet weak var P120Runtime: UITextField!
    @IBOutlet weak var P119Runtime: UITextField!
    @IBOutlet weak var filtrationMinimumSpeed: UITextField!
    @IBOutlet weak var P120MinimumSpeed: UITextField!
    @IBOutlet weak var P119MinimumSpeed: UITextField!
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl: UILabel!
    
    var readCurrentSPOnce = false
    var logger = Logger()
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool) {
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        
        constructSaveButton()
        
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }

    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        
        let (plcConnection,serverConnection) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            readDataFromPLC()
            
        }
        
        if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED{
            
            connectionFailed(plcConnection: plcConnection, serverConnection: serverConnection)
        }
        
        if plcConnection == CONNECTION_STATE_CONNECTING{
            
            
            //Change the connection stat indicator
            noConnectionView.alpha = 1
            noConnectionView.isUserInteractionEnabled = true
            noConnectionLbl.text = "CONNECTING TO PLC..."
            logger.logData(data: "WATER LEVEL SETTINGS: CONNECTING")
            
        }
        
    }
    
    
    
    /***************************************************************************
     * Function :  connectionFailed
     * Input    :  plcConnection state, serverConnection state
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func connectionFailed(plcConnection:Int,serverConnection:Int){
        
        let totalState = plcConnection + serverConnection
        noConnectionView.alpha = 1
        noConnectionView.isUserInteractionEnabled = true
        
        if totalState == 2{
            
            //Change the connection stat indicator
            noConnectionLbl.text = "PLC AND SERVER CONNECTION FAILED"
            logger.logData(data: "WATER LEVEL SETTINGS: PLC AND SERVER CONNECTION FAILED")
            
        }else if totalState == 1{
            
            if plcConnection == CONNECTION_STATE_FAILED{
                noConnectionLbl.text = "PLC CONNECTION FAILED"
                logger.logData(data: "WATER LEVEL SETTINGS: PLC CONNECTION FAILED")
            }else{
                noConnectionLbl.text = "SERVER CONNECTION FAILED"
                logger.logData(data: "WATER LEVEL SETTINGS: SERVER CONNECTION FAILED")
            }
        }
        
    }
    
    /***************************************************************************
     * Function :  constructSaveButton
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }
    
    
    
     @objc private func saveSetpoints(){
        savePoints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.readCurrentSPOnce = false

            
        }
    }
    
    
    /***************************************************************************
     * Function :  LT1001SaveSetpoint
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func savePoints(){
        
        
        if let filtrationRuntime = filtrationRuntime.text, !filtrationRuntime.isEmpty,
            let runtime = Int(filtrationRuntime) {
            
            CENTRAL_SYSTEM?.writeRegister(register: START_UP_FILTRATION_MIN_RUN_TIME, value: runtime)
        }
        
        
        if let P120Runtime = P120Runtime.text, !P120Runtime.isEmpty,
            let runtime = Int(P120Runtime) {
            
            CENTRAL_SYSTEM?.writeRegister(register: START_UP_P120_MIN_RUN_TIME, value: runtime)
        }
        
        if let P119Runtime = P119Runtime.text, !P119Runtime.isEmpty,
            let runtime = Int(P119Runtime) {
            
            CENTRAL_SYSTEM?.writeRegister(register: START_UP_P119_MIN_RUN_TIME, value: runtime)
        }
        
        if let filtrationMinimumSpeed = filtrationMinimumSpeed.text, !filtrationMinimumSpeed.isEmpty,
            let speed = Int(filtrationMinimumSpeed) {
            
            let convertedSpeed = speed * 10
            
            CENTRAL_SYSTEM?.writeRegister(register: START_UP_FILTRATION_MIN_SPEED_CHECK, value: convertedSpeed)
        }
        
        
        if let P120MinimumSpeed = P120MinimumSpeed.text, !P120MinimumSpeed.isEmpty,
            let speed = Int(P120MinimumSpeed){
            
            let convertedSpeed = speed * 10
            
            CENTRAL_SYSTEM?.writeRegister(register: START_UP_P120_MIN_SPEED_CHECK, value: convertedSpeed)
        }
        
        
        if let P119MinimumSpeed = P119MinimumSpeed.text, !P119MinimumSpeed.isEmpty,
            let speed = Int(P119MinimumSpeed) {
            
            let convertedSpeed = speed * 10
            
            CENTRAL_SYSTEM?.writeRegister(register: START_UP_P119_MIN_SPEED_CHECK, value: convertedSpeed)
        }
        
    }
    
    
    /***************************************************************************
     * Function :  readDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :  Reads the timer values and passes to the settings page
     ***************************************************************************/
    
    
    private func readDataFromPLC(){
        
        if !readCurrentSPOnce {
            
            
            CENTRAL_SYSTEM!.readRegister(length: Int32(START_UP_SETTINGS_BIT.count), startingRegister: Int32(START_UP_SETTINGS_BIT.startBit),  completion: { (success, response) in
                
                guard success == true else { return }
                
                let filtrationSpeed      =  Int(truncating: response![0] as! NSNumber)
                let filtrationRuntime    =  Int(truncating: response![1] as! NSNumber)
                let P120Speed            =  Int(truncating: response![2] as! NSNumber)
                let P120Runtime          =  Int(truncating: response![3] as! NSNumber)
                let P119Speed            =  Int(truncating: response![4] as! NSNumber)
                let P119Runtime          =  Int(truncating: response![5] as! NSNumber)
                
                let convertedFiltrationSpeed = filtrationSpeed / 10
                let convertedP120Speed       = P120Speed / 10
                let convertedP119Speed       = P119Speed / 10
                
                
                self.filtrationRuntime.text           = "\(filtrationRuntime)"
                self.filtrationMinimumSpeed.text      = "\(convertedFiltrationSpeed)"
                self.P120Runtime.text                 = "\(P120Runtime)"
                self.P120MinimumSpeed.text            = "\(convertedP120Speed)"
                self.P119Runtime.text                 = "\(P119Runtime)"
                self.P119MinimumSpeed.text            = "\(convertedP119Speed)"
            })
            
        }

    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if filtrationRuntime.isEditing || P120Runtime.isEditing || P119Runtime.isEditing || filtrationMinimumSpeed.isEditing ||  P120MinimumSpeed.isEditing || P119MinimumSpeed.isEditing {
            self.readCurrentSPOnce = true
        }
        
    }
    
    
}
