
//Scheduled BW only
//manual BW is based on manBWcanRun bit. and iPad sends trigger directly to the PLC.

function bwWrapper(){

	//console.log("backwash script cycle triggered");
	//Create a new moment from Date Object as soon as the script loads
	var moment = new Date();
	var dayToday = moment.getDay() + 1; //getDay is 0-6 but we need 1-7
	var now = moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds();

	//get curent days schedule 
	var schedule = alphabufferData[1];

	var pumpStatus_addr = 1036;
	var pdsh_Addr = 4011;
	var bw_trigAddr = 4006;
	var bwStatus_addr = 4007;

	//get duration from the PLC
	plc_client.readHoldingRegister(6514,1,function(resp){
		if (resp != undefined && resp != null){
			bwData3.duration = resp.register[0];	
		}  
		else{
			bwData3.duration = 3;
		}      
	});

	//check if manual BW can be trigger at this moment
	if (autoMan === 0){//auto mode
		bwData3.manBWcanRun = checkManualBW(bwData3.duration,Math.floor(now/100),dayToday);
	}
	else{//man Mode
		if(manPlay){// if playing manual shows, then block BW routine
			bwData3.manBWcanRun = 0;
		}
		else{//if playlist is not playing shows then we can run BW
			bwData3.manBWcanRun = 1;
		}
	}

	//check filtration pump status, 4012 - Fault Status
	plc_client.readCoils(pumpStatus_addr,1,function(resp){
		if(resp.coils[0]){
			filtrationPump_fault = 1;
		}
		else{
			filtrationPump_fault = 0;
		}
		//watchDog.eventLog("filtrationPump_fault: " +filtrationPump_fault);
	});
	
	//PDSH - request for BW
	var trigger_BW_PDSH = 0;

	plc_client.readCoils(pdsh_Addr,1,function(resp){
		if(resp.coils[0]){
			bwData3.PDSH_req4BW = 1;
		}
		else{
			bwData3.PDSH_req4BW = 0;
		}
	});

	if (bwData3.PDSH_req4BW){
		trigger_BW_PDSH = checkManualBW(bwData3.duration,Math.floor(now/100),dayToday);
		//server still considers this as a scheduled BW and checks for timeout status
	}
	else{
		trigger_BW_PDSH = 0;
	}
	//PDSH - end

	//======================== BW Trigger conditions start ==============================

		if (bwData3.SchBWStatus === 0) {

			// 3 IF Statements below. Schedule time, PDSH request and BackLog

			//check for:
			//schDay should be the current day	
			//if time jumps on the server
            var timeOffset = (alphaconverter.endtime(bwData3.schTime,1))*100;		
			if ( (dayToday === bwData3.schDay) && (( now >= (bwData3.schTime*100) ) && ( now <= timeOffset )) ){
				
				//execute only in AUTO Mode
				//manBWcanrun tells us if we can run the BW now
				//playing = 0 tells us there is no show running right now

				if ( (bwData3.manBWcanRun == 1) && (playing == 0) ){
					watchDog.eventLog("About to trigger Sch BW routine");
					//Issue the BW trigger to PLC
					if (filtrationPump_fault === 0){
						trigBW(now,moment);
					}
					else{
						watchDog.eventLog("Aborted Scheduled BW because of Filtration Pump Fault");
						bwData3.trigBacklog = 1;
					}
				}
				
				//if BW could NOT be executed, set the flag and run the routine when possible
				else{
					bwData3.trigBacklog = 1;
				}
			}// end of sch check
			else{
				//do nothing
			}

			//PDSH request for BW. One SHOT
			if (trigger_BW_PDSH){
				if (filtrationPump_fault === 0){
					watchDog.eventLog("About to trigger BW routine as requested by PDSH Sensor");
					//Issue the BW trigger to PLC
			       	trigBW(now,moment); 
			    }    	
			}
			//trigger backup BW when possible. One SHOT
			if ((bwData3.trigBacklog == 1) && (autoMan == 0)){
				var gapCheck = checkManualBW(bwData3.duration,Math.floor(now/100),dayToday);
				if (gapCheck){
					if (filtrationPump_fault === 0){
						watchDog.eventLog("Triggering backed-up scheduled BW now");
						//Issue the BW trigger to PLC
						trigBW(now,moment);
						bwData3.trigBacklog = 0;
					}
				}
			}

		}// end of IF blockSchBW

		else if (bwData3.SchBWStatus === 1){
			plc_client.writeSingleCoil(bw_trigAddr,0,function(resp){
				plc_client.readCoils(bwStatus_addr,1,function(resp){
					if(resp.coils[0]){
						bwData3.SchBWStatus = 2;
						watchDog.eventLog("Sch BW Running");
						bwData3.timeoutCountdown = bwData3.timeout;
					}
					//else wait for PLC to acknowledge BW is running
					if ( (resp.coils[0] ==0) && ( (now/100) >= alphaconverter.endtime(((bwData3.timeLastBW)/100),1) ) ){
						//no acknowledgement from PLC after 1 min
						//abort bw routine
						bwData3.SchBWStatus = 0;
						bwData3.blockBWuntil = 0;
						watchDog.eventLog("PLC did not respond to a BW Trigger from the Server.");
					}
				});
			});	
		} // end of else if

		else if (bwData3.SchBWStatus === 2){// if blockSchBW = 2
            //watchDog.eventLog(alphaconverter.endtime(bwData3.timeLastBW,bwData3.timeout));
            var timeoutMoment = new Date(bwData3.blockBWuntil);
            if (moment.getTime() >= timeoutMoment.getTime()){
                bwData3.SchBWStatus = 0; //end of timeout
            } 
            else{
                bwData3.SchBWStatus = 2;
            }
            bwData3.timeoutCountdown = Math.round ( (timeoutMoment.getTime() - moment.getTime() )/1000 );
		}// end of else if

		else{
			//catch exception. bwData3.SchBWStatus should be 0, 1 or 2. 
		}

	//======================== BW Trigger conditions end ==============================
	//update txt file
	if (bwData3.blockBWuntil !== undefined){
		//watchDog.eventLog("bwData3 ok");
		fs.writeFileSync(homeD+'/UserFiles/backwash.txt',JSON.stringify(bwData3),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/backwashBkp.txt',JSON.stringify(bwData3),'utf-8');
	}
	else{
		//bwData3 is corrupt. Load default values and write to the file
		watchDog.eventLog("bwData3 Undefined. Pushed in default values.");
		bwData3 = {"BWshowNumber":999,"duration":3,"SchBWStatus":0,"timeout":86400,"timeoutCountdown":0,"timeLastBW":0,"trigBacklog":0,"manBWcanRun":1,"PDSH_req4BW":0,"schDay":1,"schTime":2300, "blockBWuntil":0 };
		fs.writeFileSync(homeD+'/UserFiles/backwash.txt',JSON.stringify(bwData3),'utf-8');
		fs.writeFileSync(homeD+'/UserFiles/backwashBkp.txt',JSON.stringify(bwData3),'utf-8');
	}
}

module.exports=bwWrapper;

function checkManualBW(duration,timeNow,dayID){
	//check if there is a show playing
	//check if there is a show scheduled to run between now and (now + BW duration)
	//check for Filtration Pump status - no fault - checking on iPad side is easier
	var canRunManBWnow = 0;

	var gapAvailable = alphaconverter.checkInsert(alphaconverter.endtime(timeNow,2),999,dayID);//2 seconds in the future

	//watchDog.eventLog("Gap available: " +gapAvailable);

	if ((playing == 0) && (gapAvailable == 1)){
		canRunManBWnow = 1;
		//watchDog.eventLog("Can Run");
	}
	else{
		canRunManBWnow = 0;
		//watchDog.eventLog("Nope!");
	}

	return canRunManBWnow;
}

function trigBW(now,moment){
	//only when there is no pump Fault
	plc_client.writeSingleCoil(bw_trigAddr,1,function(resp){
		bwData3.SchBWStatus = 1;
		bwData3.timeLastBW = now;
		bwData3.blockBWuntil = new Date(moment.getTime() + (bwData3.timeout * 1000) );
		bwData3.trigBacklog = 0;
	});
}

				
