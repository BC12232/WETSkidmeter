//
//  ReadPumpScheduleViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 6/21/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class ReadPumpScheduleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var cannotRunBwashLbl: UILabel!
    @IBOutlet weak var manualBwashButton: UIButton!
    @IBOutlet weak var countDownTimer: UILabel!
    @IBOutlet weak var countDownTimerBG: UIView!
    @IBOutlet weak var backwashDuration: UILabel!
    @IBOutlet weak var backwashScheduler: UIView!
    @IBOutlet weak var schedulerTxt: UILabel!
    
    private let httpComm = HTTPComm()
    private var loadedScheduler = 0
    private var component0AlreadySelected = false
    private var component1AlreadySelected = false
    private var component2AlreadySelected = false
    private var component3AlreadySelected = false
    private var selectedDay = 0
    private var selectedHour = 0
    private var selectedMinute = 0
    private var selectedTimeOfDay = 0
    private var duration = 0  //In Minutes
    private var backWashShowNumber = 999
    private var is24hours = true
    var pumpTag = 0
    
    override func viewWillAppear(_ animated: Bool){
        loadedScheduler = 0
        loadBWDuration()
        readBWFeedback()
        readManualBwash()
        readBackWashRunning()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func toggleManualBwash(_ sender: UIButton) {
        if pumpTag == 131{
            CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_TOGGLE_BWASH_BIT_1, value: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_TOGGLE_BWASH_BIT_1, value: 0)
                
            }
        } else if pumpTag == 132 {
            CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_TOGGLE_BWASH_BIT_2, value: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_TOGGLE_BWASH_BIT_2, value: 0)
                
            }
        } else if pumpTag == 133 {
            CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_TOGGLE_BWASH_BIT_3, value: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_TOGGLE_BWASH_BIT_3, value: 0)
                
            }
        }
    }
    
    
    @IBAction func setBwashScheduler(_ sender: UIButton) {
        let hour = UserDefaults.standard.integer(forKey: "SelectedHour")
        let minute = UserDefaults.standard.integer(forKey: "SelectedMinute")
        let day = UserDefaults.standard.integer(forKey: "SelectedDay")
        let timeOfDay =  UserDefaults.standard.integer(forKey: "SelectedTimeOfDay")
        
        var time = 0
        //Converting hour and minute to 4 digit
        
        if is24hours {
            time = (hour * 100) + minute
        } else {
            time = ((hour + timeOfDay) * 100)
            
            if time == 1200 {
                //12 AM
                time = (time * 0) + minute
            } else if time == 2400 {
                //12 PM
                time = (time - 1200) + minute
            } else {
                time += minute
            }
        }
        
        if pumpTag == 131 {
            httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeBW1?[\(day),\(time)]"){ (response) in
                self.loadedScheduler = 0
            }
        } else if pumpTag == 132 {
            httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeBW2?[\(day),\(time)]"){ (response) in
                self.loadedScheduler = 0
            }
        } else if pumpTag == 133 {
            httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/writeBW3?[\(day),\(time)]"){ (response) in
                self.loadedScheduler = 0
            }
        }
        
        //NOTE: The Data Structure be [DAY,TIME]
        
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        if pumpTag == 131{
            //Selected Day
            if component == 0 {
                
                selectedDay = row + 1
                UserDefaults.standard.set(selectedDay, forKey: "SelectedDay")
                component0AlreadySelected = true
            } else {
                if !component0AlreadySelected {
                    let defaultDay = UserDefaults.standard.integer(forKey: "Day1")
                    UserDefaults.standard.set(defaultDay, forKey: "SelectedDay")
                }
            }
            
            if component == 1 {
                if is24hours {
                    selectedHour = row
                } else {
                    selectedHour = row + 1
                }
                
                UserDefaults.standard.set(selectedHour, forKey: "SelectedHour")
                component1AlreadySelected = true
            } else {
                if !component1AlreadySelected {
                    let hour = UserDefaults.standard.integer(forKey: "Hour1")
                    
                    if is24hours {
                        UserDefaults.standard.set(hour, forKey: "SelectedHour")
                    } else {
                        UserDefaults.standard.set(hour + 1, forKey: "SelectedHour")
                    }
                }
            }
            
            if component == 2 {
                
                selectedMinute = row
                UserDefaults.standard.set(selectedMinute, forKey: "SelectedMinute")
                component2AlreadySelected = true
            } else {
                if !component2AlreadySelected {
                    let minute = UserDefaults.standard.integer(forKey: "Minute1")
                    UserDefaults.standard.set(minute, forKey: "SelectedMinute")
                }
            }
            
            if component == 3 {
                if !is24hours {
                    if row == 0 {
                        selectedTimeOfDay = 0
                    } else {
                        selectedTimeOfDay = 12
                    }
                } else {
                    selectedTimeOfDay = 0
                }
                
                UserDefaults.standard.set(selectedTimeOfDay, forKey: "SelectedTimeOfDay")
                component3AlreadySelected = true
            } else {
                if !component3AlreadySelected {
                    let day = UserDefaults.standard.integer(forKey: "TimeOfDay1")
                    UserDefaults.standard.set(day, forKey: "SelectedTimeOfDay")
                }
            }
        }
        
        if pumpTag == 132{
            //Selected Day
            if component == 0 {
                
                selectedDay = row + 1
                UserDefaults.standard.set(selectedDay, forKey: "SelectedDay")
                component0AlreadySelected = true
            } else {
                if !component0AlreadySelected {
                    let defaultDay = UserDefaults.standard.integer(forKey: "Day2")
                    UserDefaults.standard.set(defaultDay, forKey: "SelectedDay")
                }
            }
            
            if component == 1 {
                if is24hours {
                    selectedHour = row
                } else {
                    selectedHour = row + 1
                }
                
                UserDefaults.standard.set(selectedHour, forKey: "SelectedHour")
                component1AlreadySelected = true
            } else {
                if !component1AlreadySelected {
                    let hour = UserDefaults.standard.integer(forKey: "Hour2")
                    
                    if is24hours {
                        UserDefaults.standard.set(hour, forKey: "SelectedHour")
                    } else {
                        UserDefaults.standard.set(hour + 1, forKey: "SelectedHour")
                    }
                }
            }
            
            if component == 2 {
                
                selectedMinute = row
                UserDefaults.standard.set(selectedMinute, forKey: "SelectedMinute")
                component2AlreadySelected = true
            } else {
                if !component2AlreadySelected {
                    let minute = UserDefaults.standard.integer(forKey: "Minute2")
                    UserDefaults.standard.set(minute, forKey: "SelectedMinute")
                }
            }
            
            if component == 3 {
                if !is24hours {
                    if row == 0 {
                        selectedTimeOfDay = 0
                    } else {
                        selectedTimeOfDay = 12
                    }
                } else {
                    selectedTimeOfDay = 0
                }
                
                UserDefaults.standard.set(selectedTimeOfDay, forKey: "SelectedTimeOfDay")
                component3AlreadySelected = true
            } else {
                if !component3AlreadySelected {
                    let day = UserDefaults.standard.integer(forKey: "TimeOfDay2")
                    UserDefaults.standard.set(day, forKey: "SelectedTimeOfDay")
                }
            }
        }
        
        if pumpTag == 133{
            //Selected Day
            if component == 0 {
                
                selectedDay = row + 1
                UserDefaults.standard.set(selectedDay, forKey: "SelectedDay")
                component0AlreadySelected = true
            } else {
                if !component0AlreadySelected {
                    let defaultDay = UserDefaults.standard.integer(forKey: "Day3")
                    UserDefaults.standard.set(defaultDay, forKey: "SelectedDay")
                }
            }
            
            if component == 1 {
                if is24hours {
                    selectedHour = row
                } else {
                    selectedHour = row + 1
                }
                
                UserDefaults.standard.set(selectedHour, forKey: "SelectedHour")
                component1AlreadySelected = true
            } else {
                if !component1AlreadySelected {
                    let hour = UserDefaults.standard.integer(forKey: "Hour3")
                    
                    if is24hours {
                        UserDefaults.standard.set(hour, forKey: "SelectedHour")
                    } else {
                        UserDefaults.standard.set(hour + 1, forKey: "SelectedHour")
                    }
                }
            }
            
            if component == 2 {
                
                selectedMinute = row
                UserDefaults.standard.set(selectedMinute, forKey: "SelectedMinute")
                component2AlreadySelected = true
            } else {
                if !component2AlreadySelected {
                    let minute = UserDefaults.standard.integer(forKey: "Minute3")
                    UserDefaults.standard.set(minute, forKey: "SelectedMinute")
                }
            }
            
            if component == 3 {
                if !is24hours {
                    if row == 0 {
                        selectedTimeOfDay = 0
                    } else {
                        selectedTimeOfDay = 12
                    }
                } else {
                    selectedTimeOfDay = 0
                }
                
                UserDefaults.standard.set(selectedTimeOfDay, forKey: "SelectedTimeOfDay")
                component3AlreadySelected = true
            } else {
                if !component3AlreadySelected {
                    let day = UserDefaults.standard.integer(forKey: "TimeOfDay3")
                    UserDefaults.standard.set(day, forKey: "SelectedTimeOfDay")
                }
            }
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textColor = .white
            pickerLabel?.font = UIFont(name: ".SFUIDisplay", size: 20)
            pickerLabel?.textAlignment = .left
            
            
            switch component {
                
            case 0:
                pickerLabel?.text = DAY_PICKER_DATA_SOURCE[row]
                
            case 1:
                pickerLabel?.textAlignment = .right
                
                if is24hours {
                    let formattedHour = String(format: "%02i", row)
                    pickerLabel?.text = "\(formattedHour)"
                } else {
                    pickerLabel?.text = "\(row + 1)"
                }
                
            case 2:
                let formattedMinutes = String(format: "%02i", row)
                pickerLabel?.text = ": \(formattedMinutes)"
                
            case 3:
                pickerLabel?.text = AM_PM_PICKER_DATA_SOURCE[row]
                
            default:
                pickerLabel?.text = "Error"
            }
            
        }
        
        
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if is24hours {
            if component == 0 {
                return 175
            } else if component == 1 {
                return 50
            } else {
                return 80
            }
        } else if !is24hours {
            if component == 0 {
                return 150
            } else {
                return 50
            }
        } else {
            return 0
        }
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if is24hours {
            return 3
        } else {
            return 4
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        if component == 0{
            
            return 7
            
        } else if component == 1{
            
            if is24hours {
                return 24
            } else {
                return 12
            }
            
        } else if component == 2{
            
            return 60
            
        } else {
            
            return 2
            
        }
        
        
    }
    private func readBWFeedback(){
        if pumpTag == 131 {
            self.httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW1"){ (response) in
                
                guard let responseDictinary = response as? NSDictionary else { return }
                
                
                let backWashStatus = responseDictinary["SchBWStatus"] as? Int
                
                if self.loadedScheduler == 0 {
                    guard
                        let backWashScheduledDay = responseDictinary["schDay"] as? Int,
                        let backWashScheduledTime = responseDictinary["schTime"] as? Int else { return }
                    
                    self.dayPicker.selectRow(backWashScheduledDay - 1, inComponent: 0, animated: true)
                    UserDefaults.standard.set(backWashScheduledDay, forKey: "Day1")
                    
                    if self.is24hours {
                        
                        let hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        self.schedulerTxt.text = "\(DAY_PICKER_DATA_SOURCE[backWashScheduledDay - 1])" + "  " + "\(hour)" + ":" + "\(minute)"
                        self.dayPicker.selectRow(hour, inComponent: 1, animated: true)
                        self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                        
                        UserDefaults.standard.set(hour, forKey: "Hour1")
                        UserDefaults.standard.set(minute, forKey: "Minute1")
                        self.loadedScheduler = 1
                        
                        
                    } else {
                        var hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        let timeOfDay = hour - 12
                        
                        
                        // check if its 12 AM
                        if backWashScheduledTime < 60 {
                            self.dayPicker.selectRow(11, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(11, forKey: "Hour1")
                            UserDefaults.standard.set(minute, forKey: "Minute1")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay1")
                            
                        } else if timeOfDay == 0{
                            //check if it's 12 PM
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour1")
                            UserDefaults.standard.set(minute, forKey: "Minute1")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay1")
                            
                        } else if timeOfDay < 0 {
                            //check if it's AM in general
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour1")
                            UserDefaults.standard.set(minute, forKey: "Minute1")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay1")
                            
                            
                            
                        } else {
                            //check if it's PM
                            hour = timeOfDay
                            
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour1")
                            UserDefaults.standard.set(minute, forKey: "Minute1")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay1")
                            
                        }
                        
                        self.loadedScheduler = 1
                        
                    }
                    
                }
                
                //If the back wash status is 2: show the count down timer
                
                if backWashStatus == 2{
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = false
                    
                    if let countDownSeconds = responseDictinary["timeoutCountdown"] as? Int {
                        let hours = countDownSeconds / 3600
                        let minutes = (countDownSeconds % 3600) / 60
                        let seconds = (countDownSeconds % 3600) % 60
                        
                        self.countDownTimer.text = "\(hours):\(minutes):\(seconds)"
                    }
                    
                    
                    
                    
                } else if backWashStatus == 0 {
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                } else {
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                }
                
            }
        } else if pumpTag == 132{
            self.httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW2"){ (response) in
                
                guard let responseDictinary = response as? NSDictionary else { return }
                
                
                let backWashStatus = responseDictinary["SchBWStatus"] as? Int
                
                if self.loadedScheduler == 0 {
                    guard
                        let backWashScheduledDay = responseDictinary["schDay"] as? Int,
                        let backWashScheduledTime = responseDictinary["schTime"] as? Int else { return }
                    
                    self.dayPicker.selectRow(backWashScheduledDay - 1, inComponent: 0, animated: true)
                    UserDefaults.standard.set(backWashScheduledDay, forKey: "Day2")
                    
                    if self.is24hours {
                        
                        let hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        
                        self.schedulerTxt.text = "\(DAY_PICKER_DATA_SOURCE[backWashScheduledDay - 1])" + "\(hour)" + ":" + "\(minute)"
                        
                        self.dayPicker.selectRow(hour, inComponent: 1, animated: true)
                        self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                        
                        UserDefaults.standard.set(hour, forKey: "Hour2")
                        UserDefaults.standard.set(minute, forKey: "Minute2")
                        self.loadedScheduler = 1
                        
                        
                    } else {
                        var hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        let timeOfDay = hour - 12
                        
                        
                        // check if its 12 AM
                        if backWashScheduledTime < 60 {
                            self.dayPicker.selectRow(11, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(11, forKey: "Hour2")
                            UserDefaults.standard.set(minute, forKey: "Minute2")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay2")
                            
                        } else if timeOfDay == 0{
                            //check if it's 12 PM
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour2")
                            UserDefaults.standard.set(minute, forKey: "Minute2")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay2")
                            
                        } else if timeOfDay < 0 {
                            //check if it's AM in general
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour2")
                            UserDefaults.standard.set(minute, forKey: "Minute2")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay2")
                            
                            
                            
                        } else {
                            //check if it's PM
                            hour = timeOfDay
                            
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour2")
                            UserDefaults.standard.set(minute, forKey: "Minute2")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay2")
                            
                        }
                        
                        self.loadedScheduler = 1
                        
                    }
                    
                }
                
                //If the back wash status is 2: show the count down timer
                
                if backWashStatus == 2{
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = false
                    
                    if let countDownSeconds = responseDictinary["timeoutCountdown"] as? Int {
                        let hours = countDownSeconds / 3600
                        let minutes = (countDownSeconds % 3600) / 60
                        let seconds = (countDownSeconds % 3600) % 60
                        
                        self.countDownTimer.text = "\(hours):\(minutes):\(seconds)"
                    }
                    
                    
                    
                    
                } else if backWashStatus == 0 {
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                } else {
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                }
                
            }
        } else if pumpTag == 133{
            self.httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW3"){ (response) in
                
                guard let responseDictinary = response as? NSDictionary else { return }
                
                
                let backWashStatus = responseDictinary["SchBWStatus"] as? Int
                
                if self.loadedScheduler == 0 {
                    guard
                        let backWashScheduledDay = responseDictinary["schDay"] as? Int,
                        let backWashScheduledTime = responseDictinary["schTime"] as? Int else { return }
                    
                        
                    
                    self.dayPicker.selectRow(backWashScheduledDay - 1, inComponent: 0, animated: true)
                    UserDefaults.standard.set(backWashScheduledDay, forKey: "Day3")
                    
                    if self.is24hours {
                        
                        let hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        
                        self.schedulerTxt.text = "\(DAY_PICKER_DATA_SOURCE[backWashScheduledDay - 1])" + "\(hour)" + ":" + "\(minute)"
                        
                        self.dayPicker.selectRow(hour, inComponent: 1, animated: true)
                        self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                        
                        UserDefaults.standard.set(hour, forKey: "Hour3")
                        UserDefaults.standard.set(minute, forKey: "Minute3")
                        self.loadedScheduler = 1
                        
                        
                    } else {
                        var hour = backWashScheduledTime / 100
                        let minute = backWashScheduledTime % 100
                        let timeOfDay = hour - 12
                        
                        
                        // check if its 12 AM
                        if backWashScheduledTime < 60 {
                            self.dayPicker.selectRow(11, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(11, forKey: "Hour3")
                            UserDefaults.standard.set(minute, forKey: "Minute3")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay3")
                            
                        } else if timeOfDay == 0{
                            //check if it's 12 PM
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour3")
                            UserDefaults.standard.set(minute, forKey: "Minute3")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay3")
                            
                        } else if timeOfDay < 0 {
                            //check if it's AM in general
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(0, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour3")
                            UserDefaults.standard.set(minute, forKey: "Minute3")
                            UserDefaults.standard.set(0, forKey: "TimeOfDay3")
                            
                            
                            
                        } else {
                            //check if it's PM
                            hour = timeOfDay
                            
                            self.dayPicker.selectRow(hour - 1, inComponent: 1, animated: true)
                            self.dayPicker.selectRow(minute, inComponent: 2, animated: true)
                            self.dayPicker.selectRow(1, inComponent: 3, animated: true)
                            
                            UserDefaults.standard.set(hour - 1, forKey: "Hour3")
                            UserDefaults.standard.set(minute, forKey: "Minute3")
                            UserDefaults.standard.set(12, forKey: "TimeOfDay3")
                            
                        }
                        
                        self.loadedScheduler = 1
                        
                    }
                    
                }
                
                //If the back wash status is 2: show the count down timer
                
                if backWashStatus == 2{
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = false
                    
                    if let countDownSeconds = responseDictinary["timeoutCountdown"] as? Int {
                        let hours = countDownSeconds / 3600
                        let minutes = (countDownSeconds % 3600) / 60
                        let seconds = (countDownSeconds % 3600) % 60
                        
                        self.countDownTimer.text = "\(hours):\(minutes):\(seconds)"
                    }
                    
                    
                    
                    
                } else if backWashStatus == 0 {
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                } else {
                    self.backwashScheduler.isHidden = false
                    self.countDownTimerBG.isHidden = true
                }
                
            }
        }
        
    }
    private func readBackWashRunning(){
        if pumpTag == 131 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT_1), completion: { (success, bw1Response) in
                
                guard success == true else { return }
                
                let bw1Status = Int(truncating: bw1Response![0] as! NSNumber)
                if bw1Status == 1{
                    self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashRunning"), for: .normal)
                } else {
                    self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashIcon"), for: .normal)
                }
            })
        } else if pumpTag == 132 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT_2), completion: { (success, bw1Response) in
                
                guard success == true else { return }
                
                let bw1Status = Int(truncating: bw1Response![0] as! NSNumber)
                if bw1Status == 1{
                    self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashRunning"), for: .normal)
                } else {
                    self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashIcon"), for: .normal)
                }
            })
        } else if pumpTag == 133 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_BWASH_RUNNING_BIT_3), completion: { (success, bw1Response) in
                
                guard success == true else { return }
                
                let bw1Status = Int(truncating: bw1Response![0] as! NSNumber)
                if bw1Status == 1{
                    self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashRunning"), for: .normal)
                } else {
                    self.manualBwashButton.setImage(#imageLiteral(resourceName: "bwashIcon"), for: .normal)
                }
            })
        }
       
    }
    
    private func readManualBwash(){
        if pumpTag == 131{
            self.httpComm.httpGetResponseFromPath(url: READ_BACK_WASH1){ (response) in
                
                guard let responseDictionary = response as? NSDictionary else { return }
                
                let backwash = Int(truncating: responseDictionary.object(forKey: "manBWcanRun") as! NSNumber)
                
                if backwash == 1{
                    
                    self.manualBwashButton.isHidden = false
                    self.cannotRunBwashLbl.isHidden = true
                    
                }else{
                    
                    self.manualBwashButton.isHidden = true
                    self.cannotRunBwashLbl.isHidden = false
                    
                }
            }
        } else if pumpTag == 132{
            self.httpComm.httpGetResponseFromPath(url: READ_BACK_WASH2){ (response) in
                
                guard let responseDictionary = response as? NSDictionary else { return }
                
                let backwash = Int(truncating: responseDictionary.object(forKey: "manBWcanRun") as! NSNumber)
                
                if backwash == 1{
                    
                    self.manualBwashButton.isHidden = false
                    self.cannotRunBwashLbl.isHidden = true
                    
                }else{
                    
                    self.manualBwashButton.isHidden = true
                    self.cannotRunBwashLbl.isHidden = false
                    
                }
            }
        } else if pumpTag == 133{
            self.httpComm.httpGetResponseFromPath(url: READ_BACK_WASH3){ (response) in
                
                guard let responseDictionary = response as? NSDictionary else { return }
                
                let backwash = Int(truncating: responseDictionary.object(forKey: "manBWcanRun") as! NSNumber)
                
                if backwash == 1{
                    
                    self.manualBwashButton.isHidden = false
                    self.cannotRunBwashLbl.isHidden = true
                    
                }else{
                    
                    self.manualBwashButton.isHidden = true
                    self.cannotRunBwashLbl.isHidden = false
                    
                }
            }
        }
        
        
    }
    /***************************************************************************
     * Function :  Load Back Wash Duration
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func loadBWDuration(){
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(FILTRATION_BW_DURATION_REGISTER), completion: { (success, response) in
            
            guard success == true else { return }
            
            let bwDuration = Int(truncating: response![0] as! NSNumber)
            self.backwashDuration.text = "\(bwDuration) m"
        })
    }
}
