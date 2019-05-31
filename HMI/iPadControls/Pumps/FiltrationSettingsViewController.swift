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
    @IBOutlet weak var p101SP: UITextField!
    @IBOutlet weak var p102SP: UITextField!
    @IBOutlet weak var p103SP: UITextField!
    @IBOutlet weak var kp101: UITextField!
    @IBOutlet weak var kp102: UITextField!
    @IBOutlet weak var kp103: UITextField!
    @IBOutlet weak var ti101: UITextField!
    @IBOutlet weak var ti102: UITextField!
    @IBOutlet weak var ti103: UITextField!
    @IBOutlet weak var scaledValpt1001: UILabel!
    @IBOutlet weak var scaledValpt1002: UILabel!
    @IBOutlet weak var scaledValpt1003: UILabel!
    @IBOutlet weak var minVal1001: UILabel!
    @IBOutlet weak var minVal1002: UILabel!
    @IBOutlet weak var minVal1003: UILabel!
    @IBOutlet weak var maxVal1001: UILabel!
    @IBOutlet weak var maxVal1002: UILabel!
    @IBOutlet weak var maxVal1003: UILabel!
    
    private var readSettings = true

    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        constructSaveButton()
        readFaults()
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
            let valveOpenCloseValue = Int(valveOpenCloseText),
            let p101SP = Float(self.p101SP.text!),
            let kpVal101  = Int(self.kp101.text!),
            let tiVal101  = Int(self.ti101.text!),
            let p102SP = Float(self.p102SP.text!),
            let kpVal102  = Int(self.kp102.text!),
            let tiVal102  = Int(self.ti102.text!),
            let p103SP = Float(self.p103SP.text!),
            let kpVal103  = Int(self.kp103.text!),
            let tiVal103  = Int(self.ti103.text!) else { return }
        
        
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_BW_DURATION_REGISTER, value: backWashValue)
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT, value: valveOpenCloseValue)
        
        CENTRAL_SYSTEM!.writeRealValue(register: 5050, value: p101SP)
        CENTRAL_SYSTEM!.writeRegister (register: 5052, value: kpVal101)
        CENTRAL_SYSTEM!.writeRegister (register: 5053, value: tiVal101)
        
        CENTRAL_SYSTEM!.writeRealValue(register: 5054, value: p102SP)
        CENTRAL_SYSTEM!.writeRegister (register: 5056, value: kpVal102)
        CENTRAL_SYSTEM!.writeRegister (register: 5057, value: tiVal102)
        
        CENTRAL_SYSTEM!.writeRealValue(register: 5058, value: p103SP)
        CENTRAL_SYSTEM!.writeRegister (register: 5060, value: kpVal103)
        CENTRAL_SYSTEM!.writeRegister (register: 5061, value: tiVal103)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.readSettings = true
           
        }
         self.readFaults()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if bwDuration.isEditing || valveOpenClose.isEditing {
            self.readSettings = false
        }
        
    }
    
    
    func readFaults(){
        
        CENTRAL_SYSTEM?.readRealRegister(register: 5000, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let scaledVal = Float(response)
            self.scaledValpt1001.text =  String(format: "%.1f", scaledVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5002, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let minVal = Float(response)
            self.minVal1001.text =  String(format: "%.1f", minVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5004, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let maxVal = Float(response)
            self.maxVal1001.text =  String(format: "%.1f", maxVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5050, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let p101SP = Float(response)
            self.p101SP.text =  String(format: "%.1f", p101SP!)
        })
        CENTRAL_SYSTEM?.readRegister(length: 2, startingRegister: 5052, completion: { (success, response) in
            guard success == true else { return }
            let kpVal  = Int(truncating: response![0] as! NSNumber)
            let tiVal  = Int(truncating: response![1] as! NSNumber)
            self.kp101.text = String(kpVal)
            self.ti101.text = String(tiVal)
        })
        
        CENTRAL_SYSTEM?.readRealRegister(register: 5020, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let scaledVal = Float(response)
            self.scaledValpt1002.text =  String(format: "%.1f", scaledVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5022, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let minVal = Float(response)
            self.minVal1002.text =  String(format: "%.1f", minVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5024, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let maxVal = Float(response)
            self.maxVal1002.text =  String(format: "%.1f", maxVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5054, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let p101SP = Float(response)
            self.p102SP.text =  String(format: "%.1f", p101SP!)
        })
        CENTRAL_SYSTEM?.readRegister(length: 2, startingRegister: 5056, completion: { (success, response) in
            guard success == true else { return }
            let kpVal  = Int(truncating: response![0] as! NSNumber)
            let tiVal  = Int(truncating: response![1] as! NSNumber)
            self.kp102.text = String(kpVal)
            self.ti102.text = String(tiVal)
        })
        
        CENTRAL_SYSTEM?.readRealRegister(register: 5040, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let scaledVal = Float(response)
            self.scaledValpt1003.text =  String(format: "%.1f", scaledVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5042, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let minVal = Float(response)
            self.minVal1003.text =  String(format: "%.1f", minVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5044, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let maxVal = Float(response)
            self.maxVal1003.text =  String(format: "%.1f", maxVal!)
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 5058, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let p101SP = Float(response)
            self.p103SP.text =  String(format: "%.1f", p101SP!)
        })
        CENTRAL_SYSTEM?.readRegister(length: 2, startingRegister: 5060, completion: { (success, response) in
            guard success == true else { return }
            let kpVal  = Int(truncating: response![0] as! NSNumber)
            let tiVal  = Int(truncating: response![1] as! NSNumber)
            self.kp103.text = String(kpVal)
            self.ti103.text = String(tiVal)
        })
    }
    
    
}
