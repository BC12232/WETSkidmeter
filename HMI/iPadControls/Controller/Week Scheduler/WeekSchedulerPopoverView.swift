//
//  WeekSchedulerPopoverView.swift
//  iPadControls
//
//  Created by Jan Manalo on 8/9/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

class WeekSchedulerPopoverView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var schedulelist = [Int]()
    var weekdayStartTime = Int()
    var weekdayEndTime = Int()
    var weekendStartTime = Int()
    var weekendEndTime = Int()
    var selectedHour = Int()
    var selectedMinute = Int()
    var selectedTimeOfDay = Int()
    var slider = Int()
    var time = 0
    var pickerView = UIPickerView()
    var loadedScheduler = 0
    
    var topWeekdaySliderValue: Float = 0.0
    var bottomWeekdaySliderValue: Float = 0.0
    var topWeekendSliderValue: Float = 0.0
    var bottomWeekendSliderValue: Float = 0.0
    
    var httpComm = HTTPComm()
    var weekScheduler = WeekSchedulerViewController()
    
    override func viewWillDisappear(_ animated: Bool) {
        timePickerPresented = false
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
 
    override func viewWillAppear(_ animated: Bool) {
        pickerView = view.viewWithTag(100) as! UIPickerView
        setSlidersValue()
    }
    
    private func setSlidersValue(){
        var setTime = 0
        
        switch slider {
        case 1000:
            setTime = weekdayStartTime
        case 2000:
            setTime = weekdayEndTime
        case 3000:
            setTime = weekendStartTime
        case 4000:
            setTime = weekendEndTime
        default:
            print("No Slider")
        }
        
        
        if is24hours {
            
            let hour = setTime / 100
            let minute = setTime % 100
            
            
            pickerView.selectRow(hour, inComponent: 0, animated: true)
            pickerView.selectRow(minute, inComponent: 1, animated: true)
            loadedScheduler = 1
            
            selectedHour = hour
            selectedMinute = minute
            
            
        } else {
            var hour = setTime / 100
            let minute = setTime % 100
            let timeOfDay = hour - 12
            
            
            // checks if its 12 AM
            if setTime < 60 {
                pickerView.selectRow(11, inComponent: 0, animated: true)
                pickerView.selectRow(minute, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                
                selectedHour = hour
                selectedMinute = minute
                selectedTimeOfDay = 0
                
                
            } else if timeOfDay == 0{
                //checks if it's 12 PM
                pickerView.selectRow(hour - 1, inComponent: 0, animated: true)
                pickerView.selectRow(minute, inComponent: 1, animated: true)
                pickerView.selectRow(1, inComponent: 2, animated: true)
                
                selectedHour = hour
                selectedMinute = minute
                selectedTimeOfDay = 0
                selectedTimeOfDay = 12
                
            } else if timeOfDay < 0 {
                //check if it's AM in general
                pickerView.selectRow(hour - 1, inComponent: 0, animated: true)
                pickerView.selectRow(minute, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                
                selectedHour = hour
                selectedMinute = minute
                selectedTimeOfDay = 0
                
            } else {
                //check if it's PM
                hour = timeOfDay
                
                pickerView.selectRow(hour - 1, inComponent: 0, animated: true)
                pickerView.selectRow(minute, inComponent: 1, animated: true)
                pickerView.selectRow(1, inComponent: 2, animated: true)
                
                selectedHour = hour 
                selectedMinute = minute
                selectedTimeOfDay = 12
                
            }
            
            self.loadedScheduler = 1
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if is24hours {
            return 2
        } else {
            return 3
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0{
            
            if is24hours {
                return 24
            } else {
                return 12
            }
            
        } else if component == 1{
            
            return 60
            
        } else {
            
            return 2
            
        }
        
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if is24hours {
            if component == 0 {
                return 60
            } else {
                return 80
            }
        } else if !is24hours {
            if component == 1{
                return 40
            } else {
                return 55
            }
        } else {
            return 0
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
                
            case 0 :
                pickerLabel?.textAlignment = .right
                
                if is24hours {
                    let formattedHour = String(format: "%02i", row)
                    pickerLabel?.text = "\(formattedHour)"
                } else {
                    pickerLabel?.text = "\(row + 1)"
                }
                
            case 1:
                let formattedMinutes = String(format: "%02i", row)
                pickerLabel?.text = ": \(formattedMinutes)"
                
            case 2:
                pickerLabel?.text = AM_PM_PICKER_DATA_SOURCE[row]
                
                
            default:
                pickerLabel?.text = "Error"
            }
            
        }
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        if component == 0 {
            if is24hours {
                selectedHour = row
            } else {
                selectedHour = row + 1
            }
            
        } else if component == 1 {
            selectedMinute = row
            
        } else {
            if !is24hours {
                if row == 0 {
                    selectedTimeOfDay = 0
                } else {
                    selectedTimeOfDay = 12
                }
            } else {
                selectedTimeOfDay = 0
            }
            
        }
        
    }
    
    //MARK: - Write Schedule
    
    private func writeSchedule() {

        //Checks which slider was being selected, and based on it we will know which should we set the time on
        
        switch slider {
        case 1000:
            weekdayStartTime = time
        case 2000:
            weekdayEndTime = time
        case 3000:
            weekendStartTime = time
        case 4000:
            weekendEndTime = time
        default:
            print("wrong slider")
        }
        
        
        for (index,value) in self.schedulelist.enumerated() where index % 3 == 0 {
            
            if value == 0 {
                if slider == 1000 {
                    schedulelist[index + 1] = weekdayStartTime
                } else if slider == 2000 {
                    schedulelist[index + 2] = weekdayEndTime
                }
            }
            
            if value == 1 {
                if slider == 3000 {
                    schedulelist[index + 1] = weekendStartTime
                } else if slider == 4000 {
                    schedulelist[index + 2] = weekendEndTime
                }
            }
        }

        
        let jsonData = try? JSONSerialization.data(withJSONObject: schedulelist, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: String.Encoding.utf8)
        let escapedDataString = jsonString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        httpComm.httpGet(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/\(writeServerPath)?\(escapedDataString!)") { (response, success) in
            if success == true {
                readScheduleOnce = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.weekScheduler.readLightsORPumpsData()
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
 
    }



    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if is24hours {
            time = (selectedHour * 100) + selectedMinute
        } else {
            time = ((selectedHour + selectedTimeOfDay) * 100)
            
            if time == 1200 {
                //12 AM
                time = (time * 0) + selectedMinute
            } else if time == 2400 {
                //12 PM
                time = (time - 1200) + selectedMinute
            } else {
                time += selectedMinute
            }
        }
        
        var computedWeekValues = 0
        var sliderValue: Float = 0.0
        /*************************** Compute Slider Values ******************************************/
        
        if time < 600 {
            computedWeekValues = (time + 2400) / 100
    
        } else {
            computedWeekValues = time / 100

        }
        
        let computedWeekRemainder =  time % 100
       
        sliderValue = Float((computedWeekValues * 60) + computedWeekRemainder)
        
        
        switch slider {
        case 1000:
            
            if sliderValue < bottomWeekdaySliderValue {
                writeSchedule()
            } else {
                return
            }
        case 2000:
            if sliderValue > topWeekdaySliderValue {
                writeSchedule()
            } else {
                return
            }
        case 3000:
            if sliderValue < bottomWeekendSliderValue {
                writeSchedule()
            } else {
                return
            }
        case 4000:
            if sliderValue > topWeekendSliderValue {
                writeSchedule()
            } else {
                return
            }
        default:
            print("Wrong Slider")
            
        }
        

    }
    

}



