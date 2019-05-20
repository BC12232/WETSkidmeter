//
//  PumpsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 8/14/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class CascadePumpsViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
 
    
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var numberOfWaterSkinON = 0
    private var pumpStats = [Any]()
    private var waterSkinStats = [Int]()
    private var inHandMode = false
    private var autoHandStats = 0


    
    override func viewWillAppear(_ animated: Bool) {
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            getPumpFaults()
        }
        addShowStoppers()
        navigationItem.title = "WATER SKIN PUMPS"
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       numberOfWaterSkinON = 0
       waterSkinStats = []
      
        NotificationCenter.default.removeObserver(self)

    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,serverConnection) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, get the lights data
           getPumpFaults()
          
         //   readWaterSkinFaults()
            
        } else {
            noConnectionView.alpha = 1
            
            if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "SERVER CONNECTION FAILED, PLC GOOD"
                } else {
                    noConnectionErrorLbl.text = "SERVER AND PLC CONNECTION FAILED"
                }
            }
            
            if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER, PLC CONNECTED"
                } else {
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER AND PLC.."
                }
            }
            
            if plcConnection == CONNECTION_STATE_POOR_CONNECTION && serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER AND PLC POOR CONNECTION"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            } else if serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER POOR CONNECTION, PLC CONNECTED"
            }
        }
    }
    

    
    
    
    
    
    private func readWaterSkinFaults() {
        let offset = 14
        
        for i in 0..<3 {
            
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(WATER_SKIN_PUMP_FAULTS_START_REGISTER + (offset * i)), completion: { (success, response) in
                
                guard success == true else { return }
                
                let pumpFaultState = Int(truncating: response![0] as! NSNumber)
                let pumFaultLabel = self.view.viewWithTag(i + 318) as! UILabel
                
                if pumpFaultState == 1 {
                    pumFaultLabel.textColor = RED_COLOR
                } else {
                    pumFaultLabel.textColor = DEFAULT_GRAY
                }
                
            })
        }
    }
    
    
    
    private func readIndividualWaterSkinONOFF() {
        if inHandMode {
            for (index,value) in waterSkinStats.enumerated() {
                let waterSkinButton = view.viewWithTag(index + 218) as? UIButton
                let pumpIconButton = view.viewWithTag(index + 118) as? UIButton
                
                if value == 1 && waterSkinButton?.imageView?.image != #imageLiteral(resourceName: "stopButton"){
                    pumpIconButton?.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                    waterSkinButton?.setImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
                    
                } else if value == 0 && waterSkinButton?.imageView?.image != #imageLiteral(resourceName: "playButton") {
                    pumpIconButton?.setImage(#imageLiteral(resourceName: "pumps"), for: .normal)
                    waterSkinButton?.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
                    
                }
                
            }
        }
    }
    
    
    @IBAction func pumpsButtonPressed(_ sender: UIButton) {
        let pumpDetailVC = UIStoryboard.init(name: "cascade", bundle: nil).instantiateViewController(withIdentifier: "cascadePumpDetail") as! CascadePumpDetailViewController
        pumpDetailVC.pumpNumber = sender.tag
        navigationController?.pushViewController(pumpDetailVC, animated: true)
    }
    
    func getPumpFaults(){
        let offset = 14
        
        for i in 0..<12 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CASCADE_PUMP_FAULT_REGISTER + (i * offset)), completion:{ (success, response) in
                
                print("This is the register \(Int32(PUMP_FAULT_REGISTER + (i * offset)))")
                guard response != nil else { return }
                
                
                let pumpButton = self.view.viewWithTag(201 + i) as? UIButton
                print("This is the pump button \(201 + i )")
                
                let faultStat = Int(truncating: response![0] as! NSNumber)
                
                
                faultStat == 1 ? (pumpButton?.setTitleColor(RED_COLOR, for: .normal)) : (pumpButton?.setTitleColor(DEFAULT_GRAY, for: .normal))
                
                
            })
        }
    }
    
  
    
    @IBAction func showHiddentSettingsButton(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
}
