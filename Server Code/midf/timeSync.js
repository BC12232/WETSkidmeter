function timeSyncWrapper(){

if (PLCConnected){
	plc_client.readHoldingRegister(100,5,function(resp){
		time_dayofWeek = resp.register[0];
		time_Seconds = resp.register[1];

		var time_HourMin = resp.register[2];
		time_Minutes = ( time_HourMin - ( Math.floor(time_HourMin/100) *100) );
		time_Hour = Math.floor(time_HourMin/100);

		var time_MonthDate = resp.register[3];
		time_Date = ( time_MonthDate - ( Math.floor(time_MonthDate/100) *100) );
		time_Month = Math.floor(time_MonthDate/100);

		time_Century = resp.register[4];
		//watchDog.eventLog('PLC Time: ' +time_Century +"-" +time_Month +"-" +time_Date +" " +time_Hour +":" +time_Minutes +":" +time_Seconds);
		
		correct_time_Month = "";
		if (time_Month < 10){
			correct_time_Month = String("0" + time_Month);
		}
		else{
			correct_time_Month = String(time_Month);
		}

		correct_time_Date = "";
		if (time_Date < 10){
			correct_time_Date = String("0" + time_Date);
		}
		else{
			correct_time_Date = String(time_Date);
		}

		correct_time_Hour = "";
		if (time_Hour < 10){
			correct_time_Hour = String("0" + time_Hour);
		}
		else{
			correct_time_Hour = String(time_Hour);
		}

		correct_time_Minutes = "";
		if (time_Minutes < 10){
			correct_time_Minutes = String("0" + time_Minutes);
		}
		else{
			correct_time_Minutes = String(time_Minutes);
		}

		correct_time_Seconds = "";
		if (time_Seconds < 1000){
			correct_time_Seconds = String("0" + (time_Seconds/100));
		}
		else{
			correct_time_Seconds = String(time_Seconds/100);
		}

		mainTime1 = new Date("2017-05-05T15:33:00+03:00");
		//watchDog.eventLog(time_Century +"-" +correct_time_Month +"-" +correct_time_Date +"T" +correct_time_Hour +":" +correct_time_Minutes +":" +correct_time_Seconds +"Z");
		var timeString = String(time_Century +"-" +correct_time_Month +"-" +correct_time_Date +"T" +correct_time_Hour +":" +correct_time_Minutes +":" +correct_time_Seconds +"+08:00");
		
		mainTime = new Date(timeString);

		if ( runOnceOnly && (mainTime != mainTime1) ){
			watchDog.eventLog("AlphaConverter Initiated");
			alphaconverter.initiate(0);
			runOnceOnly = 0;
		}

	});
}

}

module.exports=timeSyncWrapper;