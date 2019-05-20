function eventLog(entry){
	entry = JSON.stringify(entry);
	var moment = mainTime;
	var zerosInFront;

	if ((moment.getMilliseconds() >= 10) && (moment.getMilliseconds() < 100)){
		zerosInFront = '0';
	}
	else if ((moment.getMilliseconds() >= 0) && (moment.getMilliseconds() < 10)){
		zerosInFront = '00';
	}
	else{
		zerosInFront = '';
	}

	var timeStamp = (moment.getFullYear() 
					+ '-' + (moment.getMonth()+1)) 
					+ '-' + moment.getDate() 
					+ ' ' + moment.getHours() 
					+ ':' + (moment.getMinutes()<10?'0':'') + moment.getMinutes() 
					+ ':' + (moment.getSeconds()<10?'0':'') + moment.getSeconds()
					+ ':'+ zerosInFront + moment.getMilliseconds();
	// +'^'
	entry+='\n';
	fs.appendFile(homeD+'/UserFiles/logFile.txt','['+proj.toUpperCase()+'] '+timeStamp+' @ '+entry,function(err){
		if(err){throw err;}
	});

	// var mainTime1 = new Date("2017-05-05T15:33:00+03:00");

	// if (mainTime !== mainTime1){
	// 	//store backup in separate file (1 file each day)
	// 	fs.appendFile(homeD+'/UserFiles/LogFile_' +moment.getDate() +'.txt','['+proj.toUpperCase()+'] '+timeStamp+' @ '+entry,function(err){
	// 		if(err){throw err;}
	// 	});


	// 	//purge next day's file
	// 	var tomorrowDate = mainTime;
	//     tomorrowDate.setDate(mainTime.getDate() + 1);
	//     fs.writeFile(homeD+'/UserFiles/LogFile_' +tomorrowDate.getDate() +'.txt', '');
	// }

}

module.exports.eventLog=eventLog;