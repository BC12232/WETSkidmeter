//
//  FogViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//


import UIKit


class FogViewController: UIViewController{
    
    private let logger =  Logger()
    
    @IBOutlet weak var autoModeImage:   UIImageView!
    @IBOutlet weak var handModeImage:   UIImageView!

    
    //No Connection View
    
    @IBOutlet weak var noConnectionView:     UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var motorOverload:        UILabel!
    @IBOutlet weak var pumpFault:            UILabel!
    @IBOutlet weak var fogOnOffLbl:          UILabel!
    @IBOutlet weak var lowPressure:          UILabel!
    @IBOutlet weak var blockView:            UIView!
    @IBOutlet weak var handSwitchNotOnAutoLabel: UILabel!
    
    @IBOutlet weak var autoHandToggleBtn:    UIButton!
    @IBOutlet weak var playStopBtn:          UIButton!
    
    @IBOutlet weak var playStopBtn122: UIButton!
    @IBOutlet weak var fogOnOfflbl122: UILabel!
    @IBOutlet weak var pumpFault122: UILabel!
    @IBOutlet weak var motorOverload122: UILabel!
    @IBOutlet weak var lowPressure122: UILabel!
    @IBOutlet weak var blockView122: UIView!
    @IBOutlet weak var handSwitchNotOnAuto122Label: UILabel!
    
    @IBOutlet weak var playStopBtn421: UIButton!
    @IBOutlet weak var fogOnOfflbl421: UILabel!
    @IBOutlet weak var pumpFault421: UILabel!
    @IBOutlet weak var motorOverload421: UILabel!
    @IBOutlet weak var lowPressure421: UILabel!
    @IBOutlet weak var blockView421: UIView!
    @IBOutlet weak var handSwitchNotOnAuto421Label: UILabel!
    
    @IBOutlet weak var playStopBtn422: UIButton!
    @IBOutlet weak var fogOnOfflbl422: UILabel!
    @IBOutlet weak var pumpFault422: UILabel!
    @IBOutlet weak var motorOverload422: UILabel!
    @IBOutlet weak var lowPressure422: UILabel!
    @IBOutlet weak var blockView422: UIView!
    @IBOutlet weak var handSwitchNotOnAuto422Label: UILabel!
    
    @IBOutlet weak var p413pumpFault: UILabel!
    @IBOutlet weak var p413motorOverload: UILabel!
    @IBOutlet weak var p413lowPressure: UILabel!
    @IBOutlet weak var p213pumpFault: UILabel!
    @IBOutlet weak var p213motorOverload: UILabel!
    @IBOutlet weak var p213lowPressure: UILabel!
    
