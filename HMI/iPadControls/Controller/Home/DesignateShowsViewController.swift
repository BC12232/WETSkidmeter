//
//  DesignateShowsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 4/17/19.
//  Copyright © 2019 WET. All rights reserved.
//


import UIKit


class DesignateShowsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private var shows: [Any]? = nil
    private var showColors: [Any]? = nil
    private var showTable: UITableView!
    private let showManager = ShowManager()
    private let httpComm = HTTPComm()
    var showProperties: NSObject? = nil
    let GET_FILLER_SHOW_STATE_PATH  = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readFillerShow"
    let SET_FILLER_SHOW_STATE_PATH  = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeFillerShow"
    var testStat      = 0
    var specialStat   = 0
    var fillerStat    = 0
    var fillerSpecialNum = 0
    var fillerCount = 0
    var specialCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        createShowTableView()
        readShowFile()
        UserDefaults.standard.set(true, forKey: "isDesignateShows")
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
          UserDefaults.standard.set(false, forKey: "isDesignateShows")
    }
    
    func readShowFile() {
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "shows") != nil {
            
            if let object = defaults.object(forKey: "shows") as? [Any] {
                shows = object
            }
            showTable.reloadData()
        }
    }
    func createShowTableView() {
        
        let shows = UILabel(frame: CGRect(x: 150, y: 42, width: 300, height: 25))
        shows.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
        if let font = UIFont(name: "Verdana", size: 24) {
            shows.font = font
        }
        shows.textAlignment = .center
        if fillerSpecialNum == 1111{
            shows.text = "FILLER SHOWS"
        }
        if fillerSpecialNum == 2222 {
            shows.text = "SPECIAL SHOWS"
        }
        if fillerSpecialNum == 3333 {
            shows.text = "TEST SHOWS"
        }
        
        view.addSubview(shows)
        
        showTable = UITableView(frame: CGRect(x: 0, y: 100, width: 600, height: 270), style: .plain)
        showTable.backgroundColor = UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)
        showTable.bounces = false
        showTable.delegate = self
        showTable.dataSource = self
        showTable.isScrollEnabled = true
        
        showTable.allowsMultipleSelection = true
        view.addSubview(showTable)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (shows?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "EditableTextCell")
        let duration: Int = ((shows![indexPath.row] as? [AnyHashable : Any])?["duration"] as? NSNumber)?.intValue ?? 0
        let min: Int = duration / 60
        let sec: Int = duration % 60
        let showNum: Int = ((shows![indexPath.row] as? [AnyHashable : Any])?["number"] as? NSNumber)?.intValue ?? 0
        if duration == 0 || showNum == 0 {
            cell.isHidden = true
        }
        if showNum == 0 {
            let showObjects = shows![indexPath.row] as? NSObject
            showProperties = showObjects
            var showDictionary = showProperties as? [String:Any]
            showDictionary?.updateValue(true, forKey: "special")
            showDictionary?.updateValue(true, forKey: "filler")
            showDictionary?.updateValue(true, forKey: "test")
            shows![indexPath.row] = showDictionary! as NSObject
            updateTestFillSpecialShows()
        }
        
        cell.textLabel?.text = (shows![indexPath.row] as? [AnyHashable : Any])?["name"] as? String
        cell.detailTextLabel?.text = "\(min < 10 ? "0" : "")\(min):\(sec < 10 ? "0" : "")\(sec)"
        
        
        if let font = UIFont(name: "Verdana", size: 16) {
            cell.detailTextLabel?.font = font
        }
        
        if let font = UIFont(name: "Verdana", size: 16) {
            cell.textLabel?.font = font
        }
        
        if ((shows![indexPath.row] as? [AnyHashable : Any])?["test"] as? NSNumber)?.boolValue ?? false {
            cell.detailTextLabel?.textColor = UIColor(red: 130.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor(red: 130.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        } else if ((shows![indexPath.row] as? [AnyHashable : Any])?["filler"] as? NSNumber)?.boolValue ?? false {
            cell.detailTextLabel?.textColor = UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            fillerCount = fillerCount + 1
        } else if ((shows![indexPath.row] as? [AnyHashable : Any])?["special"] as? NSNumber)?.boolValue ?? false {
            cell.detailTextLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 250.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
            specialCount = specialCount + 1
        } else {
            cell.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
        }
        
        cell.backgroundColor = UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let separatorLineView = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 0.27)) /// change size as you need.
        separatorLineView.backgroundColor = UIColor(red: 150.0 / 255.0, green: 150.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0) // you can also put image here
        cell.contentView.addSubview(separatorLineView)
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let duration: Int = ((shows![indexPath.row] as? [AnyHashable : Any])?["duration"] as? NSNumber)?.intValue ?? 0
        let min: Int = duration / 60
        let sec: Int = duration % 60
        let showNum: Int = ((shows![indexPath.row] as? [AnyHashable : Any])?["number"] as? NSNumber)?.intValue ?? 0
        if duration == 0 || showNum == 0 {
            return 0
        } else {
            return 45
        }

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        //        "color": 1,
        //        "number": 1,
        //        "test": true,
        //        "filler": false,
        //        "name": "SHOW0001 VW All Canopy Test Show",
        //        "duration": 436
        
        if let showObjects = shows![indexPath.row] as? NSObject {
            showProperties = showObjects
            var showDictionary = showProperties as? [String:Any]
            if showDictionary!["special"] != nil {
                self.specialStat = (showDictionary!["special"] as? Int)!
            }
            if showDictionary!["test"] != nil {
                self.testStat = (showDictionary!["test"] as? Int)!
            }
            if showDictionary!["filler"] != nil {
                self.fillerStat  = (showDictionary!["filler"] as? Int)!
            }
            let cell = showTable.cellForRow(at: indexPath)
            
            if fillerSpecialNum == 1111 {
                if testStat == 0 && specialStat == 0{
                    if fillerStat == 0{
                        fillerStat = 1
                        let result = true
                        showDictionary?.updateValue(result, forKey: "filler")
                        cell!.detailTextLabel?.textColor = UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.detailTextLabel?.font = font
                        }
                        cell!.textLabel?.textColor = UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.textLabel?.font = font
                        }
                        fillerCount = fillerCount + 1
                    } else {
                        fillerStat = 0
                        let result = false
                        showDictionary?.updateValue(result, forKey: "filler")
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.detailTextLabel?.font = font
                        }
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.textLabel?.font = font
                        }
                        fillerCount = fillerCount - 1
                    }
                }
            }
            
            if fillerSpecialNum == 2222 {
                if testStat == 0 && fillerStat == 0{
                    if specialStat == 0{
                        specialStat = 1
                        let result = true
                        showDictionary?.updateValue(result, forKey: "special")
                        cell!.detailTextLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.detailTextLabel?.font = font
                        }
                        cell!.textLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.textLabel?.font = font
                        }
                        specialCount = specialCount + 1
                    } else {
                        specialStat = 0
                        let result = false
                        showDictionary?.updateValue(result, forKey: "special")
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.detailTextLabel?.font = font
                        }
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.textLabel?.font = font
                        }
                        specialCount = specialCount - 1
                    }
                }
            }
            
            if fillerSpecialNum == 3333 {
                if specialStat == 0 && fillerStat == 0{
                    if testStat == 0{
                        testStat = 1
                        let result = true
                        showDictionary?.updateValue(result, forKey: "test")
                        cell!.detailTextLabel?.textColor = UIColor(red: 130.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.detailTextLabel?.font = font
                        }
                        cell!.textLabel?.textColor = UIColor(red: 130.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.textLabel?.font = font
                        }
                    } else {
                        testStat = 0
                        let result = false
                        showDictionary?.updateValue(result, forKey: "test")
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.detailTextLabel?.font = font
                        }
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if let font = UIFont(name: "Verdana", size: 16) {
                            cell!.textLabel?.font = font
                        }
                    }
                }
            }
            
            
            showProperties = showDictionary! as NSObject
            shows![indexPath.row] = showProperties!
            
        }
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let showObjects = shows![indexPath.row] as? NSObject {
            showProperties = showObjects
            var showDictionary = showProperties as? [String:Any]
            if showDictionary!["special"] != nil {
                self.specialStat = (showDictionary!["special"] as? Int)!
            }
            if showDictionary!["test"] != nil {
                self.testStat  = (showDictionary!["test"] as? Int)!
            }
            if showDictionary!["filler"] != nil {
                self.fillerStat  = (showDictionary!["filler"] as? Int)!
            }
            let duration: Int = ((shows![indexPath.row] as? [AnyHashable : Any])?["duration"] as? NSNumber)?.intValue ?? 0
            
            if duration != 0{
                let cell = showTable.cellForRow(at: indexPath)
                if fillerSpecialNum == 1111{
                    if self.testStat != 1 && self.specialStat != 1{
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        
                        if self.fillerStat == 0 {
                            showDictionary?.updateValue(false, forKey: "filler")
                            cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        } else {
                            showDictionary?.updateValue(true, forKey: "filler")
                            cell!.detailTextLabel?.textColor = UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                        }
                    }
                }
                
                
                if fillerSpecialNum == 2222{
                    if self.testStat != 1 && self.fillerStat != 1{
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        
                        if self.specialStat == 0 {
                             showDictionary?.updateValue(false, forKey: "special")
                            cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        } else {
                             showDictionary?.updateValue(true, forKey: "special")
                            cell!.detailTextLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        }
                    }
                }
                
                
                if fillerSpecialNum == 3333{
                    if self.specialStat != 1 && self.fillerStat != 1{
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if self.testStat == 0 {
                            showDictionary?.updateValue(false, forKey: "test")
                            cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        } else {
                            showDictionary?.updateValue(true, forKey: "test")
                            cell!.detailTextLabel?.textColor = UIColor(red: 130.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 130.0 / 255.0, green: 180.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        }
                    }
                }
                
            }
            shows![indexPath.row] = showDictionary! as NSObject
            updateTestFillSpecialShows()
        }
        
    }
    
    @objc func updateTestFillSpecialShows() {
        let defaults = UserDefaults.standard
        defaults.set(shows!, forKey: "shows")
        convertToJSON(object: shows!) { (dataString) in
            self.httpComm.httpGet(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeShows?\(dataString!)") { (response, success) in
                if success == true {
                    
                }
            }
        }
        if fillerCount == 0 {
            httpComm.httpGetResponseFromPath(url: GET_FILLER_SHOW_STATE_PATH) { (response) in
                
                var dictionary  = response as? [String:Any]
                dictionary?.updateValue(0, forKey: "FillerShow_Number")
                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                var jsonString: String? = nil
                
                if let aData = jsonData{
                    jsonString = String(data: aData, encoding: .utf8)
                }
                
                let escapedString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let strURL = "\(self.SET_FILLER_SHOW_STATE_PATH)?\(String(describing: escapedString))"
                
                self.httpComm.httpGetResponseFromPath(url: strURL) { (response) in
                    
                }
            }
            
            
        }
        if specialCount == 0 {
            httpComm.httpGetResponseFromPath(url: GET_FILLER_SHOW_STATE_PATH) { (response) in
                
                var dictionary  = response as? [String:Any]
                dictionary?.updateValue(0, forKey: "SpecialShow")
                let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                var jsonString: String? = nil
                
                if let aData = jsonData{
                    jsonString = String(data: aData, encoding: .utf8)
                }
                
                let escapedString = jsonString!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let strURL = "\(self.SET_FILLER_SHOW_STATE_PATH)?\(String(describing: escapedString))"
                
                self.httpComm.httpGetResponseFromPath(url: strURL) { (response) in
                    
                }
            }
            
            
        }
    }
    
}
