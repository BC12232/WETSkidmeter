//
//  PumpDetailViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/27/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

class PumpDetailViewController: UIViewController,UIGestureRecognizerDelegate{
    
    var pumpNumber = 0
    
    private var pumpIndicatorLimit = 0
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private let helper = Helper()
    
    @IBOutlet weak var vfdFaultLbl: UILabel!
    @IBOutlet weak var cleanStrainerLbl: UILabel!
    @IBOutlet weak var pumpFaultLbl: UILabel!
    
    //MARK: - Frequency Label Indicators
    

    @IBOutlet weak var setFrequencyHandle: UIView!
    @IBOutlet weak var frequencySetLabel: UILabel!
    
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyValueLabel: UILabel!
    @IBOutlet weak var frequencyIndicator: UIView!
    @IBOutlet weak var frequencyIndicatorValue: UILabel!
    @IBOutlet weak var frequencySetpointBackground: UIView!
    @IBOutlet weak var manualSpeedView: UIView!
    @IBOutlet weak var manualSpeedValue: UITextField!
    
    
    //MARK: - Voltage Label Indicators
    
    @IBOutlet weak var voltageLabel: UILabel!
    @IBOutlet weak var voltageValueLabel: UILabel!
    @IBOutlet weak var voltageIndicator: UIView!
    @IBOutlet weak var voltageIndicatorValue: UILabel!
    @IBOutlet weak var voltageSetpointBackground: UIView!
    @IBOutlet weak var voltageBackground: UIView!
    
    //MARK: - Current Label Indicators
    
    @IBOutlet weak var currentBackground: UIView!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var currentSetpointBackground: UIView!
    @IBOutlet weak var currentIndicator: UIView!
    @IBOutlet weak var currentIndicatorValues: UILabel!
    
    //MARK: - Temperature Label Indicators
    
    @IBOutlet weak var temperatureIndicator: UIView!
    @IBOutlet weak var temperatureIndicatorValue: UILabel!
    @IBOutlet weak var temperatureGreen: UIView!
    @IBOutlet weak var temperatureYellow: UIView!
    @IBOutlet weak var temperatureBackground: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    

    @IBOutlet weak var playStopButtonIcon: UIButton!
    private var isManualMode = false
   
    
    //MARK: - Data Structures
    
    private var langData = Dictionary<String, String>()
    private var pumpModel:Pump?
    private var iPadNumber = 0
    private var showStoppers = ShowStoppers()
    private var pumpState = 0 //POSSIBLE STATES: 0 (Auto) 1 (Hand) 2 (Off)
    private var localStat = 0
    private var readFrequencyCount = 0
    private var readOnce = 0
    private var readPumpDetailSpecsOnce = 0
    private var readManualFrequencySpeed = false
    private var readManualFrequencySpeedOnce = false
    private var HZMax = 0
    
    private var voltageMaxRangeValue = 0
    private var voltageMinRangeValue = 0
    private var voltageLimit = 0
    private var pixelPerVoltage  = 0.0
    
    private var currentLimit = 0
    private var currentMaxRangeValue = 0
    private var pixelPerCurrent = 0.0
    
    private var temperatureMaxRangeValue = 0
    private var pixelPerTemperature = 0.0
    private var temperatureLimit = 100
    private var pumpFaulted = false
    
    var manualPumpGesture: UIPanGestureRecognizer!
    
