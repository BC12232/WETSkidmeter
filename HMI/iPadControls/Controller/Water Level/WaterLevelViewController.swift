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
    
    @IBOutlet weak var waterLevelIcon:                      UIImageView!
    @IBOutlet weak var noConnectionView:                    UIView!
    @IBOutlet weak var noConnectionErrorLbl:                UILabel!
    
    //MARK: - Water Level Sensors Faults
    
    @IBOutlet weak var lowWaterNoLights:                    UIImageView!
    @IBOutlet weak var lowWaterNoShow:                      UIImageView!
    @IBOutlet weak var fillTimeout:                         UIImageView!
    @IBOutlet weak var basinView:                           UIImageView!
    
    @IBOutlet weak var fogBasemakeupFaucet:  UIImageView!
    @IBOutlet weak var fogquadDmakeupFaucet: UIImageView!
    @IBOutlet weak var waterMakeupFaucet:    UIImageView!

    @IBOutlet weak var quadDmainTankGreen: UIImageView!
    @IBOutlet weak var quadAmainTankGreen: UIImageView!
    @IBOutlet weak var basemainTankGreen: UIImageView!
    @IBOutlet weak var quadCmainTankGreen: UIImageView!
    @IBOutlet weak var quadBmainTankGreen: UIImageView!
    @IBOutlet weak var fogTankbasementGreen: UIImageView!
    @IBOutlet weak var fogTankquadDGreen: UIImageView!
    
    @IBOutlet weak var quadDmainTank: UILabel!
    @IBOutlet weak var fogTankquadD: UILabel!
    @IBOutlet weak var quadAmainTank: UILabel!
    @IBOutlet weak var quadCmainTank: UILabel!
    @IBOutlet weak var quadBmainTank: UILabel!
    @IBOutlet weak var basemainTank: UILabel!
    @IBOutlet weak var fogTankbasement: UILabel!
    
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
    private var liveSensorValues110  = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues213 = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues401 = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues402 = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues403 = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues404 = WATER_LEVEL_SENSOR_VALUES()
    private var liveSensorValues405 = WATER_LEVEL_SENSOR_VALUES()
    
    private var LT1001_values: [Int] = []
    private var LT1002_values: [Int] = []
    private var LT1003_values: [Int] = []
    
    var quadAstatus = 0
    var quadBstatus = 0
    var quadCstatus = 0
    var quadDstatus = 0
    private var acquiredTimersFromPLC = 0
     let CHANNEL_FAULT_TANK_REGISTER     = 3000
     let BASE_TANK_LEVEL_REGISTER        = 3001
     let FOG_BASE_LEVEL_REGISTER         = 3021
     let QUADA_TANK_LEVEL_REGISTER       = 3041
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
        quadDmainTankGreen.isHidden = true
        quadCmainTankGreen.isHidden = true
        quadBmainTankGreen.isHidden = true
        quadAmainTankGreen.isHidden = true
        basemainTankGreen.isHidden  = true
        fogTankquadDGreen.isHidden  = true
        fogTankbasementGreen.isHidden = true
        readChannelFault()
        parseMakeup()
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
            readChannelFault()
            readWaterLevelLiveValuesLT110()
            readWaterLevelLiveValuesLT213()
            readWaterLevelLiveValuesLT401()
            readWaterLevelLiveValuesLT402()
            readWaterLevelLiveValuesLT403()
            readWaterLevelLiveValuesLT404()
            readWaterLevelLiveValuesLT405()
            parseWaterLevelFaults()
            parseMakeup()
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
    
    func readChannelFault(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
               self.basemainTank.textColor = RED_COLOR
            } else {
               self.basemainTank.textColor = DEFAULT_GRAY
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER + 20), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
                self.fogTankbasement.textColor = RED_COLOR
            } else {
                self.fogTankbasement.textColor = DEFAULT_GRAY
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER + 40), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
                self.quadAmainTank.textColor = RED_COLOR
            } else {
                self.quadAmainTank.textColor = DEFAULT_GRAY
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER + 60), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
                self.quadBmainTank.textColor = RED_COLOR
            } else {
                self.quadBmainTank.textColor = DEFAULT_GRAY
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER + 80), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
                self.quadCmainTank.textColor = RED_COLOR
            } else {
                self.quadCmainTank.textColor = DEFAULT_GRAY
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER + 100), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
                self.quadDmainTank.textColor = RED_COLOR
            } else {
                self.quadDmainTank.textColor = DEFAULT_GRAY
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(CHANNEL_FAULT_TANK_REGISTER + 120), completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
                self.fogTankquadD.textColor = RED_COLOR
            } else {
                self.fogTankquadD.textColor = DEFAULT_GRAY
            }
        })
        
        self.parseWaterLevelStat()
        
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
    
    private func readWaterLevelLiveValuesLT110(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT110.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT110.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1002: FAILED TO GET RESPONSE FROM PLC")
                return
            }
    
            self.liveSensorValues110.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues110.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues110.malfunction      = Int(truncating: response![2] as! NSNumber)
            self.liveSensorValues110.waterMakeup      = Int(truncating: response![3] as! NSNumber)
            self.liveSensorValues110.waterMakeupTimeout = Int(truncating: response![4] as! NSNumber)
        })
        
    }
    
    
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readWaterLevelLiveValuesLT213(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT213.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT213.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1002: FAILED TO GET RESPONSE FROM PLC")
                return
            }

            self.liveSensorValues213.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues213.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues213.malfunction      = Int(truncating: response![2] as! NSNumber)
            self.liveSensorValues213.waterMakeup      = Int(truncating: response![3] as! NSNumber)
            self.liveSensorValues213.waterMakeupTimeout = Int(truncating: response![4] as! NSNumber)

        })
        
    }
    
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readWaterLevelLiveValuesLT401(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT401.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT401.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1003: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            
            self.liveSensorValues401.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues401.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues401.malfunction      = Int(truncating: response![2] as! NSNumber)
            
            
        })
        
    }
    private func readWaterLevelLiveValuesLT402(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT402.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT402.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1003: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            
            self.liveSensorValues402.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues402.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues402.malfunction      = Int(truncating: response![2] as! NSNumber)
            
        })
        
    }
    private func readWaterLevelLiveValuesLT403(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT403.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT403.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1003: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            
            self.liveSensorValues403.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues403.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues403.malfunction      = Int(truncating: response![2] as! NSNumber)
            
        })
        
    }
    private func readWaterLevelLiveValuesLT404(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT404.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT404.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1003: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            
            self.liveSensorValues404.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues404.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues404.malfunction      = Int(truncating: response![2] as! NSNumber)
            
        })
        
    }
    private func readWaterLevelLiveValuesLT405(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_LT405.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_LT405.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL LT1003: FAILED TO GET RESPONSE FROM PLC")
                return
            }
            
            self.liveSensorValues405.below_ll         = Int(truncating: response![0] as! NSNumber)
            self.liveSensorValues405.below_lll        = Int(truncating: response![1] as! NSNumber)
            self.liveSensorValues405.malfunction      = Int(truncating: response![2] as! NSNumber)
            self.liveSensorValues405.waterMakeup      = Int(truncating: response![3] as! NSNumber)
            self.liveSensorValues405.waterMakeupTimeout = Int(truncating: response![4] as! NSNumber)
        })
        
    }
    /***************************************************************************
     * Function :  parseWaterLevelStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    
    func parseWaterLevelStat(){
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(BASE_TANK_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let below_l   = Int(truncating: response![1] as! NSNumber)
            let below_ll  = Int(truncating: response![2] as! NSNumber)
            let below_lll = Int(truncating: response![3] as! NSNumber)
            
            if self.liveSensorValues110.waterMakeup == 1{
                self.basemainTankGreen.isHidden = false
            } else {
                if below_l == 1 || below_ll == 1 || below_lll == 1{
                    self.basemainTankGreen.isHidden = true
                } else {
                    self.basemainTankGreen.isHidden = false
                }
            }
            
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(FOG_BASE_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let below_l   = Int(truncating: response![1] as! NSNumber)
            let below_ll  = Int(truncating: response![2] as! NSNumber)
            let below_lll = Int(truncating: response![3] as! NSNumber)
            
            if self.liveSensorValues213.waterMakeup == 1{
                self.fogTankbasementGreen.isHidden = false
            } else {
                if below_l == 1 || below_ll == 1 || below_lll == 1{
                    self.fogTankbasementGreen.isHidden = true
                } else {
                    self.fogTankbasementGreen.isHidden = false
                }
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(QUADA_TANK_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let aboveHigh = Int(truncating: response![0] as! NSNumber)
            let below_lll   = Int(truncating: response![3] as! NSNumber)
            CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: 3400, completion: { (success, response) in
                guard success == true else { return }
                let pumpOFfH1 = Int(truncating: response![0] as! NSNumber)
                let pumpOFfL1 = Int(truncating: response![1] as! NSNumber)
                let tankLeak  = Int(truncating: response![2] as! NSNumber)
                if tankLeak == 1{
                    self.quadAleakIcon.alpha = 1
                } else {
                    self.quadAleakIcon.alpha = 0
                    if aboveHigh == 1 || pumpOFfH1 == 1 || pumpOFfL1 == 1 || below_lll == 1{
                        self.quadAmainTankGreen.isHidden   = true
                    } else {
                        self.quadAmainTankGreen.isHidden   = false
                    }
                }
                
               
            })
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(QUADB_TANK_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let aboveHigh = Int(truncating: response![0] as! NSNumber)
            let below_lll   = Int(truncating: response![3] as! NSNumber)
            CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: 3403, completion: { (success, response) in
                guard success == true else { return }
                let pumpOFfH1 = Int(truncating: response![0] as! NSNumber)
                let pumpOFfL1 = Int(truncating: response![1] as! NSNumber)
                let tankLeak  = Int(truncating: response![2] as! NSNumber)
                if tankLeak == 1{
                    self.quadBleakIcon.alpha = 1
                } else {
                    self.quadBleakIcon.alpha = 0
                    if aboveHigh == 1 || pumpOFfH1 == 1 || pumpOFfL1 == 1 || below_lll == 1{
                        self.quadBmainTankGreen.isHidden   = true
                    } else {
                        self.quadBmainTankGreen.isHidden   = false
                    }
                }
            })
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(QUADC_TANK_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let aboveHigh = Int(truncating: response![0] as! NSNumber)
            let below_lll   = Int(truncating: response![3] as! NSNumber)
            CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: 3406, completion: { (success, response) in
                guard success == true else { return }
                let pumpOFfH1 = Int(truncating: response![0] as! NSNumber)
                let pumpOFfL1 = Int(truncating: response![1] as! NSNumber)
                let tankLeak  = Int(truncating: response![2] as! NSNumber)
                if tankLeak == 1{
                    self.quadCleakIcon.alpha = 1
                } else {
                    self.quadCleakIcon.alpha = 0
                    if aboveHigh == 1 || pumpOFfH1 == 1 || pumpOFfL1 == 1 || below_lll == 1{
                        self.quadCmainTankGreen.isHidden   = true
                    } else {
                        self.quadCmainTankGreen.isHidden   = false
                    }
                }
            })
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(QUADD_TANK_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let aboveHigh = Int(truncating: response![0] as! NSNumber)
            let below_lll   = Int(truncating: response![3] as! NSNumber)
            CENTRAL_SYSTEM?.readBits(length: 3, startingRegister: 3409, completion: { (success, response) in
                guard success == true else { return }
                let pumpOFfH1 = Int(truncating: response![0] as! NSNumber)
                let pumpOFfL1 = Int(truncating: response![1] as! NSNumber)
                let tankLeak  = Int(truncating: response![2] as! NSNumber)
                if tankLeak == 1{
                    self.quadDleakIcon.alpha = 1
                } else {
                    self.quadDleakIcon.alpha = 0
                    if aboveHigh == 1 || pumpOFfH1 == 1 || pumpOFfL1 == 1 || below_lll == 1{
                        self.quadDmainTankGreen.isHidden   = true
                    } else {
                        self.quadDmainTankGreen.isHidden   = false
                    }
                }
            })
        })
        CENTRAL_SYSTEM?.readBits(length: 4, startingRegister: Int32(FOG_BASE_LEVEL_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let below_l   = Int(truncating: response![1] as! NSNumber)
            let below_ll  = Int(truncating: response![2] as! NSNumber)
            let below_lll = Int(truncating: response![3] as! NSNumber)
            
            if self.liveSensorValues405.waterMakeup == 1{
                self.fogTankquadDGreen.isHidden = false
            } else {
                if below_l == 1 || below_ll == 1 || below_lll == 1{
                    self.fogTankquadDGreen.isHidden = true
                } else {
                    self.fogTankquadDGreen.isHidden = false
                }
            }
        })
    }
    
    
    
    /***************************************************************************
     * Function :  parseWaterLevelFaults
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    
    
    private func parseMakeup(){
       
        var makeupbaseTank        = 0
        var fogbaseTank           = 0
        var fogquadDTank          = 0
        var makeupbaseTankTimeout = 0
        var fogbaseTankTimeout    = 0
        var fogquadDTankTimeout   = 0
        
        CENTRAL_SYSTEM?.readBits(length: 2, startingRegister: 3006, completion: { (success, response) in
            guard success == true else { return }
            makeupbaseTank = Int(truncating: response![0] as! NSNumber)
            makeupbaseTankTimeout =  Int(truncating: response![1] as! NSNumber)
            
            CENTRAL_SYSTEM?.readBits(length: 2, startingRegister: 3026, completion: { (success, response) in
                guard success == true else { return }
                fogbaseTank = Int(truncating: response![0] as! NSNumber)
                fogbaseTankTimeout = Int(truncating: response![1] as! NSNumber)
                
                CENTRAL_SYSTEM?.readBits(length: 2, startingRegister: 3126, completion: { (success, response) in
                    guard success == true else { return }
                    fogquadDTank = Int(truncating: response![0] as! NSNumber)
                    fogquadDTankTimeout = Int(truncating: response![1] as! NSNumber)
                    
                    if makeupbaseTankTimeout == 1 || fogbaseTankTimeout == 1 || fogquadDTankTimeout == 1{
                        self.fillTimeout.alpha = 1
                    } else {
                        self.fillTimeout.alpha = 0
                    }
                    
                    if makeupbaseTank == 1{
                        self.basemainTankGreen.isHidden    = false
                        self.basemainTankGreen.backgroundColor = DEFAULT_GRAY
                        self.waterMakeupFaucet.alpha = 1
                    } else {
                        self.basemainTankGreen.backgroundColor = GREEN_COLOR
                        self.waterMakeupFaucet.alpha = 0
                    }
                    if fogbaseTank == 1{
                        self.fogTankbasementGreen.isHidden    = false
                        self.fogTankbasementGreen.backgroundColor = DEFAULT_GRAY
                        self.fogBasemakeupFaucet.alpha = 1
                    } else {
                        self.fogTankbasementGreen.backgroundColor = GREEN_COLOR
                        self.fogBasemakeupFaucet.alpha = 0
                    }
                    if fogquadDTank == 1{
                        self.fogTankquadDGreen.isHidden    = false
                        self.fogTankquadDGreen.backgroundColor = DEFAULT_GRAY
                        self.fogquadDmakeupFaucet.alpha = 1
                    } else {
                        self.fogTankquadDGreen.backgroundColor = GREEN_COLOR
                        self.fogquadDmakeupFaucet.alpha = 0
                    }
                })
            })
        })
       
        
        
        
    }
    
   
    private func parseWaterLevelFaults(){
        
        if liveSensorValues110.malfunction == 1 || liveSensorValues213.malfunction == 1 || liveSensorValues401.malfunction == 1 || liveSensorValues402.malfunction == 1 || liveSensorValues403.malfunction == 1 || liveSensorValues404.malfunction == 1 || liveSensorValues405.malfunction == 1{
            waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-red")
        } else {
            waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-gray")
        }
        
        if liveSensorValues110.below_ll == 1 || liveSensorValues213.below_ll == 1 || liveSensorValues401.below_ll == 1 || liveSensorValues402.below_ll == 1 || liveSensorValues403.below_ll == 1 || liveSensorValues404.below_ll == 1 || liveSensorValues405.below_ll == 1{
            lowWaterNoLights.isHidden = false
        } else {
            lowWaterNoLights.isHidden = true
        }
        
        if liveSensorValues110.below_lll == 1 || liveSensorValues213.below_lll == 1 || liveSensorValues401.below_lll == 1 || liveSensorValues402.below_lll == 1 || liveSensorValues403.below_lll == 1 || liveSensorValues404.below_lll == 1 || liveSensorValues405.below_lll == 1{
            lowWaterNoShow.isHidden = false
        } else {
            lowWaterNoShow.isHidden = true
        }
    }
    
    
    @IBAction func showHiddenSettings(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
    
}
