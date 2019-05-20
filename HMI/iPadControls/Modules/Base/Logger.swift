//=================================== ABOUT ===================================

/*
 *  @FILE:          Logger.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This module handles all consol logs for debugging purposes
 *  @VERSION:       2.0.0
 */


import UIKit

class Logger: NSObject{
    var debugMode = true
    
    var INTRUSION_DEBUG = false
    
    /***************************************************************************
     * Function :  logData
     * Input    :  data message
     * Output   :  none
     * Comment  :  If the debug mode is active, log the messages on terminal
     ***************************************************************************/
    
    func logData(data:String){
        
        if INTRUSION_DEBUG == true{
            print("TIME: \(getTime()) " + data)
        }
        
    }
    
    
    func logData(data:String,flag:Int){
        
        if INTRUSION_DEBUG == true{
            
            if flag == 1{
                print("TIME: \(getTime()) " + data)
            }
            
        }
        
    }
    
    /***************************************************************************
     * Function :  getTime
     * Input    :  none
     * Output   :  System Timestamp
     * Comment  :  Get the current system time
     ***************************************************************************/
    
    func getTime() -> String{
        
        let currentDateTime = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.hour,.minute,.second], from: currentDateTime)
        let hour = components.hour!
        let min = components.minute!
        let sec = components.second!
        
        return "\(hour):\(min):\(sec)"
        
    }
    
}
