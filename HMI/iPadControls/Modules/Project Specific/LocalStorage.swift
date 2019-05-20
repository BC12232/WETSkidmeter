//=================================== ABOUT ===================================

/*
 *  @FILE:          LocalStorage.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module handles all local storage related operations
 *  @VERSION:       2.0.0
 */

import UIKit

public class LocalStorage{
    
    let logger = Logger()
    
    /***************************************************************************
     * Function :  saveInitialDataAcquisitinSystemParams
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    public func saveInitialDataAcquisitionSystemParams(){
        
        //We want to make su
        let saved = UserDefaults.standard.value(forKey:"savedDefaults") as? String
        
        //We want to make sure the defaultt data gets saved only once
        guard saved == nil else{
            
            self.logger.logData(data:"ALREADY SAVED INITIAL USER DATA")
            return
            
        }
        
        //Save All Default Parameters For Each Module
        saveDefaultNetworkData()
        saveDefaultWindParameters()
        saveDefaultPumpDetails()
        saveDefaultPumpScreenParams()
        
        //This parameter is set to 1 to make sure default settings will not get saved over and over
        //that will cause the custom user defined settings to be overriten
        UserDefaults.standard.set("1", forKey: "savedDefaults")
        
    }
    
    /***************************************************************************
     * Function :  saveDefaultNetworkData
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func saveDefaultNetworkData(){
    
        let network             = Network.create() as! Network
        network.plcIpAddress    = PLC_IP_ADDRESS
        network.serverIpAddress = SERVER_IP_ADDRESS
        network.spmIpAddress    = SPM_IP_ADDRESS
        _ = network.save()
        
    }
    
    //MARK: - Setup Default Wind Sensor Screen Parameters
    
    private func saveDefaultWindParameters(){
        
        UserDefaults.standard.set(15, forKey: "windBitsOnDelay")
        UserDefaults.standard.set(15, forKey: "windBitsOffDelay")
        UserDefaults.standard.set(15, forKey: "windAbortDelay")
        
        let wind = Wind.create() as! Wind
        
        wind.screenName = "WIND"
        wind.metric = false
        wind.numberOfWindSensors = 4
        wind.outOfRangeMessage = "CHECK SETTIGNS"
        wind.enableSetPoints = true
        
        let saved = wind.save()
        
        if saved == false{
            
            print("Failed To Save Default Wind Configuration Parameters")
            
        }
        
    }
    
    //MARK: - Setup Default Pump Parameters
    
    private func saveDefaultPumpScreenParams(){
        
        let pumpScreen               = Pump.create() as! Pump
        pumpScreen.maxPumpFrequency  = 60
        pumpScreen.outOfRangeMessage = "CHECK SETTIGNS"
        pumpScreen.screenName        = "PUMPS"
        
        let saved = pumpScreen.save()
        
        if saved == false{
            
            print("Failed To Save Default Pump Screen Configuration Parameters")
            
        }
    }
    
    //MARK: - Setup Defualt Pump Details
    
    private func saveDefaultPumpDetails(){
        
        let pumpDetail = PumpDetail.create() as! PumpDetail
        pumpDetail.pumpNumber       = 1
        pumpDetail.currentMax       = 55
        pumpDetail.temperatureMax   = 60
        pumpDetail.temperatureMid   = 50
        pumpDetail.voltageMax       = 180
        pumpDetail.voltageMin       = 80
        pumpDetail.maxFrequency     = 50
        
        let saved = pumpDetail.save()
        
        if saved == false{
            
            print("Failed To Save Default Pump Details Configuration Parameters")
            
        }
        
    }
}
