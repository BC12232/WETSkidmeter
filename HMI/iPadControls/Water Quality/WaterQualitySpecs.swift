//
//  WaterQualitySpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/18/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

//=============== Water Quality

let WQ_LIVE_SERVER_PATH            = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/WQ_Live"
let WQ_DAY_SERVER_PATH             = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/WQ_Day"

//Water Quality Channel Faults

let WQ_PH_CHANNEL_FAULT_BIT           = 300
let WQ_OPR_CHANNEL_FAULT_BIT          = 310
let WQ_TDS_CHANNEL_FAULT_BIT          = 320
let WQ_PH_SCALED_VALUE                = 300
let WQ_BR_DOSING_TIMEOUT_BIT          = 327
let WQ_BR_ENABLED_BIT                 = 325
let WQ_BR_DOSING                      = 326

//Water Quality Timers

let WQ_PH_TIMER_REGISTER              = 6501
let WQ_ORP_TIMER_REGISTER             = 6502
let WQ_TDS_TIMER_REGISTER             = 6503
let WQ_BROMINATOR_TIMEOUT_REGISTER    = 6519

//Water Quality Scale Min/ Max Real Value Addresses

//PH SCALE MIN : 302
//PH SCALE MAX : 304
//OPR SCALE MIN: 312
//ORP SCALE MAX: 314
//TDS SCALE MIN: 322
//TDS SCALE MAX: 324

let WQ_SCALE_MIN = 302
let WQ_SCALE_MAX = 304

//SETPOINTs - not used for this project

let WQ_ORP_TARGET_VAL_SP_ADDR_REAL   = 330
let WQ_ORP_HIGH_SP_ADDR_REAL         = 318
let WQ_ORP_LOW_SP_ADDR_REAL          = 316

//Water Quality Data Acquisition States

let WQ_LIVE_MODE_STATE                = 0
let WQ_DAY_MODE_STATE                 = 1
let WQ_WEEK_MODE_STATE                = 2

//Water Quality Data Setpoints

let WQ_GRAPH_LINE_WIDTH:CGFloat       = 1.5
let WQ_GRAPH_LINE_COLOR:UIColor       = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
let WQ_GRAPH_FILL_ALPHA:CGFloat       = 0.4

//Min and Max Sensor values based on PLC Specsheet

let WQ_PH_MAX_VAL                     = 14.0
let WQ_PH_MIN_VAL                     = 0.0

let WQ_BR_MAX_VAL                     = 1.0
let WQ_BR_MIN_VAL                     = 0.0

let WQ_ORP_MAX_VAL                    = 1000.0
let WQ_ORP_MIN_VAL                    = 0.0

let WQ_TDS_MAX_VAL                    = 1999.0
let WQ_TDS_MIN_VAL                    = 0.0

let WQ_PH_LOW_SP                      = 7.00
let WQ_PH_HI_SP                       = 8.00

let WQ_GRAPH_MAX_DATA_POINTS          = 900.0
let WQ_GRAPH_X_AXIS_RANGE:Double      = 900

let WQ_PH_VALUE_DIVISOR               = 100.0
