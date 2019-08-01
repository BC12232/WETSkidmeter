/*********************  TIME KEEPER VARIABLE INFO

    showNumber:

    Description: This variable will hold the current scheduled manual show from the playlist arrau
    Possible Values: Integer Numbers
    Note: This variable only get accessed on Manual state

**********************/


function timeKeeperWrapper(){

    //console.log("TimeKeeper script triggered");
    //watchDog.eventLog("TimeKeeper script triggered");
    //========= Initialization Parameters
    //Special Show will override AUTO and MANUAL shows ONLY when FILLER SHOW SCH is true
    //Heirarchy: Show Stoppers > Special Show > Show > Filler Show
    //Filler Show will run only in AUTO mode

    //Create a new moment from Date Object as soon as the script loads
    var moment = new Date();
    
    //Get the current hour and minute from the new moment Data Object created
    var now = moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds();

    //Variable to hold as schedulep[g] changes
    var spmRequest;

    //Load and parse appropriate schedule according to the day of the week
    var today = moment.getDay();

    //watchDog.eventLog("ShowStopper: " +showStopper);

    //========================== MAIN SHOW STOPPER CHECK POINT =======================//

    //Implement Show Stopper Values check point.
    //If there is a show stopping fault read from the PLC, play show 0 to 'stop' the show

    if(showStopper > 0){  

        //Check if a show is playing so that show0 is trigger only when needed
        if (playing == 1 && show != 0){
            //Instruct the SPM To Play Show Zero
            spm_client.writeSingleRegister(1005,0,function(resp){
                show = 0;
                spm_client.writeSingleRegister(1004,0,function(resp){
                    spm_client.writeSingleRegister(1004,8,function(resp){
                        playing = 0;
                        jumpToStep_auto = 0;
                        jumpToStep_manual = 0;
                        watchDog.eventLog("Show Aborted");
                    });
                });
            });

        }
        else{
            //Do nothing if there is no show playing
        }

    }
    
    //Conditions are OK to play shows
    else{

        //========================== MANUAL MODE =======================//
        if(autoMan == 1){

            //watchDog.eventLog("SERVER IS IN MANUAL MODE");
            jumpToStep_auto = 0;

            //Logic
            //Play show 0 as soon as it enters manual mode - only once
            //Wait for user to click on play button
            //Play according to betabuffer

            if (jumpToStep_manual == 0){//jumpToStep_manual is set to 0 when in auto mode

                //Instruct the SPM To Play Show Zero
                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            jumpToStep_manual = 2;
                            watchDog.eventLog("Playing Show #0. Playlist ready to run.");
                        });
                    });
                });

                jumpToStep_manual = 1;

            }

            if (!manPlay && jumpToStep_manual != 1){//covers the condition when user aborts the playlist ie jumpToStep_manual = 8

                //Start time of the first show is always 2 seconds from the current time 
                betabufferData = alphaconverter.sew(alphaconverter.endtime(now,2),'p'+manFocus);
                jumpToStep_manual = 4;    

            }

            if (jumpToStep_manual == 4){

                //Wait for user to click on PLAY button

                if (manPlay && jumpToStep_manual !== 8){

                    //steal logic for Auto mode and use betabuffer instead of alphabuffer
                    var schedule = betabufferData;
                    var playlistEndtime = alphaconverter.getEndtime( betabufferData[betabufferData.length-2] , betabufferData[betabufferData.length-1]);

                    //last element in the schedule array  
                    for (var g=schedule.length-2;g>=0;g-=2){

                        //show start time + 2 sec.
                        showTriggerTime = alphaconverter.endtime(schedule[g],2);

                        //Make sure we dont run a show0 when nothing is scheduled
                        //Compare with timeLastCmnd to make sure it plays the existing show only once
                        if ((now <= showTriggerTime && now >= schedule[g]) && (schedule[g+1] != 0) && (schedule[g] > timeLastCmnd)){

                            currentShow = schedule[g+1];
                            manIndex = (g/2) + 1;

                            watchDog.eventLog("About to Start Show #" + currentShow);
                            watchDog.eventLog("This is #" + manIndex +" show in the playlist #" +manFocus);

                            spm_client.writeSingleRegister(1005,currentShow,function(resp){
                                show = currentShow;
                                spm_client.writeSingleRegister(1004,0,function(resp){
                                    spm_client.writeSingleRegister(1004,8,function(resp){
                                        playing = 1;
                                        moment1 = moment;   //displays time on iPad
                                        timeLastCmnd = now;
                                        watchDog.eventLog("MANUAL: Play Show # " + currentShow);
                                    });
                                });
                            });

                            jumpToStep_manual = 5;

                        }

                        if (now >= playlistEndtime){

                            playing = 0;
                            jumpToStep_manual = 6;
                            //play show0 once, logic cant be implemented if iPad does NOT set manPlay to 0

                        }
                    }
                }
            }

            if (jumpToStep_manual == 5 && playing){
                jumpToStep_manual = 4; //acts like a break statement
            }

            if (jumpToStep_manual == 6){

                //Play show0 at the end of the playlist

                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            jumpToStep_manual = 8;
                            manPlay = 0;
                            watchDog.eventLog("Playing Show #0. End of playlist.");
                        });
                    });
                });

                jumpToStep_manual = 7;

            }

            //User presses the STOP button

            if (!manPlay && playing){

                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            jumpToStep_manual = 8;
                            watchDog.eventLog("Playing Show #0. Playlist Aborted.");
                        });
                    });
                }); 

                playing = 0;    
            }
        }
        //========================== MANUAL MODE END =======================//

        //========================== AUTO MODE ========================//
        else if(autoMan == 0){

            //watchDog.eventLog("SERVER IS IN AUTO MODE");
            jumpToStep_manual = 0;    

            if(now<235950){

                //get curent days schedule 
                var schedule = alphabufferData[1];

                //compare current hour and minute to schedule and play appropriate show
                //start comparing from the last element of the array

                if (jumpToStep_auto == 0){

                    for(var g=schedule.length-2;g>=0;g-=2){

                        //show start time + 2 sec.
                        showTriggerTime = alphaconverter.endtime(schedule[g],2);
                        //trigger show between (show start time) and (show start time + 2)seconds.
                        //make sure we dont run a show0 when nothing is scheduled
                        //compare with timeLastCmnd to make sure it plays the existing show only once

                        if ((now <= showTriggerTime && now >= schedule[g]) && (schedule[g+1] != 0) && (schedule[g] > timeLastCmnd)){
                            currentShow = schedule[g+1];
                            spmRequest = schedule[g];
                            //watchDog.eventLog("schedule[g] is " + schedule[g]);

                            jumpToStep_auto = 1;
                            //watchDog.eventLog("jumpToStep_auto is " + jumpToStep_auto);
                            break;
                        }

                        else{

                            jumpToStep_auto = 0;

                        }
                    }

                    //Read Status from the SPM
                    spm_client.readHoldingRegister(2000,1,function(resp){

                        if (nthBit(resp.register[0],4) == 1){
                            playing = 1;
                        }
                        else{
                            playing = 0;
                        }

                    });

                }

                if (jumpToStep_auto == 1){

                    //watchDog.eventLog("jumpToStep_auto is " + jumpToStep_auto);
                    watchDog.eventLog("About to Start Show # " + currentShow);

                    //Issue the SPM to Play SHOW
                    spm_client.writeSingleRegister(1005,currentShow,function(resp){
                        show = currentShow;
                        spm_client.writeSingleRegister(1004,0,function(resp){
                            spm_client.writeSingleRegister(1004,8,function(resp){
                                watchDog.eventLog("SCHEDULER: Play Show # "+currentShow);
                                jumpToStep_auto = 3;
                                playing = 1;
                                moment1 = moment;//displays time on iPad
                                
                                //Set timeLastCmnd only after successful write to SPM
                                //If set to now, it triggers the show twice, so I am forcing it to be scheduled time
                                timeLastCmnd = spmRequest;  
                                //watchDog.eventLog("timeLastCmnd : "+timeLastCmnd);
                            });       
                        });
                    });

                    jumpToStep_auto = 2;
                }    

                if (jumpToStep_auto == 3){

                    //Check after 3 seconds to confirm if SPM has responded to the command
                    //watchDog.eventLog("now: " +now +", timeLastCmnd+3: " +(alphaconverter.endtime(timeLastCmnd,3)) +"timeLastCmnd+6: " +(alphaconverter.endtime(timeLastCmnd,6))  );
                    if ( (now >= alphaconverter.endtime(timeLastCmnd,3)) && (now < alphaconverter.endtime(timeLastCmnd,6)) ) {

                        //Read Status from the SPM
                        //watchDog.eventLog("IF is true in jumpStep == 3");
                        spm_client.readHoldingRegister(2000,1,function(resp){
                            if (nthBit(resp.register[0],4) == 1){   
                                //Stop checking and reset jumpToStep_auto to 0
                                jumpToStep_auto = 0;
                                playing = 1; 
                            }
                        }); 
                    }
                    else if (now >= alphaconverter.endtime(timeLastCmnd,6)){
                        //Show did not start after issuing the command 
                        watchDog.eventLog("SPM Status did not change");
                        playing = 0;
                        timeLastCmnd == now;
                        jumpToStep_auto = 0;
                    }
                }

            }
        }
        //========================== AUTO MODE END =======================//

        else{
            //do nothing. Should not be here.
        }
    
    }
    
    //============================== Show 0 at the end of the schedule  ============//
    if (playing == 0){
        idleState_Counter++;
        //watchDog.eventLog("END LOGIC: IDLE state " +idleState_Counter +"show0_endShow: " +show0_endShow); 
        if(show0_endShow == 0){
            watchDog.eventLog("END LOGIC: Prepping to play Show0 " );
            if (idleState_Counter >= 5){
                watchDog.eventLog("END LOGIC: Play Show 0" );
                // no shows having playing for 5s   
                show0_endShow = 1; //one shot
                //play show 0
                spm_client.writeSingleRegister(1005,0,function(resp){
                    show = 0;
                    spm_client.writeSingleRegister(1004,0,function(resp){
                        spm_client.writeSingleRegister(1004,8,function(resp){
                            playing = 0;
                            jumpToStep_auto = 0;
                            jumpToStep_manual = 0;
                            idleState_Counter = 0;
                            watchDog.eventLog("END LOGIC: Gap in scheduled shows. Playing Show 0.");
                        });
                    });
                });
            }
        }
        if (idleState_Counter >= 30){
            //reset counter
            idleState_Counter = 0;
            //watchDog.eventLog("END LOGIC: Show0 already played. SPM is IDLE. Reset Counter" );
        }
    }
    else{
        if (show != 0){
            //some other show is playing
            //watchDog.eventLog("END LOGIC: Show #"+show +" is playing");
            idleState_Counter = 0; //sets counterback to 0
            show0_endShow = 0; //sets up server to play show0 no show is running
        }
        else{
            //watchDog.eventLog("END LOGIC: Show 0 is playing");
        }
    }

    //============================== offset show playing Time  ============//

    if ( (autoMan == 0) && (showStopper === 0) ){
        var schedule_mirror = alphabufferData[1];//will still work if SPM is not connected
        for(var g=schedule_mirror.length-2;g>=0;g-=2){
            //takes current time and adds 5 sec to it
            var futureTime_3mins = alphaconverter.endtime(now,5);

            if ((futureTime_3mins >= schedule_mirror[g] && now <= schedule_mirror[g]) && (schedule_mirror[g+1] != 0) && (schedule_mirror[g] > timeLastCmnd)){
                plc_client.writeSingleCoil(2,1,function(resp){});
                break;
            }
            
        }
    }

    if ( (playing===1) || (showStopper > 0) ){
       plc_client.writeSingleCoil(2,0,function(resp){});
    }
    //============================== offset show playing Time  ============//

    //========================== NEXT SHOW IDENTIFICATION =======================//
    if (autoMan == 0){

        for (var g=alphabufferData[1].length-2;g>=0;g-=2){
            if ( (g>=2) && (now < alphabufferData[1][g]) && (now >= alphabufferData[1][g-2]) ){
                nxtTime = alphabufferData[1][g];
                nxtShow = alphabufferData[1][g+1];
                //watchDog.eventLog('Here1');
                break;
            }
            else if ( (g==0) && (now < alphabufferData[1][0]) ){
                nxtTime = alphabufferData[1][0];
                nxtShow = alphabufferData[1][1];
                //watchDog.eventLog('Here2');
                break;
            }
            else if ( (now > alphabufferData[1][g]) && (alphabufferData[1][g] != 0) && (alphabufferData[1][g+2] === 0) ){
                //next days scheduled show
                var nextDayData = alphaconverter.tomorrowFirstShow();

                nxtTime = nextDayData[0];
                nxtShow = nextDayData[1];
                //watchDog.eventLog('was here for next days first show data');

                break;
            }
            else{
                //watchDog.eventLog('Here4');
            }
        }    
   
    }
    else{
        if (manPlay){
            for (var g=betabufferData.length-2;g>=0;g-=2){
                if ( (g>=2) && (now < betabufferData[g]) && (now >= betabufferData[g-2]) ){
                    nxtTime = betabufferData[g];
                    nxtShow = betabufferData[g+1];
                    break;
                }
                else if ( (g==0) && (now < betabufferData[0]) ){
                    nxtTime = betabufferData[0];
                    nxtShow = betabufferData[1];
                    break;
                }
                else if ( (now > betabufferData[g]) && (g===betabufferData.length-2) ){
                    nxtTime = 0;
                    nxtShow = 0;
                    break;
                }
            }
        }
        else{ 
            nxtTime=0;
            nxtShow=0;
        }
    }

    // stringifying date object in order to broadcast when SPM started playing show
    // For iPad Show Time Display
    if(playing === 1){
        deflate = JSON.stringify(moment1);
    }
    else{
        deflate = "nothing";
    }

    //========================== NEXT SHOW IDENTIFICATION =======================//

    //========================== SPM PLC CONNECTION STATUS =======================//
    //Check SPM Connection
    if(SPM_Heartbeat == 2){
        spm_client.readHoldingRegister(2000,1,function(resp){
            SPM_Heartbeat = 0; //check again in the next scan
            SPMConnected = true;       
        });
        SPM_Heartbeat = 3;
    }
    else{
        SPM_Heartbeat++;
    }

    if(SPM_Heartbeat==9){
        if (SPMConnected){
            watchDog.eventLog('SPM MODBUS CONNECTION FAILED');
        }//log it only once
        SPMConnected = false;
    }
    //Check SPM Connection

    //Check PLC Connection
    if(PLC_Heartbeat == 2){
        plc_client.readHoldingRegister(1,1,function(resp){
            PLC_Heartbeat = 0; //check again in the next scan
            PLCConnected = true;       
        });
        PLC_Heartbeat = 3;
    }
    else{
        PLC_Heartbeat++;
    }

    if(PLC_Heartbeat==9){
        if (PLCConnected){
            watchDog.eventLog('PLC MODBUS CONNECTION FAILED');
        }//log it only once
        PLCConnected = false;
    }
    //Check PLC Connection

    //========================== TIME CALCULATION FUNCIONS ===========//

    //first 2s of the day
    if(now <= 2){
        if(newDay){
            //Initiate the alphabuffer to build "tomorrow's" schedule
            watchDog.eventLog('alphaconverter: NEW DAY - ' + moment.getDay());
            alphaconverter.initiate(0);
            timeLastCmnd = -1;
            //Define the next show
            var future = alphaconverter.seer(moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds(),0);
            nxtShow=future[1];
            nxtTime=future[0];

            //purge LogFile for new entries
            var data1 = JSON.stringify(0);
            data1+='\n';

            fs.writeFileSync(homeD+'/UserFiles/logFile_' +moment.getDate() +'.txt',' @ ' +now +' @ :' +data1,'utf-8');
            watchDog.eventLog("*******New Day Log*********");

            //Prevent loop from repetitively updating to newDay every second of 12:59PM
            newDay=0;
        }
    }
    else{
        newDay = 1; //prep for next day update   
    }


