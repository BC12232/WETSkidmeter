//
//  WeekSchedulerViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/27/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit


class WeekSchedulerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var bottomWeekendSlider: UISlider!
    @IBOutlet weak var topWeekendSlider: UISlider!
    @IBOutlet weak var bottomWeekdaySlider: UISlider!
    @IBOutlet weak var topWeekdaySlider: UISlider!
    @IBOutlet weak var weekdayTimeIntervalImageView: UIImageView!
    @IBOutlet weak var weekendTimeIntervalImageView: UIImageView!
    
    private let logger = Logger()
    private let helper = Helper()
    private let utilities = Utilits()
    private let httpComm = HTTPComm()
    
    private var weekdayStartTime = Int()
    private var weekdayEndTime = Int()
    private var weekendStartTime = Int()
    private var weekendEndTime = Int()
    
    var checkIfWeekendOrWeekday: Set<Int> = []
    var fullScheduleList: [Int] = []
    var addedTopSliderValues: Int?
    var addedBottomSliderValues: Int?
    var functionCounter = 0
    var isSliderDraggedInside = false
    var timer : Timer?
    
    @IBOutlet weak var weekdayTrackerView: UIView!
    @IBOutlet weak var weekdayStartTimeLabel: UILabel!
    @IBOutlet weak var weekdayEndTimeLabel: UILabel!
    @IBOutlet weak var weekendTrackerView: UIView!
    @IBOutlet weak var weekendStartTimeLabel: UILabel!
    @IBOutlet weak var weekendEndTimeLabel: UILabel!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        startModifyingSchedulerLook()
        
        
        //Set the slider up to check if it stopped sliding
        bottomWeekdaySlider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        bottomWeekendSlider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        topWeekendSlider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        topWeekdaySlider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        
        //Call readLightsORPumpsData() every second
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(readLightsORPumpsData), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        /*
         1. Invalidates timer and set it to nil
         2. Reset variables
         */
        
        timer?.invalidate()
        timer = nil
        readScheduleOnce = false
        functionCounter = 0
    }
    
    
    
    /***********************************************************************************************************************
     MARK: Read lights or pumps data
     1. Read the lights or pumps data from the server by using the read path.
     2. This function will only read from the server once.
     
     ***********************************************************************************************************************/
    
    @objc func readLightsORPumpsData() {
        
        if !readScheduleOnce {
            checkIfWeekendOrWeekday = []
            
            
            self.httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/\(readServerPath)"){ (response) in
                
                print("This is the read server path \(readServerPath)")
                guard let responseArray = response as? [Int] else { return }

                self.fullScheduleList = responseArray

                for (index,value) in self.fullScheduleList.enumerated() where index % 3 == 0 {


                    if value == 0 {
                        if self.bottomWeekdaySlider != nil && self.topWeekdaySlider != nil {
                            self.bottomWeekdaySlider.isHidden = false
                            self.topWeekdaySlider.isHidden = false
                        }
                   
                     

                        self.weekdayStartTime = self.fullScheduleList[index + 1]
                        self.weekdayEndTime = self.fullScheduleList[index + 2]


                        self.constructSlider(time: self.weekdayStartTime, labelTag: 111, trackerViewTag: 10000, sliderTag: 1000)
                        self.constructSlider(time: self.weekdayEndTime, labelTag: 222, trackerViewTag: 10000, sliderTag: 2000)
                        self.checkIfWeekendOrWeekday.insert(value)

                    }



                    if value == 1 {
                        if self.bottomWeekdaySlider != nil && self.topWeekendSlider != nil {
                            self.bottomWeekendSlider.isHidden = false
                            self.topWeekendSlider.isHidden = false
                        }
                 
                        self.weekendStartTime = self.fullScheduleList[index + 1]
                        self.weekendEndTime = self.fullScheduleList[index + 2]


                        self.constructSlider(time: self.weekendStartTime, labelTag: 333, trackerViewTag: 20000, sliderTag: 3000)
                        self.constructSlider(time: self.weekendEndTime, labelTag: 444, trackerViewTag: 20000, sliderTag: 4000)
                        self.checkIfWeekendOrWeekday.insert(value)
                    }



                }


                if !self.checkIfWeekendOrWeekday.contains(0) {
                    if self.topWeekdaySlider != nil && self.bottomWeekdaySlider != nil {
                        self.topWeekdaySlider.isHidden = true
                        self.bottomWeekdaySlider.isHidden = true
                    }
                   
                    self.constructSlider(time: 0, labelTag: 111, trackerViewTag: 10000, sliderTag: 1000)
                    self.constructSlider(time: 0, labelTag: 222, trackerViewTag: 10000, sliderTag: 2000)

                } else if !self.checkIfWeekendOrWeekday.contains(1) {
                    if self.topWeekendSlider != nil && self.bottomWeekendSlider != nil {
                        self.topWeekendSlider.isHidden = true
                        self.bottomWeekendSlider.isHidden = true
                    }
                
                    self.constructSlider(time: 0, labelTag: 333, trackerViewTag: 20000, sliderTag: 3000)
                    self.constructSlider(time: 0, labelTag: 444, trackerViewTag: 20000, sliderTag: 4000)
                }

            }
              readScheduleOnce = true
            
        }
      
        
        
    }
    
    
    /***********************************************************************************************************************
     
     MARK : Modify Light/Pump Image According To Schedule
     Change lights/pumps image to lights_on/pump_on if local time is in between the schedule time
     Note:
     1. We need to convert the local time in accordance to the slider value range to check if the local time is in between the two slider values
     
     ***********************************************************************************************************************/
    
    
    private func modifyLightORPumpImageAccordingToSchedule(){
        var localTimeSliderValue: Float = 0.0
        var computedLocalTime = 0
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.hour, .minute], from: currentDate)
        let localTime = (components.hour! * 100) + components.minute!
        
        if localTime < 600 {
            computedLocalTime = (localTime + 2400) / 100
        } else {
            computedLocalTime = localTime / 100
        }
        
        let computerLocalTimeRemainder = localTime % 100
        localTimeSliderValue = Float((computedLocalTime * 60) + computerLocalTimeRemainder)
        
        
        if topWeekdaySlider != nil && bottomWeekdaySlider != nil && topWeekendSlider != nil && bottomWeekendSlider != nil {
            if localTimeSliderValue >= topWeekdaySlider.value && localTimeSliderValue <= bottomWeekdaySlider.value ||
                localTimeSliderValue >= topWeekendSlider.value && localTimeSliderValue <= bottomWeekendSlider.value {
                if readServerPath == "readLights" {
                    scheduleIsOn = true
                } else if readServerPath == "readBasinPumpSch" {
                    scheduleIsOn = true
                } else if readServerPath == "readFire" {
                    scheduleIsOn = true
                } else if readServerPath == "readFillerShowSch" {
                    scheduleIsOn = true
                }
            } else {
                scheduleIsOn = false
            }
        }
        
  
    }
    
    
    /**********************************************************************************************************************
     
     MARK: Start Modifiying How Scheduler Look When View Appears
     
     ***********************************************************************************************************************/
    
    private func startModifyingSchedulerLook(){
        weekdayTrackerView.isUserInteractionEnabled = false
        weekendTrackerView.isUserInteractionEnabled = false
        modifyTimeIntervalImageView()
        modifySchedulerHeadLook()
    }
    
    
    /**********************************************************************************************************************
     
     MARK: Construct Slider and Frame of the Scheduler
     1. From the data extracted, this function will take care of how it would be presented to the user - taking account of what hour system the user uses (12 hr or 24 hour system)
     2. This function will be executed once unless called again.
     
     ***********************************************************************************************************************/
    
    private func constructSlider(time: Int, labelTag: Int, trackerViewTag: Int, sliderTag: Int){
        var added2400 = false
        var computedWeekValues = 0
        let slider = view.viewWithTag(sliderTag) as? UISlider
        let label = view.viewWithTag(labelTag) as? UILabel
        
        
        
        /*************************** Construct Top Slider 12 or 24 hours system ******************************************/
        
        if time < 600 {
            /* The Server uses a 24 (0-24) hour time system. For example, 12:53 AM would be written as 053 or 53 which means 60 is equivalent to 60 minutes or 1 hour.
             The time frame starts at 6 AM which is written as 600 on the server.
             If it's less than that then we add 2400 to mimic a 24 hour system. */
            computedWeekValues = (time + 2400) / 100
            added2400 = true
        } else {
            computedWeekValues = time / 100
            added2400 = false
        }
        
        let computedWeekRemainder =  time % 100
        
        switch functionCounter {
            /*Function counter counts how many times this function was called to make sure we have a start and end time values before we execute other functions.
             */
        case 0,2:
            addedTopSliderValues = (computedWeekValues * 60) + computedWeekRemainder
            if slider != nil {
               slider!.value = Float(addedTopSliderValues!)
            }
            
        case 1,3:
            addedBottomSliderValues = (computedWeekValues * 60) + computedWeekRemainder
            if slider != nil {
                slider!.value = Float(addedBottomSliderValues!)
            }
            
        default:
            break
        }
        
        
        var hour = 0
        let minutes = computedWeekRemainder
        
        switch is24hours {
        case true:
            if added2400 {
                hour = ((computedWeekValues * 100) - 2400) / 100
            } else {
                hour = computedWeekValues
            }
            
        case false:
            if added2400 {
                if computedWeekValues > 24 {
                    // Subtract 2400 so it would be equivalent to 12 AM
                    hour = ((computedWeekValues * 100) - 2400) / 100
                } else {
                    // Subtract 1200 so it would be equivalent to 12 PM
                    hour = ((computedWeekValues * 100) - 1200) / 100
                }
                
            } else if Int(computedWeekValues) >= 13 && Int(computedWeekValues) < 24 {
                // Subtract 1200 to mimic a 12 hour time system. For example, the server gave a value of 1300, subtract 1200 so it will be equivalent to 1 which means 1:00.
                hour = ((computedWeekValues * 100) - 1200) / 100
            } else {
                hour = computedWeekValues
            }
        }
        
        
        let formattedHour = String(format: "%02i", hour)
        let formattedMinutes = String(format: "%02i", minutes)
        
        switch is24hours {
          
        case true:
            if label !=  nil  {
                 label!.text = "\(formattedHour) : \(formattedMinutes)"
            }
           
            
        case false:
            if slider != nil && label != nil {
                if slider!.value <= 720 {
                    label!.text = "\(formattedHour) : \(formattedMinutes) AM"
                }
                
                if slider!.value >= 720 && slider!.value <= 1440 {
                    label!.text = "\(formattedHour) : \(formattedMinutes) PM"
                }
                
                if slider!.value >= 1440 {
                    label!.text = "\(formattedHour) : \(formattedMinutes) AM"
                }            }
       
        }
        
        if functionCounter == 3 {
            functionCounter = 0
            modifyLightORPumpImageAccordingToSchedule()
        } else {
            functionCounter += 1 
        }
        
        
        
        /* Construct Weekday Tracker View
         1. This function will only work when the top slider and bottom slider is not nil.
         */
        
        if addedTopSliderValues != nil && addedBottomSliderValues != nil {
            constructTrackerFrame(topSliderValues: addedTopSliderValues!, bottomSliderValue: addedBottomSliderValues!, trackerTag: trackerViewTag)
        } else {
            return
        }
        
    }
    
    
    /***********************************************************************************************************************
     
     MARK : Construck Tracker
     1. This function will only run once when the view appears unless called again
     
     ***********************************************************************************************************************/
    
    private func constructTrackerFrame(topSliderValues: Int, bottomSliderValue: Int, trackerTag: Int) {
        let pixelPerMinute = 600.0/1439.0
        let trackerView = view.viewWithTag(trackerTag)
        
        let convertedValue = (Double(topSliderValues) * pixelPerMinute) - 150.0
        
        trackerView?.frame = CGRect(x: convertedValue, y: 0.0, width: Double(bottomSliderValue - topSliderValues) * pixelPerMinute, height: 24.0)
        
        addedTopSliderValues = nil
        addedBottomSliderValues = nil
        
    }
    
    
    /***********************************************************************************************************************
     
     MARK : Slider Value Changed
     1. All four sliders are connected to this function
     2. Based on the slider's value, time will be computed depending on which hour system the user's using.
     
     ***********************************************************************************************************************/
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        var isAM = true
        var sliderRangeOkay = false
        var sliderValue: Float = 0.0
        var label = UILabel()
        var tracker = UIView()
        
        let pixelPerMinute = 600.0 / 1439.0
        
        switch sender.tag {
        case 1000:
            sliderValue = bottomWeekdaySlider.value
            label = weekdayStartTimeLabel
            tracker = weekdayTrackerView
        case 2000:
            sliderValue = topWeekdaySlider.value
            label = weekdayEndTimeLabel
            tracker = weekdayTrackerView
        case 3000:
            sliderValue = bottomWeekendSlider.value
            label = weekendStartTimeLabel
            tracker = weekendTrackerView
        case 4000:
            sliderValue = topWeekendSlider.value
            label = weekendEndTimeLabel
            tracker = weekendTrackerView
        default:
            print("No slider")
            
        }
        
        if sender.tag == 1000 || sender.tag == 3000 {
            if sender.value < sliderValue {
                let convertedValue = (Double(sender.value) * pixelPerMinute) - 150.0
                tracker.frame = CGRect(x: convertedValue, y: 0.0, width: Double(sliderValue - sender.value) * pixelPerMinute, height: 24.0)
                sliderRangeOkay = true
            } else {
                sender.value = sliderValue - 1
                sliderRangeOkay = true
            }
        } else if sender.tag == 2000 || sender.tag == 4000 {
            if sender.value > sliderValue {
                let xcoordinate = (Double(sliderValue) * pixelPerMinute) - 150.0
                tracker.frame = CGRect(x: xcoordinate, y: 0.0, width:  Double(sender.value - sliderValue) * pixelPerMinute, height: 24.0)
                sliderRangeOkay = true
            } else {
                sender.value = sliderValue + 1
                sliderRangeOkay = true
            }
        }
        
        if sliderRangeOkay {
            switch is24hours {
            case true:
                var hour = 0
                var minute = 0
                
                
                if sender.value <= 1440 {
                    
                    hour = Int(sender.value) / 60
                    minute = Int(sender.value.truncatingRemainder(dividingBy: 60))
                    let formattedHour = String(format: "%02i", hour)
                    let formattedMinute = String(format: "%02i", minute)
                    label.text = "\(formattedHour) : \(formattedMinute)"
                    
                } else {
                    
                    hour = (Int(sender.value) / 60) - 24
                    minute = Int(sender.value.truncatingRemainder(dividingBy: 60))
                    let formattedHour = String(format: "%02i", hour)
                    let formattedMinute = String(format: "%02i", minute)
                    label.text = "\(formattedHour) : \(formattedMinute)"
                    
                }
                
                if sender.tag == 1000 {
                    weekdayStartTime = Int("\(hour)\(minute)")!
                } else if sender.tag == 2000 {
                    weekdayEndTime = Int("\(hour)\(minute)")!
                } else if sender.tag == 3000 {
                    weekendStartTime = Int("\(hour)\(minute)")!
                } else if sender.tag == 4000 {
                    weekendEndTime = Int("\(hour)\(minute)")!
                }
                
                
            case false:
                
                if sender.value < 1440 {
                    
                    var hour = Int(sender.value) / 60
                    let minute = Int(sender.value.truncatingRemainder(dividingBy: 60))
                    let formattedMinute = String(format: "%02i", minute)
                    
                    if sender.tag == 1000 {
                        weekdayStartTime = Int("\(hour)\(formattedMinute)")!
                    } else if sender.tag == 2000 {
                        weekdayEndTime = Int("\(hour)\(formattedMinute)")!
                    } else if sender.tag == 3000 {
                        weekendStartTime = Int("\(hour)\(formattedMinute)")!
                    } else if sender.tag == 4000 {
                        weekendEndTime = Int("\(hour)\(formattedMinute)")!
                    }
                    
                    
                    if sender.value > 720 && sender.value < 780 {
                        isAM = false
                    }
                    
                    if sender.value > 780 && sender.value < 1440 {
                        hour -= 12
                        isAM = false
                    }
                    
                    let formattedHour = String(format: "%02i", hour)
                    
                    
                    if isAM {
                        label.text = "\(formattedHour) : \(formattedMinute) AM"
                    } else {
                        label.text = "\(formattedHour) : \(formattedMinute) PM"
                    }
                    
                    
                } else {
                    
                    var hour = (Int(sender.value) / 60)
                    let minute = Int(sender.value.truncatingRemainder(dividingBy: 60))
                    let formattedMinute = String(format: "%02i", minute)
                    
                    hour -= 24
                    
                    if sender.tag == 1000 {
                        weekdayStartTime = Int("\(hour)\(formattedMinute)")!
                    } else if sender.tag == 2000 {
                        weekdayEndTime = Int("\(hour)\(formattedMinute)")!
                    } else if sender.tag == 3000 {
                        weekendStartTime = Int("\(hour)\(formattedMinute)")!
                    } else if sender.tag == 4000 {
                        weekendEndTime = Int("\(hour)\(formattedMinute)")!
                    }
                    
                    
                    if sender.value > 1440 && sender.value < 1500 {
                        hour += 12
                    }
                    
                    let formattedHour = String(format: "%02i", hour)
                    
                    label.text = "\(formattedHour) : \(formattedMinute) AM"
                    
                }
            }
        }
    }
    
    
    
    /**********************************************************************************************************************
     
     1. Checks if user is dragging the slider or not.
     2. When user stopped dragging it will write the new schedule to the server
     ***********************************************************************************************************************/
    
    @IBAction func sliderDragInside(_ sender: UISlider) {
        isSliderDraggedInside = true
    }

    @objc func sliderDidEndSliding(_ sender: UISlider) {
        if !timePickerPresented {
            writeSchedule()
            
        }
    }
    
    
    /**********************************************************************************************************************
     
     1. We used an image to show the time interval on the scheduler.
     2. If user is using 12 hour system, we show a time interval image which ranges are from 6 am to 6 am, and vice versa.
     
     ***********************************************************************************************************************/
    
    private func modifyTimeIntervalImageView(){
        if is24hours {
            weekdayTimeIntervalImageView.image = #imageLiteral(resourceName: "WeekTimeInterval24")
            weekendTimeIntervalImageView.image = #imageLiteral(resourceName: "WeekTimeInterval24")
        } else {
            weekdayTimeIntervalImageView.image = #imageLiteral(resourceName: "WeekTimeInterval12")
            weekendTimeIntervalImageView.image = #imageLiteral(resourceName: "WeekTimeInterval12")
        }
    }
    
    
    /**********************************************************************************************************************
     1. Modify the way the head of the slider looked.
     
     ***********************************************************************************************************************/
    
    private func modifySchedulerHeadLook() {
        topWeekdaySlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowDown"), for: .normal)
        topWeekendSlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowDown"), for: .normal)
        bottomWeekdaySlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowUp"), for: .normal)
        bottomWeekendSlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowUp"), for: .normal)
        
        topWeekdaySlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowDown"), for: .highlighted)
        topWeekendSlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowDown"), for: .highlighted)
        bottomWeekdaySlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowUp"), for: .highlighted)
        bottomWeekendSlider.setThumbImage(#imageLiteral(resourceName: "scheduleArrowUp"), for: .highlighted)
        
        
    }
    
    /**********************************************************************************************************************
     1. Present the weekend popover to the user.
     
     ***********************************************************************************************************************/
    
    @IBAction func weekendButtonPressed(_ sender: UIButton) {
        if !fullScheduleList.isEmpty {
            let weekendPopover = UIStoryboard.init(name: "\(screen_Name)", bundle: nil).instantiateViewController(withIdentifier: "weekendView") as! WeekendViewController
            weekendPopover.schedulelist = fullScheduleList
            weekendPopover.weekendStartTime = weekendStartTime
            weekendPopover.weekendEndTime = weekendEndTime
            weekendPopover.weekdayStartTime = weekdayStartTime
            weekendPopover.weekdayEndTime = weekdayEndTime
            weekendPopover.modalPresentationStyle = UIModalPresentationStyle.popover
            weekendPopover.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
            weekendPopover.popoverPresentationController?.delegate = self
            weekendPopover.preferredContentSize = CGSize(width: 440.0, height: 225.0)
            weekendPopover.popoverPresentationController?.sourceView = self.view
            weekendPopover.popoverPresentationController?.sourceRect = CGRect(x: 85, y: 230, width: 0, height: 0)
            if readServerPath == "readWeirPumpSch" {
                weekendPopover.popoverPresentationController?.sourceRect = CGRect(x: 50, y:205, width: 0, height: 0)
                weekendPopover.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
            }
            
            present(weekendPopover, animated: false) {
                weekendPopover.view.superview?.layer.cornerRadius = 0
                
            }
        }

    }
    
    
    /**********************************************************************************************************************
     MARK: Write Schedule to the Server
     Note:
     1. Since we are using an array (fullschedulelist), we need to encode it using utf8. If not this function will not work **
     
     ***********************************************************************************************************************/
    
    
    private func writeSchedule(){
        
        for (index,value) in fullScheduleList.enumerated() where index % 3 == 0 {
            
            if value == 0 {
                fullScheduleList[index + 1] = weekdayStartTime
                fullScheduleList[index + 2] = weekdayEndTime
                
            }
            
            if value == 1 {
                fullScheduleList[index + 1] = weekendStartTime
                fullScheduleList[index + 2] = weekendEndTime
                
            }
        }
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: fullScheduleList, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: String.Encoding.utf8)
        let escapedDataString = jsonString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        print(writeServerPath)
        print("\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/\(writeServerPath)?\(escapedDataString!)")
        httpComm.httpGet(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/\(writeServerPath)?\(escapedDataString!)") { (response, success) in
            if success == true {
                readScheduleOnce = false
            }
        }

    }
    
    
    /**********************************************************************************************************************
     1. Present Time Picker Popover
     
     ***********************************************************************************************************************/
    
    @IBAction func presentTimePicker(_ sender: UISlider) {
        
        if !isSliderDraggedInside {
            timePickerPresented = true
            let weekSchedulerPopover = UIStoryboard.init(name: "\(screen_Name)", bundle: nil).instantiateViewController(withIdentifier: "weekSchedulerPopover") as! WeekSchedulerPopoverView
            weekSchedulerPopover.schedulelist = fullScheduleList
            weekSchedulerPopover.weekendStartTime = weekendStartTime
            weekSchedulerPopover.weekendEndTime = weekendEndTime
            weekSchedulerPopover.weekdayStartTime = weekdayStartTime
            weekSchedulerPopover.weekdayEndTime = weekdayEndTime
            weekSchedulerPopover.topWeekdaySliderValue = topWeekdaySlider.value
            weekSchedulerPopover.bottomWeekdaySliderValue = bottomWeekdaySlider.value
            weekSchedulerPopover.topWeekendSliderValue = topWeekendSlider.value
            weekSchedulerPopover.bottomWeekendSliderValue = bottomWeekendSlider.value
            weekSchedulerPopover.slider = sender.tag
            weekSchedulerPopover.modalPresentationStyle = UIModalPresentationStyle.popover
            weekSchedulerPopover.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            weekSchedulerPopover.popoverPresentationController?.delegate = self
            weekSchedulerPopover.preferredContentSize = CGSize(width: 300.0, height: 300.0)
            weekSchedulerPopover.popoverPresentationController?.sourceView = self.view
            weekSchedulerPopover.popoverPresentationController?.sourceRect = CGRect(x: sender.center.x, y: sender.center.y, width: 1, height: 1)
            
            
            present(weekSchedulerPopover, animated: false) {
                weekSchedulerPopover.view.superview?.layer.cornerRadius = 0
                
            }
            
            
        }
        
        isSliderDraggedInside = false
    }
    
}

