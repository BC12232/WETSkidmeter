//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterQualitySettingsViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module sets all timer settings for water quality 
 *                  sensors
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Quality screen configuration parameters located in specs.swift file
 *     should be modified
 *
 ***************************************************************************/

import UIKit

class WaterQualitySettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var orpDelayTimerTxt: UITextField!
    @IBOutlet weak var phDelayTimerTxt: UITextField!
    @IBOutlet weak var tdsDelayTimerTxt: UITextField!
    @IBOutlet weak var brominatorTimeoutTxt: UITextField!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLabel: UILabel!
    
    @IBOutlet weak var orpscaleMin: UILabel!
    @IBOutlet weak var phscaleMin: UILabel!
    @IBOutlet weak var tdsscaleMin: UILabel!
    @IBOutlet weak var orpscaleMax: UILabel!
    @IBOutlet weak var phscaleMax: UILabel!
    @IBOutlet weak var tdsscaleMax: UILabel!
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        constructSaveButton()
        
        //Get initial setpoints from PLC
        getSetpoints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func checkSystemStat(){
        let (plcConnection,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLabel.text = "PLC CONNECTION FAILED"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLabel.text = "CONNECTING TO PLC..."
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLabel.text = "PLC POOR CONNECTION, PLEASE WAIT..."
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(false)
    }
    
    

    /***************************************************************************
     * Function :  constructSaveButton
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }

    /***************************************************************************
     * Function :  getSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func getSetpoints(){
        
        //Get all Sensor Scale MIN/MAX Values from PLC
        
        readScaleMinMaxSensorDataFromPLC()
        
        //Get WQ Delay Timer Setpoints
        
        CENTRAL_SYSTEM?.readRegister(length: 3, startingRegister: Int32(WQ_PH_TIMER_REGISTER), completion:{ (success, response) in
            
            if success == true{
                
                let PHSetpoint  = Int(truncating: response![0] as! NSNumber)
                let ORPSetpoint = Int(truncating: response![1] as! NSNumber)
                let TDSSetpoint = Int(truncating: response![2] as! NSNumber)
                
                self.orpDelayTimerTxt.text = ORPSetpoint.description
                self.phDelayTimerTxt.text = PHSetpoint.description
                self.tdsDelayTimerTxt.text = TDSSetpoint.description
                
            }
        })
        
        getMinMaxValues(register: WQ_PH_CHANNEL_FAULT_BIT, index: 1)
        getMinMaxValues(register: WQ_OPR_CHANNEL_FAULT_BIT, index: 2)
        getMinMaxValues(register: WQ_TDS_CHANNEL_FAULT_BIT, index: 3)
        //Get Brominator Timeout Setpoints
        
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(WQ_BROMINATOR_TIMEOUT_REGISTER), completion: { (success, response) in
            
            if success == true{
                let brominatorTimeout = Int(truncating: response![0] as! NSNumber)
                self.brominatorTimeoutTxt.text = brominatorTimeout.description
            }
        })
        
    }
    
    func getMinMaxValues(register: Int, index: Int){
        CENTRAL_SYSTEM?.readRealRegister(register: register + 2, length: 2, completion: { (success, response) in
            
            if success == true{
                let minValue  = Float(response)
                switch index {
                    case 1: self.phscaleMin.text = String(format: "%.1f", minValue!)
                    case 2: self.orpscaleMin.text = String(format: "%.1f", minValue!)
                    case 3: self.tdsscaleMin.text = String(format: "%.1f", minValue!)
                default:
                    print("No Tag")
                }
            }
        })
        CENTRAL_SYSTEM?.readRealRegister(register: register + 4, length: 2, completion: { (success, response) in
            
            if success == true{
                let maxValue  = Float(response)
                switch index {
                    case 1: self.phscaleMax.text = String(format: "%.1f", maxValue!)
                    case 2: self.orpscaleMax.text = String(format: "%.1f", maxValue!)
                    case 3: self.tdsscaleMax.text = String(format: "%.1f", maxValue!)
                default:
                    print("No Tag")
                }
            }
        })
    }
    /***************************************************************************
     * Function :  readScaleMinMaxSensorDataFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :  Reads all the scale min and max values from PLC for each sensor
     ***************************************************************************/
    
    private func readScaleMinMaxSensorDataFromPLC(){
        
        var sensorCount = 0
        
        while sensorCount < 3 {
            
            //We want to dynamically get the PLC addresses insread of calling the read function evey time one after another.
            //To get an idea of what are the PLC address we are trying to calculate here, please review WaterQualitySpecs.swift file
            //It will explain the pattern between individual scale values which justifies the following equation
            
            let PLCAddr_MIN = WQ_SCALE_MIN+(sensorCount*10)
            
            CENTRAL_SYSTEM?.readRealRegister(register: PLCAddr_MIN, length: 2, completion: { (success, response) in
                
                let sensorRawValue = self.view.viewWithTag(PLCAddr_MIN) as? UILabel
                sensorRawValue?.text = response
                
            })
            
            let PLCAddr_MAX = WQ_SCALE_MAX+(sensorCount*10)

            CENTRAL_SYSTEM?.readRealRegister(register: PLCAddr_MAX, length: 2, completion: { (success, response) in
                
                let sensorRawValue = self.view.viewWithTag(PLCAddr_MAX) as? UILabel
                sensorRawValue?.text = response
                
            })
            
            sensorCount = sensorCount+1;
            
        }
        
    }
    
    /***************************************************************************
     * Function :  saveSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func saveSetpoints(){
        
        saveSetpointDelaysToPLC()
        
    }
    
    /***************************************************************************
     * Function :  saveSetpointDelaysToPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func saveSetpointDelaysToPLC(){
        
        let oprDelayTimerSP     = Int(orpDelayTimerTxt.text!)
        let phDelayTimerSP      = Int(phDelayTimerTxt.text!)
        let tdsDelayTimerSP     = Int(tdsDelayTimerTxt.text!)
        let brominatorTimeoutSP = Int(brominatorTimeoutTxt.text!)
        
        //Checkpoints to make sure setpoint inputs are not empty
        guard oprDelayTimerSP != nil && phDelayTimerSP != nil && tdsDelayTimerSP != nil && brominatorTimeoutSP != nil else { return }
        
        CENTRAL_SYSTEM?.writeRegister(register: WQ_ORP_TIMER_REGISTER, value: oprDelayTimerSP!)
        CENTRAL_SYSTEM?.writeRegister(register: WQ_PH_TIMER_REGISTER, value: phDelayTimerSP!)
        CENTRAL_SYSTEM?.writeRegister(register: WQ_TDS_TIMER_REGISTER, value: tdsDelayTimerSP!)
        CENTRAL_SYSTEM?.writeRegister(register: WQ_BROMINATOR_TIMEOUT_REGISTER, value: brominatorTimeoutSP!)

    }

}