//============================ RAT MODE =================================//
spm_client.readHoldingRegister(2000,2,function(resp){
    spmRATMode = nthBit(resp.register[0],8);
    dayModeStatus = nthBit(resp.register[1],7);
    //watchDog.eventLog('Play Status: ' +nthBit(resp.register[0],4) );
});

spm_client.readHoldingRegister(2005,1,function(resp){
    //watchDog.eventLog('SPM Data 2000: ' +resp.register[0] +' 2001: ' +resp.register[1] +' 2002: ' +resp.register[2] +' 2003: ' +resp.register[3] +' 2004: ' +resp.register[4] +' : ');
    //watchDog.eventLog('SPM Data 2005: ' +resp.register[5] +' 2006: ' +resp.register[6] +' 2007: ' +resp.register[7] +' 2008: ' +resp.register[8] +' 2009: ' +resp.register[9] +' : ');
    var spm_data_2005 = resp.register[0];
    //plc_client.writeSingleRegister(50,spm_data_2005,function(resp){});
});

// spm_client.readHoldingRegister(2008,1,function(resp){
//     watchDog.eventLog('ShowTime_sec: ' +(intByte_HiLo(resp.register[0])[1])/256 );
//     watchDog.eventLog('ShowTime_ticks: ' +intByte_HiLo(resp.register[0])[0] );
// });

// spm_client.readHoldingRegister(2020,1,function(resp){
//     watchDog.eventLog('inputOffset_sec: ' +intByte_HiLo(resp.register[0])[1] );
//     watchDog.eventLog('inputOffset_ticks: ' +intByte_HiLo(resp.register[0])[0] );
// });

}

//==== Return the value of the b-th of n 

function nthBit(n,b){

    var currentBit = 1 << b;

    if (currentBit & n){
        return 1;
    }

    return 0;
}

function intByte_HiLo(query){
    var loByte = 0;
    for(var i = 0; i < 8; i++){
        loByte = loByte + (nthBit(query,i)* Math.pow(2, i));
    }
    var hiByte = 0;
    for(var i = 8; i < 16; i++){
        hiByte = hiByte + (nthBit(query,i)* Math.pow(2, i));
    }
    var byte_arr = [];
    byte_arr[0] = loByte;
    byte_arr[1] = hiByte;
    return byte_arr;
}

module.exports=timeKeeperWrapper;

