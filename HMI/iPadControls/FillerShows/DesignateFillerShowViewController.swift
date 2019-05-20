//
//  DesignateFillerShowViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/23/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class DesignateFillerShowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private var shows: [Any]? = nil
    private var showColors: [Any]? = nil
    private var showTable: UITableView!
    private let showManager = ShowManager()
    private let httpComm = HTTPComm()
    var showProperties: NSObject? = nil
    var testStat      = 0
    var specialStat   = 0
    var fillerStat    = 0
    var fillerSpecialNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createShowTableView()
        readShowFile()
        // Do any additional setup after loading the view.
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
        } else if fillerSpecialNum == 2222 {
            shows.text = "SPECIAL SHOWS"
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
        
        var addButton = UIButton(frame: CGRect(x: 265, y: 395, width: 70, height: 30))
        addButton.setBackgroundImage(UIImage(named: "done_70x30"), for: .normal)
        addButton.addTarget(self, action: #selector(self.updateTestShows), for: .touchDown)
        view.addSubview(addButton)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (shows?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "EditableTextCell")
        let duration: Int = ((shows![indexPath.row] as? [AnyHashable : Any])?["duration"] as? NSNumber)?.intValue ?? 0
        let min: Int = duration / 60
        let sec: Int = duration % 60
        
        if duration == 0 {
            cell.isHidden = true
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
            
            showTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else if ((shows![indexPath.row] as? [AnyHashable : Any])?["filler"] as? NSNumber)?.boolValue ?? false {
            cell.detailTextLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
        } else {
            cell.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
            showTable.deselectRow(at: indexPath, animated: false)
        }
        
        cell.backgroundColor = UIColor(red: 50.0 / 255.0, green: 50.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none

        let separatorLineView = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 0.27)) /// change size as you need.
        separatorLineView.backgroundColor = UIColor(red: 150.0 / 255.0, green: 150.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0) // you can also put image here
        cell.contentView.addSubview(separatorLineView)
        
        return cell

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
                            cell!.detailTextLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                            if let font = UIFont(name: "Verdana", size: 16) {
                                cell!.detailTextLabel?.font = font
                            }
                            cell!.textLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                            if let font = UIFont(name: "Verdana", size: 16) {
                                cell!.textLabel?.font = font
                            }
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
                        }
                }
            }
            
            if fillerSpecialNum == 2222 {
                if testStat == 0 && fillerStat == 0{
                        if specialStat == 0{
                            specialStat = 1
                            let result = true
                            showDictionary?.updateValue(result, forKey: "special")
                            cell!.detailTextLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                            if let font = UIFont(name: "Verdana", size: 16) {
                                cell!.detailTextLabel?.font = font
                            }
                            cell!.textLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                            if let font = UIFont(name: "Verdana", size: 16) {
                                cell!.textLabel?.font = font
                            }
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
                            showTable.deselectRow(at: indexPath, animated: true)
                            cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        } else {
                            cell!.detailTextLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 14.0 / 255.0, green: 240.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
                        }
                     }
                }
                
                
                if fillerSpecialNum == 2222{
                     if self.testStat != 1 && self.fillerStat != 1{
                        cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        if self.specialStat == 0 {
                            showTable.deselectRow(at: indexPath, animated: true)
                            cell!.detailTextLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
                        } else {
                            cell!.detailTextLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                            cell!.textLabel?.textColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
                        }
                }
              }
                
            }
        }
    }
    
    @objc func updateTestShows() {
        let defaults = UserDefaults.standard
        defaults.set(shows!, forKey: "shows")
        convertToJSON(object: shows!) { (dataString) in
            self.httpComm.httpGet(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeShows?\(dataString!)") { (response, success) in
                if success == true {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    
    }
    
    
    
  
}
