function statusLogWrapper(){

    //console.log("StatusLog script triggered");

    var totalStatus;
    var data = [];
    var status_temperature = [];
    var status_windSensor = [];
    var fault_PUMPS = [];
    var status_WaterLevel = [];
    var status_WaterQuality = [];
    var status_LIGHTS = [];
    var fault_ESTOP = [];
    var fault_INTRUSION = [];
    var fault_FOG = [];
    var status_AirPressure = [];
    var fault_BMS = [];
    var status_Ethernet = [];
    var fault_ShowStoppers = [];
    var status_filtration = [];

if (PLCConnected){
    plc_client.readCoils(0,145,function(resp){
        
        if (resp != undefined && resp != null){

            //EStop
            fault_ESTOP.push(resp.coils[1] ? resp.coils[1] : 0); //E-Stop Status
            var estopIndex = 42;//dhir
            fault_ESTOP.push(resp.coils[estopIndex] ? resp.coils[estopIndex] : 0); //CP 101
            fault_ESTOP.push(resp.coils[estopIndex+1] ? resp.coils[estopIndex+1] : 0); //CP 102
            fault_ESTOP.push(resp.coils[estopIndex+2] ? resp.coils[estopIndex+2] : 0); //CP 103
            fault_ESTOP.push(resp.coils[estopIndex+3] ? resp.coils[estopIndex+3] : 0); //CP 104
            fault_ESTOP.push(resp.coils[estopIndex+4] ? resp.coils[estopIndex+4] : 0); //FCP 101
            fault_ESTOP.push(resp.coils[estopIndex+5] ? resp.coils[estopIndex+5] : 0); //RES 101
            fault_ESTOP.push(resp.coils[estopIndex+6] ? resp.coils[estopIndex+6] : 0); //SPP 101
            fault_ESTOP.push(resp.coils[estopIndex+7] ? resp.coils[estopIndex+7] : 0); //SPP 102
            fault_ESTOP.push(resp.coils[estopIndex+8] ? resp.coils[estopIndex+8] : 0); //SPP 103
            fault_ESTOP.push(resp.coils[estopIndex+9] ? resp.coils[estopIndex+9] : 0); //MCC 101
            fault_ESTOP.push(resp.coils[estopIndex+10] ? resp.coils[estopIndex+10] : 0); //MCC 102
            fault_ESTOP.push(resp.coils[estopIndex+11] ? resp.coils[estopIndex+11] : 0); //MCC 103
            fault_ESTOP.push(resp.coils[estopIndex+12] ? resp.coils[estopIndex+12] : 0); //MCC 104

            // Show Stoppers - dhir
            fault_ShowStoppers.push(resp.coils[5] ? resp.coils[5] : 0); //EStop
            fault_ShowStoppers.push(resp.coils[6] ? resp.coils[6] : 0); //Intrusion
            fault_ShowStoppers.push(resp.coils[7] ? resp.coils[7] : 0); //Water Level Below LLL
            fault_ShowStoppers.push(resp.coils[8] ? resp.coils[8] : 0); //Water Level Below LLL
            fault_ShowStoppers.push(resp.coils[9] ? resp.coils[9] : 0); //Water Level Below LLL
            fault_ShowStoppers.push(resp.coils[10] ? resp.coils[10] : 0); //Speed Abort Show
            fault_ShowStoppers.push(resp.coils[11] ? resp.coils[11] : 0); //Speed Abort Show
            fault_ShowStoppers.push(resp.coils[12] ? resp.coils[12] : 0); //Supervisory Station
            fault_ShowStoppers.push(resp.coils[13] ? resp.coils[13] : 0); //LEL Above Hi
            fault_ShowStoppers.push(resp.coils[14] ? resp.coils[14] : 0); //LEL Channel Fault
            fault_ShowStoppers.push(resp.coils[15] ? resp.coils[15] : 0); //not_assigned
            fault_ShowStoppers.push(resp.coils[16] ? resp.coils[16] : 0); //not_assigned
            fault_ShowStoppers.push(resp.coils[17] ? resp.coils[17] : 0); //not_assigned
            fault_ShowStoppers.push(resp.coils[18] ? resp.coils[18] : 0); //not_assigned
            fault_ShowStoppers.push(resp.coils[19] ? resp.coils[19] : 0); //not_assigned
            fault_ShowStoppers.push(resp.coils[20] ? resp.coils[20] : 0); //not_assigned
            
            // Wind Speed - dhir
            status_windSensor.push(resp.coils[21] ? resp.coils[21] : 0); // ST1001_Speed_Channel_Fault
            status_windSensor.push(resp.coils[22] ? resp.coils[22] : 0); // ST1001_Above_Hi
            status_windSensor.push(resp.coils[23] ? resp.coils[23] : 0); // ST1001_Below_Lo
            status_windSensor.push(resp.coils[24] ? resp.coils[24] : 0); // ST1001_Drctn_Channel_Fault

            status_windSensor.push(resp.coils[25] ? resp.coils[25] : 0); // ST1002_Speed_Channel_Fault
            status_windSensor.push(resp.coils[26] ? resp.coils[26] : 0); // ST1002_Above_Hi
            status_windSensor.push(resp.coils[27] ? resp.coils[27] : 0); // ST1002_Below_Lo
            status_windSensor.push(resp.coils[28] ? resp.coils[28] : 0); // ST1002_Drctn_Channel_Fault

            // Pressure Sensor
            status_AirPressure.push(0); // PT1001_Channel_Fault

            // Water Level Sensor
            var WL_Index = 29; //dhir
            status_WaterLevel.push(resp.coils[WL_Index] ? resp.coils[WL_Index] : 0); // LT 1001 Channel Fault
            status_WaterLevel.push(resp.coils[WL_Index+1] ? resp.coils[WL_Index+1] : 0); // LT 1001 Water makeup
            status_WaterLevel.push(resp.coils[WL_Index+2] ? resp.coils[WL_Index+2] : 0); // LT 1001 Water makeup TImeout
            status_WaterLevel.push(resp.coils[WL_Index+3] ? resp.coils[WL_Index+3] : 0); // LT 1002 Channel Fault
            status_WaterLevel.push(resp.coils[WL_Index+4] ? resp.coils[WL_Index+4] : 0); // LT 1003 Channel Fault

            // Water Temperature
            status_temperature.push(0); // TT1001_ChanneL_Fault

            // Pumps
            var pumpIndex = 103; //dhir
            fault_PUMPS.push(resp.coils[pumpIndex] ? resp.coils[pumpIndex] : 0); // VFD 101 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+1] ? resp.coils[pumpIndex+1] : 0); // VFD 102 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+2] ? resp.coils[pumpIndex+2] : 0); // VFD 103 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+3] ? resp.coils[pumpIndex+3] : 0); // VFD 104 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+4] ? resp.coils[pumpIndex+4] : 0); // VFD 105 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+5] ? resp.coils[pumpIndex+5] : 0); // VFD 106 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+6] ? resp.coils[pumpIndex+6] : 0); // VFD 107 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+7] ? resp.coils[pumpIndex+7] : 0); // VFD 108 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+8] ? resp.coils[pumpIndex+8] : 0); // VFD 109 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+9] ? resp.coils[pumpIndex+9] : 0); // VFD 110 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+10] ? resp.coils[pumpIndex+10] : 0); // VFD 111 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+11] ? resp.coils[pumpIndex+11] : 0); // VFD 112 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+12] ? resp.coils[pumpIndex+12] : 0); // VFD 113 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+13] ? resp.coils[pumpIndex+13] : 0); // VFD 114 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+14] ? resp.coils[pumpIndex+14] : 0); // VFD 115 Fault
            fault_PUMPS.push(resp.coils[pumpIndex+15] ? resp.coils[pumpIndex+15] : 0); // VFD 116 Fault

            // Lights
            var lightIndex = 55;
            status_LIGHTS.push(resp.coils[lightIndex] ? resp.coils[lightIndex] : 0); // Lights Auto Manual Mode
            // status_LIGHTS.push(resp.coils[lightIndex+1] ? resp.coils[lightIndex+1] : 0); // LCP101 Status
            // status_LIGHTS.push(resp.coils[lightIndex+2] ? resp.coils[lightIndex+2] : 0); // LCP102 Status
            // status_LIGHTS.push(resp.coils[lightIndex+3] ? resp.coils[lightIndex+3] : 0); // LCP103 Status

            //Ethernet Status
            var ethernetIndex = 121;//dhir
            status_Ethernet.push(resp.coils[ethernetIndex] ? resp.coils[ethernetIndex] : 0); // VFD_100A
            status_Ethernet.push(resp.coils[ethernetIndex+1] ? resp.coils[ethernetIndex+1] : 0); // VFD_102
            status_Ethernet.push(resp.coils[ethernetIndex+2] ? resp.coils[ethernetIndex+2] : 0); // VFD_103
            status_Ethernet.push(resp.coils[ethernetIndex+3] ? resp.coils[ethernetIndex+3] : 0); // VFD_104
            status_Ethernet.push(resp.coils[ethernetIndex+4] ? resp.coils[ethernetIndex+4] : 0); // VFD_105
            status_Ethernet.push(resp.coils[ethernetIndex+5] ? resp.coils[ethernetIndex+5] : 0); // VFD_106
            status_Ethernet.push(resp.coils[ethernetIndex+6] ? resp.coils[ethernetIndex+6] : 0); // VFD_107
            status_Ethernet.push(resp.coils[ethernetIndex+7] ? resp.coils[ethernetIndex+7] : 0); // VFD_108
            status_Ethernet.push(resp.coils[ethernetIndex+8] ? resp.coils[ethernetIndex+8] : 0); // VFD_109
            status_Ethernet.push(resp.coils[ethernetIndex+9] ? resp.coils[ethernetIndex+9] : 0); // VFD_110
            status_Ethernet.push(resp.coils[ethernetIndex+10] ? resp.coils[ethernetIndex+10] : 0); // VFD_111
            status_Ethernet.push(resp.coils[ethernetIndex+11] ? resp.coils[ethernetIndex+11] : 0); // VFD_112
            status_Ethernet.push(resp.coils[ethernetIndex+12] ? resp.coils[ethernetIndex+12] : 0); // VFD_113
            status_Ethernet.push(resp.coils[ethernetIndex+13] ? resp.coils[ethernetIndex+13] : 0); // VFD_114
            status_Ethernet.push(resp.coils[ethernetIndex+14] ? resp.coils[ethernetIndex+14] : 0); // VFD_115
            status_Ethernet.push(resp.coils[ethernetIndex+15] ? resp.coils[ethernetIndex+15] : 0); // VFD_116
            status_Ethernet.push(resp.coils[ethernetIndex+16] ? resp.coils[ethernetIndex+16] : 0); // VFD_117
            status_Ethernet.push(resp.coils[ethernetIndex+17] ? resp.coils[ethernetIndex+17] : 0); // VFD_118
            status_Ethernet.push(resp.coils[ethernetIndex+18] ? resp.coils[ethernetIndex+18] : 0); // VFD_119
            status_Ethernet.push(resp.coils[ethernetIndex+19] ? resp.coils[ethernetIndex+19] : 0); // VFD_120
            status_Ethernet.push(resp.coils[ethernetIndex+20] ? resp.coils[ethernetIndex+20] : 0); // FCP 101
            status_Ethernet.push(resp.coils[ethernetIndex+21] ? resp.coils[ethernetIndex+21] : 0); // SPP 101
            status_Ethernet.push(resp.coils[ethernetIndex+22] ? resp.coils[ethernetIndex+22] : 0); // bender

            //Filtration System Status
            var filtrationStatus = 56; //dhir
            status_filtration.push(resp.coils[filtrationStatus] ? resp.coils[filtrationStatus] : 0);//Filtration Pump Fault
            status_filtration.push(resp.coils[filtrationStatus+1] ? resp.coils[filtrationStatus+1] : 0);//Pump Press Fault
            status_filtration.push(resp.coils[filtrationStatus+2] ? resp.coils[filtrationStatus+2] : 0);//BackWash Running

            var WQ_Index = 34;//dhir
            status_WaterQuality.push(resp.coils[WQ_Index] ? resp.coils[WQ_Index] : 0);//pH channel Fault
            status_WaterQuality.push(resp.coils[WQ_Index+1] ? resp.coils[WQ_Index+1] : 0);//ORP channel Fault
            status_WaterQuality.push(resp.coils[WQ_Index+2] ? resp.coils[WQ_Index+2] : 0);//TDS channel Fault
            status_WaterQuality.push(resp.coils[WQ_Index+3] ? resp.coils[WQ_Index+3] : 0);//Bromine Valve
            status_WaterQuality.push(resp.coils[WQ_Index+4] ? resp.coils[WQ_Index+4] : 0);//Br Enable
            status_WaterQuality.push(resp.coils[WQ_Index+5] ? resp.coils[WQ_Index+5] : 0);//Br Timeout
            status_WaterQuality.push(resp.coils[WQ_Index+6] ? resp.coils[WQ_Index+6] : 0);//Ozone Generator
            status_WaterQuality.push(resp.coils[WQ_Index+7] ? resp.coils[WQ_Index+7] : 0);//P121 Pump Fault

            showStopper = 0;
            for (var i=0; i <= (fault_ShowStoppers.length-2); i++){
                showStopper = showStopper + fault_ShowStoppers[i];
            }

            totalStatus = [fault_ESTOP,
                            fault_ShowStoppers,
                            status_windSensor,
                            status_AirPressure,
                            status_WaterLevel,
                            status_temperature,
                            fault_PUMPS,
                            status_LIGHTS,
                            status_Ethernet,
                            fault_BMS,
                            status_filtration,
                            status_WaterQuality];

            totalStatus = bool2int(totalStatus);

            if (devStatus.length > 1) {
                logChanges(totalStatus); // detects change of total status
                if  ((devStatus[7][0] === 0) && (totalStatus[7][0] === 1)){
                    //Lights toggled to Manual Mode
                    dayMode = 1;//turn dayMode ON so that the lights are OFF
                    watchDog.eventLog('dayMode set to  ' +dayMode);
                }
            }

            devStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            sysStatus = [{
                            "EStop": fault_ESTOP,
                            "PlayMode": autoMan,
                            "playStatus":playing,
                            "CurrentShow":show,
                            "deflate":deflate,
                            "nextShowTime": nxtTime,
                            "nextShowNumber": nxtShow,
                            "timeLastCmnd": timeLastCmnd,
                            "spm_RAT_Mode":spmRATMode,
                            "dayMode": dayModeStatus,
                            "ShowStoppers": fault_ShowStoppers,
                            "Temp":status_temperature,
                            "Wind_Sensors":status_windSensor,
                            "PumpFaults":fault_PUMPS,
                            "WaterLevel":status_WaterLevel,
                            "WaterFilter": status_filtration,
                            "statusLights": status_LIGHTS,
                            "Filtration": status_filtration,
                            "WaterQuality": status_WaterQuality,
                            "BMS_Status": fault_BMS,
                            "JumpToStepAuto": jumpToStep_auto,
                            "JumpToStepManual": jumpToStep_manual,
                            "SPM_Heartbeat": SPM_Heartbeat,
                            "SPM_Modbus_Connection": SPMConnected,
                            "PLC_Heartbeat": PLC_Heartbeat,
                            "PLC_Modbus _Connection": PLCConnected,
                            }];

            playStatus = [{
                            "Play Mode": autoMan,
                            "play status":playing,
                            "Current Show":show,
                            "deflate":deflate,
                            "next Show Time": nxtTime,
                            "next Show Num": nxtShow
                            }];
        
        }
    });//end of first PLC modbus call
}

if (SPMConnected){
    if(playing===1){
       plc_client.writeSingleCoil(3,1,function(resp){});
    }
    else{
      plc_client.writeSingleCoil(3,0,function(resp){});
    }
}

    // compares current state to previous state to log differences
    function logChanges(currentState){
        // {"yes":"n/a","no":"n/a"} object template for detection but no logging... "n/a" disables log
        // {"yes":"positive edge message","no":"negative edge message"} object template for detection and logging
        // pattern of statements must match devStatus and totalStatus format
        var statements=[

            [   // estop - dhir
                {"yes":"ESTOP Resolved","no":"ESTOP Engaged"},
                {"yes":"CP101 ESTOP Engaged","no":"CP101 ESTOP Resolved"},
                {"yes":"CP102 ESTOP Engaged","no":"CP102 ESTOP Resolved"},
                {"yes":"CP103 ESTOP Engaged","no":"CP103 ESTOP Resolved"},
                {"yes":"CP104 ESTOP Engaged","no":"CP104 ESTOP Resolved"},
                {"yes":"FCP101 ESTOP Engaged","no":"FCP101 ESTOP Resolved"},
                {"yes":"RES101 ESTOP Engaged","no":"RES101 ESTOP Resolved"},
                {"yes":"SPP101 ESTOP Engaged","no":"SPP101 ESTOP Resolved"},
                {"yes":"SPP102 ESTOP Engaged","no":"SPP102 ESTOP Resolved"}, 
                {"yes":"SPP103 ESTOP Engaged","no":"SPP103 ESTOP Resolved"},
                {"yes":"MCC101 ESTOP Engaged","no":"MCC101 ESTOP Resolved"}, 
                {"yes":"MCC102 ESTOP Engaged","no":"MCC102 ESTOP Resolved"},
                {"yes":"MCC103 ESTOP Engaged","no":"MCC103 ESTOP Resolved"}, 
                {"yes":"MCC104 ESTOP Engaged","no":"MCC104 ESTOP Resolved"},          
            ],

            [   // Show Stopper - dhir
                {"yes":"Show Stopper: EStop","no":"Show Stopper Resolved: EStop"},
                {"yes":"Show Stopper: Intrusion Detected","no":"Show Stopper Resolved: Intrusion"},
                {"yes":"Show Stopper: LT1001 Water Level LLL","no":"Show Stopper Resolved: LT1001 Water Level LLL"},
                {"yes":"Show Stopper: LT1002 Water Level LLL","no":"Show Stopper Resolved: LT1002 Water Level LLL"},
                {"yes":"Show Stopper: LT1003 Water Level LLL","no":"Show Stopper Resolved: LT1003 Water Level LLL"},
                {"yes":"Show Stopper: ST1001 Wind Speed Abort","no":"Show Stopper Resolved: ST1001 Wind Speed Abort"},
                {"yes":"Show Stopper: ST1002 Wind Speed Abort","no":"Show Stopper Resolved: ST1002 Wind Speed Abort"},
                {"yes":"Show Stopper: SS101 Alarm","no":"Show Stopper Resolved: SS101 Alarm"},
                {"yes":"Show Stopper: LEL Above Hi","no":"Show Stopper Resolved: LEL Above Hi"},
                {"yes":"Show Stopper: LEL Channel Fault","no":"Show Stopper Resolved: LEL Channel Fault"},
            ],

            [   // anemometer - dhir
                {"yes":"ST1001 Speed Channel Fault","no":"ST1001 Speed Channel Fault Resolved"},
                {"yes":"ST1001 Wind Speed Above Hi","no":"ST1001 Wind Speed Okay"},
                {"yes":"ST1001 Wind Speed Below Low","no":"ST1001 Wind Speed Okay"},
                {"yes":"ST1001 Direction Channel Fault","no":"ST1001 Direction Channel Fault Resolved"},

                {"yes":"ST1002 Speed Channel Fault","no":"ST1002 Speed Channel Fault Resolved"},
                {"yes":"ST1002 Wind Speed Above Hi","no":"ST1002 Wind Speed Okay"},
                {"yes":"ST1002 Wind Speed Below Low","no":"ST1002 Wind Speed Okay"},
                {"yes":"ST1002 Direction Channel Fault","no":"ST1002 Direction Channel Fault Resolved"},
            ],

            [   
                // Pressure Sensors
            ],

            [   // water level - dhir
                {"yes":"LT 1001 Channel Fault","no":"Resolved: LT 1001 Channel Fault"},
                {"yes":"LT 1001 Water Makeup ON","no":"LT1001 Water Makeup OFF"},
                {"yes":"LT 1001 Timeout : Water Makeup","no":"Resolved: LT1001 Watermakeup Timeout"},
                {"yes":"LT 1002 Channel Fault","no":"Resolved: LT 1002 Channel Fault"},
                {"yes":"LT 1003 Channel Fault","no":"Resolved: LT 1003 Channel Fault"},
            ],

            [   
                // temperature
            ],

            [   // pumps - dhir
                {"yes":"P101 Pump Fault","no":"Resolved: P101 Pump Fault"},  
                {"yes":"P102 Pump Fault","no":"Resolved: P102 Pump Fault"}, 
                {"yes":"P103 Pump Fault","no":"Resolved: P103 Pump Fault"}, 
                {"yes":"P104 Pump Fault","no":"Resolved: P104 Pump Fault"}, 
                {"yes":"P105 Pump Fault","no":"Resolved: P105 Pump Fault"}, 
                {"yes":"P106 Pump Fault","no":"Resolved: P106 Pump Fault"}, 
                {"yes":"P107 Pump Fault","no":"Resolved: P107 Pump Fault"}, 
                {"yes":"P108 Pump Fault","no":"Resolved: P108 Pump Fault"}, 
                {"yes":"P109 Pump Fault","no":"Resolved: P109 Pump Fault"},  
                {"yes":"P110 Pump Fault","no":"Resolved: P110 Pump Fault"}, 
                {"yes":"P111 Pump Fault","no":"Resolved: P111 Pump Fault"},  
                {"yes":"P112 Pump Fault","no":"Resolved: P112 Pump Fault"}, 
                {"yes":"P113 Pump Fault","no":"Resolved: P113 Pump Fault"}, 
                {"yes":"P114 Pump Fault","no":"Resolved: P114 Pump Fault"}, 
                {"yes":"P115 Pump Fault","no":"Resolved: P115 Pump Fault"}, 
                {"yes":"P116 Pump Fault","no":"Resolved: P116 Pump Fault"},                 
            ],

            [   // lights - NOT set for dhir
                {"yes":"Lights are on Manual","no":"Lights are on Auto"},
            ],

            [   //Ethernet Status
                {"yes":"VFD101 Online","no":"VFD101 Offline"},
                {"yes":"VFD102 Online","no":"VFD102 Offline"},
                {"yes":"VFD103 Online","no":"VFD103 Offline"},
                {"yes":"VFD104 Online","no":"VFD104 Offline"},
                {"yes":"VFD105 Online","no":"VFD105 Offline"},
                {"yes":"VFD106 Online","no":"VFD106 Offline"},
                {"yes":"VFD107 Online","no":"VFD107 Offline"},
                {"yes":"VFD108 Online","no":"VFD108 Offline"},
                {"yes":"VFD109 Online","no":"VFD109 Offline"},
                {"yes":"VFD110 Online","no":"VFD110 Offline"},
                {"yes":"VFD111 Online","no":"VFD111 Offline"},
                {"yes":"VFD112 Online","no":"VFD112 Offline"},
                {"yes":"VFD113 Online","no":"VFD113 Offline"},
                {"yes":"VFD114 Online","no":"VFD114 Offline"},
                {"yes":"VFD115 Online","no":"VFD115 Offline"},
                {"yes":"VFD116 Online","no":"VFD116 Offline"},
                {"yes":"VFD117 Online","no":"VFD117 Offline"},
                {"yes":"VFD118 Online","no":"VFD118 Offline"},
                {"yes":"VFD119 Online","no":"VFD119 Offline"},
                {"yes":"VFD120 Online","no":"VFD120 Offline"},
                {"yes":"remIO FCP101 Online","no":"remIO FCP101 Offline"},
                {"yes":"remIO SPP101 Online","no":"remIO SPP101 Offline"},
                {"yes":"Bender Gateway Online","no":"Bender Gateway Offline"},
            ],

            [   
                // BMS
            ],

            [   //Filtration Status
                {"yes":"P117 Fault","no":"P117 Fault Resolved"},
                {"yes":"P117 Pressure Fault","no":"P117 Pressure Fault Offline"},
                {"yes":"BackWash Routine Started","no":"Filter Mode. BW is not running."},
            ],

            [   //Water Quality Status
                {"yes":"pH Sensor Channel Fault","no":"pH Sensor Channel Fault Resolved"},
                {"yes":"ORP Sensor Channel Fault","no":"ORP Sensor Channel Fault Resolved"},
                {"yes":"TDS Sensor Channel Fault","no":"TDS Sensor Channel Fault Resolved"},
                {"yes":"Br Dosing Enabled","no":"Br Dosing Disabled"},
                {"yes":"Br Dosing","no":"Br Dosing Stopped"},
                {"yes":"Br Timeout","no":"Br Timeout Resolved"},
                {"yes":"Ozone Generator Running","no":"Ozone Generator Stopped"},
                {"yes":"P121 Pump Fault","no":"Resolved: P121 Pump Fault"},                
            ]

        ];

        if (devStatus.length > 0) {
            for(var each in currentState){
                // find all indeces with values different from previous examination
                var suspects = kompare(currentState[each],devStatus[each]);
                for(var each2 in suspects){
                    var text = (currentState[each][suspects[each2]]) ? statements[each][suspects[each2]].yes:statements[each][suspects[each2]].no;
                    if(text !== "n/a"){
                        //watchDog.eventLog('each: ' +each +' and each2: ' +each2+' and suspcts: ' +suspects);
                        if (each !== "2"){
                            watchDog.eventLog(text);
                        }
                    }
                }
            }
        }

    }

    // returns the value of the bth bit of n
    function nthBit(n,b){
        var here = 1 << b;
        if (here & n){
            return 1;
        }
        return 0;
    }

    // converts up to 11-bit binary (including 0 bit) to decimal
    function oddByte(fruit){
        var min=0;
        for (k=0;k<11;k++){
            if(nthBit(fruit,k)){min+=Math.pow(2,k);}
        }
        return min;
    }

    // general function that will help DEEP compare arrays
    function kompare (array1,array2) {
        var collisions = [];

        for (var i = 0, l=array1.length; i < l; i++) {
            // Check if we have nested arrays
            if (array1[i] instanceof Array && array2[i] instanceof Array) {
                // recurse into the nested arrays
                if (!kompare(array1[i],array2[i])){
                    return [false];
                }
            }
            else if (array1[i] !== array2[i]) {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                collisions.push(i);
            }
        }

        return collisions;
    }

    // convert boolean to int
    function bool2int(array){
        for (var each in array) {
            // Check if we have nested arrays
            if (array[each] instanceof Array) {
                // recurse into the nested arrays
                array[each] = bool2int(array[each]);
            }
            else {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                array[each] = (array[each]) ? 1 : 0;
            }
        }
        return array;
    }
}

module.exports=statusLogWrapper;
