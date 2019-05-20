//
//  OzonePopupViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 4/9/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class OzonePopupViewController: UIViewController {

    
    @IBOutlet weak var pumpFault: UILabel!
    @IBOutlet weak var motorOverload: UILabel!
    @IBOutlet weak var pressureFault: UILabel!
    @IBOutlet weak var ozonePumpOnOffLbl: UILabel!
    @IBOutlet weak var ozonePlayStp: UIButton!
    
    let OZONE_FAULTS                 = 2253
    let OZONE_PUMPRUNNING            = 2252
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pumpFault.isHidden = true
        self.motorOverload.isHidden = true
        self.pressureFault.isHidden = true
        
        readOzoneFaults()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    func readOzoneFaults(){
        CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: Int32(OZONE_FAULTS), completion: { (sucess, response) in
            
            if response != nil{
                
                let pumpFault = Int(truncating: response![0] as! NSNumber)
                let motorOverload = Int(truncating: response![1] as! NSNumber)
                let lowPressure = Int(truncating: response![2] as! NSNumber)
                
                if pumpFault == 1{
                    self.pumpFault.isHidden = false
                } else {
                    self.pumpFault.isHidden = true
                }
                if motorOverload == 1{
                    self.motorOverload.isHidden = false
                } else {
                    self.motorOverload.isHidden = true
                }
                if lowPressure == 1{
                    self.pressureFault.isHidden = false
                } else {
                    self.pressureFault.isHidden = true
                }
            }
            
        })
   
    
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(OZONE_PUMPRUNNING), completion: { (sucess, response) in
        
            if response != nil{
        
                let pumpRunning = Int(truncating: response![0] as! NSNumber)
                    if pumpRunning == 1{
        
                        self.ozonePumpOnOffLbl.text = "PUMP CURRENTLY ON"
                        self.ozonePumpOnOffLbl.textColor = GREEN_COLOR
//                        Currently not giving access to playstp button
//                          self.ozonePlayStp.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
        
                    } else if pumpRunning == 0{
        
                        self.ozonePumpOnOffLbl.text = "PUMP CURRENTLY OFF"
                        self.ozonePumpOnOffLbl.textColor = DEFAULT_GRAY
//                        Currently not giving access to playstp button
//                        self.ozonePlayStp.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
                    }
            }
        })
     }
    
    @IBAction func playStopOzonePump(_ sender: Any) {
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(OZONE_PUMPRUNNING), completion: { (sucess, response) in
            
            if response != nil{
                
                    let pumpRunning = Int(truncating: response![0] as! NSNumber)
                        if pumpRunning == 1{
                    
                            CENTRAL_SYSTEM?.writeBit(bit: 2251 , value: 0)
                            
                        }else{
                            
                            CENTRAL_SYSTEM?.writeBit(bit: 2251 , value: 1)
                            
                        }
                
                }
            })
    
    
        }
    
    
    @objc func getData(){
        readOzoneFaults()
    }
}
