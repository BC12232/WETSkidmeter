//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterLevelViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all water level sensor values and
 *                  displays on the screen
 *  @VERSION:       2.0.0
 */

/***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Level screen configuration parameters located in specs.swift file
 *     should be modified
 * 2 : readWaterLevelLiveValues function should be modified based on required
 *     value readings
 * 3 : Basin images should be replaced according to project drawings.
 *     Note: The image names should remain the same as what is provied in the
 *           project workspace image files
 * 4 : parseWaterLevelFaults() function should be modified based on required
 *     fault readings
 ***************************************************************************/


import UIKit


class WaterLevelViewController: UIViewController{
    
    //MARK: - UI View Outlets
    
    @IBOutlet weak var fillFaucet: UIImageView!
    @IBOutlet weak var waterLevelIcon:                      UIImageView!
    @IBOutlet weak var noConnectionView:                    UIView!
    @IBOutlet weak var noConnectionErrorLbl:                UILabel!
    
    //MARK: - Water Level Sensors Faults
    
    @IBOutlet weak var lt1003Basin: UIImageView!
    @IBOutlet weak var innerBasin: UIImageView!
    @IBOutlet weak var outerBasin: UIImageView!
    @IBOutlet weak var lowWaterNoLights:                    UIImageView!
    @IBOutlet weak var lowWaterNoShow:                      UIImageView!
    @IBOutlet weak var fillTimeout:                         UIImageView!
    @IBOutlet weak var basinView:                           UIImageView!
    
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger          =          Logger()
    private let helper          =          Helper()
    private let utility         =         Utilits()
    private let operationManual = OperationManual()
    
    //MARK: - Data Structures
    
    @IBOutlet weak var quadCleakIcon: UIImageView!
    @IBOutlet weak var quadBleakIcon: UIImageView!
    @IBOutlet weak var quadDleakIcon: UIImageView!
    @IBOutlet weak var quadAleakIcon: UIImageView!
    private var langData          = Dictionary<String, String>()
    private var liveSensorValues1001  = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues1002 = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues1003 = WATER_LEVEL_SENSOR_VALUES()
    
    private var LT1001_values: [Int] = []
    private var LT1002_values: [Int] = []
    private var LT1003_values: [Int] = []
    
    var quadAstatus = 0
    var quadBstatus = 0
    var quadCstatus = 0
    var quadDstatus = 0
    private var acquiredTimersFromPLC = 0
     let CHANNEL_FAULT_TANK_REGISTER     = 3000
     let LT1001_TANK_REGISTER            = 3001
     let LT1002_TANK_REGISTER            = 3021
     let LT1003_TANK_REGISTER            = 3041
     let QUADB_TANK_LEVEL_REGISTER       = 3061
     let QUADC_TANK_LEVEL_REGISTER       = 3081
     let QUADD_TANK_LEVEL_REGISTER       = 3101
     let FOG_QUADD_LEVEL_REGISTER        = 3121
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
     * Function :  viewDidAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(WaterLevelViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        //Configure Water Level Screen
        configureWaterLevel()
        
        //Configure WaterLeveScreen Text Content Based On Device Language
        configureScreenTextContent()
        
        addShowStoppers()
        //This line of code is an extension added to the view controller by showStoppers module
        //This is the only line needed to add show stopper
        
        
        
        
    }
    
