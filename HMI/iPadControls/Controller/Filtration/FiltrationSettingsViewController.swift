//
//  FiltrationSettingsViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 2/28/17.
//  Copyright © 2017 WET. All rights reserved.
//

import UIKit

class FiltrationSettingsViewController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var bwDuration: UITextField!
    @IBOutlet weak var valveOpenClose: UITextField!
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()

    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(false)
    }
    
    
    //MARK: - View Did Appear
    
    override func viewDidAppear(_ animated: Bool){
        
        loadCurrentBWDuration()
        constructSaveButton()
        
    }
    
    //MARK: - Construct Save bar button item
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }

    //MARK: - Load Current BW Duration
    
    private func loadCurrentBWDuration(){
        let bwDuration = UserDefaults.standard.object(forKey: "bwDuration") as? Int
        let valveOpenCloseTime = UserDefaults.standard.object(forKey: "valveOpenCloseTime") as? Int
        
        
        if valveOpenCloseTime == nil{
        
            UserDefaults.standard.set(32, forKey: "valveOpenCloseTime")
            valveOpenClose.text = "32"

        }else{
        
            valveOpenClose.text = "\(valveOpenCloseTime!)"
            
        }
        
        if bwDuration == nil{
        
            UserDefaults.standard.set(3, forKey: "bwDuration")
            self.bwDuration.text = "3"
            
        }else{
            
            self.bwDuration.text = "\(bwDuration!)"
        
        }
        
    }
    
    
    //MARK: - Save  Setpoints
    
    @objc private func saveSetpoints(){
        guard let backwashDurationText = bwDuration.text,
              let backWashValue = Int(backwashDurationText),
              let valveOpenCloseText = valveOpenClose.text,
              let valveOpenCloseValue = Int(valveOpenCloseText) else { return }
        
        UserDefaults.standard.set(backWashValue, forKey: "bwDuration")
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_BW_DURATION_REGISTER, value: backWashValue)
        

        UserDefaults.standard.set(valveOpenCloseValue, forKey: "valveOpenCloseTime")
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT, value: valveOpenCloseValue)
        
        self.setBackWashDuration()
    }

    
    /***************************************************************************
     * Function :  Set Back Wash Duration
     * Input    :  none
     * Output   :  none
     * Comment  :  How long the back wash will run. Can be set on the hidden screen.
     We are fetching backwash duration from local storage and we have to send it to PLC
     ***************************************************************************/
    
    private func setBackWashDuration(){
        
        //We are fetching backwash duration from local storage and we have to send it to PLC
        let bwDuration = UserDefaults.standard.object(forKey: "bwDuration") as? Int
        print("BW DURATION : \(bwDuration!)")
        
        CENTRAL_SYSTEM?.writeRegister(register: FILTRATION_BW_DURATION_REGISTER, value: bwDuration!)
        
    }
    
    

}
