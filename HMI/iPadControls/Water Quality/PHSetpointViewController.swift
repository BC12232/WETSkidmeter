//
//  PHSetpointViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/20/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class PHSetpointViewController: UIViewController {

    @IBOutlet weak var phSetpointLow: UITextField!
    @IBOutlet weak var phSetpointHigh: UITextField!
    @IBOutlet weak var phSetpointTarget: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSetPoints()
        // Do any additional setup after loading the view.
    }
    private func readSetPoints(){
        
        CENTRAL_SYSTEM?.readRealRegister(register: 306, length: 2, completion: { (success, response) in
            
            self.phSetpointLow.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 600, length: 2, completion: { (success, response) in
            
            self.phSetpointTarget.text   = "\(response)"
        })
        CENTRAL_SYSTEM?.readRealRegister(register: 308, length: 2, completion: { (success, response) in
            
            self.phSetpointHigh.text   = "\(response)"
        })
        
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @IBAction func writeSetpoints(_ sender: UIButton) {
        var setpointlow  = Float(self.phSetpointLow.text!)
        var target   = Float(self.phSetpointTarget.text!)
        var setpointhigh  = Float(self.phSetpointHigh.text!)
        
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
        
        CENTRAL_SYSTEM?.writeRealValue(register: 306, value: Float(setpointlow!))
        CENTRAL_SYSTEM?.writeRealValue(register: 600, value: Float(target!))
        CENTRAL_SYSTEM?.writeRealValue(register: 308, value: Float(setpointhigh!))
        
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