    /***************************************************************************
     * Function :  viewDidDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidDisappear(_ animated: Bool){
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, run functions
            readWaterLevelLiveValuesLT1001()
            readWaterLevelLiveValuesLT1002()
            readWaterLevelLiveValuesLT1003()
            parseWaterLevelFaults()
            parseWaterLevelStat()

        } else {
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
    /***************************************************************************
     * Function :  configureWaterLevel
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func configureWaterLevel(){
        
        lowWaterNoLights.isHidden = true
        lowWaterNoShow.isHidden = true
        acquiredTimersFromPLC = 0
        
    }
    
    
    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: WATER_LEVEL_LANGUAGE_DATA_PARAM)
        
        self.navigationItem.title = langData["WATER LEVEL"]!
        self.noConnectionErrorLbl.text = "NO CONNECTION"
        
    }
    
 
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readWaterLevelLiveValuesLT1001(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT1001.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT1001.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1002: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            self.liveSensorValues1001.channelFault      = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues1001.below_ll         = Int(truncating: response![3] as! NSNumber)
            self.liveSensorValues1001.below_lll        = Int(truncating: response![4] as! NSNumber)
            self.liveSensorValues1001.waterMakeup      = Int(truncating: response![6] as! NSNumber)
            self.liveSensorValues1001.waterMakeupTimeout = Int(truncating: response![7] as! NSNumber)
        })
        
    }
    
    
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readWaterLevelLiveValuesLT1002(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT1002.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT1002.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1002: FAILED TO GET RESPONSE FROM PLC")
                return
            }

            self.liveSensorValues1002.channelFault      = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues1002.below_ll         = Int(truncating: response![3] as! NSNumber)
            self.liveSensorValues1002.below_lll        = Int(truncating: response![4] as! NSNumber)
            self.liveSensorValues1002.waterMakeup      = Int(truncating: response![6] as! NSNumber)
            self.liveSensorValues1002.waterMakeupTimeout = Int(truncating: response![7] as! NSNumber)

        })
        
    }
    
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readWaterLevelLiveValuesLT1003(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT1003.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT1003.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1003: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            
            self.liveSensorValues1003.channelFault      = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues1003.below_ll         = Int(truncating: response![3] as! NSNumber)
            self.liveSensorValues1003.below_lll        = Int(truncating: response![4] as! NSNumber)
            self.liveSensorValues1003.waterMakeup      = Int(truncating: response![6] as! NSNumber)
            self.liveSensorValues1003.waterMakeupTimeout = Int(truncating: response![7] as! NSNumber)
            
            
        })
        
    }
    /***************************************************************************
     * Function :  parseWaterLevelStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    
    func parseWaterLevelStat(){
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(LT1001_TANK_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let below_l   = Int(truncating: response![1] as! NSNumber)
            let below_ll  = Int(truncating: response![2] as! NSNumber)
            let below_lll = Int(truncating: response![3] as! NSNumber)
            
            if self.liveSensorValues1001.waterMakeup == 1{
               self.outerBasin.image = #imageLiteral(resourceName: "outerBasinGray")
               self.fillFaucet.isHidden = false
            } else {
                self.fillFaucet.isHidden = true
                if below_l == 1 || below_ll == 1 || below_lll == 1{
                   self.outerBasin.image = #imageLiteral(resourceName: "outerBasinRed")
                } else {
                    self.outerBasin.image = #imageLiteral(resourceName: "outerBasinGreen")
                }
            }
            
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(LT1002_TANK_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let below_l   = Int(truncating: response![1] as! NSNumber)
            let below_ll  = Int(truncating: response![2] as! NSNumber)
            let below_lll = Int(truncating: response![3] as! NSNumber)
            
            if below_l == 0 || below_ll == 1 || below_lll == 1{
                self.innerBasin.image = #imageLiteral(resourceName: "innerBasinRed")
            } else {
                self.innerBasin.image = #imageLiteral(resourceName: "innerBasinGreen")
            }
        })
       
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(LT1003_TANK_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let below_l   = Int(truncating: response![1] as! NSNumber)
            let below_ll  = Int(truncating: response![2] as! NSNumber)
            let below_lll = Int(truncating: response![3] as! NSNumber)
            
            if below_l == 1 || below_ll == 1 || below_lll == 1{
                self.lt1003Basin.backgroundColor = RED_COLOR
            } else {
                self.lt1003Basin.backgroundColor = GREEN_COLOR
            }
            
        })
    }
   
    private func parseWaterLevelFaults(){
        
        if liveSensorValues1001.channelFault == 1 || liveSensorValues1002.channelFault == 1 || liveSensorValues1003.channelFault == 1{
            waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-red")
        } else {
            waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-gray")
        }
        
        if liveSensorValues1001.below_ll == 1 || liveSensorValues1002.below_ll == 1 {
            lowWaterNoLights.isHidden = false
        } else {
            lowWaterNoLights.isHidden = true
        }
        
        if liveSensorValues1001.below_lll == 1 || liveSensorValues1002.below_lll == 1 || liveSensorValues1003.below_lll == 1{
            lowWaterNoShow.isHidden = false
        } else {
            lowWaterNoShow.isHidden = true
        }
        
        if self.liveSensorValues1001.waterMakeupTimeout == 1{
            fillTimeout.isHidden = false
        } else {
            fillTimeout.isHidden = true
        }
    }
    
    
    @IBAction func showHiddenSettings(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
    
}
