//
//  FogSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

/***************************************************************************
 * Section  :  FOG SPECS
 * Comments :  Use this file to change and write the correct address
 ***************************************************************************/

let FOG_AUTO_HAND_SWITCH_ADDRS_121 = (startAddr: 7002, count:2)
let FOG_AUTO_HAND_SWITCH_ADDRS_122 = (startAddr: 7006, count:2)
let FOG_AUTO_HAND_SWITCH_ADDRS_421 = (startAddr: 7010, count:2)
let FOG_AUTO_HAND_SWITCH_ADDRS_422 = (startAddr: 7014, count:2)
let FOG_FAULTS_121                 = (startAddr: 7101, count:4)
let FOG_FAULTS_122                 = (startAddr: 7106, count:4)
let FOG_FAULTS_421                 = (startAddr: 7111, count:4)
let FOG_FAULTS_422                 = (startAddr: 7116, count:4)
let FOG_FAULTS_413                 = 2263
let FOG_FAULTS_213                 = 2258
let PUMP_RUNNING               = 7101
let FOG_AUTO_HAND_BIT_ADDR     = 7000
let FOG_ZONE_STATS             = 7201
let FOG_PLAY_STOP_BIT_ADDR_121     = 7001
let FOG_PLAY_STOP_BIT_ADDR_122     = 7005
let FOG_PLAY_STOP_BIT_ADDR_421     = 7009
let FOG_PLAY_STOP_BIT_ADDR_422     = 7013
let FOG_ONSTATUS               = 7004
let FOG_JOCKEYPUMP_TRIGGER     = 6520
let FOG_BOOSTER_TRIGGER     = 6523

struct FOG_MOTOR_LIVE_VALUES{
    
    var pumpStart     = 0
    var pumpRunning   = 0
    var pumpFault     = 0
    var pumpOverLoad  = 0
    var pressureFault = 0
    var pumpStart122     = 0
    var pumpRunning122   = 0
    var pumpFault122     = 0
    var pumpOverLoad122  = 0
    var pressureFault122 = 0
    var pumpStart421    = 0
    var pumpRunning421   = 0
    var pumpFault421     = 0
    var pumpOverLoad421  = 0
    var pressureFault421 = 0
    var pumpStart422     = 0
    var pumpRunning422   = 0
    var pumpFault422     = 0
    var pumpOverLoad422  = 0
    var pressureFault422 = 0
    var autoMode      = 0
    var pumpONOFF     = 0
}