    var fogMotorLiveValues = FOG_MOTOR_LIVE_VALUES()
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
    }

    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        super.viewWillAppear(true)
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        //This line of code is an extension added to the view controller by showStoppers module
        //This is the only line needed to add show stopper
        checkAutoHandMode()
        addShowStoppers()
        
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        
        NotificationCenter.default.removeObserver(self)
        self.logger.logData(data:"View Is Disappearing")
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the network connection for all system components
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,serverConnection) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, get the lights data 
            checkAutoHandMode()
            getFogDataFromPLC()
            
            
        }  else {
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
    

    
    /***************************************************************************
     * Function :  checkAutoHandMode
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func checkAutoHandMode(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_121.count), startingRegister: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_121.startAddr), completion: { (success, response) in
            
       
                guard success == true else { return }
            
                if (response![0] as? NSNumber == 1) && (response![1] as? NSNumber == 0) {
                    //If the physical switch is in auto mode
                    self.blockView.isHidden = true
                    self.handSwitchNotOnAutoLabel.isHidden = true
                    
                    CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FOG_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
                        
                        if response != nil{
                            
                            let autoHandMode = Int(truncating: response![0] as! NSNumber)
                            
                            if autoHandMode == 1{
                                //If is in manual mode on the ipad
                                self.changeAutManModeIndicatorRotation(autoMode: false)
                                self.playStopBtn.alpha = 1
                                self.fogMotorLiveValues.autoMode = 0
                            }else{
                                //If is in auto mode on the ipad
                                self.playStopBtn.alpha = 0
                                self.fogMotorLiveValues.autoMode = 1
                                self.changeAutManModeIndicatorRotation(autoMode: true)
                                
                            }
                            self.readFogPlayStopData()
                        }
                        
                    })
                    
                } else if (response![0] as? NSNumber == 0) && (response![1] as? NSNumber == 1) {
                    //If the physical switch is in manual mode
                    
                    self.blockView.isHidden = false
                    self.handSwitchNotOnAutoLabel.isHidden = false
                    
                } else{
                    
                    self.blockView.isHidden = false
                    self.handSwitchNotOnAutoLabel.isHidden = false
                    
                }
   
        })
        
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_122.count), startingRegister: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_122.startAddr), completion: { (success, response) in
            
            
            guard success == true else { return }
            
            if (response![0] as? NSNumber == 1) && (response![1] as? NSNumber == 0) {
                //If the physical switch is in auto mode
                self.blockView122.isHidden = true
                self.handSwitchNotOnAuto122Label.isHidden = true
                
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FOG_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
                    
                    if response != nil{
                        
                        let autoHandMode = Int(truncating: response![0] as! NSNumber)
                        
                        if autoHandMode == 1{
                            //If is in manual mode on the ipad
                            self.changeAutManModeIndicatorRotation(autoMode: false)
                            self.playStopBtn122.alpha = 1
                            self.fogMotorLiveValues.autoMode = 0
                        }else{
                            //If is in auto mode on the ipad
                            self.playStopBtn122.alpha = 0
                            self.fogMotorLiveValues.autoMode = 1
                            self.changeAutManModeIndicatorRotation(autoMode: true)
                           
                        }
                         self.readFogPlayStopData()
                    }
                    
                })
                
            } else if (response![0] as? NSNumber == 0) && (response![1] as? NSNumber == 1) {
                //If the physical switch is in manual mode
                
                self.blockView122.isHidden = false
                self.handSwitchNotOnAuto122Label.isHidden = false
                
            } else{
                
                self.blockView122.isHidden = false
                self.handSwitchNotOnAuto122Label.isHidden = false
                
            }
            
        })
        
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_421.count), startingRegister: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_421.startAddr), completion: { (success, response) in
            
            
            guard success == true else { return }
            
            if (response![0] as? NSNumber == 1) && (response![1] as? NSNumber == 0) {
                //If the physical switch is in auto mode
                self.blockView421.isHidden = true
                self.handSwitchNotOnAuto421Label.isHidden = true
                
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FOG_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
                    
                    if response != nil{
                        
                        let autoHandMode = Int(truncating: response![0] as! NSNumber)
                        
                        if autoHandMode == 1{
                            //If is in manual mode on the ipad
                            self.changeAutManModeIndicatorRotation(autoMode: false)
                            self.playStopBtn421.alpha = 1
                            self.fogMotorLiveValues.autoMode = 0
                        }else{
                            //If is in auto mode on the ipad
                            self.playStopBtn421.alpha = 0
                            self.fogMotorLiveValues.autoMode = 1
                            self.changeAutManModeIndicatorRotation(autoMode: true)
                            
                        }
                        self.readFogPlayStopData()
                    }
                    
                })
                
            } else if (response![0] as? NSNumber == 0) && (response![1] as? NSNumber == 1) {
                //If the physical switch is in manual mode
                
                self.blockView421.isHidden = false
                self.handSwitchNotOnAuto421Label.isHidden = false
                
            } else{
                
                self.blockView421.isHidden = false
                self.handSwitchNotOnAuto421Label.isHidden = false
                
            }
            
        })
        
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_422.count), startingRegister: Int32(FOG_AUTO_HAND_SWITCH_ADDRS_422.startAddr), completion: { (success, response) in
            
            
            guard success == true else { return }
            
            if (response![0] as? NSNumber == 1) && (response![1] as? NSNumber == 0) {
                //If the physical switch is in auto mode
                self.blockView422.isHidden = true
                self.handSwitchNotOnAuto422Label.isHidden = true
                
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FOG_AUTO_HAND_BIT_ADDR), completion: { (success, response) in
                    
                    if response != nil{
                        
                        let autoHandMode = Int(truncating: response![0] as! NSNumber)
                        
                        if autoHandMode == 1{
                            //If is in manual mode on the ipad
                            self.changeAutManModeIndicatorRotation(autoMode: false)
                            self.playStopBtn422.alpha = 1
                            self.fogMotorLiveValues.autoMode = 0
                        }else{
                            //If is in auto mode on the ipad
                            self.playStopBtn422.alpha = 0
                            self.fogMotorLiveValues.autoMode = 1
                            self.changeAutManModeIndicatorRotation(autoMode: true)
                           
                        }
                         self.readFogPlayStopData()
                    }
                    
                })
                
            } else if (response![0] as? NSNumber == 0) && (response![1] as? NSNumber == 1) {
                //If the physical switch is in manual mode
                
                self.blockView422.isHidden = false
                self.handSwitchNotOnAuto422Label.isHidden = false
                
            } else{
                
                self.blockView422.isHidden = false
                self.handSwitchNotOnAuto422Label.isHidden = false
                
            }
            
        })
    }
    
    
    /***************************************************************************
     * Function :  readFogPlayStopData
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func readFogPlayStopData(){
        if self.fogMotorLiveValues.pumpRunning == 1 {
                self.playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
            } else {
                self.playStopBtn.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            }
        
       if self.fogMotorLiveValues.pumpRunning122 == 1 {
                self.playStopBtn122.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
            } else {
                self.playStopBtn122.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            }
        
        if self.fogMotorLiveValues.pumpRunning421 == 1 {
                self.playStopBtn421.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
            } else {
                self.playStopBtn421.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            }
        
       if self.fogMotorLiveValues.pumpRunning422 == 1 {
                self.playStopBtn422.setBackgroundImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
            } else {
                self.playStopBtn422.setBackgroundImage(#imageLiteral(resourceName: "playButton"), for: .normal)
            }
        
        
    }
    
    
    /***************************************************************************
     * Function :  getFogDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func getFogDataFromPLC(){
        
        CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: Int32(FOG_FAULTS_213), completion: { (sucess, response) in
            
            if response != nil{
                
                let pumpFault = Int(truncating: response![0] as! NSNumber)
                let motorOverload = Int(truncating: response![1] as! NSNumber)
                let lowPressure = Int(truncating: response![2] as! NSNumber)
                
                if pumpFault == 1{
                    self.p213pumpFault.isHidden = false
                } else {
                     self.p213pumpFault.isHidden = true
                }
                if motorOverload == 1{
                     self.p213motorOverload.isHidden = false
                } else {
                     self.p213motorOverload.isHidden = true
                }
                if lowPressure == 1{
                     self.p213lowPressure.isHidden = false
                } else {
                     self.p213lowPressure.isHidden = true
                }
            }
            
        })
        
        CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: Int32(FOG_FAULTS_413), completion: { (sucess, response) in
            
            if response != nil{
                
                let pumpFault = Int(truncating: response![0] as! NSNumber)
                let motorOverload = Int(truncating: response![1] as! NSNumber)
                let lowPressure = Int(truncating: response![2] as! NSNumber)
                
                if pumpFault == 1{
                    self.p413pumpFault.isHidden = false
                } else {
                    self.p413pumpFault.isHidden = true
                }
                if motorOverload == 1{
                    self.p413motorOverload.isHidden = false
                } else {
                    self.p413motorOverload.isHidden = true
                }
                if lowPressure == 1{
                    self.p413lowPressure.isHidden = false
                } else {
                    self.p413lowPressure.isHidden = true
                }
            }
            
        })
        
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_FAULTS_121.count), startingRegister: Int32(FOG_FAULTS_121.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotorLiveValues.pumpRunning   = Int(truncating: response![0] as! NSNumber)
                self.fogMotorLiveValues.pumpFault     = Int(truncating: response![1] as! NSNumber)
                self.fogMotorLiveValues.pumpOverLoad  = Int(truncating: response![2] as! NSNumber)
                self.fogMotorLiveValues.pressureFault = Int(truncating: response![3] as! NSNumber)
                
            }
            
        })
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_FAULTS_122.count), startingRegister: Int32(FOG_FAULTS_122.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotorLiveValues.pumpRunning122   = Int(truncating: response![0] as! NSNumber)
                self.fogMotorLiveValues.pumpFault122     = Int(truncating: response![1] as! NSNumber)
                self.fogMotorLiveValues.pumpOverLoad122  = Int(truncating: response![2] as! NSNumber)
                self.fogMotorLiveValues.pressureFault122 = Int(truncating: response![3] as! NSNumber)
                
            }
            
        })
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_FAULTS_421.count), startingRegister: Int32(FOG_FAULTS_421.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotorLiveValues.pumpRunning421   = Int(truncating: response![0] as! NSNumber)
                self.fogMotorLiveValues.pumpFault421     = Int(truncating: response![1] as! NSNumber)
                self.fogMotorLiveValues.pumpOverLoad421  = Int(truncating: response![2] as! NSNumber)
                self.fogMotorLiveValues.pressureFault421 = Int(truncating: response![3] as! NSNumber)
                
            }
            
        })
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_FAULTS_422.count), startingRegister: Int32(FOG_FAULTS_422.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotorLiveValues.pumpRunning422   = Int(truncating: response![0] as! NSNumber)
                self.fogMotorLiveValues.pumpFault422     = Int(truncating: response![1] as! NSNumber)
                self.fogMotorLiveValues.pumpOverLoad422  = Int(truncating: response![2] as! NSNumber)
                self.fogMotorLiveValues.pressureFault422 = Int(truncating: response![3] as! NSNumber)
                
            }
            
        })
        
     
        
         self.parseFogPumpData()
        
    }
    
    /***************************************************************************
     * Function :  parseFogPumpData
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func parseFogPumpData(){
        
        if fogMotorLiveValues.pumpOverLoad == 1{
            motorOverload.alpha = 1
        } else {
            motorOverload.alpha = 0
        }
    
        
        if fogMotorLiveValues.pressureFault == 1{
            lowPressure.alpha = 1
        } else {
            lowPressure.alpha = 0
        }
        
        
        if fogMotorLiveValues.pumpFault == 1 {
            
           pumpFault.alpha = 1
           autoHandToggleBtn.setBackgroundImage(#imageLiteral(resourceName: "fog"), for: .normal)
            
        } else {
           
                pumpFault.alpha = 0
        }
        
        if fogMotorLiveValues.pumpRunning == 1{
            
            fogOnOffLbl.text = "FOG CURRENTLY ON"
            fogOnOffLbl.textColor = GREEN_COLOR
            
            
        } else if fogMotorLiveValues.pumpRunning == 0{
            
            fogOnOffLbl.text = "FOG CURRENTLY OFF"
            fogOnOffLbl.textColor = DEFAULT_GRAY
            
            
            
        }
        
        if fogMotorLiveValues.pumpOverLoad122 == 1{
            motorOverload122.alpha = 1
        } else {
            motorOverload122.alpha = 0
        }
        
        
        if fogMotorLiveValues.pressureFault122 == 1{
            lowPressure122.alpha = 1
        } else {
            lowPressure122.alpha = 0
        }
        
        
        if fogMotorLiveValues.pumpFault122 == 1 {
            
            pumpFault122.alpha = 1
            autoHandToggleBtn.setBackgroundImage(#imageLiteral(resourceName: "fog"), for: .normal)
            
        } else {
            
            pumpFault122.alpha = 0
            
        }
        
        
        if fogMotorLiveValues.pumpRunning122 == 1{
            
            fogOnOfflbl122.text = "FOG CURRENTLY ON"
            fogOnOfflbl122.textColor = GREEN_COLOR
            
            
        } else if fogMotorLiveValues.pumpRunning122 == 0{
            
            fogOnOfflbl122.text = "FOG CURRENTLY OFF"
            fogOnOfflbl122.textColor = DEFAULT_GRAY
            
            
            
        }
        if fogMotorLiveValues.pumpOverLoad421 == 1{
            motorOverload421.alpha = 1
        } else {
            motorOverload421.alpha = 0
        }
        
        
        if fogMotorLiveValues.pressureFault421 == 1{
            lowPressure421.alpha = 1
        } else {
            lowPressure421.alpha = 0
        }
        
        
        if fogMotorLiveValues.pumpFault421 == 1 {
            
            pumpFault421.alpha = 1
            autoHandToggleBtn.setBackgroundImage(#imageLiteral(resourceName: "fog"), for: .normal)
            
        } else {
            
            pumpFault421.alpha = 0
            
        }
        
        if fogMotorLiveValues.pumpRunning421 == 1{
            
            fogOnOfflbl421.text = "FOG CURRENTLY ON"
            fogOnOfflbl421.textColor = GREEN_COLOR
            
            
        } else if fogMotorLiveValues.pumpRunning421 == 0{
            
            fogOnOfflbl421.text = "FOG CURRENTLY OFF"
            fogOnOfflbl421.textColor = DEFAULT_GRAY
            
            
            
        }
        if fogMotorLiveValues.pumpOverLoad422 == 1{
            motorOverload422.alpha = 1
        } else {
            motorOverload422.alpha = 0
        }
        
        
        if fogMotorLiveValues.pressureFault422 == 1{
            lowPressure422.alpha = 1
        } else {
            lowPressure422.alpha = 0
        }
        
        
        if fogMotorLiveValues.pumpFault422 == 1 {
            
            pumpFault422.alpha = 1
            autoHandToggleBtn.setBackgroundImage(#imageLiteral(resourceName: "fog"), for: .normal)
            
        } else {
            
            pumpFault422.alpha = 0
            
        
        }
        
        if fogMotorLiveValues.pumpRunning422 == 1{
            
            fogOnOfflbl422.text = "FOG CURRENTLY ON"
            fogOnOfflbl422.textColor = GREEN_COLOR
            
            
        } else if fogMotorLiveValues.pumpRunning422 == 0{
            
            fogOnOfflbl422.text = "FOG CURRENTLY OFF"
            fogOnOfflbl422.textColor = DEFAULT_GRAY
            
            
            
        }
    }
    
    /***************************************************************************
     * Function :  changeAutManModeIndicatorRotation
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func changeAutManModeIndicatorRotation(autoMode:Bool){
        
        /*
         NOTE: 2 Possible Options
         Option 1: Automode (animate) = True => Will result in any view object to rotate 360 degrees infinitly
         Option 2: Automode (animate) = False => Will result in any view object to stand still
         */
        
        self.autoModeImage.rotate360Degrees(animate: autoMode)
        
        if autoMode == true{
            
            self.autoModeImage.alpha = 1
            self.handModeImage.alpha = 0
            
        }else{
            
            self.handModeImage.alpha = 1
            self.autoModeImage.alpha = 0
            
        }
        
    }
    
    /***************************************************************************
     * Function :  toggleAutoHandMode
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func toggleAutoHandMode(_ sender: Any){
        
        //NOTE: The auto/hand mode value on PLC is opposite to autoModeValue
        //On PLC Auto Mode: 0 , Hand Mode: 1
        
       
        if self.fogMotorLiveValues.autoMode == 1{
            //In manual mode, change to auto mode
            CENTRAL_SYSTEM?.writeBit(bit: FOG_AUTO_HAND_BIT_ADDR, value: 1)
            
        }else{
            //In auto mode, change it to manual mode
            CENTRAL_SYSTEM?.writeBit(bit: FOG_AUTO_HAND_BIT_ADDR, value: 0)
            
        }
        
    }
    

    
    
    /***************************************************************************
     * Function :  playStopFog
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func playStopFog(_ sender: UIButton){
        
        let fogBtn = sender.tag
        switch fogBtn {
        case 1: if self.fogMotorLiveValues.pumpRunning == 1{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_121, value: 0)
            
                }else{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_121, value: 1)
            
                }
        case 2: if self.fogMotorLiveValues.pumpRunning122 == 1{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_122, value: 0)
            
                }else{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_122, value: 1)
            
                }
        case 3: if self.fogMotorLiveValues.pumpRunning421 == 1{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_421, value: 0)
            
                }else{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_421, value: 1)
            
                }
        case 4: if self.fogMotorLiveValues.pumpRunning422 == 1{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_422, value: 0)
            
                }else{
            
                    CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_422, value: 1)
            
                }
        default: print("No Tag")
        
        }
    }
    
    @IBAction func showSettingsButton(_ sender: UIButton) {
         self.addAlertAction(button: sender)
    }
}
