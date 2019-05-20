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
    let WATERLEVEL_LT110                           = 3000
    let WATERLEVEL_LT110_WRITESP                   = 3006
    
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
            case 0: tankNameLbl.text = "LT110"
                    scaledValueLabel.text = "LT110 SCALED VALUE"
                    belowLLLSPLabel.text = "LT110 BELOW LLL SP"
                    belowLLSPLabel.text = "LT110 BELOW LL SP"
                    belowLSPLabel.text = "LT110 BELOW L SP"
                    aboveHighSPLabel.text = "LT110 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            case 1: tankNameLbl.text = "LT213"
                    scaledValueLabel.text = "LT213 SCALED VALUE"
                    belowLLLSPLabel.text = "LT213 BELOW LLL SP"
                    belowLLSPLabel.text = "LT213 BELOW LL SP"
                    belowLSPLabel.text = "LT213 BELOW L SP"
                    aboveHighSPLabel.text = "LT110 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            case 2: tankNameLbl.text = "LT401"
                    scaledValueLabel.text = "LT401 SCALED VALUE"
                    belowLLLSPLabel.text = "LT401 BELOW LLL SP"
                    belowLLSPLabel.text = "LT401 BELOW LL SP"
                    belowLSPLabel.text = "LT401 BELOW L SP"
                    aboveHighSPLabel.text = "LT401 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            case 3: tankNameLbl.text = "LT402"
                    scaledValueLabel.text = "LT402 SCALED VALUE"
                    belowLLLSPLabel.text = "LT402 BELOW LLL SP"
                    belowLLSPLabel.text = "LT402 BELOW LL SP"
                    belowLSPLabel.text = "LT402 BELOW L SP"
                    aboveHighSPLabel.text = "LT402 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            case 4: tankNameLbl.text = "LT403"
                    scaledValueLabel.text = "LT403 SCALED VALUE"
                    belowLLLSPLabel.text = "LT403 BELOW LLL SP"
                    belowLLSPLabel.text = "LT403 BELOW LL SP"
                    belowLSPLabel.text = "LT403 BELOW L SP"
                    aboveHighSPLabel.text = "LT403 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            case 5: tankNameLbl.text = "LT404"
                    scaledValueLabel.text = "LT404 SCALED VALUE"
                    belowLLLSPLabel.text = "LT404 BELOW LLL SP"
                    belowLLSPLabel.text = "LT404 BELOW LL SP"
                    belowLSPLabel.text = "LT404 BELOW L SP"
                    aboveHighSPLabel.text = "LT404 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            case 6: tankNameLbl.text = "LT405"
                    scaledValueLabel.text = "LT405 SCALED VALUE"
                    belowLLLSPLabel.text = "LT405 BELOW LLL SP"
                    belowLLSPLabel.text = "LT405 BELOW LL SP"
                    belowLSPLabel.text = "LT405 BELOW L SP"
                    aboveHighSPLabel.text = "LT405 ABOVE HI SP"
                    self.readSetpoints(register: WATERLEVEL_LT110 + (offset*waterTankNum))
            
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
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT110_WRITESP + (offset*waterTankNum), value: waterLLLSP!)
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT110_WRITESP + (offset*waterTankNum) + 2, value: waterLLSP!)
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT110_WRITESP + (offset*waterTankNum) + 4, value: waterLSP!)
                        CENTRAL_SYSTEM!.writeRealValue(register: WATERLEVEL_LT110_WRITESP + (offset*waterTankNum) + 6, value: aboveHigh!)
                default: print("No Number")
            }
        
    }
}
