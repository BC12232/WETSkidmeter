//
//  ORPSetpointViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 10/30/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class ORPSetpointViewController: UIViewController {

    @IBOutlet weak var OrpSetpointLow: UITextField!
    @IBOutlet weak var orpSetpointTarget: UITextField!
    @IBOutlet weak var orpSetpointHigh: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSetPoints()
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @IBAction func writeSetpoints(_ sender: Any) {
        
        var setpointlow  = Float(self.OrpSetpointLow.text!)
        var target   = Float(self.orpSetpointTarget.text!)
        var setpointhigh  = Float(self.orpSetpointHigh.text!)
        
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
        
            CENTRAL_SYSTEM?.writeRealValue(register: 316, value: Float(setpointlow!))
            CENTRAL_SYSTEM?.writeRealValue(register: 600, value: Float(target!))
            CENTRAL_SYSTEM?.writeRealValue(register: 318, value: Float(setpointhigh!))
    }
    private func readSetPoints(){
        
        CENTRAL_SYSTEM?.readRealRegister(register: 316, length: 2, completion: { (success, response) in
            
            self.OrpSetpointLow.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 600, length: 2, completion: { (success, response) in
            
            self.orpSetpointTarget.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 318, length: 2, completion: { (success, response) in
            
            self.orpSetpointHigh.text   = "\(response)"
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
