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

let READ_BACK_WASH                              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBW"
let FILTRATION_PUMP_NUMBERS                     = [101]
let READ_FILTRATION_SERVER_PATH                 = "readFilterSch"
let WRITE_FILTRATION_SERVER_PATH                = "writeFilterSch"
let FILTRATION_STATUS                           = (register: 2013,type:"EBOOL", count: 1)
let FILTRATION_ON_OFF_WRITE_REGISTERS           = [2012]
let FILTRATION_AUTO_HAND_PLC_REGISTER           = (register: 2010,type:"EBOOL", name: "Filtration_Auto_Man_mode")

/* SHOWN ON BACKWASH TAB ON EXCEL */
let FILTRATION_BW_DURATION_REGISTER             = 6514 // BW_Duration_SP
let FILTRATION_TOGGLE_BWASH_BIT                 = 4000 // BW1_Server_Trigger
let FILTRATION_VALVE_OPEN_CLOSE_TIME_BIT        = 6516 // Modified Timer/Times Tab on Spreadsheet. Check T_BW_Value
let FILTRATION_BWASH_RUNNING_BIT                = 4001 // BW1_Running
let FILTRATION_PUMP_FAULT                       = 1232

/* SHOWN ON PUMPS TAB ON EXCEL -- SHOULD SAY FILTRATION */
let FILTRATION_BWASH_SPEED_REGISTERS            = [1231] // Check BW_Speed address
let FILTRATION_PUMP_SPEED_ADDRESSESS            = [1225] // Use this if the fountain doesn't use the pump template, else we write pump number to read/write speed

/* SHOWN ON STRAINER TAB ON EXCEL -- SHOULD SAY FILTRATION */
let FILTRATION_CLEAN_STRAINER_START_BIT         = 4500 // Check spread sheet, see what's the first register
let FILTRATION_CLEAN_STRAINER_BIT_COUNT         = 4    // How many clean strainer does it have. Modify function that use this accordingly
let CONVERTED_FREQUENCY_LIMIT                   = 500  // Change to 600 if limit is 60 hertz. Change to 500 if limit is 50 hertz
let CONVERTED_BW_SPEED_LIMIT                    = 500  // Change to 600 if limit is 60 hertz. Change to 500 if limit is 50 hertz

/* MISC */
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





