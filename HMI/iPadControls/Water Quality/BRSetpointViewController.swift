//
//  BRSetpointViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/20/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class BRSetpointViewController: UIViewController {

    @IBOutlet weak var brSetpointHigh: UITextField!
    @IBOutlet weak var brSetpointLow: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        readSetPoints()
        // Do any additional setup after loading the view.
    }
    private func readSetPoints(){
        
        CENTRAL_SYSTEM?.readRealRegister(register: 330, length: 2, completion: { (success, response) in
            
            self.brSetpointLow.text   = "\(response)"
        })
        
        CENTRAL_SYSTEM?.readRealRegister(register: 332, length: 2, completion: { (success, response) in
            
            self.brSetpointHigh.text   = "\(response)"
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    
    @IBAction func writeSetpoints(_ sender: UIButton) {
        var setpointlow  = Float(self.brSetpointLow.text!)
        var setpointhigh  = Float(self.brSetpointHigh.text!)
        
        if setpointlow == nil {
            setpointlow = 0
        }
        if setpointhigh == nil {
            setpointhigh = 100
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
       
        
        CENTRAL_SYSTEM?.writeRealValue(register: 330, value: Float(setpointlow!))
        CENTRAL_SYSTEM?.writeRealValue(register: 332, value: Float(setpointhigh!))
        
        
        
    }
    

}
