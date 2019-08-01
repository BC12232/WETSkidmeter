function eventLog(entry){
	entry = JSON.stringify(entry);
	var moment = new Date();
	var timeStamp = (moment.getFullYear()+'/'+(moment.getMonth()+1))+'/'+ moment.getDate()+' '+ moment.getHours()+':' + (moment.getMinutes()<10?'0':'') + moment.getMinutes()+':'+ (moment.getSeconds()<10?'0':'')+moment.getSeconds();
	// +'^'
	entry+='\n';
	fs.appendFile(homeD+'/UserFiles/logFileClient.txt',JSON.stringify(timeStamp) +' , '+entry,function(err){
		if(err){throw err;}
	});
}

module.exports.eventLog=eventLog;