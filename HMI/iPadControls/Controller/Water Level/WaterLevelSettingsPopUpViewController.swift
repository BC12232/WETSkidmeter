//
//  WaterLevelSettingsPopUpViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/16/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class WaterLevelSettingsPopUpViewController: UIViewController {
    var waterTankNum = 0
    let offset = 20
    let WATERLEVEL_LT1001                           = 3000
    let WATERLEVEL_LT1001_WRITESP                   = 3006
    
    @IBOutlet weak var tankNameLbl: UILabel!
    @IBOutlet weak var scaledValueLabel: UILabel!
    @IBOutlet weak var belowLLLSPLabel: UILabel!
    @IBOutlet weak var belowLLSPLabel: UILabel!
    @IBOutlet weak var belowLSPLabel: UILabel!
    @IBOutlet weak var aboveHighSPLabel: UILabel!
    
    @IBOutlet weak var scaledValueTxt: UILabel!
    @IBOutlet weak var waterLLLSPTxt: UITextField!
    @IBOutlet weak var waterLLSPTxt: UITextField!
    @IBOutlet weak var waterLSPTxt: UITextField!
    @IBOutlet weak var waterAbHighSPTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch waterTankNum {
            case 0: tankNameLbl.text = "LT1001"
                    scaledValueLabel.text = "LT1001 SCALED VALUE"
                    belowLLLSPLabel.text = "LT1001 BELOW LLL SP"
                    belowLLSPLabel.text = "LT1001 BELOW LL SP"
                    belowLSPLabel.text = "LT1001 BELOW L SP"
                    aboveHighSPLabel.text = "LT1001 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT1001 + (offset*waterTankNum))
            case 1: tankNameLbl.text = "LT1002"
                    scaledValueLabel.text = "LT1002 SCALED VALUE"
                    belowLLLSPLabel.text = "LT1002 BELOW LLL SP"
                    belowLLSPLabel.text = "LT1002 BELOW LL SP"
                    belowLSPLabel.text = "LT1002 BELOW L SP"
                    aboveHighSPLabel.text = "LT1002 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT1001 + (offset*waterTankNum))
            case 2: tankNameLbl.text = "LT1003"
                    scaledValueLabel.text = "LT1003 SCALED VALUE"
                    belowLLLSPLabel.text = "LT1003 BELOW LLL SP"
                    belowLLSPLabel.text = "LT1003 BELOW LL SP"
                    belowLSPLabel.text = "LT1003 BELOW L SP"
                    aboveHighSPLabel.text = "LT1003 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT1001 + (offset*waterTankNum))
            
            default: print("No Number")
        }
        
        // Do any additional setup after loading the view.
    }
    
    func readSetpoints(register:Int){
        switch waterTankNum {
        case 0...6:
            CENTRAL_SYSTEM?.readRealRegister(register: Int(register), length: 2, completion: { (success, response) in
                guard success == true else { return }
                self.scaledValueTxt.text = "\(response)"
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(register + 6), length: 2, completion: { (success, response) in
                guard success == true else { return }
                self.waterLLLSPTxt.text = "\(response)"
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(register + 8), length: 2, completion: { (success, response) in
                guard success == true else { return }
                self.waterLLSPTxt.text = "\(response)"
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(register + 10), length: 2, completion: { (success, response) in
                guard success == true else { return }
                self.waterLSPTxt.text =  "\(response)"
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(register + 12), length: 2, completion: { (success, response) in
                guard success == true else { return }
                self.waterAbHighSPTxt.text =  "\(response)"
            })
        default: print("No Number")
        }
    }
    
    @IBAction func updateSetpoints(_ sender: UITextField) {
        
        let waterLSP   = Float(self.waterLSPTxt.text!)
        let waterLLSP  = Float(self.waterLLSPTxt.text!)
        let waterLLLSP = Float(self.waterLLLSPTxt.text!)
        let aboveHigh  = Float(self.waterAbHighSPTxt.text!)
        
        guard  waterLSP != nil && waterLLSP != nil && waterLLLSP != nil && aboveHigh != nil else{
            return
        }
        switch waterTankNum {
        
            case 0...6:
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT1001_WRITESP + (offset*waterTankNum), value: waterLLLSP!)
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT1001_WRITESP + (offset*waterTankNum) + 2, value: waterLLSP!)
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT1001_WRITESP + (offset*waterTankNum) + 4, value: waterLSP!)
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT1001_WRITESP + (offset*waterTankNum) + 6, value: aboveHigh!)
                default: print("No Number")
            }
        
    }
}
