function eventLog(entry){
	entry = JSON.stringify(entry);
	var moment = new Date();
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
	// fs.appendFile(homeD+'/UserFiles/logFile.txt','['+proj.toUpperCase()+'] '+timeStamp+' @ '+entry,function(err){
	// 	if(err){throw err;}
	// });

	fs.appendFile(homeD+'/UserFiles/logFile_' +moment.getDate() +'.txt','['+proj.toUpperCase()+'] '+timeStamp+' @ '+entry,function(err){
		if(err){throw err;}
	});

}

module.exports.eventLog=eventLog;