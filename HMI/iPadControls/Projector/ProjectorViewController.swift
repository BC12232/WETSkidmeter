//
//  ProjectorViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/28/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

struct PROJECTOR_STATS{
    var connectionStat = ""
    var powerStat = ""
    var shutterStat = ""
    var temp_intake = 0
    var temp_mainBoard = 0
    var temp_psu_heat_sink = 0
    var warningMsg = ""
    var projName = ""
}

class ProjectorViewController: UIViewController {
    
    @IBOutlet weak var prj212Btn: UIButton!
    @IBOutlet weak var prj211Btn: UIButton!
    @IBOutlet weak var prj210Btn: UIButton!
    @IBOutlet weak var prj209Btn: UIButton!
    @IBOutlet weak var prj208Btn: UIButton!
    @IBOutlet weak var prj207Btn: UIButton!
    @IBOutlet weak var prj206Btn: UIButton!
    @IBOutlet weak var prj204Btn: UIButton!
    @IBOutlet weak var prj205Btn: UIButton!
    @IBOutlet weak var prj203Btn: UIButton!
    @IBOutlet weak var prj202Btn: UIButton!
    @IBOutlet weak var prj201Btn: UIButton!
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrLbl: UILabel!
    private var httpComm = HTTPComm()
    private let logger = Logger()
    
    var prj201Stats = PROJECTOR_STATS()
    var prj202Stats = PROJECTOR_STATS()
    var prj203Stats = PROJECTOR_STATS()
    var prj204Stats = PROJECTOR_STATS()
    var prj205Stats = PROJECTOR_STATS()
    var prj206Stats = PROJECTOR_STATS()
    var prj207Stats = PROJECTOR_STATS()
    var prj208Stats = PROJECTOR_STATS()
    var prj209Stats = PROJECTOR_STATS()
    var prj210Stats = PROJECTOR_STATS()
    var prj211Stats = PROJECTOR_STATS()
    var prj212Stats = PROJECTOR_STATS()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         addShowStoppers()
         getProjectorStatus()
         NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    @objc func checkSystemStat(){
        
        let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
//            getProjectorStatus()
            noConnectionView.isUserInteractionEnabled = false
            //Check if the pumps or on auto mode or hand mode
            
            logger.logData(data: "PUMP: CONNECTION SUCCESS")
            
        }  else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
        
    }
    
        public func getProjectorStatus() {
    
            httpComm.httpGetResponseFromPath(url: READ_PANDORA_STAT){ (response) in
    
                if response != nil {
                    guard let responseDictionary = response as? [String : Any] else { return }
    
                    if !responseDictionary.isEmpty {
                        let resultArray = responseDictionary["result"] as! NSArray
                        let tempDict = resultArray.value(forKey: "temp") as! NSArray
                        let counter = resultArray.count
                        var index = 1
                        while index <= counter {
                            switch index {
                                case 1 :  self.prj201Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj201Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj201Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj201Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 2 :  self.prj202Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj202Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj202Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj202Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 3 :  self.prj203Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj203Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj203Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj203Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 4 :  self.prj204Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj204Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj204Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj204Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 5 :  self.prj205Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj205Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj205Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj205Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 6 :  self.prj206Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj206Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj206Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj206Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 7 :  self.prj207Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj207Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj207Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj207Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 8 :  self.prj208Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj208Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj208Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj208Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 9 :  self.prj209Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj209Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj209Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj209Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 10 : self.prj210Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj210Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj210Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj210Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 11 : self.prj211Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj211Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj211Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj211Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                
                                case 12 : self.prj212Stats.connectionStat = (resultArray[index - 1] as! NSObject).value(forKey: "connected") as! String
                                          self.prj212Stats.powerStat = (resultArray[index - 1] as! NSObject).value(forKey: "power") as! String
                                          self.prj212Stats.shutterStat = (resultArray[index - 1] as! NSObject).value(forKey: "shutter") as! String
                                          self.prj212Stats.projName = (resultArray[index - 1] as! NSObject).value(forKey: "name") as! String
                                default:
                                    print("FAULT TAG NOT FOUND")
                            }
                            index = index + 1
                        }
                        self.readProjectorConnectionStat()
                    }
                }
            }
        }
    
    
    func readProjectorConnectionStat (){
        if prj201Stats.connectionStat == "Connected" {
            self.prj201Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj201Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj202Stats.connectionStat == "Connected" {
            self.prj202Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj202Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj203Stats.connectionStat == "Connected" {
            self.prj203Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj203Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj204Stats.connectionStat == "Connected" {
            self.prj204Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj204Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj205Stats.connectionStat == "Connected" {
            self.prj205Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj205Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj206Stats.connectionStat == "Connected" {
            self.prj206Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj206Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj207Stats.connectionStat == "Connected" {
            self.prj207Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj207Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj208Stats.connectionStat == "Connected" {
            self.prj208Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj208Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj209Stats.connectionStat == "Connected" {
            self.prj209Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj209Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj210Stats.connectionStat == "Connected" {
            self.prj210Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj210Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj211Stats.connectionStat == "Connected" {
            self.prj211Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj211Btn.setTitleColor(RED_COLOR, for: .normal)
        }
        if prj212Stats.connectionStat == "Connected" {
            self.prj212Btn.setTitleColor(GREEN_COLOR, for: .normal)
        } else {
            self.prj212Btn.setTitleColor(RED_COLOR, for: .normal)
        }
    }
    @IBAction func prjStatusBtnPushed(_ sender: UIButton) {
        let prjStatusVC = UIStoryboard.init(name: "Projector", bundle: nil).instantiateViewController(withIdentifier: "ProjectorStatus") as! ProjectorStatusViewController
        prjStatusVC.prjNumber = sender.tag
        switch sender.tag {
            case 101: prjStatusVC.projectorStats = prj201Stats
            case 102: prjStatusVC.projectorStats = prj202Stats
            case 103: prjStatusVC.projectorStats = prj203Stats
            case 104: prjStatusVC.projectorStats = prj204Stats
            case 105: prjStatusVC.projectorStats = prj205Stats
            case 106: prjStatusVC.projectorStats = prj206Stats
            case 107: prjStatusVC.projectorStats = prj207Stats
            case 108: prjStatusVC.projectorStats = prj208Stats
            case 109: prjStatusVC.projectorStats = prj209Stats
            case 110: prjStatusVC.projectorStats = prj210Stats
            case 111: prjStatusVC.projectorStats = prj211Stats
            case 112: prjStatusVC.projectorStats = prj212Stats
            default:
                      print("PROJECTOR TAG NOT FOUND")
        }
        navigationController?.pushViewController(prjStatusVC, animated: true)
    }
    
    
}
