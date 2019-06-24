//
//  CascadeSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation



/***************************************************************************
 * Section  :  CASCADE/WALL SPECS
 * Comments :  This file is use for any pumps with scheduler. Just change the word which should be the path to access the server
 ***************************************************************************/

let READ_WATERSKIN_PUMPS_SERVER_PATH          = "readWeirPumpSch"
let WRITE_WATERSKIN_PUMPS_SERVER_PATH         = "writeWeirPumpSch"
let WATER_SKIN_STATUS                       = (startBit: 2003, count: 5)
let WATER_SKIN_AUTO_HAND_MODE               = 2000
let WATER_SKIN_ON_OFF_REGISTERS             = [2002, 2004, 2006]
let WATER_SKIN_PUMP_FAULTS_START_REGISTER   = 1246
let START_UP_FILTRATION_MIN_SPEED_CHECK     = 2000
let START_UP_FILTRATION_MIN_RUN_TIME        = 2001
let START_UP_P120_MIN_SPEED_CHECK           = 2002
let START_UP_P120_MIN_RUN_TIME              = 2003
let START_UP_P119_MIN_SPEED_CHECK           = 2004
let START_UP_P119_MIN_RUN_TIME              = 2005
let START_UP_SETTINGS_BIT                   = (startBit: 2000, count: 6)
