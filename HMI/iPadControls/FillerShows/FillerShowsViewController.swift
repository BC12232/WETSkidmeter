//
//  LightsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit


class FillerShowsViewController: UIViewController,UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    @IBOutlet weak var pumpIconButton: UIButton!
    @IBOutlet weak var noConnectionView:       UIView!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var noConnectionErrorLabel: UILabel!
    @IBOutlet weak var fillerShowNumberTxt: UITextField!
    @IBOutlet weak var fillerShowEnabledDisbaledLbl: UILabel!
    @IBOutlet weak var specialShowNumtxt: UITextField!
    @IBOutlet weak var dropDown: UIPickerView!
    @IBOutlet weak var rainSensor: UIImageView!
    @IBOutlet weak var sensorStatus: UIImageView!
    @IBOutlet weak var specialShwControlSwitch: UISwitch!
    @IBOutlet weak var dropDownSpecial: UIPickerView!
    
    @IBOutlet weak var percipitationLive: UILabel!
    @IBOutlet weak var timeDelay: UITextField!
    @IBOutlet weak var percipitaionSP: UITextField!
    @IBOutlet weak var specialShwViw: UIView!
    @IBOutlet weak var noShowPumpSpeed: UITextField!
    
    let GET_FILLER_SHOW_STATE_HTTP_PATH  = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readFillerShow"
    let SET_FILLER_SHOW_STATE_HTTP_PATH  = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeFillerShow"
    let FILLER_SHOW_STATUS_WRITE_REGISTER        = 5502
    let PERCIPITATION_TIME_DELAY                 = 6004
    let PERCIPITATION_SP                         = 6000
    let PERCIPITATION_LIVE                       = 6002
    
    let READ_SHOW_STOPPER_FAULTS_SERVER_PATH = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readFaultsAll"
    private var shows: [Any]? = nil
    private var fillerShowStatus: Int = 0
    var currentFillerShowState  = 0
    var currentFillerShowNumber = 0
    var specialShowNumber       = 0
    var showNumberRead          = 0
    private let logger   = Logger()
    private let httpComm = HTTPComm()
    var list:[String] = []
    var speciallist:[String] = []
    var centralSystem:CentralSystem?
    var editingBegan = false
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        addShowStoppers()
        self.readFillerShowState()
        readFillerShowOnOff()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /***************************************************************************
     * Function :  didReceiveMemoryWarning
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()
        
    }
    func readShowFile() {
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "shows") != nil {
            
            if let object = defaults.object(forKey: "shows") as? [Any] {
                shows = object
            }
        }
        
        for show in self.shows!{
            
            let dictionary  = show as! NSDictionary
            let filler      = dictionary.object(forKey: "filler") as? Int
            let special      = dictionary.object(forKey: "special") as? Int
            let name        = dictionary.object(forKey: "name") as? String
            let number      = dictionary.object(forKey: "number") as? Int
            
            if number != 0{
                if filler != nil {
                    if filler == 1{
                        if !list.contains(name!){
                            self.list.append(name!)
                        }
                    }
                }
                if special != nil {
                    if special == 1{
                        if !speciallist.contains(name!){
                            self.speciallist.append(name!)
                        }
                    }
                }
            }
        }
        print(list)
        print(speciallist)
        dropDown.reloadAllComponents()
        dropDownSpecial.reloadAllComponents()
        print(list.count)
        print(speciallist.count)
    }
    
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        readShowFile()
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(FillerShowsViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
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
        self.list.removeAll()
        self.speciallist.removeAll()
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        
        let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{

            //Change the connection stat indicator
            self.noConnectionView.alpha = 0
            self.noConnectionView.isUserInteractionEnabled = false
            readFillerShowOnOff()
            self.readFillerShowState()
           
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLabel.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLabel.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    func readFillerShowOnOff(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILLER_SHOW_STATUS_WRITE_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let status       = Int(truncating: response![0] as! NSNumber)
            self.fillerShowStatus = status
            if self.fillerShowStatus == 1 {
                self.pumpIconButton.setImage(UIImage.init(named: "fillerShowOn"), for: .normal)
            } else {
                 self.pumpIconButton.setImage(UIImage.init(named: "fillerShow"), for: .normal)
            }
        })
        
        CENTRAL_SYSTEM?.readBits(length: 2, startingRegister: Int32(RAIN_SENSOR_STATUS_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            let sensorStatus = Int(truncating: response![0] as! NSNumber)
            let rainStatus   = Int(truncating: response![1] as! NSNumber)
            
            if sensorStatus == 0{
                self.sensorStatus.image = UIImage(imageLiteralResourceName: "red.png")
            } else {
                self.sensorStatus.image = UIImage(imageLiteralResourceName: "green.png")
            }
            if rainStatus == 1{
                self.rainSensor.alpha = 1
            } else {
                self.rainSensor.alpha = 0.3
            }
        })
        
        CENTRAL_SYSTEM?.readRealRegister(register: PERCIPITATION_LIVE, length: 2, completion: { (success, response) in
            guard success == true else { return }
            let value       = Float(response)
            self.percipitationLive.text = String(format: "%.1f", value!)
        })
        
        if editingBegan == false {
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(PERCIPITATION_TIME_DELAY), completion: { (success, response) in
                guard success == true else { return }
                let value       = Int(truncating: response![0] as! NSNumber)
                self.timeDelay.text = "\(value)"
            })
            CENTRAL_SYSTEM?.readRealRegister(register: PERCIPITATION_SP, length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value       = Float(response)
                self.percipitaionSP.text = String(format: "%.1f", value!)
            })
        }
        
    }
    
    /***************************************************************************
     * Function :  enableDisableFillerShows
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func enableDisableFillerShows(_ sender: Any){
        
        var setState = 0
        var specialShowEnable = 0
        if(currentFillerShowState == 1){
            setState = 0
        }else if(currentFillerShowState == 0){
            setState = 1
        }
        
        if self.specialShwControlSwitch.isOn == true {
            specialShowEnable = 1
        } else {
            specialShowEnable = 0
        }
        
        let sendData = [
            "FillerShow_Enable" : setState,
            "FillerShow_Number" : currentFillerShowNumber,
            "SpecialShow"       : specialShowNumber,
            "SpecialShow_Enable": specialShowEnable
        ]
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: sendData, options: .prettyPrinted)
        var jsonString: String? = nil
        
        if let aData = jsonData{
            jsonString = String(data: aData, encoding: .utf8)
        }
        
        let escapedString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let strURL = "\(SET_FILLER_SHOW_STATE_HTTP_PATH)?\(String(describing: escapedString))"
        
        self.httpComm.httpGetResponseFromPath(url: strURL) { (response) in
            
        }

    }
    
    /***************************************************************************
     * Function :  enableDisableFillerShows
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readFillerShowState(){
        
        httpComm.httpGetResponseFromPath(url: GET_FILLER_SHOW_STATE_HTTP_PATH) { (response) in
            
            let dictionary  = response as! NSDictionary
            let enabledDisabled    = dictionary.object(forKey: "FillerShow_Enable") as? Int
            let fillerShowNumber   = dictionary.object(forKey: "FillerShow_Number") as? Int
            let specialShowNum     = dictionary.object(forKey: "SpecialShow") as? Int
            let specialShowEnable  = dictionary.object(forKey: "SpecialShow_Enable") as? Int
            
           
            
            if fillerShowNumber != nil && self.showNumberRead == 0 && specialShowNum != nil{
                CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: 5500, completion: { (success, response) in
                    guard success == true else { return }
                    var value = Float(truncating: response![0] as! NSNumber)
                    value = value/10
                    self.noShowPumpSpeed.text = String(format: "%.1f", value)
                    
                })
                self.fillerShowNumberTxt.text = "\(fillerShowNumber!)"
                self.specialShowNumtxt.text = "\(specialShowNum!)"
                self.currentFillerShowNumber  = fillerShowNumber!
                self.specialShowNumber = specialShowNum!
                if specialShowEnable != nil{
                    if specialShowEnable == 1{
                        self.specialShwControlSwitch.isOn = true
                    } else {
                        self.specialShwControlSwitch.isOn = false
                    }
                }
                self.showNumberRead = 1
                
            }

            self.currentFillerShowState = enabledDisabled!
            
            if(enabledDisabled == 0){
                
                self.fillerShowEnabledDisbaledLbl.text = "FILLER SHOW DISABLED"
                
            }else{
                
                self.fillerShowEnabledDisbaledLbl.text = "FILLER SHOW ENABLED"
                
            }
        }
    }
    
    /***************************************************************************
     * Function :  setFillerShowNumber
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func setFillerShowNumber(_ sender: Any){
       writeToServer()
    }
    
    
    func writeToServer(){
        let showNumber = Int(self.fillerShowNumberTxt.text!)
        let specialShowNum = Int(self.specialShowNumtxt.text!)
        
        var noShowPumpspeed = Float(self.noShowPumpSpeed.text!)
        var specialShowEnable = 0
        if self.specialShwControlSwitch.isOn == true {
            specialShowEnable = 1
        } else {
            specialShowEnable = 0
        }
        
        guard showNumber != nil && specialShowNum != nil && noShowPumpspeed != nil else{
            return
        }
        noShowPumpspeed! = noShowPumpspeed! * 10
        guard noShowPumpspeed != nil else { return }
        CENTRAL_SYSTEM!.writeRegister(register: 5500, value: Int(noShowPumpspeed!))
        
        let sendData = [
            "FillerShow_Enable" : currentFillerShowState,
            "FillerShow_Number" : showNumber!,
            "SpecialShow"       : specialShowNum!,
            "SpecialShow_Enable": specialShowEnable
        ]
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: sendData, options: .prettyPrinted)
        var jsonString: String? = nil
        
        if let aData = jsonData{
            jsonString = String(data: aData, encoding: .utf8)
        }
        
        let escapedString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let strURL = "\(SET_FILLER_SHOW_STATE_HTTP_PATH)?\(String(describing: escapedString))"
        
        self.httpComm.httpGetResponseFromPath(url: strURL) { (response) in
            
        }
    }
    /***************************************************************************
     * Function :  Text Field Delegate Handler
     * Input    :  none
     * Output   :  none
     * Comment  :  When user touches anywhere on the screen, text field resignes
     *             from being first responder and keyboard disappears
     ***************************************************************************/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        self.fillerShowNumberTxt.resignFirstResponder()
        self.specialShowNumtxt.resignFirstResponder()
        self.noShowPumpSpeed.resignFirstResponder()
        self.timeDelay.resignFirstResponder()
        self.percipitaionSP.resignFirstResponder()
    }
    
    @IBAction func settingsbtnPressed(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
       
        
        if fillerShowNumberTxt.isEditing {
            self.dropDown.isHidden = false
            self.fillerShowNumberTxt.endEditing(true)
            if list.count == 0{
                self.view.endEditing(true)
                let alert = UIAlertController(title: "FillerShow", message: "ERROR CODE(2) CONTACT WET", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.dropDown.isHidden = true
                self.fillerShowNumberTxt.text = "0"
                return
            }
        } else {
            self.dropDownSpecial.isHidden = false
            self.specialShowNumtxt.endEditing(true)
            if speciallist.count == 0{
                self.view.endEditing(true)
                let alert = UIAlertController(title: "SpecialShow", message: "ERROR CODE(3) CONTACT WET", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.dropDownSpecial.isHidden = true
                self.specialShowNumtxt.text = "0"
                return
            }
        }
        
       
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return list.count
        } else {
            return speciallist.count
        }
        
    }
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        if pickerView.tag == 1{
            return list[row]
        } else {
            return speciallist[row]
        }
        
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 1{
            let showName = self.list[row]
            let defaults = UserDefaults.standard
        
            if defaults.object(forKey: "shows") != nil {
                
                if let object = defaults.object(forKey: "shows") as? [Any] {
                    shows = object
                }
            }
             for show in self.shows!{
                let dictionary  = show as! NSDictionary
                let number      = dictionary.object(forKey: "number") as! Int
                
                let selectedShow = dictionary.object(forKey: "name") as? String
                if selectedShow == showName {
                    self.fillerShowNumberTxt.text = "\(number)"
                }
            }
            self.dropDown.isHidden = true
    } else {
            let specialShowName = self.speciallist[row]
            let defaults = UserDefaults.standard
        
            if defaults.object(forKey: "shows") != nil {
                
                if let object = defaults.object(forKey: "shows") as? [Any] {
                    shows = object
                }
            }
            for show in self.shows!{
                let dictionary  = show as! NSDictionary
                let number      = dictionary.object(forKey: "number") as! Int
                
                let selectedShow = dictionary.object(forKey: "name") as? String
                if selectedShow == specialShowName {
                    self.specialShowNumtxt.text = "\(number)"
                }
            }
            self.dropDownSpecial.isHidden = true
        }
        writeToServer()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if specialShowNumtxt.isEditing || percipitaionSP.isEditing || timeDelay.isEditing {
            editingBegan = true
            specialShwViw.frame.origin.y = 181
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if specialShowNumtxt.isEditing || percipitaionSP.isEditing || timeDelay.isEditing {
            editingBegan = false
            specialShwViw.frame.origin.y = 601
        }
        
    }
    
    @IBAction func controlSwitchToggle(_ sender: Any) {
        if  self.specialShwControlSwitch.isOn == false {
            self.specialShwControlSwitch.isOn = true
        } else {
            self.specialShwControlSwitch.isOn = false
        }
        writeToServer()
    }
    
    @IBAction func setPercipitationTimeDelay(_ sender: Any) {
        var value = Int(timeDelay.text!)
        if value != nil{
            if value! > 600{
                value = 600
            }
            CENTRAL_SYSTEM?.writeRegister(register: Int(PERCIPITATION_TIME_DELAY), value: value!)
        }
    }
    
    @IBAction func setpercipitationSP(_ sender: Any) {
        var value = Float(percipitaionSP.text!)
        if value != nil{
            CENTRAL_SYSTEM?.writeRealValue(register: Int(PERCIPITATION_SP), value: value!)
        }
    }
    
    
}
