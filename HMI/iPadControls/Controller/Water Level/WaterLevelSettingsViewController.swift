//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterLevelSettingsViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module sets all timer and sensor presets for
 *                  water level screen
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Level Settrings screen configuration parameters located 
 *     in specs.swift file should be modified to match the PLC registers
 *     provided by the controls engineer
 *
 ***************************************************************************/

import UIKit

class WaterLevelSettingsViewController: UIViewController{
    
    @IBOutlet weak var aboveHSPDelay: UITextField!
    @IBOutlet weak var makeupTimeout: UITextField!
    @IBOutlet weak var belowLLLSPDelay: UITextField!
    @IBOutlet weak var belowLSPDelay: UITextField!
    @IBOutlet weak var belowLLSPDelay: UITextField!
    
    @IBOutlet weak var bottomView: UIView!
    
    
    
    //No Connection View
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl:  UILabel!
    
    //Object References
    let logger = Logger()
    
    var currentSetpoints = WATER_LEVEL_SENSOR_VALUES()
    var LT1001SetPoints = [Double]()
    var LT1002SetPoints = [Double]()
    var LT1003SetPoints = [Double]()
    var readLT1001once = false
    var readLT1002once = false
    var readLT1003once = false
    var readCurrentSPOnce = false
    
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
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool) {
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        readTimersFromPLC()
        saveTimerSetpointDelaysToPLC()
        
      
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
      
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    /***************************************************************************
     * Function :  constructSaveButton
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    

    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        
        let (plcConnection,serverConnection) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            saveTimerSetpointDelaysToPLC()
        }
        
        if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED{
            
            connectionFailed(plcConnection: plcConnection, serverConnection: serverConnection)
        }
        
        if plcConnection == CONNECTION_STATE_CONNECTING{
            
            
            //Change the connection stat indicator
            noConnectionView.alpha = 1
            noConnectionView.isUserInteractionEnabled = true
            noConnectionLbl.text = "CONNECTING TO PLC..."
            logger.logData(data: "WATER LEVEL SETTINGS: CONNECTING")
            
        }
        
    }

    
    /***************************************************************************
     * Function :  readTimersFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :  Reads the timer values and passes to the settings page
     ***************************************************************************/
    
    
    private func readTimersFromPLC(){
        
        if !readCurrentSPOnce {
            
            CENTRAL_SYSTEM!.readRegister(length: Int32(WATER_LEVEL_TIMER_BITS.count), startingRegister: Int32(WATER_LEVEL_TIMER_BITS.startBit),  completion: { (success, response) in
                
                guard success == true else { return }
                
                self.currentSetpoints.above_high_timer =  Int(truncating: response![0] as! NSNumber)
                self.currentSetpoints.below_l_timer    =  Int(truncating: response![1] as! NSNumber)
                self.currentSetpoints.below_ll_timer   =  Int(truncating: response![2] as! NSNumber)
                self.currentSetpoints.below_lll_timer  =  Int(truncating: response![3] as! NSNumber)
                
                self.aboveHSPDelay.text       = "\(self.currentSetpoints.above_high_timer)"
                self.belowLSPDelay.text      = "\(self.currentSetpoints.below_l_timer)"
                self.belowLLLSPDelay.text    = "\(self.currentSetpoints.below_lll_timer)"
                self.belowLLSPDelay.text     = "\(self.currentSetpoints.below_ll_timer)"
            })
            
            CENTRAL_SYSTEM!.readRegister(length:1, startingRegister: Int32(WATER_MAKEUP_TIMEROUT_TIMER), completion: { (success, response) in
                
                guard success == true else { return }
                
                self.currentSetpoints.makeup_timeout_timer = Int(truncating: response![0] as! NSNumber)
                self.makeupTimeout.text      = "\(self.currentSetpoints.makeup_timeout_timer)"
                
                
            })
            
            
        }
        
        
    }
 
    /***************************************************************************
     * Function :  saveSetpointDelaysToPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func saveTimerSetpointDelaysToPLC(){
        if let aboveHiSPDelay = aboveHSPDelay.text, !aboveHiSPDelay.isEmpty,
            let aboveHI = Int(aboveHiSPDelay) {
            if aboveHI >= 0 && aboveHI <= 5 {
                CENTRAL_SYSTEM?.writeRegister(register: WATER_LEVEL_ABOVE_H_DELAY_TIMER, value: aboveHI)
            }
        }
        
        if let belowLSPDelay = belowLSPDelay.text, !belowLSPDelay.isEmpty,
            let belowL = Int(belowLSPDelay) {
            if belowL >= 0 && belowL <= 30 {
                CENTRAL_SYSTEM?.writeRegister(register: WATER_LEVEL_BELOW_L_TIMER, value: belowL)
            }
        }
        
        if let belowLLSPDelay  = belowLLSPDelay.text, !belowLLSPDelay.isEmpty,
            let belowLL = Int(belowLLSPDelay) {
            if belowLL >= 0 && belowLL <= 30 {
                CENTRAL_SYSTEM?.writeRegister(register: WATER_LEVEL_BELOW_LL_TIMER, value: belowLL)
            }
        }
        
        if let belowLLLSPDelay = belowLLLSPDelay.text, !belowLLLSPDelay.isEmpty,
            let belowLLL = Int(belowLLLSPDelay) {
            if belowLLL >= 0 && belowLLL <= 30 {
                CENTRAL_SYSTEM?.writeRegister(register: WATER_LEVEL_BELOW_LLL_TIMER, value: belowLLL)
            }
        }
        
        if let makeupTimeout = makeupTimeout.text, !makeupTimeout.isEmpty,
            let makeup = Int(makeupTimeout) {
            if makeup >= 0 && makeup <= 24 {
                CENTRAL_SYSTEM?.writeRegister(register: WATER_MAKEUP_TIMEROUT_TIMER, value: makeup)
            }
        }
        
        
    }
    
    
    /***************************************************************************
     * Function :  connectionFailed
     * Input    :  plcConnection state, serverConnection state
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func connectionFailed(plcConnection:Int,serverConnection:Int){
        
        let totalState = plcConnection + serverConnection
        noConnectionView.alpha = 1
        noConnectionView.isUserInteractionEnabled = true
        
        if totalState == 2{
            
            //Change the connection stat indicator
            noConnectionLbl.text = "PLC AND SERVER CONNECTION FAILED"
            logger.logData(data: "WATER LEVEL SETTINGS: PLC AND SERVER CONNECTION FAILED")
            
        }else if totalState == 1{
            
            if plcConnection == CONNECTION_STATE_FAILED{
               noConnectionLbl.text = "PLC CONNECTION FAILED"
               logger.logData(data: "WATER LEVEL SETTINGS: PLC CONNECTION FAILED")
            }else{
               noConnectionLbl.text = "SERVER CONNECTION FAILED"
               logger.logData(data: "WATER LEVEL SETTINGS: SERVER CONNECTION FAILED")
            }
        }
        
    }
    
    @IBAction func updateSetpointsBtnPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "waterLevel", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "WaterLevelSettingsPopUp") as! WaterLevelSettingsPopUpViewController
        popoverContent.waterTankNum = sender.tag
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popover?.sourceRect = CGRect(x: -200, y: -130, width: 580, height: 190)
        if popoverContent.waterTankNum == 5 {
            popover?.sourceRect = CGRect(x: -180, y: -130, width: 580, height: 190)
        }
        if popoverContent.waterTankNum == 6 {
            popover?.sourceRect = CGRect(x: -300, y: -130, width: 580, height: 190)
        }
        popoverContent.preferredContentSize = CGSize(width: 580, height: 190)
        popover?.sourceView = sender
        self.present(nav, animated: true, completion: nil)
    }
    
  
    
   
    
}
