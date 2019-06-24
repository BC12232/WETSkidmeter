//
//  FiltrationSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

/***************************************************************************
 * Section  :  FILTRATION SPECS
 * Comments :  Use this file to change and write the correct address
 * Note     :  Double check if the read and write server path is correct
 ***************************************************************************/

let READ_BACK_WASH1                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW1"
let READ_BACK_WASH2                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW2"
let READ_BACK_WASH3                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW3"
let FILTRATION_PUMP_NUMBER                      = 1001

/* NOTE For Filtration Scheduler.. Will leave just in case Kranti decided to add one */
let READ_FILTRATION_SERVER_PATH                 = "readFilterSch"
let WRITE_FILTRATION_SERVER_PATH                = "writeFilterSch"
let FILTRATION_STATUS                           = (register: 1200,type:"EBOOL", count: 15)
let FILTRATION_ON_OFF_WRITE_REGISTERS           = [1199,1213]
let FILTRATION_AUTO_HAND_PLC_REGISTER           = (register: 2010,type:"EBOOL", name: "Filtration_Auto_Man_mode")

/* SHOWN ON BACKWASH TAB ON EXCEL */
let FILTRATION_BW_DURATION_REGISTER             = 6514 // BW_Duration_SP
let FILTRATION_TOGGLE_BWASH_BIT_1               = 4002 // iPad_BW1_Trigger
let FILTRATION_BWASH_RUNNING_BIT_1              = 4003 // BW1_Running
let FILTRATION_TOGGLE_BWASH_BIT_2               = 4004 // iPad_BW2_Trigger
let FILTRATION_BWASH_RUNNING_BIT_2              = 4005 // BW2_Running
let FILTRATION_TOGGLE_BWASH_BIT_3               = 4006 // iPad_BW3_Trigger
let FILTRATION_BWASH_RUNNING_BIT_3              = 4007 // BW3_Running
let FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT        = 6516 // BW_ValveActuation_Time. If not present check timer tab

/* SHOWN ON PUMPS TAB ON EXCEL -- SHOULD SAY FILTRATION */
let FILTRATION_PUMP_FAULT                       = 1008   // Check Pump Fault
let FILTRATION_PUMP_FAULT_102                   = 1022
let FILTRATION_PUMP_FAULT_103                   = 1036
let FILTRATION_PUMP_FAULT_105                   = 1064


/* SHOWN ON STRAINER TAB ON EXCEL -- SHOULD SAY FILTRATION */
let FILTRATION_CLEAN_STRAINER_START_BIT         = 4500 // Check spread sheet, see what's the first register
let FILTRATION_CLEAN_STRAINER_BIT_COUNT         = 7    // How many clean strainer does it have. Modify function that use this accordingly
let CONVERTED_FREQUENCY_LIMIT                   = 500  // Change to 600 if limit is 60 hertz. Change to 500 if limit is 50 hertz
let CONVERTED_BW_SPEED_LIMIT                    = 500  // Change to 600 if limit is 60 hertz. Change to 500 if limit is 50 hertz

/* NOTE change 50.0 to 60.0 if limit is 60 hertz, if not leave it. Double check with Kranti*/
let FILTRATION_PIXEL_PER_BACKWASH               = 258.0 / 50.0
let PIXEL_PER_FREQUENCY                         = 258.0 / 50.0
let FILTRATION_PIXEL_PER_MANUAL_SPEED           = 258.0 / 50.0
let FILTRATION_PUMP_SPEED_INDICATOR_READ_LIMIT  = 2
let FILTRATION_BW_SPEED_INDICATOR_READ_LIMIT    = 2
let FILTRATION_PIXEL_PER_FREQUENCY              = 50.0 / 258.0
let CONVERTED_FILTRATION_PIXEL_PER_FREQUENCY    = Float(String(format: "%.2f", FILTRATION_PIXEL_PER_FREQUENCY))
let CONVERTED_FILTRATION_PIXEL_PER_BW           = Float(String(format: "%.2f", FILTRATION_PIXEL_PER_FREQUENCY))
let MAX_FILTRATION_BACKWASH_SPEED               = 50.0
let MAX_FILTRATION_FREQUENCY                    = 50.0
let DAY_PICKER_DATA_SOURCE                      = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"]






