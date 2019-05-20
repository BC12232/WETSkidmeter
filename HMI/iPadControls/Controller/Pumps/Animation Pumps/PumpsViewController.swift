//
//  PumpsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/27/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class PumpsViewController: UIViewController{

    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var quadABtn: UIButton!
    @IBOutlet weak var quadBBtn: UIButton!
    @IBOutlet weak var quadCBtn: UIButton!
    @IBOutlet weak var quadDBtn: UIButton!
    
    @IBOutlet weak var settingsBtn: UIButton!
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private var centralSystem = CentralSystem()
    private let helper = Helper()
    
    //MARK: - Data Structures
    
    private var langData = Dictionary<String, String>()
    private var pumpModel:Pump?
    private var iPadNumber = 0
    private var selectedPumpNumber = 0

    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    }
    
    //MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool){
        
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
         quadABtn.isUserInteractionEnabled = false
         quadBBtn.isUserInteractionEnabled = false
         quadCBtn.isUserInteractionEnabled = false
         quadDBtn.isUserInteractionEnabled = false
        
        //Show Show Stopper Indicators
        addShowStoppers()
        
        //Get Pump Parameters From Local Storage
        getPumpParameters()
        
     
        
        //Configure Pump Screen Text Content Based On Device Language
        configureScreenTextContent()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        quadLock?.setBackgroundImage(#imageLiteral(resourceName: "lockRed"), for: .normal)
        quadLock?.isUserInteractionEnabled = true
        
    }
    
    //MARK: - Check Status Of The Connections To Server and PLC
    
    @objc func checkSystemStat(){
        
        let (plcConnection,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false

            //Show pump faults
            getAnimationPumpFaults()
            
            logger.logData(data: "PUMP: CONNECTION SUCCESS")
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
    
    //MARK: - Get Wind Screen Parameters
    
    private func getPumpParameters(){
        
        //Fetch Pump Settings From Local Core Data Storage
        let pump = Pump.all() as! [Pump]
        
        self.logger.logData(data: "PUMP - MODEL COUNT -> \(pump.count)")
        
        guard pump.count != 0 else{ return }
        
        pumpModel = pump[0] as Pump
        
    }
    
    
    //MARK: - Configure Screen Text Content Based On Device Language
    
    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: PUMPS_LANGUAGE_DATA_PARAM)
        
        guard pumpModel != nil else {
            
            self.logger.logData(data: "PUMPS: PUMP MODEL EMPTY")
            
            //If the pump model is empty, put default parameters to avoid system crash
            self.navigationItem.title = langData["PUMPS"]!
            self.noConnectionErrorLbl.text = "CHECK SETTINGS"
            
            return
            
        }
        
        //Get iPad Number Specified On User Side
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            self.iPadNumber = 1
        }else{
            self.iPadNumber = ipadNum!
        }
        
        self.setDefaultSelectedPumpNumber()
        
        self.navigationItem.title = langData[pumpModel!.screenName!]!
        self.noConnectionErrorLbl.text = pumpModel!.outOfRangeMessage!
        
    }

    //MARK: - By Default Set the current selected pump to 0
    
    private func setDefaultSelectedPumpNumber(){
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        CENTRAL_SYSTEM!.writeRegister(register: iPadNumberRegister.register, value: 0)
        
        
    }
    
    
    
 
    //MARK: - Get Animation Pump Faults
    
    func getAnimationPumpFaults(){
        let offset = 14
        
        for i in 0..<6 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PUMP_FAULT_REGISTER + (i * offset)), completion:{ (success, response) in
                
                print("This is the register \(Int32(PUMP_FAULT_REGISTER + (i * offset)))")
                guard response != nil else { return }
                
                
                let pumpButton = self.view.viewWithTag(301 + i) as? UIButton
                print("This is the pump button \(301 + i )")
                
                let faultStat = Int(truncating: response![0] as! NSNumber)
                
                
                faultStat == 1 ? (pumpButton?.setTitleColor(RED_COLOR, for: .normal)) : (pumpButton?.setTitleColor(DEFAULT_GRAY, for: .normal))
                
                
            })
        }
        for i in 6..<18 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PUMP_FAULT_REGISTER + (i * offset)), completion:{ (success, response) in
                
                print("This is the register \(Int32(PUMP_FAULT_REGISTER + (i * offset)))")
                guard response != nil else { return }
                
                
                let pumpButton = self.view.viewWithTag(395 + i) as? UIButton
                print("This is the pump button \(395 + i )")
                
                let faultStat = Int(truncating: response![0] as! NSNumber)
                
                
                faultStat == 1 ? (pumpButton?.setTitleColor(RED_COLOR, for: .normal)) : (pumpButton?.setTitleColor(DEFAULT_GRAY, for: .normal))
                
                
            })
        }
    }
    
    @IBAction func setAllPumpsAutoButtonPressed(_ sender: UIButton) {
        CENTRAL_SYSTEM?.writeRegister(register: PUMPS_AUTO_HAND_PLC_REGISTER.register, value: 1)
    }
    

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       self.addAlertAction(button: sender)
    }
    
    //MARK: - Redirect To Pump Details
    
    @IBAction func redirectToPumpDetails(_ sender: UIButton){

            //PUMP TYPE: ANIMATION (VFD)
            let storyBoard : UIStoryboard = UIStoryboard(name: "pumps", bundle:nil)
            
            let pumpDetail = storyBoard.instantiateViewController(withIdentifier: "pumpDetail") as! PumpDetailViewController
            pumpDetail.pumpNumber = sender.tag
            self.navigationController?.pushViewController(pumpDetail, animated: true)

    }
    
    @IBAction func setAllPumpAuto(_ sender: UIButton) {
        
        CENTRAL_SYSTEM?.writeRegister(register: SET_ALL_PUMPS_AUTO, value: 1)
        print("I am writing 1")
    }
    
    @IBAction func popUpQuadrantsBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "pumps", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "quadpop") as! QuadrantsPopUpViewController
        popoverContent.quadrantNumber = sender.tag
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 450, height: 300)
        if popoverContent.quadrantNumber == 1{
          popover?.sourceRect = CGRect(x: 0, y: -100, width: 450, height: 300)
        }
        if popoverContent.quadrantNumber == 4{
             popover?.sourceRect = CGRect(x: 40, y: -450, width: 450, height: 300)
        }
        popover?.sourceView = sender
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func unlockQuadControl(_ sender: UIButton) {
         self.addQuadAlert(button: sender)
    }
    
    @IBAction func showSettingsIconBtnPressed(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
    
}
