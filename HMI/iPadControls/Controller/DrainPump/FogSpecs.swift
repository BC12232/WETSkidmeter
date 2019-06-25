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

let FOG_FAULTS_121                 = (startAddr: 2252, count:4)
let FOG_PLAY_STOP_BIT_ADDR_121     = 2251
let FOG_ONSTATUS               = 7004
let FOG_JOCKEYPUMP_TRIGGER     = 6520
let FOG_BOOSTER_TRIGGER     = 6523

struct FOG_MOTOR_LIVE_VALUES{
    
    var pumpStart     = 0
    var pumpRunning   = 0
    var pumpFault     = 0
    var pumpOverLoad  = 0
    var pressureFault = 0
    var autoMode      = 0
    var pumpONOFF     = 0
}
