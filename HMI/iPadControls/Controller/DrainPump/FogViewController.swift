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

    
    //No Connection View
    
    @IBOutlet weak var noConnectionView:     UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var motorOverload:        UILabel!
    @IBOutlet weak var pumpFault:            UILabel!
    @IBOutlet weak var fogOnOffLbl:          UILabel!
    @IBOutlet weak var lowPressure:          UILabel!
    @IBOutlet weak var playStopBtn:          UIButton!
    @IBOutlet weak var waterlevelLowMsg: UILabel!
    

    
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
            getFogDataFromPLC()
            readDrainStatus()
            
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
    
    func readDrainStatus(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: 3023, completion: { (success, response) in
            guard success == true else { return }
            let status = Int(truncating: response![0] as! NSNumber)
            if status == 1{
               self.playStopBtn.isHidden = true
               self.waterlevelLowMsg.isHidden = false
            } else {
               self.playStopBtn.isHidden = false
               self.waterlevelLowMsg.isHidden = true
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
    }
    
    
    /***************************************************************************
     * Function :  getFogDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func getFogDataFromPLC(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(FOG_FAULTS_121.count), startingRegister: Int32(FOG_FAULTS_121.startAddr), completion: { (sucess, response) in
            
            if response != nil{
                
                
                self.fogMotorLiveValues.pumpRunning   = Int(truncating: response![0] as! NSNumber)
                self.fogMotorLiveValues.pumpFault     = Int(truncating: response![1] as! NSNumber)
                self.fogMotorLiveValues.pumpOverLoad  = Int(truncating: response![2] as! NSNumber)
                self.fogMotorLiveValues.pressureFault = Int(truncating: response![3] as! NSNumber)
                
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
            
        } else {
           
            pumpFault.alpha = 0
        }
        
        if fogMotorLiveValues.pumpRunning == 1{
            
            fogOnOffLbl.text = "PUMP CURRENTLY ON"
            fogOnOffLbl.textColor = GREEN_COLOR
            
            
        } else if fogMotorLiveValues.pumpRunning == 0{
            
            fogOnOffLbl.text = "PUMP CURRENTLY OFF"
            fogOnOffLbl.textColor = DEFAULT_GRAY
            
            
            
        }
    }
    
  
 
    
    /***************************************************************************
     * Function :  playStopFog
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func playStopFog(_ sender: UIButton){
        
      if self.fogMotorLiveValues.pumpRunning == 1{
            
            CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_121, value: 0)
            
      }else{
            
            CENTRAL_SYSTEM?.writeBit(bit: FOG_PLAY_STOP_BIT_ADDR_121, value: 1)
            
      }
    }
    
    @IBAction func showSettingsButton(_ sender: UIButton) {
         self.addAlertAction(button: sender)
    }
}
