//
//  ReadSetPointsPopUpViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 5/17/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class ReadSetPointsPopUpViewController: UIViewController {

    var faultTag = 0
    
    
    @IBOutlet weak var pt1001ScaledVal: UILabel!
    @IBOutlet weak var pt1001minVal: UILabel!
    @IBOutlet weak var pt1001maxVal: UILabel!
    @IBOutlet weak var pt1002ScaledVal: UILabel!
    @IBOutlet weak var pt1002minVal: UILabel!
    @IBOutlet weak var pt1002maxVal: UILabel!
    @IBOutlet weak var pt1003ScaledVal: UILabel!
    @IBOutlet weak var pt1003minVal: UILabel!
    @IBOutlet weak var pt1003maxVal: UILabel!
    @IBOutlet weak var cleanStrainerSP: UITextField!
    @IBOutlet weak var pumpOffSP: UITextField!
    @IBOutlet weak var pressSP: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseFaultStats()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let starinerSP = Float(self.cleanStrainerSP.text!)
        let pumpOffSP  = Float(self.pumpOffSP.text!)
        let bwPressSP  = Float(self.pressSP.text!)
        
        guard  starinerSP != nil && pumpOffSP != nil &&  bwPressSP != nil else{
            return
        }
        switch faultTag {
            case 1:  CENTRAL_SYSTEM!.writeRealValue(register: 4100, value: starinerSP!)
                     CENTRAL_SYSTEM!.writeRealValue(register: 4101, value: pumpOffSP!)
                     CENTRAL_SYSTEM!.writeRealValue(register: 4102, value: bwPressSP!)
            case 2:  CENTRAL_SYSTEM!.writeRealValue(register: 4200, value: starinerSP!)
                     CENTRAL_SYSTEM!.writeRealValue(register: 4201, value: pumpOffSP!)
                     CENTRAL_SYSTEM!.writeRealValue(register: 4202, value: bwPressSP!)
            case 3:  CENTRAL_SYSTEM!.writeRealValue(register: 4300, value: starinerSP!)
                     CENTRAL_SYSTEM!.writeRealValue(register: 4301, value: pumpOffSP!)
                     CENTRAL_SYSTEM!.writeRealValue(register: 4302, value: bwPressSP!)
            default:
                print("NO TAG")
        }
    }
    
    func readFaults(startingRegister:Int,setPointRegister:Int){
        
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let scaledVal = Float(response)
                        self.pt1001ScaledVal.text =  String(format: "%.2f", scaledVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 2, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let minVal = Float(response)
                        self.pt1001minVal.text =  String(format: "%.2f", minVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 4, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let maxVal = Float(response)
                        self.pt1001maxVal.text =  String(format: "%.2f", maxVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 6, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let scaledVal = Float(response)
                        self.pt1002ScaledVal.text =  String(format: "%.2f", scaledVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 8, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let minVal = Float(response)
                        self.pt1002minVal.text =  String(format: "%.2f", minVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 10, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let maxVal = Float(response)
                        self.pt1002maxVal.text =  String(format: "%.2f", maxVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 12, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let scaledVal = Float(response)
                        self.pt1003ScaledVal.text =  String(format: "%.2f", scaledVal!)
                     })
                     CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 14, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let minVal = Float(response)
                        self.pt1003minVal.text =  String(format: "%.2f", minVal!)
                     })
                    CENTRAL_SYSTEM?.readRealRegister(register: startingRegister + 16, length: 2, completion: { (success, response) in
                        guard success == true else { return }
                        let maxVal = Float(response)
                        self.pt1003maxVal.text =  String(format: "%.2f", maxVal!)
                        
                    })
        
                    CENTRAL_SYSTEM?.readRegister(length: 3, startingRegister: Int32(setPointRegister), completion: { (success, response) in
                        guard success == true else { return }
                            let strainerSP = Int(truncating: response![0] as! NSNumber)
                            let pumpOFFSP  = Int(truncating: response![1] as! NSNumber)
                            let bwPressSP  = Int(truncating: response![2] as! NSNumber)
                            self.cleanStrainerSP.text = String(strainerSP)
                            self.pumpOffSP.text = String(pumpOFFSP)
                            self.pressSP.text = String(bwPressSP)
                    })
    }
    
    func parseFaultStats(){
        switch faultTag {
            case 1: self.readFaults(startingRegister: 4104, setPointRegister: 4100)
            case 2: self.readFaults(startingRegister: 4204, setPointRegister: 4200)
            case 3: self.readFaults(startingRegister: 4304, setPointRegister: 4300)
            default:
                print("NO TAG")
        }
    }

}
