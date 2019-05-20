//
//  PumpSettingsViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/28/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

class PumpSettingsViewController: UIViewController{
    
    //No Connection View
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl: UILabel!
    
    @IBOutlet weak var p301Kp1: UITextField!
    @IBOutlet weak var p301Ti1: UITextField!
    @IBOutlet weak var p302Kp2: UITextField!
    @IBOutlet weak var p302Ti2: UITextField!
    @IBOutlet weak var p303Kp1: UITextField!
    @IBOutlet weak var p303Ti1: UITextField!
    
    @IBOutlet weak var p304Kp1: UITextField!
    @IBOutlet weak var p304Ti1: UITextField!
    @IBOutlet weak var p305Kp1: UITextField!
    @IBOutlet weak var p305Ti1: UITextField!
    @IBOutlet weak var p306Kp2: UITextField!
    @IBOutlet weak var p306Ti2: UITextField!
    
    //Object References
    let logger = Logger()
    
    //Show stoppers tructure
    var showStopper = ShowStoppers()
    
    //Selected Pump Number and Details
    var pumpDetails:PumpDetail?

    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        readSettings()
    }

    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()

    }
    
    //MARK: - View Did Appear
    
    override func viewDidAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    //================================== CONNECION CHECK POINT

    
    func readSettings() {
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5040), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p301Kp1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5041), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p301Ti1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5042), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p302Kp2.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5043), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p302Ti2.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5044), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p303Kp1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5045), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p303Ti1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5046), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p304Kp1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5047), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p304Ti1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5048), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p305Kp1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5049), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p305Ti1.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5050), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p306Kp2.text = "\(value)"
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(5051), completion: { (success, response) in
            guard success == true else { return }
            let value = Int(truncating: response![0] as! NSNumber)
            self.p306Ti2.text = "\(value)"
        })
    }
    //MARK: - Check Status Of The Connections To Server and PLC
    
    @objc func checkSystemStat(){
        
        let (plcConnection,serverConnection) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
        } else if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
            noConnectionView.alpha = 1
            noConnectionView.isUserInteractionEnabled = true
            
            if plcConnection == CONNECTION_STATE_FAILED && serverConnection == CONNECTION_STATE_FAILED {
                noConnectionLbl.text = "PLC AND SERVER CONNECTION FAILED"
            } else if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionLbl.text = "PLC CONNECTION FAILED"
            } else if serverConnection == CONNECTION_STATE_FAILED {
                noConnectionLbl.text = "SERVER CONNECTION FAILED"
            }
            
        } else if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
            //Change the connection stat indicator
            noConnectionView.alpha = 1
            noConnectionView.isUserInteractionEnabled = true
            if plcConnection == CONNECTION_STATE_CONNECTING && serverConnection == CONNECTION_STATE_CONNECTING {
                noConnectionLbl.text = "CONNECTING TO PLC AND SERVER"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionLbl.text = "CONNECTING TO PLC"
            } else if serverConnection == CONNECTION_STATE_CONNECTING {
                noConnectionLbl.text = "CONNECTING TO SERVER"
            }
            
        }
    }
    
    @IBAction func settingsupdate(_ sender: UITextField) {
        
        let p301Kp = Int(self.p301Kp1.text!)
        let p301Ti = Int(self.p301Ti1.text!)
        
        let p302Kp = Int(self.p302Kp2.text!)
        let p302Ti = Int(self.p302Ti2.text!)
        
        let p303Kp = Int(self.p303Kp1.text!)
        let p303Ti = Int(self.p303Ti1.text!)
        
        let p304Kp = Int(self.p304Kp1.text!)
        let p304Ti = Int(self.p304Ti1.text!)
        
        let p305Kp = Int(self.p305Kp1.text!)
        let p305Ti = Int(self.p305Ti1.text!)
        
        let p306Kp = Int(self.p306Kp2.text!)
        let p306Ti = Int(self.p306Ti2.text!)
        
        guard  p301Kp != nil && p301Ti != nil && p302Kp != nil && p302Ti != nil && p303Kp != nil && p303Ti != nil && p304Kp != nil && p304Ti != nil && p305Kp != nil && p305Ti != nil && p306Kp != nil && p306Ti != nil else{
            return
        }
        
        CENTRAL_SYSTEM!.writeRegister(register: 5040, value: p301Kp!)
        CENTRAL_SYSTEM!.writeRegister(register: 5041, value: p301Ti!)
        
        CENTRAL_SYSTEM!.writeRegister(register: 5042, value: p302Kp!)
        CENTRAL_SYSTEM!.writeRegister(register: 5043, value: p302Ti!)
        
        CENTRAL_SYSTEM!.writeRegister(register: 5044, value: p303Kp!)
        CENTRAL_SYSTEM!.writeRegister(register: 5045, value: p303Ti!)
        
        CENTRAL_SYSTEM!.writeRegister(register: 5046, value: p304Kp!)
        CENTRAL_SYSTEM!.writeRegister(register: 5047, value: p304Ti!)
        
        CENTRAL_SYSTEM!.writeRegister(register: 5048, value: p305Kp!)
        CENTRAL_SYSTEM!.writeRegister(register: 5049, value: p305Ti!)
        
        CENTRAL_SYSTEM!.writeRegister(register: 5050, value: p306Kp!)
        CENTRAL_SYSTEM!.writeRegister(register: 5051, value: p306Ti!)
    }
}
