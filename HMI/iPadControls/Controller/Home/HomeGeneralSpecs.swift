//
//  HomeGeneralSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/10/18.
//  Copyright © 2018 WET. All rights reserved.
//


import UIKit

/***************************************************************************
 * Section  :  UI COLORS
 * Comments :  SET DEFAULT colors we can use
 ***************************************************************************/

let GREEN_COLOR                    = UIColor(red:130.0/255.0, green:190.0/255.0, blue:0.0/255.0, alpha:1.0)
let RED_COLOR                      = UIColor(red:235.0/255.0, green:30.0/255.0, blue:35.0/255.0, alpha:1.0)
let DEFAULT_GRAY                   = UIColor(red:200.0/255.0, green:200.0/255.0, blue: 200.0/255.0, alpha:1.0)
let HELP_SCREEN_GRAY               = UIColor(red:150/255, green: 150/255, blue: 150/255, alpha: 1.0)
let PICKER_VIEW_BG_COLOR           = UIColor(red:60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
let ORANGE_COLOR                   = UIColor(red:255.0/255.0, green:140.0/255.0, blue:0.0/255.0, alpha:1.0)
let BABY_BLUE_COLOR                = UIColor(red:0/255.0, green:166.0/255.0, blue:255.0/255.0, alpha:1.0)
let WEEKEND_SELECTED_COLOR         = UIColor(red: 0 / 255.0, green: 170.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)


/***************************************************************************
 * Section  : CONNECTION ERROR TEXTS
 * Comments :  Show's up when ipad cannot connect to server nor plc
 ***************************************************************************/


var DESIGNATE_SHOW_PATH                        = ""

let ERROR_PLC_COMM_FAILED                      = "PLC CONNECTION FAILED"
let ERROR_SERVER_COMM_FAILED                   = "SERVER CONNECTION FAILED"
let ERROR_PLC_AND_SERVER_COMM_FAILED           = "PLC AND SERVER CONNECTION FAILED"
let RAIN_SENSOR_STATUS_REGISTER              = 6000


/***************************************************************************
 * Section  : SYSTEM NETWORK SPECS
 * Comments : Always double check if the addresses & port are correct
 ***************************************************************************/
let PLC_IP_ADDRESS                 = "192.168.1.230"
let SERVER_IP_ADDRESS              = "192.168.1.1"
let SPM_IP_ADDRESS                 = "192.168.1.199"

//let PLC_IP_ADDRESS                 = "10.0.4.230"
//let SERVER_IP_ADDRESS              = "10.0.4.2"
//let SPM_IP_ADDRESS                 = "192.168.1.201"
let PLC_PORT:Int32                 = 502
let WARNING_RESET_REGISTER         = 10503
let FAULT_RESET_REGISTER           = 10504

/***************************************************************************
 * Section  : SERVER HTTP PATHS
 * Comments : These paths are used to connect to the server. Path may be written differently always check with Kranti
              This is also used to sync the time from the ipad to the server
 ***************************************************************************/

let HTTP_PASS                      = "http://wet_act:A3139gg1121@"
let READ_PLAYLIST_PATH             = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readPlaylists"
let READ_SHOWS_PATH                = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readShows"
let ERROR_LOG_FTP_PATH             = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readErrorLog"
let STATUS_LOG_FTP_PATH            = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readStatusLog"
let READ_SHOW_PLAY_STAT            = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readplayStatus"
let RESET_TIME_LAST_COMMAND        = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/setTimeLastCmnd"
let SERVER_TIME_PATH               = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readServerTime"
let READ_AUTOMAN_PATH              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/autoMan"
let PRESSURE_LIVE_SERVER_PATH      = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readPressure_Live"
let PRESSURE_DAY_SERVER_PATH       = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readPressure_Day"
let WEIR_PUMP_SERVER_PATH          = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readBasinPumpSch"
let LIGHTS_SERVER_PATH             = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readLights"
let READ_TIME_TABLE                = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readTimeTable"
let READ_PANDORA_STAT              = "\(HTTP_PASS)\(SERVER_IP_ADDRESS):8080/readPandoraStatus"
/***************************************************************************
 * Section  : SSH Credentials
 * Comments : Credentials to access the server
 ***************************************************************************/

let SSH_HOST_IP_ADDRESS            = "\(SERVER_IP_ADDRESS):22"
let SSH_USER_LOGIN                 = "root"
let SSH_USER_PASSWORD              = "A3139gg1121"
var setUDForConnection            = false


/***************************************************************************
 * Section  : PLC Addresses
 * Comments : These addresses are used to sync the ipad time to the PLC
 ***************************************************************************/


let SYSTEM_TIME_SECOND_PLC_ADDR     = 106
let SYSTEM_TIME_HOUR_MINUTE         = 107
let SYSTEM_TIME_DAY_MONTH_PLC_ADDR  = 108
let SYSTEM_TIME_YEAR_PLC_ADDR       = 109
let SYSTEM_TIME_TRIGGER_PLC_ADDR    = 110

/***************************************************************************
 * Section  : SYSTEM CONNECTION STATE
 * Comments : Variable for the state. These should not change
 ***************************************************************************/

let CONNECTION_STATE_INACTIVE      = 0
let CONNECTION_STATE_CONNECTING    = 1
let CONNECTION_STATE_CONNECTED     = 2
let CONNECTION_STATE_FAILED        = 3
let CONNECTION_STATE_POOR_CONNECTION = 4
let SHOW_CONNECTING                = 50
let MAX_CONNECTION_FAULTS          = 10
let MAX_CONNECTION_FAILED          = 20

/* Data Acquisition */

let DATA_ACQUISITION_TIME_INTERVAL = 1
let DATA_ACQUISITION_STATE_SUCCESS = 1
let DATA_ACQUISITION_STATE_FAILED  = 0
let FAULT_DETECTED                 = 1


/***************************************************************************
 * Section  : PLC CONVERSION
 * Comments : PLC returns this value when ever there is value of "1" as REAL number. So "1" = "5.87747e-39"
 ***************************************************************************/


let PLC_REAL_VALUE_ONE                    = "5.877472e-39"
let PLC_REAL_VALUE_ZERO                   = 5.8774717541114375e-39
let DEBUG_MODE                            = true



/***************************************************************************
 * Section  : SETTINGS SCREEN
 * Comments : Always change the four letter projectname (/act/projectname)
 ***************************************************************************/

let IPAD_NUMBER_USER_DEFAULTS_NAME = "iPadNum"
let CONTROLS_APP_UPDATE_URL        = "https://act:act@www.controlshelp.com/act/midf/index.php?"

/* To show the hidden settings click on the wet logo for more than 3 seconds, and type in the word "act"*/
let SETTINGS_ICON_TAG   = 99999

let QUADA_ICON_TAG       = 1
let QUADB_ICON_TAG       = 2
let QUADC_ICON_TAG       = 3
let QUADD_ICON_TAG       = 4

let LOGIN_BTN_INDEX     = 1
let APP_PASSWORD =      "act"
let QUAD_PASSWORD =     "wet"
let SETTINGS_SHOW_DELAY = 3.0


/***************************************************************************
 * Section  : IPAD SCREEN ORDER
 * Comments : Always change the four letter projectname (/act/projectname)
 ***************************************************************************/

/** IMPORTANT NOTE: Based on the project, the screen names should be placed in SCREENS array accordingly.
 **       The full list of screens in correct order are:
 **
 **
 **        playlist
 **        scheduler
 **        lights
 **        temperature
 **        pumps
 **        pumpSafety
 **        wind
 **        waterQuality
 **        waterLevel
 **        cascade
 **        filtration
 **        fire
 **        intrusion
 **        operationManual
 **        fog
 **        settings
 **        showList
 **
 **
 **/

let SCREENS = [
    
    "playlist",
    "scheduler",
    "lights",
    "systemstatus",
    "filtration",
    "waterskin",
    "fog",
    "waterQuality",
    "waterLevel",
    "",
    "pumps",
    "",
    "",
    "Projector",
    "fog",
    "settings",
    "showList"
    
];

let GET_FILLER_SHOW_SCH_HTTP_PATH  = "readFillerShowSch"
let SET_FILLER_SHOW_SCH_HTTP_PATH  = "writeFillerShowSch"



