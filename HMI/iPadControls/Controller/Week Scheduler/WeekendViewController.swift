//
//  WeekendViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 8/1/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class WeekendViewController: UIViewController {
  
    
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    
    
    var schedulelist = [Int]()
    var weekdayStartTime = Int()
    var weekdayEndTime = Int()
    var weekendStartTime = Int()
    var weekendEndTime = Int()
    private var setToWeekend = 0
    private let httpComm = HTTPComm()
    private let weekScheduler = WeekSchedulerViewController()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modifyWeekButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        writeSchedule()
    }
    
    
    /**********************************************************************************************************************
     MARK: Modify Week Buttons
     
     1. Using schedulelist this functions checks if a button is weekend or weekday if it has a border -> calls the proper function and modify its looks
     ***********************************************************************************************************************/
    
    private func modifyWeekButtons() {
        if !schedulelist.isEmpty {
            schedulelist[0] == 1 ? buttonIsHighlighted(button: sundayButton): buttonNotHighlighted(button: sundayButton)
            schedulelist[3] == 1 ? (buttonIsHighlighted(button: mondayButton)) : (buttonNotHighlighted(button: mondayButton))
            schedulelist[6] == 1 ? (buttonIsHighlighted(button: tuesdayButton)) : (buttonNotHighlighted(button: tuesdayButton))
            schedulelist[9] == 1 ? (buttonIsHighlighted(button: wednesdayButton)) : (buttonNotHighlighted(button: wednesdayButton))
            schedulelist[12] == 1 ? (buttonIsHighlighted(button: thursdayButton)) : (buttonNotHighlighted(button: thursdayButton))
            schedulelist[15] == 1 ? (buttonIsHighlighted(button: fridayButton)) : (buttonNotHighlighted(button: fridayButton))
            schedulelist[18] == 1 ? (buttonIsHighlighted(button: saturdayButton)) : (buttonNotHighlighted(button: saturdayButton))
        }
 
    }
    
    
    private func buttonIsHighlighted(button: UIButton){
        button.layer.borderWidth = 2.0
        button.layer.borderColor = WEEKEND_SELECTED_COLOR.cgColor
        button.setTitleColor(WEEKEND_SELECTED_COLOR, for: .normal)
    }
    
    
    private func buttonNotHighlighted(button: UIButton) {
        button.layer.borderWidth = 0.0
        button.setTitleColor(DEFAULT_GRAY, for: .normal)
    }
    
    
    /**********************************************************************************************************************
     MARK: Weekend Day Button Pressed
     
     1. Checks if a button is weekend or weekday if it has a border -> calls the proper function and modify its looks
     2. Sets the corresponding time if it's weekend or a weekday
     
     ***********************************************************************************************************************/
    
    @IBAction func dayButtonPressed(_ sender: UIButton) {
        if sender.layer.borderWidth == 2.0 {
            buttonNotHighlighted(button: sender)
            setToWeekend = 0
        } else {
            buttonIsHighlighted(button: sender)
            setToWeekend = 1
        }
        
        
        if setToWeekend == 1 {
            schedulelist[sender.tag] = setToWeekend
            schedulelist[sender.tag + 1] = weekendStartTime
            schedulelist[sender.tag + 2] = weekendEndTime
    
            
        } else {
            schedulelist[sender.tag] = setToWeekend
            schedulelist[sender.tag + 1] = weekdayStartTime
            schedulelist[sender.tag + 2] = weekdayEndTime
            
          
        }
        
    }
    
    
    /**********************************************************************************************************************
     MARK: Write Schedule to the Server
     Note:
     1. Since we are using an array (fullschedulelist), we need to encode it using utf8. If not this function will not work **
     
     ***********************************************************************************************************************/
   
    private func writeSchedule() {
        
        convertToJSON(object: schedulelist) { (dataString) in
            self.httpComm.httpGet(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/\(writeServerPath)?\(dataString!)") { (response, success) in
                if success == true {
                    
                

                    readScheduleOnce = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.weekScheduler.readLightsORPumpsData()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
       
        

        
//        httpComm.httpGetResponseFromPath(url: "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/\(writeServerPath)?\(escapedDataString!)"){ (response) in
//            readScheduleOnce = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                self.weekScheduler.readLightsORPumpsData()
//                self.dismiss(animated: true, completion: nil)
//            })
//        }
    }
    
    


    
    
}
