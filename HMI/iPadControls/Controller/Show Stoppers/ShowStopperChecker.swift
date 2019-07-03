//=================================== ABOUT ===================================

/*
 *  @FILE:          ShowStopperChecker.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This module is respnsble for fetching all show stoppers from PLC
 *                  and showing them on iPad
 *  @VERSION:       2.0.0
 */

/***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Add or remove show stopper data structure items from ShowStoppers
 * 2 : Go to Specs.swift file in Show Stoppers section and modify the PLC
 *     address and number of sequentil addresses to read
 * 3 : check the processShowStoppers() function. Modify individual bits 
 *     if necessary
 * 4 : Check the ShowStopper.storyboard make sure all the icons are correct
 *     if not, modify them and re connect them to ShowStopperChecker view 
 *     controller. NOTE: Modifying the outlets will affect the 
 *     processShowStoppers() function. The IBoutlet calls have to be renamed
 *     accordingly
 * 5 : In order to integrate show stoppers in each page, simple add the
 *     following line in viewDidLoad:
 *     self.addShowStoppers()
 *     NOTE: This function is added as an extension of UIViewController
 *
 ***************************************************************************/

import UIKit



class ShowStopperChecker: UIViewController{

    @IBOutlet weak var estopIndicator: UIImageView!
    @IBOutlet weak var waterLevelIndicator: UIImageView!
    
    
    var showStoppers   = ShowStoppers()
    
    private var timer:   Timer?             //Timer that handles the show stoppers every second
    private let logger = Logger()           //Helper class to log fotmatted data for debugging purposes

    /***************************************************************************
     * Function :  awakeFromNib
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed first when view appears
     ***************************************************************************/
    
    override func viewDidAppear(_ animated: Bool){

        super.viewDidAppear(animated)

        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(DATA_ACQUISITION_TIME_INTERVAL), target: self, selector: #selector(ShowStopperChecker.getShowStoppers), userInfo: nil, repeats: true)
        self.timer?.fire()
        
    }

    /***************************************************************************
     * Function :  viewDidDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed when view disappears
     ***************************************************************************/
    
    override func viewDidDisappear(_ animated: Bool){
        
        //We want to make sure to close the timer to prevent multiple instances of it
        timer?.invalidate()
        self.logger.logData(data: "SHOW STOPPERS TIMER STOPPED")

    }

    /***************************************************************************
     * Function :  getShowStoppers
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func getShowStoppers(){
        
       CENTRAL_SYSTEM?.readBits(length: Int32(SHOW_STOPPERS_PLC_REGISTERS.count), startingRegister: Int32(SHOW_STOPPERS_PLC_REGISTERS.startAddress), completion: { (success, response) in
            
            guard response != nil else{
                return
            }

            //self.processShowStoppers(response: response!)
            
        })
        
    }

    /***************************************************************************
     * Function :  processShowStoppers
     * Input    :  show stopper states response from PLC
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func processShowStoppers(response:[AnyObject]){

        //Estop Show Stopper
        let estopNot_ok                 = Int(truncating: response[5] as! NSNumber)
        
//        //Water Level Show Stopper
        let channel_fault               = Int(truncating: response[6] as! NSNumber)
        let water_level_below_lll       = Int(truncating: response[7] as! NSNumber)
        
        if estopNot_ok == FAULT_DETECTED {
            self.showStoppers.estop = true
            self.estopIndicator.isHidden = false
        }else{
            self.showStoppers.estop = false
            self.estopIndicator.isHidden = true

        }


        if water_level_below_lll == FAULT_DETECTED || channel_fault == FAULT_DETECTED {

           self.showStoppers.waterLevel = true
            self.waterLevelIndicator.isHidden = false

        }else{

            self.showStoppers.waterLevel = false
            self.waterLevelIndicator.isHidden = true

        }

    }
    
}
