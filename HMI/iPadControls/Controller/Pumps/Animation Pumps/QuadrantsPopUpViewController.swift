//
//  QuadrantsPopUpViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/8/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class QuadrantsPopUpViewController: UIViewController {


    @IBOutlet weak var targetSPtxtField: UITextField!
    @IBOutlet weak var lowWaterMaxSPtxtField: UITextField!
    @IBOutlet weak var quadrantLbl: UILabel!
    @IBOutlet weak var ipadControlSwitch: UISwitch!
    
    @IBOutlet var popOverView: UIView!
    var quadrantNumber = 0
    
    let PUMP_QUAD_A_LOW                   = 3050
    let PUMP_QUAD_A_MAX_LOW_FREQ          = 5002
    let PUMP_QUAD_A_TARGET                = 5000
    let PUMP_QUAD_A_iPAD_CONTROL          = 5000
    
    
    override func viewWillAppear(_ animated: Bool) {
        readQuadValues()
    }
    override func viewWillDisappear(_ animated: Bool) {
        var maxlowFreq = Float(self.lowWaterMaxSPtxtField.text!)
      
        let target = Float(self.targetSPtxtField.text!)
        
        guard  maxlowFreq != nil && target != nil else{
            return
        }
        maxlowFreq = maxlowFreq!*10
        if maxlowFreq! >= 500{
            maxlowFreq = 500
        }
        let pumpTargetOffset = 10
        switch quadrantNumber {
        case 1:
            CENTRAL_SYSTEM!.writeRealValue(register: PUMP_QUAD_A_TARGET, value: target!)
            CENTRAL_SYSTEM!.writeRegister(register: PUMP_QUAD_A_MAX_LOW_FREQ, value: Int(maxlowFreq!))
            
        case 2:
            CENTRAL_SYSTEM!.writeRealValue(register: PUMP_QUAD_A_TARGET + pumpTargetOffset*(quadrantNumber-1), value: target!)
            CENTRAL_SYSTEM!.writeRegister(register: PUMP_QUAD_A_MAX_LOW_FREQ + pumpTargetOffset*(quadrantNumber-1), value: Int(maxlowFreq!))
            
        case 3:
            CENTRAL_SYSTEM!.writeRealValue(register: PUMP_QUAD_A_TARGET + pumpTargetOffset*(quadrantNumber-1), value: target!)
            CENTRAL_SYSTEM!.writeRegister(register: PUMP_QUAD_A_MAX_LOW_FREQ + pumpTargetOffset*(quadrantNumber-1), value: Int(maxlowFreq!))
            
        case 4:
            CENTRAL_SYSTEM!.writeRealValue(register: PUMP_QUAD_A_TARGET + pumpTargetOffset*(quadrantNumber-1), value: target!)
            CENTRAL_SYSTEM!.writeRegister(register: PUMP_QUAD_A_MAX_LOW_FREQ + pumpTargetOffset*(quadrantNumber-1), value: Int(maxlowFreq!))
            
        default: print("No Number")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        switch quadrantNumber {
            case 1: quadrantLbl.text = "QUADRANT A"
            case 2: quadrantLbl.text = "QUADRANT B"
            case 3: quadrantLbl.text = "QUADRANT C"
            case 4: quadrantLbl.text = "QUADRANT D"
            
            default: print("No Number")
        }
        readQuadValues()
    }
    func readQuadValues(){
        let pumpTargetOffset = 10
        switch quadrantNumber {
        case 1:
                CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(PUMP_QUAD_A_MAX_LOW_FREQ), completion: { (success, response) in
                    guard success == true else { return }
                    var value = Float(truncating: response![0] as! NSNumber)
                    value = value/10
                    self.lowWaterMaxSPtxtField.text = String(format: "%.1f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(PUMP_QUAD_A_TARGET), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let number  = Float(response)
                    self.targetSPtxtField.text =  String(format: "%.2f", number!)
                })
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PUMP_QUAD_A_TARGET), completion: { (success, response) in
                    guard success == true else { return }
                    let status = Int(truncating: response![0] as! NSNumber)
                    if status == 0{
                        self.ipadControlSwitch.isOn = false
                    } else {
                        self.ipadControlSwitch.isOn = true
                    }
                })
        case 2:
                CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(PUMP_QUAD_A_MAX_LOW_FREQ + pumpTargetOffset*(quadrantNumber-1)), completion: { (success, response) in
                    guard success == true else { return }
                    var value = Float(truncating: response![0] as! NSNumber)
                    value = value/10
                    self.lowWaterMaxSPtxtField.text = String(format: "%.1f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(PUMP_QUAD_A_TARGET + pumpTargetOffset*(quadrantNumber-1)), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let number  = Float(response)
                    self.targetSPtxtField.text =  String(format: "%.2f", number!)
                })
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1)), completion: { (success, response) in
                    guard success == true else { return }
                    let status = Int(truncating: response![0] as! NSNumber)
                    if status == 0{
                        self.ipadControlSwitch.isOn = false
                    } else {
                        self.ipadControlSwitch.isOn = true
                    }
                })
        case 3:
                CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(PUMP_QUAD_A_MAX_LOW_FREQ + pumpTargetOffset*(quadrantNumber-1)), completion: { (success, response) in
                    guard success == true else { return }
                    var value = Float(truncating: response![0] as! NSNumber)
                    value = value/10
                    self.lowWaterMaxSPtxtField.text = String(format: "%.1f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(PUMP_QUAD_A_TARGET + pumpTargetOffset*(quadrantNumber-1)), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let number  = Float(response)
                    self.targetSPtxtField.text =  String(format: "%.2f", number!)
                })
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1)), completion: { (success, response) in
                    guard success == true else { return }
                    let status = Int(truncating: response![0] as! NSNumber)
                    if status == 0{
                        self.ipadControlSwitch.isOn = false
                    } else {
                        self.ipadControlSwitch.isOn = true
                    }
                })
        case 4:
                CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(PUMP_QUAD_A_MAX_LOW_FREQ + pumpTargetOffset*(quadrantNumber-1)), completion: { (success, response) in
                    guard success == true else { return }
                    var value = Float(truncating: response![0] as! NSNumber)
                    value = value/10
                    self.lowWaterMaxSPtxtField.text = String(format: "%.1f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(PUMP_QUAD_A_TARGET + pumpTargetOffset*(quadrantNumber-1)), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let number  = Float(response)
                    self.targetSPtxtField.text =  String(format: "%.2f", number!)
                })
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1)), completion: { (success, response) in
                    guard success == true else { return }
                    let status = Int(truncating: response![0] as! NSNumber)
                    if status == 0{
                        self.ipadControlSwitch.isOn = false
                    } else {
                        self.ipadControlSwitch.isOn = true
                    }
                })
        
        default: print("No Number")
        }
    }
    
    @IBAction func updateQuadrant(_ sender: UITextField) {
        print("HERE")
    }
    @IBAction func controlSwitchToggle(_ sender: UISwitch) {
        let pumpTargetOffset = 10
        if self.ipadControlSwitch.isOn == true{
            switch quadrantNumber {
                case 1:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL, value: 1)
                case 2:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1), value: 1)
                case 3:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1), value: 1)
                case 4:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1), value: 1)
                
                default: print("No Number")
            }
        } else {
            switch quadrantNumber {
                case 1:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL, value: 0)
                case 2:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1), value: 0)
                case 3:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1), value: 0)
                case 4:  CENTRAL_SYSTEM?.writeBit(bit: PUMP_QUAD_A_iPAD_CONTROL + pumpTargetOffset*(quadrantNumber-1), value: 0)
                
                default: print("No Number")
            }
        }
    }
}
