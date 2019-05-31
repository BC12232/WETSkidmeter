//
//  FiltrationSchedulerViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 10/9/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class FiltrationSchedulerViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var schedulerSwitch: UISwitch!
    
    
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var numberOfFiltrationOn = 0
    private var inHandMode = false
    private var autoHandStats = 0
    private var filtrationPumpStatus = 0
    private var filtrationPump200Status = 0
    
    override func viewWillAppear(_ animated: Bool) {
        readSchedulerEnable()
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    override func viewDidLoad() {
        navigationItem.title = "FILTRATION SCHEDULER"
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        numberOfFiltrationOn = 0
    }
    
    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection, serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            readSchedulerEnable()
           // readFiltrationData()
           // readFiltationAutoHandMode()
            
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
    
//    @objc private func readFiltrationData(){
//            CENTRAL_SYSTEM?.readBits(length: Int32(FILTRATION_STATUS.count), startingRegister: Int32(FILTRATION_STATUS.register), completion: { (success, response) in
//                guard success == true else { return }
//
//                let status = Int(truncating: response![0] as! NSNumber)
//                let status200 = Int(truncating: response![14] as! NSNumber)
//                self.filtrationPumpStatus = status
//                self.filtrationPump200Status = status200
//                if status == 1 || status200 == 1 {
//                    self.numberOfFiltrationOn += 1
//                }
//
//                if self.inHandMode && (self.filtrationPumpStatus != 1 || self.filtrationPump200Status != 1){
//                    self.filtrationIconButton.setBackgroundImage(#imageLiteral(resourceName: "pumps"), for: .normal)
//                    self.readIndividualFiltrationOnOff()
//                } else if self.inHandMode && (self.filtrationPumpStatus == 1 || self.filtrationPump200Status == 1){
//                    self.filtrationIconButton.setBackgroundImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
//                    self.readIndividualFiltrationOnOff()
//                } else if (self.filtrationPumpStatus == 1 || self.filtrationPump200Status == 1) {
//                    self.filtrationIconButton.setBackgroundImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
//                } else {
//                    self.filtrationIconButton.setBackgroundImage(#imageLiteral(resourceName: "pumps"), for: .normal)
//                }
//
//            })
//    }
//
    
    
//    @IBAction func filtrationIconButtonPressed(_ sender: UIButton) {
//        //In Auto Mode
//        if autoHandStats == 0 {
//            //Switch to Manual Mode
//            CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_AUTO_HAND_PLC_REGISTER.register, value: 1)
//            filtrationIconButton.setBackgroundImage(#imageLiteral(resourceName: "pumps"), for: .normal)
//        } else if autoHandStats == 1 {
//            //In Manual Mode
//            //Switch to Auto Mode
//            CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_AUTO_HAND_PLC_REGISTER.register, value: 0)
//        }
//        
//    }

    
//    private func filtrationInAutoMode() {
//        autoModeIcon.isHidden = false
//        autoModeIcon.rotate360Degrees(animate: true)
//        handModeIcon.isHidden = true
//        inHandMode = false
//    }
//
//    private func filtrationInManualMode() {
//        autoModeIcon.isHidden = true
//        handModeIcon.isHidden = false
//        inHandMode = true
//    }
//
    
//    private func readFiltationAutoHandMode() {
//        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
//
//            guard success == true else { return }
//
//            let autoHandStatus = Int(truncating: response![0] as! NSNumber)
//
//            self.autoHandStats = autoHandStatus
//
//            if autoHandStatus == 1 {
//                self.filtrationInManualMode()
//            } else if autoHandStatus == 0 {
//                self.filtrationInAutoMode()
//            }
//        })
//    }
//

    func readSchedulerEnable(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 2110, completion: { (success, response) in
            
            guard success == true else { return }
            
            let switchOnOff = Int(truncating: response![0] as! NSNumber)
            
            if switchOnOff == 1{
                self.schedulerSwitch.isOn = true
            } else {
                 self.schedulerSwitch.isOn = false
            }
        })
    }
    @objc private func readIndividualFiltrationOnOff(){
        if inHandMode {
            
            let filtrationButton = view.viewWithTag(1) as? UIButton
            
            if filtrationPumpStatus == 1 {
                
                filtrationButton?.setBackgroundImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                
            } else if filtrationPumpStatus == 0 {
                
                filtrationButton?.setBackgroundImage(#imageLiteral(resourceName: "pumps"), for: .normal)
                
            }
            
            let filtrationButton200 = view.viewWithTag(2) as? UIButton
            
            if filtrationPump200Status == 1 {
                
                filtrationButton?.setBackgroundImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)
                
            } else if filtrationPump200Status == 0 {
                
                filtrationButton?.setBackgroundImage(#imageLiteral(resourceName: "pumps"), for: .normal)
                
            }
            
        }
        
        
    }
    
    

    
    //MARK: - Turn On/Off Lights Manually
    
    
    @IBAction func turnFiltrationOnOff(_ sender: UIButton) {
        //NOTE: Each button tag subtracted by one, will point to the corresponding PLC register in the array for that light
        
        let filtrationRegister = FILTRATION_ON_OFF_WRITE_REGISTERS[sender.tag - 1]
        
        if sender.tag == 1 {
            if filtrationPumpStatus == 0 {
                CENTRAL_SYSTEM?.writeBit(bit: filtrationRegister, value: 1)
                
                
            } else if filtrationPumpStatus == 1 {
                
                CENTRAL_SYSTEM?.writeBit(bit: filtrationRegister, value: 0)
                
            }
        }
        
        if sender.tag == 2 {
            if filtrationPump200Status == 0 {
                CENTRAL_SYSTEM?.writeBit(bit: filtrationRegister, value: 1)
                
                
            } else if filtrationPumpStatus == 1 {
                
                CENTRAL_SYSTEM?.writeBit(bit: filtrationRegister, value: 0)
                
            }
        }
        
        numberOfFiltrationOn = 0
        
    }

    @IBAction func enableSchedulerOnOff(_ sender: Any) {
        if schedulerSwitch.isOn{
             CENTRAL_SYSTEM?.writeBit(bit: 2110, value: 1)
        } else {
             CENTRAL_SYSTEM?.writeBit(bit: 2110, value: 0)
        }
    }
    
}
