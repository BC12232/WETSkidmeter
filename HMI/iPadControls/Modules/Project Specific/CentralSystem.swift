//
//  CentralSystem.swift
//  iPadControls
//
//  Created by Jan Manalo on 12/27/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit
import PlainPing


var SERVER_TIME = ""

public class CentralSystem: NSObject, SimplePingDelegate{
    
    private var modubus:    ObjectiveLibModbus?
    private var timer:      Timer?
    private let operation = OperationQueue()
    
    //State Variables
    
    private var plcConnectionState              = 2
    private var numberOfFailedPlcConnections    = 0
    private var serverConnectionState           = 2
    private var numberOfFailedServerConnections = 0
    
    //Dipendencies
    
    private let localStorage = LocalStorage()
    private let logger       = Logger()
    private let showManager  = ShowManager()
    private let httpComm     = HTTPComm()
    private let lightControl = LightsViewController()
    private let filtrationBWCheck = FiltrationViewController()
    private var fireOnce    = false
    private var failedToPingPLC = false
    private var failedToPingserver = false
    //Data Variables
    
    private var network:Network?
    
    //Lights Global Values
    
    public var DAY_MODE = 0
    
    
    /***************************************************************************
     * Function :  initialize
     * Input    :  none
     * Output   :  none
     * Comment  :  Construct the modbus library class reference with desired PLC
     *             config parameters
     ***************************************************************************/
    