    @IBOutlet weak var vfdNumber: UILabel!
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        self.manualSpeedView.alpha = 0
        super.viewDidLoad()
        
    }
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
        }
        
        vfdNumber.text = "VFD - \(pumpNumber)"
        pumpIndicatorLimit = 0
        readSchedulerEnable()
        initializePumpGestureRecognizer()

        
        //Configure Pump Screen Text Content Based On Device Language
        configureScreenTextContent()
        getIpadNumber()
        
        
        //Add show stoppers
        addShowStoppers()
        
        setPumpNumber()
        readCurrentPumpDetailsSpecs()
        
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool){
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(register: iPadNumberRegister.register, value: 0)
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }


    
    //MARK: - Set Pump Number To PLC
    
    private func setPumpNumber(){
        
        //Let the PLC know the current PUMP number
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(register: iPadNumberRegister.register, value: pumpNumber)
    
    }
    
    //====================================
    //                                     CONNECTION AND SHOW STOPPERS CHECK POINTS
    //====================================
    
    
    //MARK: - Check Status Of The Connections To Server and PLC
    
    @objc func checkSystemStat(){
        
        let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Check if the pumps or on auto mode or hand mode
            
            logger.logData(data: "PUMP: CONNECTION SUCCESS")
           
            readCurrentPumpSpeed()
            acquireDataFromPLC()
            
        } else  {
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
    
    
    //====================================
    //                                     GET PUMP DETAILS AND READINGS
    //====================================
    
    //MARK: - Configure Screen Text Content Based On Device Language
    
    private func configureScreenTextContent(){
        
        langData = helper.getLanguageSettigns(screenName: PUMPS_LANGUAGE_DATA_PARAM)
        
        frequencyLabel.text = langData["FREQUENCY"]!
        voltageLabel.text = langData["VOLTAGE"]!
        currentLabel.text = langData["CURRENT"]!
        temperatureLabel.text = langData["TEMPERATURE"]!
        pumpFaultLbl.text = langData["PUMP FAULT"]!
        cleanStrainerLbl.text = langData["CLEAN STRAINER"]!
        vfdFaultLbl.text = langData["VFD FAULTED"]!
        
        
        guard pumpModel != nil else {
            
            logger.logData(data: "PUMPS: PUMP MODEL EMPTY")
            
            //If the pump model is empty, put default parameters to avoid system crash
            navigationItem.title = langData["PUMPS DETAILS"]!
            noConnectionErrorLbl.text = "CHECK SETTINGS"
            
            return
            
        }
        
        navigationItem.title = langData[pumpModel!.screenName!]!
        noConnectionErrorLbl.text = pumpModel!.outOfRangeMessage!
        
    }
    
    //MARK: - Get iPad Number
    
    private func getIpadNumber(){
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            self.iPadNumber = 1
        } else {
            self.iPadNumber = ipadNum!
        }

    }
    
    //MARK: - Initialize Filtration Pump Gesture Recognizer
    
    private func initializePumpGestureRecognizer(){
        
        //RME: Initiate PUMP Flow Control Gesture Handler
        
        manualPumpGesture = UIPanGestureRecognizer(target: self, action: #selector(changePumpSpeedFrequency(sender:)))
        setFrequencyHandle.isUserInteractionEnabled = true
        setFrequencyHandle.addGestureRecognizer(self.manualPumpGesture)
        manualPumpGesture.delegate = self
        
    }
    
   @objc private func readCurrentPumpDetailsSpecs() {
        var pumpSet = 0
        
        iPadNumber == 1 ? (pumpSet = 0) : (pumpSet = 1)
        
        let registersSET1 = PUMP_DETAILS_SETS[pumpSet]
        let startRegister = registersSET1[0]

        CENTRAL_SYSTEM!.readRegister(length: 5, startingRegister: Int32(startRegister.register), completion:{ (success, response) in

            guard success == true else { return }

            if self.readPumpDetailSpecsOnce == 0 {
                self.readPumpDetailSpecsOnce = 1


                self.HZMax = Int(truncating: response![0] as! NSNumber) / 10
                self.voltageMaxRangeValue  = Int(truncating: response![1] as! NSNumber)
                self.voltageMinRangeValue = Int(truncating: response![2] as! NSNumber)
                self.currentMaxRangeValue = Int(truncating: response![3] as! NSNumber) / 10
                self.temperatureMaxRangeValue = Int(truncating: response![4] as! NSNumber)

                self.frequencyValueLabel.text = "\(self.HZMax)"

                // What we are getting is a range, not the maximum value. So to get the maximum volatage value just add 100.

                self.voltageLimit = self.voltageMaxRangeValue + 100
                self.voltageValueLabel.text   = "\(self.voltageLimit)"

                // What we are getting is a range, not the maximum value. So to get the maximum current value just add 10.
                self.currentLimit = self.currentMaxRangeValue + 10
                self.currentValueLabel.text = "\(self.currentLimit)"

                //Note temperature always stays at 100 limit.


                //Add necessary view elements to the view
                self.constructViewElements()
            }

        })
    }
    
    //MARK: - Construct View Elements
    
    private func constructViewElements(){
        constructVoltageSlider()
        constructCurrentSlider()
        constructTemperatureSlider()
    }

    
    private func constructVoltageSlider(){
        let frame = 450.0
        pixelPerVoltage = frame / Double(voltageLimit)
        if pixelPerVoltage == Double.infinity {
            pixelPerVoltage = 0
        }
        
        
        let length = Double(voltageMaxRangeValue) * pixelPerVoltage
        let height = Double(voltageMaxRangeValue - voltageMinRangeValue) * pixelPerVoltage
    
       
        voltageSetpointBackground.backgroundColor = GREEN_COLOR
        voltageSetpointBackground.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - length), width: 25, height: height)
        
    }
    
    private func constructCurrentSlider(){
        let frame = 450.0
        pixelPerCurrent = frame / Double(currentLimit)
        if pixelPerCurrent == Double.infinity {
            pixelPerCurrent = 0
        }
        
        var length = Double(currentMaxRangeValue) * pixelPerCurrent
        
        if length > 450{
            length = 450
        }
        
  
        currentSetpointBackground.backgroundColor = GREEN_COLOR
        currentSetpointBackground.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - length), width: 25, height: length)
    }
    
    private func constructTemperatureSlider(){
        let frame = 450.0
        let temperatureMidRangeValue = 50.0
        pixelPerTemperature = frame / Double(temperatureLimit)
        if pixelPerTemperature == Double.infinity {
            pixelPerTemperature = 0
        }
        
        
        let temperatureRange = Double(temperatureMaxRangeValue) * pixelPerTemperature
        let temperatureFrameHeight = (Double(temperatureMaxRangeValue) - temperatureMidRangeValue) * pixelPerTemperature
        
        temperatureYellow.backgroundColor = .yellow
        temperatureGreen.backgroundColor = GREEN_COLOR
        
        temperatureYellow.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - temperatureRange), width: 25, height: temperatureFrameHeight)
        temperatureGreen.frame = CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - temperatureRange), width: 25, height: temperatureRange)
       
        
    }
    
    
    //====================================
    //                                     GET PUMP DETAILS AND READINGS
    //====================================
    
    private func readCurrentPumpSpeed() {
        pumpIndicatorLimit += 1
    
        var pumpSet = 0
        
        iPadNumber == 1 ? (pumpSet = 0) : (pumpSet = 1)

        let registersSET1 = PUMP_SETS[pumpSet]
        let startRegister = registersSET1[1]
  
        CENTRAL_SYSTEM!.readRegister(length: 11, startingRegister: Int32(startRegister.register), completion:{ (success, response) in
            
            guard response != nil else { return }
    
            self.getVoltageReading(response: response)
            self.getCurrentReading(response: response)
            self.getTemperatureReading(response: response)
            self.getManualSpeedReading(response: response)
            self.getFrequencyReading(response: response)
            self.getManualSpeedReading(response: response)
         
            
            if self.readOnce == 0 {
                self.readOnce = 1
                let feedback = Int(truncating: response![8] as! NSNumber)
                let startStopMode = Int(truncating: response![7] as! NSNumber)
                
                if feedback == 0{

                    //Pump is in auto mode
                    self.localStat = 0
                    self.frequencyIndicator.isHidden = false
                    self.setFrequencyHandle.isHidden = false

                }else if feedback == 1 && startStopMode == 1{

                    //Pump is in manual mode
                    self.localStat = 2
                    self.frequencyIndicator.isHidden = false
                    self.setFrequencyHandle.isHidden = false
                    self.isManualMode = true

                }else if feedback == 1 && startStopMode == 0{

                    //Pump is in off mode
                    self.localStat = 1
                    self.frequencyIndicator.isHidden = true
                    self.setFrequencyHandle.isHidden = false
                }

               
            }
        })
    }
    
    func pad(string : String, toSize: Int) -> String{
        
        var padded = string
        
        for _ in 0..<toSize - string.characters.count{
            padded = "0" + padded
        }
        
        return padded
        
    }
    
    
    //MARK: - Read Water On Fire Values
    
    private func acquireDataFromPLC(){
        var faultStates = 0
        
        if iPadNumber == 1 {
            faultStates = 12
        } else {
            faultStates = 32
        }
        
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(faultStates), completion:{ (success, response) in
            
            if success == true{
                
                //Bitwise Operation
                let decimalRsp = Int(truncating: response![0] as! NSNumber)
                let base_2_binary = String(decimalRsp, radix: 2)
                let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)  //Convert to 16 bit
                let bits =  Bit_16.characters.map { String($0) }
                self.parseStates(bits: bits)
                
            }
        })
    }
    
    func readSchedulerEnable(){
        if pumpNumber == 104{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 2020, completion: { (success, response) in
                guard success == true else { return }
                let switchOnOff = Int(truncating: response![0] as! NSNumber)
                if switchOnOff == 0{
                    self.playStopButtonIcon.isHidden = false
                } else {
                    self.playStopButtonIcon.isHidden = true
                }
            })
        } else {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 2010, completion: { (success, response) in
                guard success == true else { return }
                let switchOnOff = Int(truncating: response![0] as! NSNumber)
                if switchOnOff == 0{
                    self.playStopButtonIcon.isHidden = false
                } else {
                    self.playStopButtonIcon.isHidden = true
                }
            })
        }
        
    }
    
    private func parseStates(bits:[String]){

        
        for fault in PUMP_FAULT_SET {
            
            let faultTag = fault.tag
            let state = Int(bits[15 - fault.bitwiseLocation])
            let indicator = view.viewWithTag(faultTag) as? UILabel
            
            if faultTag != 200 && faultTag != 204 && faultTag != 207 {
                if state == 1 {
                    indicator?.isHidden = false
                } else {
                    indicator?.isHidden = true
                }
            }
            
            if faultTag == 200 {
                if state == 1 {
                    indicator?.isHidden = false
                    pumpFaulted = true
                } else {
                    indicator?.isHidden = true
                    pumpFaulted = false
                }
            }
            
            if faultTag == 204 {
                if state == 1 {
                    indicator?.isHidden = true
                } else {
                    indicator?.isHidden = false
                }
            }
            
            if faultTag == 207 {
             
                readPlayStopBit(startStopMode: state ?? 0)
            }
            
            if faultTag == 208 {
                if state == 1 {
                    indicator?.isHidden = false
                } else {
                    indicator?.isHidden = true
                }
            }
         
            
        }
        
    }
    
    

    
    //MARK: - Get Voltage Reading
    
    private func getVoltageReading(response:[AnyObject]?){
        
        let voltage = Int(truncating: response![3] as! NSNumber)
        let voltageValue = voltage / 10
        let voltageRemainder = voltage % 10
        let indicatorLocation = abs(690 - (Double(voltageValue) * pixelPerVoltage))
        
        
        if indicatorLocation > 690 {
            voltageIndicator.frame = CGRect(x: 419, y: 690, width: 92, height: 23)
        } else if indicatorLocation < 240 {
            voltageIndicator.frame = CGRect(x: 419, y: 240, width: 92, height: 23)
        } else {
            voltageIndicator.frame = CGRect(x: 419, y: indicatorLocation, width: 92, height: 23)
        }
        
        voltageIndicatorValue.text = "\(voltageValue).\(voltageRemainder)"
        
        if voltageValue > voltageMaxRangeValue || voltageValue < voltageMinRangeValue {
            
            voltageIndicatorValue.textColor = RED_COLOR
            
        } else {
            
            voltageIndicatorValue.textColor = GREEN_COLOR
        }
    }
    
    //MARK: Get Current Reading
    
    private func getCurrentReading(response:[AnyObject]?){
        let current = Int(truncating: response![2] as! NSNumber)
        let currentValue = current / 10
        let currentRemainder = current % 10
        let indicatorLocation = abs(690 - (Double(currentValue) * pixelPerCurrent))
        
        
        if indicatorLocation > 690 {
            currentIndicator.frame = CGRect(x: 600, y: 690, width: 92, height: 23)
        } else if indicatorLocation < 240 {
            currentIndicator.frame = CGRect(x: 600, y: 240, width: 92, height: 23)
        } else {
            currentIndicator.frame = CGRect(x: 600, y: indicatorLocation, width: 92, height: 23)
        }
        
        currentIndicatorValues.text = "\(currentValue).\(currentRemainder)"
        
        if currentValue > Int(currentMaxRangeValue){
            currentIndicatorValues.textColor = RED_COLOR
        }else{
            currentIndicatorValues.textColor = GREEN_COLOR
        }
    }
    
    //MARK: - Get Temperature Reading
    
    private func getTemperatureReading(response:[AnyObject]?){
        
        let temperature = Int(truncating: response![4] as! NSNumber)
        let temperatureMid = 50
        let indicatorLocation = 690 - (Double(temperature) * pixelPerTemperature)
        
        
        
        if indicatorLocation > 690 {
             temperatureIndicator.frame = CGRect(x: 790, y: 690, width: 75, height: 23)
        } else if indicatorLocation < 240 {
            temperatureIndicator.frame = CGRect(x: 790, y: 240, width: 75, height: 23)
        } else {
            temperatureIndicator.frame = CGRect(x: 790, y: indicatorLocation, width: 75, height: 23)
        }
        
       
        temperatureIndicatorValue.text = "\(temperature)"
        
        if temperature > temperatureMaxRangeValue {
            temperatureIndicatorValue.textColor = RED_COLOR
        }else if temperature > temperatureMid && temperature < temperatureMaxRangeValue {
            temperatureIndicatorValue.textColor = .yellow
        }else{
            temperatureIndicatorValue.textColor = GREEN_COLOR
        }
        
    }
    
    //MARK: - Get Frequency Reading
    
    private func getFrequencyReading(response:[AnyObject]?){
        // If pumpstate == 0 (Auto) then show the frequency indicator/background frame/indicator value. Note: the frequency indicator's user interaction is disabled.

            let frequency = Int(truncating: response![1] as! NSNumber)
            
            let frequencyValue = frequency / 10
            let frequencyRemainder = frequency % 10
            var pixelPerFrequency = 450.0 / Double(HZMax)
            if pixelPerFrequency == Double.infinity {
                pixelPerFrequency = 0
            }
            
            let length = Double(frequencyValue) * pixelPerFrequency
            
            if frequencyValue > Int(HZMax){
                frequencySetpointBackground.frame =  CGRect(x: 0, y: 0, width: 25, height: 450)
                frequencyIndicator.frame = CGRect(x: 212, y: 240, width: 86, height: 23)
                frequencyIndicatorValue.text = "\(HZMax)"
            } else {
                frequencySetpointBackground.frame =  CGRect(x: 0, y: (SLIDER_PIXEL_RANGE - length), width: 25, height: length)
                frequencyIndicator.frame = CGRect(x: 212, y: (690 - length), width: 86, height: 23)
                frequencyIndicatorValue.text = "\(frequencyValue).\(frequencyRemainder)"
                
                
            }

    }
    
    
    //====================================
    //                                      AUTO / MANUAL MODE
    //====================================
    
    
    

    
    
    
    @IBAction func changeAutoManMode(_ sender: Any) {
        
        var manualBit = 0
        var autoBit = 0
        var startStopBit = 0
       
        
        if iPadNumber == 1{
            
            let registerSet = PUMP_SETS[0]
            
            autoBit = registerSet[6].register
            manualBit = registerSet[7].register
            startStopBit = registerSet[8].register
          
            
        }else{
            
            let registerSet = PUMP_SETS[1]
            
            
            autoBit = registerSet[6].register
            manualBit = registerSet[7].register
            startStopBit = registerSet[8].register
          
   
        }
        
        switch pumpState{
            
        case 0:
            
            //Switch to off mode
            self.localStat = 1
            CENTRAL_SYSTEM?.writeRegister(register: manualBit, value: 1)
            CENTRAL_SYSTEM?.writeRegister(register: autoBit, value: 0)
            CENTRAL_SYSTEM?.writeRegister(register: startStopBit, value: 0)
            isManualMode = false
            
            break
            
        case 1:
            
            //Switch to Manual Mode mode
            self.localStat = 2
            
            CENTRAL_SYSTEM?.writeRegister(register: manualBit, value: 1)
            CENTRAL_SYSTEM?.writeRegister(register: autoBit, value: 0)
            CENTRAL_SYSTEM?.writeRegister(register: startStopBit, value: 0)
            isManualMode = true
           
            
            break
            
        case 2:
            
            //Switch to off mode
            self.localStat = 3
            CENTRAL_SYSTEM?.writeRegister(register: manualBit, value: 1)
            CENTRAL_SYSTEM?.writeRegister(register: autoBit, value: 0)
            CENTRAL_SYSTEM?.writeRegister(register: startStopBit, value: 0)
            isManualMode = false
        
            
            break
            
        case 3:
            
            //Switch To Auto Mode
            self.localStat = 0
            CENTRAL_SYSTEM?.writeRegister(register: manualBit, value: 0)
            CENTRAL_SYSTEM?.writeRegister(register: autoBit, value: 1)
            CENTRAL_SYSTEM?.writeRegister(register: startStopBit, value: 0)
            isManualMode = false

           
            
            break
            
            
        default:
            
            print("PUMP STATE NOT FOUND")
            
        }
        
        
        
    }
    
    
    private func readPlayStopBit(startStopMode: Int) {
       if startStopMode == 1 {
                //stop
            playStopButtonIcon.setImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
              
       } else {
                //play
            playStopButtonIcon.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
              
       }
    }
    
    @IBAction func playStopButtonPressed(_ sender: Any) {
        var startStopBit = 0
        
        if iPadNumber == 1 {
            startStopBit = 9
        } else {
            startStopBit = 29
        }
        
        
        if playStopButtonIcon.imageView?.image == #imageLiteral(resourceName: "playButton") {
            CENTRAL_SYSTEM?.writeRegister(register: startStopBit, value: 1)
        } else {
            CENTRAL_SYSTEM?.writeRegister(register: startStopBit, value: 0)
        }
    }
    
    
   
    
    
  
    
    //====================================
    //                                      MANUAL PUMP CONTROL
    //====================================
    
    
    private func getManualSpeedReading(response: [AnyObject]?){
        if readManualFrequencySpeed || !readManualFrequencySpeedOnce {
            readManualFrequencySpeedOnce = true
            readManualFrequencySpeed = false

            let manualSpeed = Int(truncating: response![0] as! NSNumber)
            let manualSpeedValue = manualSpeed / 10
            let manualSpeedRemainder = manualSpeed % 10
            var pixelPerFrequency = 450.0 / Double(HZMax)
            
            if pixelPerFrequency == Double.infinity {
                pixelPerFrequency = 0
            }
            
            let length = Double(manualSpeedValue) * pixelPerFrequency
            
            
            if manualSpeedValue > Int(HZMax){
                setFrequencyHandle.frame = CGRect(x: 403, y: 237, width: 108, height: 26)
                frequencySetLabel.textColor = GREEN_COLOR
                frequencySetLabel.text = "\(HZMax)"
                self.manualSpeedValue.text  = "\(HZMax)"
            } else {
                setFrequencyHandle.frame = CGRect(x: 403, y: (687 - length), width: 108, height: 26)
                frequencySetLabel.textColor = GREEN_COLOR
                frequencySetLabel.text = "\(manualSpeedValue).\(manualSpeedRemainder)"
                self.manualSpeedValue.text  = "\(manualSpeedValue).\(manualSpeedRemainder)"
                print("this is the manual speed: \(manualSpeedValue).\(manualSpeedRemainder)")
            }
            
            
        }
        
    }
    
    
    
    @objc func changePumpSpeedFrequency(sender: UIPanGestureRecognizer){
      
            setFrequencyHandle.isUserInteractionEnabled = true
            frequencySetLabel.textColor = GREEN_COLOR
            var touchLocation:CGPoint = sender.location(in: self.view)
            print(touchLocation.y)
            //Make sure that we don't go more than pump flow limit
            if touchLocation.y  < 250 {
                touchLocation.y = 250
            }
            if touchLocation.y  > 700 {
                touchLocation.y = 700
            }
            if touchLocation.y >= 250 && touchLocation.y <= 700 {
                
                sender.view?.center.y = touchLocation.y
                
                let flowRange = 700 - Int(touchLocation.y)
                let pixelPerFrequency = 450.0 / Double(HZMax)
                var herts = Double(flowRange) / pixelPerFrequency
                if herts > 60.0 {
                    herts = 60.0
                }
                let formattedHerts = String(format: "%.1f", herts)
                let convertedHerts = Int(herts * 10)
                
                print(convertedHerts)
                frequencySetLabel.text = formattedHerts
                
                
                if sender.state == .ended {
                    if iPadNumber == 1{
                        CENTRAL_SYSTEM?.writeRegister(register: 2, value: convertedHerts) //NOTE: We multiply the frequency by 10 becuase PLC expects 3 digit number
                        setReadManualSpeedBoolean()
                        
                    } else {
                        CENTRAL_SYSTEM?.writeRegister(register: 22, value: convertedHerts) //NOTE: We multiply the frequency by 10 becuase PLC expects 3 digit number
                        setReadManualSpeedBoolean()
                    }
                }
     
            }
  
    
    }
    
    @IBAction func setManualSpeed(_ sender: Any) {
        var manSpeed  = Float(self.manualSpeedValue.text!)
        self.manualSpeedValue.text = ""
        if manSpeed == nil{
            manSpeed = 0
        }
        if manSpeed! > 50 {
            manSpeed = 50
        }
        manSpeed = manSpeed! * 10
        if iPadNumber == 1{
            
            
            CENTRAL_SYSTEM?.writeRegister(register: 2, value: Int(manSpeed!))
            
            
        } else {
            
            
            CENTRAL_SYSTEM?.writeRegister(register: 22, value: Int(manSpeed!))
            
        }
        readManualFrequencySpeedOnce = false
    }
    
    
    
   
    private func setReadManualSpeedBoolean(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            self.readManualFrequencySpeed = true
        }
    }
    
}
