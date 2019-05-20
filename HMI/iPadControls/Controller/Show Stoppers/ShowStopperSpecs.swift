//
//  ShowStopperSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/11/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

/***************************************************************************
 * Section  :  SHOW STOPPERS
 * Comments :  Show stoppers register addresses must be taken from PLC specs
 *             to validate these registers, consult with Controls Engineers
 ***************************************************************************/

let SHOW_STOPPERS_PLC_REGISTERS = (startAddress: 0, type:"EBOOL", count: 11)


public struct ShowStoppers{
    
    var estop           = false
    var intrusion       = false
    var windSpeed       = false
    var waterLevel      = false
    var fireAlarm       = false
    
}
