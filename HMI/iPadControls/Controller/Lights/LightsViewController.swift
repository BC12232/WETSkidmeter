//
//  LightsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class LightsViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var lightIconButton: UIButton!
    @IBOutlet weak var handModeIcon: UIImageView!
    @IBOutlet weak var autoModeIcon: UIImageView!
    @IBOutlet weak var lowWaterNoLightsIcon: UIImageView!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var dayModeButton: UIButton!
    
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var numberOfLightsOn = 0
    private var inHandMode = false
    private var lightStats = [Int]()
    private var autoHandStats = 0
    private var waterLevelBelowLLFault = [Int]()
    private var dayModeStatus = 0
    
    override func viewWillAppear(_ animated: Bool) {
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        addShowStoppers()
        
        rotateAutoModeImage()
        
    }
    
    override func viewDidLoad() {
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        numberOfLightsOn = 0
        lightStats = []
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
            readLightsAutoHandMode()
            readLightsServerData()
            readWaterLevelBelowLLFault()
            getDayModeFromServer()
            
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
    
    @objc private func readLightsServerData(){
            CENTRAL_SYSTEM?.readBits(length: Int32(LIGHTS_STATUS.count), startingRegister: Int32(LIGHTS_STATUS.register), completion: { (success, response) in
                guard success == true else { return }
           
                self.lightStats.removeAll()
      
                for (index,value) in response!.enumerated()  where index % 2 == 0 {
                    let status = Int(truncating: value as! NSNumber)
                    print("\(LIGHTS_STATUS.register) + \(status)")
                    self.lightStats.append(status)
                    
                    if status == 1 {
                        self.numberOfLightsOn += 1
                    }
                }

                if self.inHandMode && !self.lightStats.contains(1){
                    self.lightIconButton.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                    self.readIndividualLightsOnOff()
                } else if self.inHandMode && self.lightStats.contains(1){
                    self.lightIconButton.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                    self.readIndividualLightsOnOff()
                } else if self.lightStats.contains(1) {
                    self.lightIconButton.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                } else {
                    self.lightIconButton.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                }

            })
    }
    
    

    @IBAction func lightsIconButtonPressed(_ sender: UIButton) {
        //In Auto Mode
        if autoHandStats == 0 {
            //Switch to Manual Mode
            CENTRAL_SYSTEM?.writeBit(bit: LIGHTS_AUTO_HAND_PLC_REGISTER.register, value: 1)
            lightIconButton.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
        } else if autoHandStats == 1 {
            //In Manual Mode
            //Switch to Auto Mode
            CENTRAL_SYSTEM?.writeBit(bit: LIGHTS_AUTO_HAND_PLC_REGISTER.register, value: 0)
        }
        
    }
    

    
    //MARK: - Read Water Level Fault From PLC
    
    private func readWaterLevelBelowLLFault(){
        let offset = 20
 
        for i in 0..<7 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(ALL_WATER_LEVEL_BELOW_LL_REGISTER.register + (i * offset)), completion: { (success, response) in
                
                guard success == true else { return }
                
                let value = Int(truncating: response![0] as! NSNumber)
                self.waterLevelBelowLLFault.append(value)
                
            })
            
        }

        if waterLevelBelowLLFault.count == 3 {
            
            if waterLevelBelowLLFault.contains(1){
                lowWaterNoLightsIcon.isHidden = false
            } else {
               lowWaterNoLightsIcon.isHidden = true
            }
        }
    
         waterLevelBelowLLFault.removeAll()
        
    }
    
    
    private func lightInAutoMode() {
        autoModeIcon.isHidden = false
        autoModeIcon.rotate360Degrees(animate: true)
        handModeIcon.isHidden = true
        inHandMode = false
        schedulerContainerView.isHidden = false
    }
    
    private func lightInManualMode() {
        autoModeIcon.isHidden = true
        autoModeIcon.rotate360Degrees(animate: false)
        handModeIcon.isHidden = false
        inHandMode = true
        schedulerContainerView.isHidden = true
    }
    
    
    private func readLightsAutoHandMode() {
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
            
            guard success == true else { return }
            
            let autoHandStatus = Int(truncating: response![0] as! NSNumber)
            
            self.autoHandStats = autoHandStatus
            
            if autoHandStatus == 1 {
                self.lightInManualMode()
            } else if autoHandStatus == 0 {
                self.lightInAutoMode()
            }
        })
    }
    
    //MARK: - Read Lights On Off
    @objc private func readIndividualLightsOnOff(){
        if inHandMode {
            print("Light stats: \(lightStats)")
            for (index,value) in lightStats.enumerated() {
                let lightButton = view.viewWithTag(index + 1) as? UIButton
                
                
                if value == 1 && lightButton?.imageView?.image != #imageLiteral(resourceName: "lights_on"){
                    
                    lightButton?.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                    
                } else if value == 0 && lightButton?.imageView?.image != #imageLiteral(resourceName: "lights") {
                    
                    lightButton?.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                    
                }
                
            }
            
            
            
            if dayModeStatus == 0{
                dayModeButton.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
            }else if dayModeStatus == 1{
                dayModeButton.setImage(#imageLiteral(resourceName: "lights"), for: .normal)

            }
        }

        
    }
    
    
    /***************************************************************************
     * Function :  getDayModeFromServer
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func getDayModeFromServer(){
        if inHandMode {
            self.httpComm.httpGetResponseFromPath(url: STATUS_LOG_FTP_PATH){ (response) in
                
                guard response != nil else { return }
                
                let responseArray = response as? NSArray
                let responseDictionary = responseArray![0] as? NSDictionary
                
                if responseDictionary != nil{
                    
                    if let dayMode  = responseDictionary?["dayMode"]{
                        print("This is the day mode value: \(dayMode)")
                        self.dayModeStatus = Int(truncating: dayMode as! NSNumber)
                    }
                }
                
                
            }
        }
       
    }
    
    //MARK: - Turn On/Off Lights Manually
    
    
    @IBAction func turnLightOnOff(_ sender: UIButton) {
        //NOTE: Each button tag subtracted by one, will point to the corresponding PLC register in the array for that light

        let lightRegister = LIGHTS_ON_OFF_WRITE_REGISTERS[sender.tag - 1]
        
        let individualLightStatus   = lightStats[sender.tag - 1]
  
        
        if individualLightStatus == 0 {
            CENTRAL_SYSTEM?.writeBit(bit: lightRegister, value: 1)
            
            
        } else if individualLightStatus == 1 {
            
            CENTRAL_SYSTEM?.writeBit(bit: lightRegister, value: 0)
            
        }

        numberOfLightsOn = 0
        
    }
    
    
    @IBAction func turnDayModeLightOnOff(_ sender: Any) {
      
            if dayModeStatus == 0 {
                
                self.httpComm.httpGetResponseFromPath(url:"\(LIGHTS_DAY_MODE_CMD)1", completion: { (response) in
                   print("Turn day mode off")
                })
                
                
            }else if dayModeStatus == 1{

                self.httpComm.httpGetResponseFromPath(url:"\(LIGHTS_DAY_MODE_CMD)0", completion: { (response) in
                    print("Turn day mode on")
                })
                
                
            }
    
    }
    
    private func rotateAutoModeImage() {
        autoModeIcon.rotate360Degrees(animate: true)
    }
    
    
}
