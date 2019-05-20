//
//  TDSSetpointViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/20/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class TDSSetpointViewController: UIViewController {

    @IBOutlet weak var tdsSetpointLow: UITextField!
    @IBOutlet weak var tdsSetpointTarget: UITextField!
    @IBOutlet weak var tdsSetpointHigh: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        readSetPoints()
        // Do any additional setup after loading the view.
    }
    private func readSetPoints(){
        
        CENTRAL_SYSTEM?.readRealRegister(register: 326, length: 2, completion: { (success, response) in
            
            self.tdsSetpointLow.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 600, length: 2, completion: { (success, response) in
            
            self.tdsSetpointTarget.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 328, length: 2, completion: { (success, response) in
            
            self.tdsSetpointHigh.text   = "\(response)"
        })
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    @IBAction func writeSetpoints(_ sender: UIButton) {
        var setpointlow  = Float(self.tdsSetpointLow.text!)
        var target   = Float(self.tdsSetpointTarget.text!)
        var setpointhigh  = Float(self.tdsSetpointHigh.text!)
        
        if setpointlow == nil {
            setpointlow = 0
        }
        if setpointhigh == nil {
            setpointhigh = 100
        }
        if target == nil {
            target = 50
        }
        
        if setpointlow! < 0{
            setpointlow = 0
        }
        if setpointlow! > 900{
            setpointlow = 900
        }
        if setpointhigh! > 1000 || setpointhigh! < 100{
            setpointhigh = setpointlow! + 100
        }
        if target! < setpointlow! || target! > setpointhigh!{
            target = (setpointlow! + setpointhigh!)/2
        }
        
        CENTRAL_SYSTEM?.writeRealValue(register: 326, value: Float(setpointlow!))
        CENTRAL_SYSTEM?.writeRealValue(register: 600, value: Float(target!))
        CENTRAL_SYSTEM?.writeRealValue(register: 328, value: Float(setpointhigh!))
        
        
        
    }

}
