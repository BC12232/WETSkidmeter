//
//  WaterSkinViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 6/24/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class WaterSkinViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var pumpbutton104: UIButton!
    @IBOutlet weak var frequencyIndicator: UIView!
    @IBOutlet weak var frequencyIndicatorValue: UILabel!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var frequencySetpointBackground: UIView!
    var manulPumpGesture: UIPanGestureRecognizer!
    var backWashGesture: UIPanGestureRecognizer!
    private var iPadNumber = 0
    private var readManualSpeedPLC = false
    private var readBackWashSpeedOnce  = false
    private var readManualSpeedOncePLC = false
    private var frequency: Int?
    private var manualSpeed: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool){
        initializePumpGestureRecognizer()
        getIpadNumber()
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    private func getIpadNumber(){
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            iPadNumber = 1
        }else{
            iPadNumber = ipadNum!
        }
        
    }
    
    @objc func checkSystemStat(){
        let (plcConnection, serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            readChannelFault()
            readCurrentFiltrationPumpDetails()
            
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
    
    @IBAction func readPumpDetails(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "pumps", bundle:nil)
        
        let pumpDetail = storyBoard.instantiateViewController(withIdentifier: "pumpDetail") as! PumpDetailViewController
        pumpDetail.pumpNumber = sender.tag
        self.navigationController?.pushViewController(pumpDetail, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        
        //Set pump number to
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        
        CENTRAL_SYSTEM!.writeRegister(register: iPadNumberRegister.register, value: 0)
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    private func initializePumpGestureRecognizer(){
        
        //RME: Initiate PUMP Flow Control Gesture Handler
        
        manulPumpGesture = UIPanGestureRecognizer(target: self, action: #selector(changePumpSpeedFrequency(sender:)))
        frequencyIndicator.isUserInteractionEnabled = true
        frequencyIndicator.addGestureRecognizer(self.manulPumpGesture)
        manulPumpGesture.delegate = self
        
    }
    
   func readChannelFault(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_PUMP_FAULT_104), completion: { (success, response) in
            
            guard response != nil else{
                return
            }
            let state = Int(truncating: response![0] as! NSNumber)
            
            if state == 1 {
                self.pumpbutton104.setTitleColor(RED_COLOR, for: .normal)
            } else if state == 0 {
                self.pumpbutton104.setTitleColor(DEFAULT_GRAY, for: .normal)
                
            }
        })
   }
    @objc func changePumpSpeedFrequency(sender: UIPanGestureRecognizer){
        frequencyIndicatorValue.textColor = DEFAULT_GRAY
        
        var touchLocation:CGPoint = sender.location(in: self.view)
        print(touchLocation.y)
        //Make sure that we don't go more than pump flow limit
        if touchLocation.y  < 130 {
            touchLocation.y = 130
        }
        if touchLocation.y  > 394 {
            touchLocation.y = 394
        }
        
        // This is set.
        if touchLocation.y >= 130 && touchLocation.y <= 394 {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 394.0 - touchLocation.y
            let hertz = Float(flowRange) * CONVERTED_FILTRATION_PIXEL_PER_FREQUENCY!
            
            
            var convertedFrequency = Int(hertz * 10)
            let frequencyValue = convertedFrequency / 10
            var frequencyRemainder = convertedFrequency % 10
            
            if frequencyValue == 50 && frequencyRemainder > 0 {
                frequencyRemainder = 0
            }
            
            if frequencyValue == 0 && frequencyRemainder < 0 {
                frequencyRemainder = 0
            }
            
            frequencyIndicatorValue.text = "\(frequencyValue).\(frequencyRemainder)"
            
            if convertedFrequency > CONVERTED_FREQUENCY_LIMIT {
                convertedFrequency = CONVERTED_FREQUENCY_LIMIT
            } else if convertedFrequency < 0 {
                convertedFrequency = 0
            }
            
            
            if sender.state == .ended {
                if convertedFrequency < 10{
                    CENTRAL_SYSTEM?.writeRegister(register: 1043, value: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.readManualSpeedPLC = true
                    }
                }else{
                    CENTRAL_SYSTEM?.writeRegister(register: 1043, value: convertedFrequency)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.readManualSpeedPLC = true
                    }
                }
            }
            
        }
    }
    
    private func readCurrentFiltrationPumpDetails(){
        
        var pumpSet = 0
        
        if iPadNumber == 1{
            pumpSet = 0
        }else if iPadNumber == 2{
            pumpSet = 1
        }
        
        let registersSET1 = PUMP_SETS[pumpSet]
        let startRegister = registersSET1[1]
        
        CENTRAL_SYSTEM!.readRegister(length: 14, startingRegister: 1043, completion:{ (success, response) in
            
            guard response != nil else { return }
            
            self.readCurrentFiltrationSpeed(response: response)
            self.readCurrentManualSpeed(response: response)
        })
    }
    
    private func readCurrentFiltrationSpeed(response:[AnyObject]?) {
        self.frequency = Int(truncating: response![1] as! NSNumber)
        
        if let frequency = frequency {
            let integer = frequency / 10
            let frequencyLocation = (Double(integer) * PIXEL_PER_FREQUENCY)
            let indicatorLocation = 389 - frequencyLocation
            
            
            if integer > Int(MAX_FILTRATION_FREQUENCY){
                frequencySetpointBackground.frame =  CGRect(x: 505, y: 190, width: 25, height: 258)
            }else{
                frequencySetpointBackground.frame =  CGRect(x: 505, y: indicatorLocation, width: 25, height:frequencyLocation)
            }
        }
    }
    private func readCurrentManualSpeed(response:[AnyObject]?) {
        if  readManualSpeedPLC || !readManualSpeedOncePLC {
            readManualSpeedPLC = false
            
            frequencyIndicatorValue.textColor = GREEN_COLOR
            self.manualSpeed = Int(truncating: response![0] as! NSNumber)
            
            if let manualSpeed = manualSpeed {
                let integer = manualSpeed / 10
                let decimal = manualSpeed % 10
                let indicatorLocation = 379 - (Double(integer) * PIXEL_PER_FREQUENCY)
                
                if integer > Int(MAX_FILTRATION_FREQUENCY){
                    frequencyIndicator.frame = CGRect(x: 405, y: 190, width: 86, height: 23)
                    frequencyIndicatorValue.text = "\(MAX_FILTRATION_FREQUENCY)"
                    readManualSpeedOncePLC = true
                }else{
                    
                    frequencyIndicator.frame = CGRect(x: 405, y: indicatorLocation, width: 86, height: 23)
                    frequencyIndicatorValue.text = "\(integer).\(decimal)"
                    readManualSpeedOncePLC = true
                }
            }
        }
    }
}
