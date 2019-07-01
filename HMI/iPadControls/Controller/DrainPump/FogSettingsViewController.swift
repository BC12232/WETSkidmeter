//
//  FogSettingsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 10/8/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

class FogSettingsViewController: UIViewController  {
    

    @IBOutlet weak var drainTimeout: UITextField!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    private var readOnce = false
    
    override func viewDidLoad() {
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        readDefaultFogDelay()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func checkSystemStat(){
        let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            readDefaultFogDelay()
        }else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    
    private func readDefaultFogDelay() {
        if !readOnce {
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(DRAIN_TIMEOUT), completion: { (success, response) in
                guard success == true else { return }
                
                let delay = Int(truncating: response![0] as! NSNumber)
                
                self.drainTimeout.text = "\(delay)"
                
            })
            self.readOnce = true
        }
    
    }
    
    

    
    @IBAction func saveSettings(_ sender: Any) {
        guard let text = drainTimeout.text, !text.isEmpty else { return }
        if let value = Int(text) {
            if value >= 0 && value <= 300 {
                CENTRAL_SYSTEM?.writeRegister(register: DRAIN_TIMEOUT, value: value)
                readOnce = false
            } else {
               showAlert()
            }
        } else {
            errorTextAlert()
        }
    }
    
    private func showAlert(){
        let alertController = UIAlertController(title: "Error", message: "Fog value is out of range. Please choose between 0 - 30 seconds.", preferredStyle: .alert)
     
        let OK = UIAlertAction(title: "OK", style: .destructive) { (alert) in
            print("OK Pressed")
        }
        
        
        alertController.addAction(OK)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func errorTextAlert(){
        let alertController = UIAlertController(title: "Error", message: "Invalid characters", preferredStyle: .alert)
        
        let OK = UIAlertAction(title: "OK", style: .destructive) { (alert) in
            print("OK Pressed")
        }
        
        
        alertController.addAction(OK)
        self.present(alertController, animated: true, completion: nil)
    }
}
