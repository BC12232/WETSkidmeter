//=================================== ABOUT ===================================

/*
 *  @FILE:          SettingsViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module provides the client with certain general settings
 *  @VERSION:       2.0.0
 */

/***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Settings screen configuration parameters located in specs.swift file
 *     should be modified
 ***************************************************************************/

import UIKit
import NMSSH

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var ipad1button:          UIButton!
    @IBOutlet weak var ipad2button:          UIButton!
    @IBOutlet weak var viewForWebView:       UIView!
    @IBOutlet weak var ipadDesignatedAs:     UILabel!
    @IBOutlet weak var ipadDateLbl:          UILabel!
    @IBOutlet weak var syncTimeStateLbl:     UILabel!

    let helper      = Helper()
    var langData    = Dictionary<String, String>()
    var httpManager = HTTPComm()
    var centralsys  = CentralSystem()
    var session: NMSSHSession!
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed only when controller resources
     *             get loaded
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        self.configureScreenTextContent()
        
    }
    
    /***************************************************************************
     * Function :  viewDidAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewDidAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        
        //Get Version Number
        self.checkForAppUpdates()
        
        //Get Current iPad Number That Was Previously Selected
        self.getCurrentIpadNumber()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(ACTHomeViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the network connection for all system components
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        
        getServerTime()
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view disappears
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        NotificationCenter.default.removeObserver(self)
        
        ipad1button          = nil
        ipad2button          = nil
        viewForWebView       = nil
        ipadDesignatedAs     = nil
        langData.removeAll(keepingCapacity: false)
        
    }
    
    /***************************************************************************
     * Function :  chooseNumber1
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func chooseNumber1(sender: AnyObject){
        
        self.highlighIpadNumber(button: ipad1button, number: 1)
        self.dehilightIpadNumber(button: ipad2button)
        
    }
    
    /***************************************************************************
     * Function :  chooseNumber2
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func chooseNumber2(sender: AnyObject){
        
        self.highlighIpadNumber(button: ipad2button, number: 2)
        self.dehilightIpadNumber(button: ipad1button)
        
    }
    
    /***************************************************************************
     * Function :  highlighIpadNumber
     * Input    :  none
     * Output   :  none
     * Comment  :  Helper Function To Highlight The Selected iPad Button and
     *             Change the Selected Device Number In The Device non volatile
     *             memeory
     ***************************************************************************/
    
    private func highlighIpadNumber(button:UIButton, number:Int){
        
        button.layer.cornerRadius = 60
        button.layer.borderWidth  = 3.0
        button.layer.borderColor  = HELP_SCREEN_GRAY.cgColor
        
        //We want to save the highlighted iPad number to iPad's Defaults Storage
        UserDefaults.standard.set(number, forKey: IPAD_NUMBER_USER_DEFAULTS_NAME)
        
    }
    
    /***************************************************************************
     * Function :  dehilightIpadNumber
     * Input    :  targeted UI button
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func dehilightIpadNumber(button:UIButton){
        
        button.layer.borderWidth = 0.0
        
    }
    
    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :  Configure Screen Text Content Based On Device Language
     ***************************************************************************/
    
    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: "help")
        ipadDesignatedAs.text = langData["THIS IPAD IS DESIGNATED AS"]!
        ipad1button.setTitle(langData["iPad 1"]!, for: .normal)
        ipad2button.setTitle(langData["iPad 2"]!, for: .normal)
        self.navigationItem.title = "SETTINGS"
        
    }
    
    /***************************************************************************
     * Function :  getCurrentIpadNumber
     * Input    :  none
     * Output   :  none
     * Comment  :  Get The Current iPad Number
     ***************************************************************************/
    
    private func getCurrentIpadNumber(){
        
        let iPadNumber = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        //We wnat to make sure the iPad number parameter exists in the local defaults storage
        
        guard iPadNumber != nil else{
            return
        }
        
        if iPadNumber == 1{
            
            self.highlighIpadNumber(button: ipad1button, number: 1)
            self.dehilightIpadNumber(button: ipad2button)
            
        }else{
            
            self.highlighIpadNumber(button: ipad2button, number: 2)
            self.dehilightIpadNumber(button: ipad1button)
            
        }
        
    }
    
    /***************************************************************************
     * Function :  checkForAppUpdates
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func checkForAppUpdates(){
        
        let (currentVersion,upadatedVersion) = self.helper.checkForAppUpdates()
        
        if currentVersion < upadatedVersion{
            
            let frame = CGRect(x: 0, y: 0, width: 190, height: 190)
            let cameraView = UIWebView(frame: frame)
            cameraView.scrollView.isScrollEnabled = false
            cameraView.scrollView.bounces = false
            cameraView.scrollView.contentInset.top = -40
            
            let serialNumber = self.helper.getSerialNumber()
            let url = NSURL(string: "\(CONTROLS_APP_UPDATE_URL)\(serialNumber)")
            let requestUrl = NSURLRequest(url: url! as URL)
            self.viewForWebView.addSubview(cameraView)
            cameraView.loadRequest(requestUrl as URLRequest)
            
        }
        
    }
    
    
    /***************************************************************************
     * Function :  syncServerTimer
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func syncServerTimer(_ sender: Any){
        syncTimeToServer()

        
        self.httpManager.httpGetResponseFromPath(url:RESET_TIME_LAST_COMMAND){ (response) in
            
            print("SUCCESSS : \(String(describing: response))")
            
        }
        centralsys.reinitialize()
    }
    
    private func syncTimeToPLC() {
        NotificationCenter.default.removeObserver(self)
        self.syncTimeStateLbl.text = "SYNCING SERVER TIME..."
        self.syncTimeStateLbl.textColor = DEFAULT_GRAY
        
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
        
        CENTRAL_SYSTEM?.writeRegister(register: SYSTEM_TIME_SECOND_PLC_ADDR, value: components.second!, completion: { (success) in
            if success == true{
                  print("success seconds")
                CENTRAL_SYSTEM?.writeRegister(register: SYSTEM_TIME_HOUR_MINUTE, value: Int("\((components.hour! * 100)+components.minute!)")!, completion: { (success) in
                    if success == true{
                        print("success hour")
                        CENTRAL_SYSTEM?.writeRegister(register: SYSTEM_TIME_DAY_MONTH_PLC_ADDR, value: Int("\((components.month! * 100)+components.day!)")!, completion: { (success) in
                            if success == true{
                                  print("success month")
                                CENTRAL_SYSTEM?.writeRegister(register: SYSTEM_TIME_YEAR_PLC_ADDR, value: components.year!, completion: { (success) in
                                    if success == true{
                                          print("success year")
                                        //Trigger Time Sync
                                        CENTRAL_SYSTEM?.writeRegister(register: SYSTEM_TIME_TRIGGER_PLC_ADDR, value: 1)
                                        let when = DispatchTime.now() + 1
                                        
                                        DispatchQueue.main.asyncAfter(deadline: when){
                                            CENTRAL_SYSTEM?.writeRegister(register: SYSTEM_TIME_TRIGGER_PLC_ADDR, value: 0)
                                        }
                                        
                                        self.syncTimeStateLbl.isHidden = false
                                        self.syncTimeStateLbl.text = "SERVER TIME SYNCHED WITH IPAD"
                                        self.syncTimeStateLbl.textColor = GREEN_COLOR
                                        
                                    }else{
                                        
                                        self.setTimeSyncFailure()
                                    }
                                })
                            }else{
                                
                                self.setTimeSyncFailure()
                                
                            }
                        })
                    }else{
                        
                        self.setTimeSyncFailure()
                        
                    }
                })
            }else{
                
                self.setTimeSyncFailure()
                
            }
        })
        
    }
    
    
    func syncTimeToServer(){
        
        self.syncTimeStateLbl.text = "SYNCING SERVER TIME..."
        self.syncTimeStateLbl.textColor = DEFAULT_GRAY
        
        //On the background global thread, execute the sync time process
        DispatchQueue.global(qos: .background).async{
            
            self.session = NMSSHSession.connect(toHost: "\(SERVER_IP_ADDRESS):22", withUsername: "root")
            
            if self.session.isConnected{
                
                self.session.authenticate(byPassword: "A3139gg1121")
                
                if self.session.isAuthorized{
                    
                    
                    let currentDate          = NSDate()
                    let dateFormatter        = DateFormatter()
                    dateFormatter.dateFormat = "MMddHHmmYYYY.ss"
                    let localDateTimeString  = dateFormatter.string(from: currentDate as Date)
                    
                    
                    self.session.channel.execute("date \(localDateTimeString)", error: nil)
                    self.session.channel.execute("exit", error: nil)
                    self.self.session.disconnect()
                    
                    //Check if SSH Session is established. If it is, disconnect.
                    
                    if self.session.isConnected{
                        self.session.disconnect()
                    }
                    
                    DispatchQueue.main.async{
                        
                        self.syncTimeStateLbl.text = "SERVER TIME SYNCED"
                        self.syncTimeStateLbl.textColor = GREEN_COLOR
                        
                    }
                }
            }
        }
    }
    
    /***************************************************************************
     * Function :  setTimeSyncFailure
     * Input    :  none
     * Output   :  none
     * Comment  :  Shows time sync failure indicator and stops the timer
     *
     *
     *
     ***************************************************************************/
    
    private func setTimeSyncFailure(){
        syncTimeStateLbl.isHidden = false
        syncTimeStateLbl.text = "SERVER TIME SYNCHED FAILED"
        syncTimeStateLbl.textColor = RED_COLOR
        
    }
    
    
    /***************************************************************************
     * Function :  getServerTime
     * Input    :  none
     * Output   :  none
     * Comment  :  Gets the system date and time and formats it to our desired
     *             timestamp
     ***************************************************************************/
    
    @objc func getServerTime(){
        
        self.httpManager.httpGetResponseFromPath(url: SERVER_TIME_PATH){ (reponse) in
            
            if reponse != nil{
                
                if let stringResponse = reponse as? String {
                    let dateFormatter = DateFormatter()
                    let tempLocale = dateFormatter.locale // save locale temporarily
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                    let date = dateFormatter.date(from: stringResponse)
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    dateFormatter.locale = tempLocale // reset the locale
                    
                    if let date = date {
                        let dateString = dateFormatter.string(from: date)
                        SERVER_TIME = dateString
                    } else {
                        SERVER_TIME = reponse as! String
                        
                    }
                    self.ipadDateLbl.text = SERVER_TIME
                    
                }
                
            }
            
        }
    }
    
}