    public func initialize(){
        
        //Initial Setpoints
        saveInitialParameters()
        getNetworkParameters()
        resetUserDefaults()
        
        //Start The Status Check
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(sendPing), userInfo: nil, repeats: true)
        
    }
    
    public func reinitialize() {
        self.timer?.invalidate()
        self.timer = nil
        self.initialize()
    }
    
    /***************************************************************************
     * Function :  getNetworkParameters
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func getNetworkParameters(){
        
        let networks = Network.all() as! [Network]
        
        guard networks.count == 1 else{
            return
        }
        
        network = networks[0]
        
        //Save parameters to user defaults so legacy screens with objective c code will be able to get this info
        
        UserDefaults.standard.set("\(network!.serverIpAddress!)", forKey: "serverIpAddress")
        UserDefaults.standard.set("\(network!.plcIpAddress!)",    forKey: "plcIpAddress")
        UserDefaults.standard.set("\(network!.spmIpAddress!)",    forKey: "spmIpAddress")
        
    }
    
    /***************************************************************************
     * Function :  resetUserDefaults
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func resetUserDefaults(){
        
        UserDefaults.standard.set("0", forKey: "scanningShows")
        UserDefaults.standard.set(-1,  forKey: "toggleLightsAutoHand")
        UserDefaults.standard.set(-1, forKey: "togglePumpsAutoHand")
    }
    
    /***************************************************************************
     * Function :  saveInitialParameters
     * Input    :  none
     * Output   :  none
     * Comment  :  Save the initial DataAcquisition System Prototypes
     *             To The Local Storage
     ***************************************************************************/
    
    public func saveInitialParameters(){
        
        //Save Data Acquisition Prototype To Local Device Storage
        self.localStorage.saveInitialDataAcquisitionSystemParams()
        
    }
    
    
    /***************************************************************************
     * Function :  getServerTime
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func getServerTime(){
            
            self.httpComm.httpGetResponseFromPath(url: SERVER_TIME_PATH){ (reponse) in
                
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
                        
                    }
                    
                }
                
            }
    }
    
    /***************************************************************************
     * Function :  connect
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    public func connect(){
        
        self.logger.logData(data: "CENTRAL SYSTEM: GOING TO ESTABLISH COMMUNICATION WITH PLC")
        
        //Before Connecting to the enclosure, we want to reset all the temporarly parameters
        
        self.disconnect()
        
        //Establish Modbus Connection
        modubus = ObjectiveLibModbus(tcp: network!.plcIpAddress!, port: Int32(PLC_PORT), device: 1)
        
        
        if modubus != nil{
            
            modubus!.connect({
                
                //Established Connection With PLC
                self.logger.logData(data: "CENTRAL SYSTEM: ESTABLISHED CONNECTION WITH PLC")
                
                self.readBits(length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
                    
                    guard success == true else {
                        self.plcConnectionState = CONNECTION_STATE_POOR_CONNECTION
                        UserDefaults.standard.set("poorPLC", forKey: "PLCConnectionStatus")
                        return
                        
                    }
                    self.fireOnce = true
                    self.plcConnectionState = CONNECTION_STATE_CONNECTED
                    
                })
                
            },failure:{ (error) in
                
                
                
            })
            
            self.logger.logData(data: "CENTRAL SYSTEM: ESTABLISHING CONNECTION WITH PLC")
            self.logger.logData(data: "CENTRAL SYSTEM: PLC CONNECTION STATE -> \(plcConnectionState)")
            
        } else {
            plcConnectionState = CONNECTION_STATE_FAILED
        }
        
    }
    
    /***************************************************************************
     * Function :  disconnect
     * Input    :  none
     * Output   :  none
     * Comment  :  Invalidate and disconnect all the timers and connections
     ***************************************************************************/
    
    private func disconnect(){
        
        //Check if modbus connection object is not empty then disconnect it
        guard modubus != nil else { return }
        
        self.modubus!.disconnect()
    }
    
    /***************************************************************************
     * Function :  sendPing
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func sendPing(){
        pingServer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.pingPLC()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    /***************************************************************************
     * Function :  pingPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func pingPLC(){
        
        guard network != nil else { return }
        
        failedToPingPLC = true
        
        PlainPing.ping(network!.plcIpAddress!, withTimeout: 1.0, completionBlock:{ (timeElapsed:Double?, error:Error?) in
            
            self.failedToPingPLC = false
            
            if let latency = timeElapsed {
//                print("PLC pinged successfully")
                self.logger.logData(data:latency.description)
                
                //After pinging the plc, you wanted to make sure that you are actually getting a data. If pinging fails then there's something wrong with the plc itself, else you are just waiting for the plc to give you a data. NOTE: any register number will do.
                
                
                // NOTE: Plain ping can only ping one address at a time. So, when PLC is already connected -- ping the server next or vice versa.
                if !self.fireOnce {
                    self.connect()
                }
                
                UserDefaults.standard.set("PLCConnected", forKey: "PLCConnectionStatus")
                if self.numberOfFailedPlcConnections > 0 {
                    self.numberOfFailedPlcConnections = 0
//                    print("RESETTING FAILED PLC COUNTER TO \(self.numberOfFailedPlcConnections)")
                    self.fireOnce = false
                }
            }
            
            if error != nil {
                self.numberOfFailedPlcConnections += 1
                print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections)")
                
                if self.numberOfFailedPlcConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedPlcConnections < MAX_CONNECTION_FAILED {
                    UserDefaults.standard.set("connectingPLC", forKey: "PLCConnectionStatus")
                    self.plcConnectionState = CONNECTION_STATE_CONNECTING
                    print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections).. RECONNECTING")
                    self.reinitialize()
                } else if self.numberOfFailedPlcConnections >= MAX_CONNECTION_FAILED {
                    self.plcConnectionState = CONNECTION_STATE_FAILED
                    print("PLC CONNECTION FAILED: \(self.numberOfFailedPlcConnections). MAX AMOUNT OF FAIL REACHED")
                    UserDefaults.standard.set("plcFailed", forKey: "PLCConnectionStatus")
                    self.reinitialize()
                }
            }
            
        })
        
        
        if failedToPingPLC {
            self.numberOfFailedPlcConnections += 1
//            print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections)")
            
            if self.numberOfFailedPlcConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedPlcConnections < MAX_CONNECTION_FAILED {
                UserDefaults.standard.set("connectingPLC", forKey: "PLCConnectionStatus")
                self.plcConnectionState = CONNECTION_STATE_CONNECTING
                print("PLC CONNECTION FAILED \(self.numberOfFailedPlcConnections).. RECONNECTING")
                self.reinitialize()
            } else if self.numberOfFailedPlcConnections >= MAX_CONNECTION_FAILED {
                self.plcConnectionState = CONNECTION_STATE_FAILED
                print("PLC CONNECTION FAILED: \(self.numberOfFailedPlcConnections). MAX AMOUNT OF FAIL REACHED")
                UserDefaults.standard.set("plcFailed", forKey: "PLCConnectionStatus")
                self.reinitialize()
                
            }
            
        }
        
        guard self.plcConnectionState == CONNECTION_STATE_CONNECTED else{
            return
        }
        
        getCurrentShowInfo()
        readBackWashRunning()
        
    }
    
    
    /***************************************************************************
     * Function :  Read Back Wash Running Bit
     * Input    :  none
     * Output   :  none
     * Comment  :  Check whether the back wash is running or not. We need to save the value to  Userdefaults. If back wash is running we cannot play a show.
     ***************************************************************************/
    
    private func readBackWashRunning(){
        
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT_1), completion: { (success, bw1Response) in
            
            guard success == true else { return }
            
            let BW1status = Int(truncating: bw1Response![0] as! NSNumber)
            
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT_2), completion: { (success, bw2Response) in
                
                guard success == true else { return }
                
                let BW2status = Int(truncating: bw2Response![0] as! NSNumber)
                
                CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT_3), completion: { (success, bw3Response) in
                    
                    guard success == true else { return }
                    
                    let BW3status = Int(truncating: bw3Response![0] as! NSNumber)
                    
                    if BW1status == 1 || BW2status == 1 ||  BW3status == 1{
                        UserDefaults.standard.set(1, forKey: "backWashRunningStat")
                    } else {
                        UserDefaults.standard.set(0, forKey: "backWashRunningStat")
                    }
                })
            })
            
        })
        
        
         CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(RAIN_SENSOR_STATUS_REGISTER), completion: { (success, response) in
            guard success == true else { return }
            
            let statusOn = Int(truncating: response![0] as! NSNumber)
            
            if statusOn == 1{
                UserDefaults.standard.set(1, forKey: "rainSensor")
            } else {
                UserDefaults.standard.set(0, forKey: "rainSensor")
            }
        })
    }
    
    /***************************************************************************
     * Function :  getCurrentShowInfo
     * Input    :  none
     * Output   :  none
     * Comment  :  Fetches current show info and saves data to user defaults
     ***************************************************************************/
    
    private func getCurrentShowInfo(){
        
        let isShowScannerActive = UserDefaults.standard.object(forKey: "scanningShows") as? String
        
        if isShowScannerActive == "0" {
            
            let showPlayStat = self.showManager.getCurrentAndNextShowInfo()
            
            UserDefaults.standard.set(showPlayStat.currentShowNumber, forKey: "currentShowNumber")
            UserDefaults.standard.set(showPlayStat.deflate, forKey: "deflate")
            UserDefaults.standard.set(showPlayStat.nextShowNumber, forKey: "nextShowNumber")
            UserDefaults.standard.set(showPlayStat.nextShowTime, forKey: "nextShowTime")
            UserDefaults.standard.set(showPlayStat.playMode, forKey: "playMode")
            UserDefaults.standard.set(showPlayStat.playStatus, forKey: "playStatus")
            UserDefaults.standard.set(showPlayStat.showDuration, forKey: "showDuration")
            UserDefaults.standard.set(showPlayStat.currentShowName, forKey: "currentShowName")
            
        } else {
            
            print("Cannot Get Show Details")
            
        }
        
    }
    
    
    
    
    /***************************************************************************
     * Function :  pingServer
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func pingServer(){
        
        guard self.network != nil else{ return }
        
        failedToPingserver = true
        
        PlainPing.ping(self.network!.serverIpAddress!, withTimeout: 1.0, completionBlock:{ (timeElapsed:Double?, error:Error?) in
            
            self.failedToPingserver = false
            
            if let latency = timeElapsed{
//                print("Server pinged succesfully")
                self.logger.logData(data:"CENTRAL SYSTEM: SERVER PINING SUCCESS -> \(latency.description)")
                
                //Same as pinging the plc.. For the server, you wanted to make sure that you are actually getting a data. If pinging fails then there's something wrong with the server itself, else you are just waiting for the server to give you a data. NOTE: any path number will do.
                
                self.httpComm.httpGetResponseFromPath(url: LIGHTS_SERVER_PATH){ (response) in
                    
                    guard response != nil else {
                        self.serverConnectionState = CONNECTION_STATE_POOR_CONNECTION
                        UserDefaults.standard.set("poorServer", forKey: "ServerConnectionStatus")
                        return
                    }
                    
                    self.serverConnectionState = CONNECTION_STATE_CONNECTED
                    
                    UserDefaults.standard.set("serverConnected", forKey: "ServerConnectionStatus")
                    self.getErrorLogFromServer()
                    //self.getServerTime()
                }
                
                
                if self.numberOfFailedServerConnections > 0 {
                    self.numberOfFailedServerConnections = 0
//                    print("RESETTING SERVER FAILED COUNTER TO \(self.numberOfFailedPlcConnections)")
                }
                
            }
            
            if error != nil {
                self.numberOfFailedServerConnections += 1
                print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections)")
                
                if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedServerConnections < MAX_CONNECTION_FAILED {
                    self.serverConnectionState = CONNECTION_STATE_CONNECTING
                    print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections).. RECONNECTING")
                    UserDefaults.standard.set("connectingServer", forKey: "ServerConnectionStatus")
                } else if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAILED {
                    self.serverConnectionState = CONNECTION_STATE_FAILED
                    print("SERVER CONNECTION FAILED: \(self.numberOfFailedServerConnections). MAX AMOUNT OF FAIL REACHED")
                    UserDefaults.standard.set("serverFailed", forKey: "ServerConnectionStatus")
                }
            }
        })
        
        if failedToPingserver {
            self.numberOfFailedServerConnections += 1
//            print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections)")
            
            if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAULTS && self.numberOfFailedServerConnections < MAX_CONNECTION_FAILED {
                self.serverConnectionState = CONNECTION_STATE_CONNECTING
                print("SERVER CONNECTION FAILED \(self.numberOfFailedServerConnections).. RECONNECTING")
                UserDefaults.standard.set("connectingServer", forKey: "ServerConnectionStatus")
            } else if self.numberOfFailedServerConnections >= MAX_CONNECTION_FAILED {
                self.serverConnectionState = CONNECTION_STATE_FAILED
                print("SERVER CONNECTION FAILED: \(self.numberOfFailedServerConnections). MAX AMOUNT OF FAIL REACHED")
                UserDefaults.standard.set("serverFailed", forKey: "ServerConnectionStatus")
            }
        }
    }
    
    /***************************************************************************
     * Function :  getErrorLogFromServer
     * Input    :  none
     * Output   :  none
     * Comment  :  Fetches certain flags from server and saves them in user
     *             defaults
     ***************************************************************************/
    
    private func getErrorLogFromServer(){
        
        self.httpComm.httpGetResponseFromPath(url: ERROR_LOG_FTP_PATH){ (response) in
            
            let responseArray = response as? NSArray
            
            if responseArray != nil && (responseArray?.count)! > 0{
                
                let responseDictionary = responseArray![0] as? NSDictionary
                
                if responseDictionary != nil{
                    
                    //                    let dayMode   = responseDictionary?.object(forKey: "dayMode")               as? NSNumber
                    //                    let ratMode   = responseDictionary?.object(forKey: "spm_RAT_Mode")          as? NSNumber
                    //                    let noSpmComm = responseDictionary?.object(forKey: "SPM_Modbus_Connection") as? NSNumber
                    
                    if let noSpmComm = responseDictionary?.object(forKey: "SPM_Modbus_Connection") as? NSNumber{
                        UserDefaults.standard.set(Int(truncating: noSpmComm), forKey:"noSpmComm")
                    }
                    
                    if let ratMode = responseDictionary?.object(forKey: "spm_RAT_Mode") as? NSNumber{
                        UserDefaults.standard.set(Int(truncating: ratMode), forKey: "ratMode")
                    }
                    
                    //                    if let dayMode   = responseDictionary?.object(forKey: "dayMode") as? NSNumber{
                    //                        UserDefaults.standard.set(Int(truncating: dayMode), forKey: "dayMode")
                    //                        self.DAY_MODE = dayMode as! Int
                    //
                    //                    }
                }
                
            }else{
                
                //TODO: Show Server Connection Error
                
            }
        }
    }
    
    
    
    
    
    
    /***************************************************************************
     * Function :  getConnectivityStat
     * Input    :  none
     * Output   :  plcConnectionState:Int , serverConnectionState:Int
     * Comment  :
     ***************************************************************************/
    
    public func getConnectivityStat()->(Int,Int){
        
        return (plcConnectionState,serverConnectionState)
        
    }
    
    /***************************************************************************
     * Function :  readRealRegister
     * Input    :  startingRegister, length
     * Output   :  State: (Bool) ,Response: (String)
     * Comment  :  Read real value type registers from PLC
     ***************************************************************************/
    
    func readRealRegister(register:Int ,length:Int, completion:@escaping (Bool,String)->()){
        
        //We want to make sure the PLC connection is established
        
        guard self.plcConnectionState == CONNECTION_STATE_CONNECTED else{
            return
        }
        
        modubus!.readRegisters(from: Int32(register), count: Int32(length), success:{ (responseArray) in
            
            guard responseArray != nil else{
                
                //Send completion handler to the controller that called this function
                completion(false,"")
                
                //Log the error for debugging purposes on the terminal
                self.logger.logData(data: "CENRAL SYSTEM: READ REGISTERS -> Empty Array While Reading \(register) REGISTER")
                
                return
                
            }
            
            //Then we want to normalize the data if necessary
            //Them we want to show it on the corresponding screens
            
            let dataWithRealValue = self.modubus!.convertArray(toReal: responseArray)
            
            if dataWithRealValue.description == PLC_REAL_VALUE_ONE{
                completion(true,"0")
            }else{
                completion(true,"\(dataWithRealValue)")
            }
            
        },failure:{ (error) in
            
            //Send completion handler to the controller that called this function
            completion(false,"")
            
            //Log the error for debugging purposes on the terminal
            self.logger.logData(data: "CENTRAL SYSTEM: READ REGISTERS ERROR -> \(String(describing: error))")
            
        })
    }
    
    /***************************************************************************
     * Function :  readBits
     * Input    :  length, startingRegister
     * Output   :  Bool,[AnyObject]
     * Comment  :  Read EBool Bits From PLC and return the Bit Array which will only
     *             containt 1 element if we read single bits
     ***************************************************************************/
    
    func readBits(length:Int32, startingRegister:Int32, completion:@escaping (Bool,[AnyObject]?)->()){
        
        modubus?.readBits(from: startingRegister, count: length,success:{ (responseObject) in
            
            guard responseObject != nil else{
                
                //Send completion handler to the controller that called this function
                completion(false,nil)
                
                //Log the error for debugging purposes on the terminal
                self.logger.logData(data: "CENTRAL SYSTEM: Empty Array While Reading \(startingRegister) REGISTER")
                
                return
                
            }
            
            //On Success, first we want to make sure we have the total number of response inside the array
            //We can check that by comparing the count of the objects inside the returned array with the length specified by the program
            
            if responseObject!.count == Int(length){
                
                completion(true, responseObject as [AnyObject]?)
                
            }
            
        },failure:{ (error) in
            
            //Send completion handler to the controller that called this function
            completion(false,nil)
            
            //Log the error for debugging purposes on the terminal
            self.logger.logData(data: "CENTRAL SYSTEM: READ BITS ERROR -> \(String(describing: error))")
            
        })
    }
    
    /***************************************************************************
     * Function :  readRegister
     * Input    :  length , starting register address
     * Output   :  completion block with state and response
     * Comment  :
     ***************************************************************************/
    
    func readRegister(length:Int32, startingRegister:Int32, completion:@escaping (Bool,[AnyObject]?)->()){
        
        modubus?.readRegisters(from: startingRegister, count: length, success: { (responseObject) in
            
            guard responseObject != nil else{
                
                //Send completion handler to the controller that called this function
                completion(false,nil)
                
                //Log the error for debugging purposes on the terminal
                self.logger.logData(data: "CENTRAL SYSTEM: Empty Array While Reading \(startingRegister) REGISTER")
                
                return
                
            }
            
            //On Success, first we want to make sure we have the total number of response inside the array
            //We can check that by comparing the count of the objects inside the returned array with the length specified by the program
            
            if responseObject!.count == Int(length){
                
                completion(true, responseObject as [AnyObject]?)
                
            }
            
        },failure:{ (error) in
            
            //Send completion handler to the controller that called this function
            completion(false,nil)
            
            //Log the error for debugging purposes on the terminal
            self.logger.logData(data: "CENTRAL SYSTEM: READ BITS ERROR -> \(String(describing: error))")
            
        })
    }
    
    /***************************************************************************
     * Function :  writeRealValue
     * Input    :  real value address: Int, value: Float
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func writeRealValue(register:Int, value:Float){
        
        modubus?.writeReal(Float32(value), Int32(register))
        
    }
    
    /***************************************************************************
     * Function :  writeRegister
     * Input    :  register address: Int, value: Int
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    func writeRegister(register:Int, value:Int){
        
        modubus?.writeRegister(Int32(register), to: Int32(value), success:{
            
        },failure:{ (error) in
            
            self.logger.logData(data: "CENTRAL SYSTEM: FAILED TO WRITE TO PLC REGISTER")
            
        })
    }
    
    
    /***************************************************************************
     * Function :  writeRegister
     * Input    :  none
     * Output   :  none
     * Comment  :  Writes Single Register To PLC With Completion Block
     *
     *
     ***************************************************************************/
    
    func writeRegister(register:Int, value:Int,completion:@escaping (_ success:Bool)->()){
        
        modubus?.writeRegister(Int32(register), to: Int32(value), success:{
            
            completion(true)
            
        },failure:{ (error) in
            
            completion(false)
            
        })
    }
    
    
    
    /***************************************************************************
     * Function :  writeBit
     * Input    :  bit: Int, value: Int (1,0)
     * Output   :  none
     * Comment  :  Write Bit To PLC
     ***************************************************************************/
    
    func writeBit(bit:Int, value:Int){
        
        var bitVal = false
        
        if value == 1{
            bitVal = true
        }else if value == 0{
            bitVal = false
        }
        
        modubus?.writeBit(Int32(bit), to: bitVal, success:{
            
        },failure:{ (error) in
            
        })
        
    }
}
