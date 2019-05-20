//
//  HomeSettingsViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/30/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

class HomeSettingsViewController: UIViewController{
    
    @IBOutlet weak var serverIpAddress: UITextField!
    @IBOutlet weak var plcIpAddress: UITextField!
    @IBOutlet weak var spmIpAddress: UITextField!
    
    @IBOutlet weak var faultBtn: UIButton!
    @IBOutlet weak var warningBtn: UIButton!
    var networkSettings:Network?
    private var timer:      Timer?
    
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed only when controller resources
     *             get loaded
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    }
    
    /***************************************************************************
     * Function :  viewDidAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewDidAppear(_ animated: Bool){
        loadCurrentSettings()
        
    }
    
    
    /***************************************************************************
     * Function :  loadCurrentSettings
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func loadCurrentSettings(){
    
        guard let networks = Network.all() as? [Network] else { return }
        
        guard networks.count != 0 else { return }
        
        networkSettings = networks[0]
        
        guard let networkSettings = networkSettings else { return }
        
        serverIpAddress.text = "\(networkSettings.serverIpAddress!)"
        plcIpAddress.text = "\(networkSettings.plcIpAddress!)"
        spmIpAddress.text = "\(networkSettings.spmIpAddress!)"
        
    }
    
    /***************************************************************************
     * Function :  saveSettings
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @IBAction func saveSettings(_ sender: Any){
        guard let networkSettings = networkSettings else { return }
        
        if serverIpAddress.text == ""{
            networkSettings.serverIpAddress = SERVER_IP_ADDRESS
        }else{
            networkSettings.serverIpAddress = serverIpAddress.text
        }
        
        if plcIpAddress.text == ""{
            networkSettings.plcIpAddress = PLC_IP_ADDRESS
        }else{
            networkSettings.plcIpAddress = plcIpAddress.text
        }
        
        if spmIpAddress.text == ""{
            networkSettings.spmIpAddress = SPM_IP_ADDRESS
        }else{
            networkSettings.spmIpAddress = spmIpAddress.text
        }
        
        _ = networkSettings.save()
        
        UserDefaults.standard.set("\(String(describing: networkSettings.serverIpAddress))", forKey: "serverIpAddress")
        UserDefaults.standard.set("\(String(describing: networkSettings.plcIpAddress))"   , forKey: "plcIpAddress")
        UserDefaults.standard.set("\(String(describing: networkSettings.spmIpAddress))"   , forKey: "spmIpAddress")

    }

    @IBAction func faultResetBtnPushed(_ sender: Any) {
      
        CENTRAL_SYSTEM?.writeBit(bit: FAULT_RESET_REGISTER, value: 1)
        self.faultBtn.isUserInteractionEnabled = false
        self.faultBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{
            CENTRAL_SYSTEM?.writeBit(bit: FAULT_RESET_REGISTER, value: 0)
            self.faultBtn.isUserInteractionEnabled = true
            self.faultBtn.isEnabled = true
        })
    }
    
    @IBAction func warningResetBtnPushed(_ sender: Any) {
        CENTRAL_SYSTEM?.writeBit(bit: WARNING_RESET_REGISTER, value: 1)
        self.warningBtn.isUserInteractionEnabled = false
        self.warningBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute:{
            CENTRAL_SYSTEM?.writeBit(bit: WARNING_RESET_REGISTER, value: 0)
            self.warningBtn.isUserInteractionEnabled = true
            self.warningBtn.isEnabled = true
        })
    }
    
    @IBAction func designateFillerShowPopover(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "designateShows") as! DesignateShowsViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 600, height: 500)
        popover?.sourceRect = CGRect(x: -695, y: 0, width: 600, height: 500)
        popover?.sourceView = sender
        popoverContent.fillerSpecialNum = sender.tag
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
}
