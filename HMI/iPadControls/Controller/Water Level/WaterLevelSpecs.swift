//
//  WaterLevelSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/11/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation




//=============== Water Level Specs

public struct WATER_LEVEL_SENSOR_VALUES{
    
    var channelFault         = 0
    var below_l              = 0
    var below_ll             = 0
    var below_ll_2           = 0
    var below_lll            = 0
    var above_High           = 0
    var channelfault         = 0
    var waterMakeup          = 0
    var waterMakeupTimeout   = 0
    var above_high_timer     = 0
    var below_l_timer        = 0
    var below_ll_timer       = 0
    var below_lll_timer      = 0
    var makeup_timeout_timer = 0
    var systemShutDown       = 0
    var lightsOff            = 0
    var ls1002State          = 0
    var ls1003State          = 0
    var ls1004State          = 0
    var ls1005State          = 0
    var ls1006State          = 0
    var ls1007State          = 0
    var ls1008State          = 0
    var scaledValue          = 0.0
    var scaleMax             = 0.0
    var scaleMin             = 0.0
    var waterlevelTotalRange = 0.0
    var unitPixelsPerInch    = 0.0
}

let WATER_LEVEL_SETTINGS_SCREEN_SEGUE          = "waterLevelSettings"
let WATER_LEVEL_LANGUAGE_DATA_PARAM            = "waterLevel"

let WATER_LEVEL_SENSOR_BITS_LT1001             = (startBit: 3000, count: 8)
let WATER_LEVEL_SENSOR_BITS_LT1002             = (startBit: 3020, count: 8)
let WATER_LEVEL_SENSOR_BITS_LT1003             = (startBit: 3040, count: 8)



let ALL_WATER_LEVEL_BELOW_LL_REGISTER          = (register: 3003, count: 3)

let WATER_LEVEL_TIMER_BITS                     = (startBit: 6510, count: 4)
//Settings Page Timer Registers
//TYPE: INT

let WATER_LEVEL_LT1001_CHANNEL_FAULT_BIT       = 3000
let WATER_LEVEL_LT1001_SCALED_VALUE_BIT        = 3000
let WATER_LEVEL_LT1001_SCALED_MAX              = 3004
let WATER_LEVEL_LT1001_SCALED_MIN              = 3002
let WATER_LEVEL_ABOVE_H_SP                     = 3012
let WATER_LEVEL_LT1001_BELOW_L_SP              = 3010
let WATER_LEVEL_LT1001_BELOW_LL_SP             = 3008
let WATER_LEVEL_LT1001_BELOW_LLL_SP            = 3006
let WATER_LEVEL_SLIDER_HEIGHT                  = 450.0
let WATER_LEVEL_SLIDER_LOWER_COORDINATE        = 653.0
let WATER_LEVEL_SLIDER_UPPER_COORDINATE        = 203.0


let WATER_LEVEL_ABOVE_H_DELAY_TIMER            = 6510
let WATER_LEVEL_BELOW_L_TIMER                  = 6511
let WATER_LEVEL_BELOW_LL_TIMER                 = 6512
let WATER_LEVEL_BELOW_LLL_TIMER                = 6513
let WATER_MAKEUP_TIMEROUT_TIMER                = 6518

let LT1001_WATER_LEVEL_BELOW_LLL               = 3006
let LT1001_WATER_LEVEL_BELOW_LL                = 3008
let LT1001_WATER_LEVEL_BELOW_L                 = 3010
let LT1001_WATER_ABOVE_HI                      = 3012


let LT1002_WATER_LEVEL_BELOW_LLL               = 3026
let LT1002_WATER_LEVEL_BELOW_LL                = 3028
let LT1002_WATER_LEVEL_BELOW_L                 = 3030
let LT1002_WATER_ABOVE_HI                      = 3032


let LT1003_WATER_LEVEL_BELOW_LLL               = 3046
let LT1003_WATER_LEVEL_BELOW_LL                = 3048
let LT1003_WATER_LEVEL_BELOW_L                 = 3050
let LT1003_WATER_ABOVE_HI                      = 3052
