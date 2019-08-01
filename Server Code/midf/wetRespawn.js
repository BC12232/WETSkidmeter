var respawn = require(__dirname+'/Includes/respawn.js');
var fs = require('fs');

//2 > wetNode.error

var monitor = respawn(['wetNode', __dirname+'/Main.js'],{

    env: {ENV_VAR:'test'}, 	//Set env vars
    cwd: '.',               //Set cwd
    maxRestarts:10,         //How many restarts are allowed within 60s
                           	//Or -1 for infinite restarts
    sleep:1000              //Time to sleep between restarts

});

monitor.start(); 

//Spawn and watch

monitor.on('stderr',function(data){

	var moment = new Date();
	moment = (moment.getFullYear()+'-'+(moment.getMonth()+1))+'-'+ moment.getDate()+' '+ moment.getHours()+':' + (moment.getMinutes()<10?'0':'') + moment.getMinutes()+':'+ (moment.getSeconds()<10?'0':'')+moment.getSeconds();
	fs.appendFileSync('/etc/wetNode.error',moment+'\n'+data.toString());

});

console.log("wetNode spawned");