var moment = new Date();

//===============  Required Modules HELLO ARPI

var http = require("http");
var sys = require("sys");
var querystring = require("querystring");
var url = require("url");
var os = require("os");
var util = require("util");

//===============  Scripts

var download_files = require("./Includes/download_files");
var logger = require("./Includes/logger");

var triggerScripts = require("./trigScripts.js");

fs = require("fs");
jsModbus = require("./Includes/jsModbus");
watchDog = require("./Includes/watchDog");

alphaconverter = require("./Includes/alphaconverter");

//===============  Global Parameters

homeD = __dirname;       //Location of the main scripts
proj = 'DHIR';    //display this on WatchDog. Also extracted from the folder name on the server    
timerCount = [0,0,0,0,0,0,0,0,0,0];

sysStatus = [];          //Array that is displayed on Read ErrorLog - old
devStatus = [];          //Array is used to compare with sysStatus to determine change in status
playStatus = [];         //Array that is displayed on Read ErrorLog - new
manPlaying = 0;          //TimeKeeper records if SPM is playing from Manual Mode. 0 = not playing 1 = playing

manIndex = 0;            //Denotes which show is being played currently by the playlist in manual mode.
playing=0;               //1 = SPM is currently playing show
show=0;                  //The show that is currently loaded in the SPM
moment1=0;               //The date object used as reference for show times
deflate=0;               //used to display show time remaining on the iPad
nxtShow=0;               //The next show in queue
nxtTime=0;               //The next show time in queue
updNxt=1;                //When the nxt's need to be updated. Updates alphabuffer when set to 1
newDay=0;                //A new day and enables the system to update and prepare for the new day

dayMode=0;
dayModeStatus=0;
spmRATMode = false;      //read RAT mode status from SPM and display it on iPad
showStopper=0;           //cumilative status of the showStopper bits read from the PLC.

jumpToStep_auto=0;       //auto mode case 
jumpToStep_manual=0;     //man mode case
autoTimeout=0;           //timekeeper code to reset jumpToStep variables   
currentShow=0;           //variable used in timekeeper to update the global variable show

PLCConnected=false;      //Server - PLC Modbus connection status   
SPMConnected=false;      //Server - SPM Modbus connection status
SPM_Heartbeat=0;         //Counter used to check Modbus connection with the SPM   
PLC_Heartbeat=0;         //Counter used to check Modbus connection with the PLC 

timeLastCmnd = 0;
//TimeKeeper records for which time last show-open command was sent to SPM, scheduler/manual
//has to be updated by the iPad when time is synced 

//===============  Sync Server execution with iPads
// 0 - server can run its scripts, 1 - waiting for iPad to finish
okToRun_BW_Script = 0;
// add all others after testing BW

//===============  Time Sync related variable
//from PLC
time_dayofWeek = 0;

time_Seconds = 0;
time_Minutes = 0;
time_Hour = 0;

time_Date = 0;
time_Month = 0;
time_Century = 0;
//into the server
mainTime = new Date("2017-05-05T15:33:00+03:00");

//===============  User Changeable Parameters

autoMan = 0;                //0 = scheduler 1 = manual
manPlay = 0;                //0 = user wants to stop show, SPM transforms to segment 0
manFocus = 1;            //Denotes what playlist is in focus on user's iPad. betaBuffer is generated using this variable

// ===============  Water Quality
mw101WQ_15mins = {"orp" : [], "ph" : [], "tds" :[], "br" : [], "date" : []};
mw101WQ_24hrs = {"orp" : [], "ph" : [], "tds" :[], "br" : [], "date" : []};
mw101WQ_Day = {"orp" : [], "ph" : [], "tds" :[], "br" : [], "date" : []};
writeWQfile = 0;            //used to store data into text files. 

//================ Misc

//Initiate alphabuffer
runOnceOnly = 1; //timeSync.js

//Filtration Pump Status used in BW code
filtrationPump_Status = 1; //1 - pump fault, 0 - good

//==================== Modbus Connection

//currentDate = new Date();

plc_client = jsModbus.createTCPClient(502,'192.168.1.230',function(err){
    if(err){
        watchDog.eventLog('PLC Modbus Connection Failed');
        PLCConnected=false;
    }
    else{  
        watchDog.eventLog('PLC Modbus Connection Successful');
        PLCConnected=true;
    }
});

spm_client = jsModbus.createTCPClient(502,'192.168.1.201',function(err){
    if(err){
        watchDog.eventLog('SPM Modbus Connection Failed');
        SPMConnected=false; 
    }
    else{
        watchDog.eventLog('SPM Modbus Connection Successful');
        SPMConnected=true;
    }
});

//==================== User File Directories

//Global Persistent Data
shows=riskyParse(fs.readFileSync(__dirname+'/UserFiles/shows.txt','utf-8'),'shows','showsBkp',1);
playlists=riskyParse(fs.readFileSync(__dirname+'/UserFiles/playlists.txt','utf-8'),'playlists','playlistsBkp',1);
alphabufferData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/alphabuffer.txt','utf-8'),'alphabuffer','alphabufferBkp',1);
betabufferData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/betabuffer.txt','utf-8'),'betabuffer','betabufferBkp',1);
schedules=[];

for(var f=1;f<5;f++){
    schedules.push(riskyParse(fs.readFileSync(__dirname+'/UserFiles/schedule'+f+'.txt','utf-8'),'schedule'+f,'schedule'+f+'Bkp',1));
}

timetable=riskyParse(fs.readFileSync(__dirname+'/UserFiles/timetable.txt','utf-8'),'timetable','timetableBkp',1);
lights=riskyParse(fs.readFileSync(__dirname+'/UserFiles/lights.txt','utf-8'),'lights','lightsBkp',1);
weirPump=riskyParse(fs.readFileSync(__dirname+'/UserFiles/weirPump.txt','utf-8'),'weirPump','weirPumpBkp',1);
windScalingData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/windScalingData.txt','utf-8'),'windScalingData','windScalingDataBkp',1);
bwData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/backwash.txt','utf-8'),'backwash','backwashBkp',1);
fireSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/fireSch.txt','utf-8'),'fireSch','fireSchBkp',1);
filterSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/filterSch.txt','utf-8'),'filterSch','filterSchBkp',1);

//bwData = JSON.parse(fs.readFileSync(__dirname+'/UserFiles/backwash.txt','utf-8'));

//Read in the project name from /etc/hostname
proj = fs.readFileSync('/etc/hostname','utf-8').replace(/(\r\n|\n|\r)/gm,"");

//initiate shows for the day
alphaconverter.initiate(0);

//Initialize the next show and next time
var future = alphaconverter.seer(moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds(),0);
nxtShow=future[1];
nxtTime=future[0];

//==================== HTTP Server

//Create server and start listening for HTTP requests

http.createServer(onRequest).listen(8080);

//Define callback function for http.createServer

function onRequest(request, response){
    
    var auth = request.headers['authorization'];
    
    if(!auth) {
    
        response.statusCode = 401;
        response.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
        response.end('<html><body>Forbidden</body></html>');
    
    }

    else if(auth){

        var tmp = auth.split(' ');
        var buf = new Buffer(tmp[1], 'base64');
        var plain_auth = buf.toString();
        var creds = plain_auth.split(':');
        var username = creds[0];
        var password = creds[1];

        if((username === 'wet_act') && (password === 'A3139gg1121')){

            var query = url.parse(request.url).query;
            var path = url.parse(request.url).pathname;

            if (path === '/readStatusLog'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(sysStatus)); 
            
            }else if (path === '/readServerTime'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(mainTime));
            
            }else if (path === '/readFireSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(fireSch));
            
            }else if (path === '/writeFireSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setFireSch(query);
                response.end(JSON.stringify(fireSch));

            }else if (path === '/readFilterSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(filterSch));
            
            }else if (path === '/writeFilterSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setFilterSch(query);
                response.end(JSON.stringify(filterSch));

            }else if (path === '/setDayMode'){
            
                response.writeHead(200,{"Content-Type": "text"});
                if (sysStatus[0].statusLights[0]){
                    dayMode = query;
                    watchDog.eventLog('dayMode set to  ' +dayMode);
                }
                else{
                    watchDog.eventLog('dayMode unchanged as Lights is not in Manual Mode');
                }

            }else if (path === '/readplayStatus'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(playStatus));

            }else if (path === '/setTimeLastCmnd'){
            
                timeLastCmnd = 0;
                response.writeHead(200,{"Content-Type": "text"});
                watchDog.eventLog('Time Synced from iPad');

            }else if (path === '/readLights'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(lights));
            
            }else if (path === '/writeLights'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setLights(query);
                response.end(JSON.stringify(lights));
            
            }else if (path === '/WQ_Live'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(mw101WQ_15mins));   

            }else if (path === '/WQ_Day'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(mw101WQ_24hrs));    

            }else if (path === '/WQ_Week'){
                
                var z = parseInt(query, 10);
                //watchDog.eventLog('query: '+z);
                if ( (z<=6) && (z !== mainTime.getDay()) ){
                    wq_Value=fs.readFileSync(__dirname+'/UserFiles/WQ_' +z +'.txt','utf-8');
                    //watchDog.eventLog('datafile: '+wq_Value);
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(JSON.stringify(wq_Value));
                }
                z=null;  
            
            }else if (path === '/readWeirSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(weirPump));
            
            }else if (path === '/writeWeirSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setWeirPumpSch(query);
                response.end(JSON.stringify(weirPump));

            }else if (path === '/readBW'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(bwData));

            }else if (path === '/writeBW'){
            
                //watchDog.eventLog('BW Query from ipad');
                response.writeHead(200,{"Content-Type": "text"});
                setBW(query);
                response.end(JSON.stringify(bwData));    

            }else if (path === '/readScheduler'){

                var z = parseInt(query, 10);
                
                if(z<5){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(JSON.stringify(schedules[z-1]));
                }

                z=null;
            
            }else if (path === '/writeScheduler1'){
                watchDog.eventLog('here at writeScheduler1' +query);
                setScheduler1(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/writeScheduler2'){

                setScheduler2(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/writeScheduler3'){

                setScheduler3(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/writeScheduler4'){

                setScheduler4(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/readShows'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(shows));

            }else if (path === '/writeShows'){

                setShows(query);
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(shows));

            }else if (path === '/readPlaylists'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(playlists));

            }else if (path === '/writePlaylists'){

                setPlaylists(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end('[]');
                },query);

            }else if (path === '/readTimeTable'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(timetable));

            }else if (path === '/writeTimeTable'){

                setTimeTable(query);
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(timetable));

            }else if (path === '/readalphabuffer'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(alphabufferData[1]));
            
            }else if (path === '/readbetabuffer'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(betabufferData));

            }else if (path === '/autoMan'){
                response.writeHead(200,{"Content-Type": "text"});

                    if(query){
                        query = decodeURIComponent(query);
                        query = JSON.parse(query);
                        manFocus = query.focus;

                        if(query.state && autoMan !== query.state){
                            autoMan = query.state;
                            watchDog.eventLog("PLAYLIST PUT IN MANUAL MODE");
                        }
                        else if(!query.state && autoMan !== query.state){
                            autoMan = query.state;
                            watchDog.eventLog("PLAYLIST PUT IN AUTO MODE");
                            updNxt=1;
                        }
                    }     
                response.end(JSON.stringify([autoMan,manFocus]));

            }else if (path === '/autoManPlay'){
                response.writeHead(200,{"Content-Type": "text"});
                if(query){

                    if(playlists[manFocus-1].duration>0){

                        manPlay=parseInt(query, 10);
                        watchDog.eventLog("Set autoManPlay: " + manPlay);
                    }
                }

                response.end(JSON.stringify([manPlay]));

            }else if (path === '/showScanner'){

                showScanner(function(info){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(JSON.stringify([info]));
                },query);

            }else if (path === '/createBkps'){

                var success = createBkps(['shows','playlists','schedule1','schedule2','schedule3','schedule4','timetable','lights']);
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(success));
                success = null;

            }else if (path === '/readWindScalingData'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(windScalingData));

            }else if (path === '/writeWindScalingData'){

                response.writeHead(200,{"Content-Type": "text"});
                setWindScalingData(query);
                response.end(JSON.stringify(windScalingData));

            }else if (path === '/saveSettings'){

                parsedData = querystring.parse(query);
                saveSettings(parsedData);
                response.writeHead(200,{"Content-Type": "text"});
                response.end('[]');

            }else if (path === '/loadSettings'){

                loadSettings(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                }, query);

            }else if(path === '/logsToFTP'){

                logsToFTP(function(error,stdout,stderr){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(JSON.stringify([error,stdout,stderr]));
                });

            }else if (path === '/reboot'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end('Rebooting Server. Please go to /os in about 1 minute.');
                var exec = require("child_process").exec;
                exec('reboot');

            }else if (path === '/clearLog'){

                response.writeHead(200,{"Content-Type": "text/html"});
                response.end('<br><input type=\'button\' onclick=\"location.href=\'/readLog\';\" value=\'Read Log\' /><input type=\'button\' onclick=\"location.href=\'/debug\';\" value=\'Debug\' /><br><br>Logs have been cleared.');
                fs.writeFileSync(__dirname+'/UserFiles/logFile.txt','Start Log','utf-8');

            }else if (path === '/clearWetNodeError'){

                response.writeHead(200,{"Content-Type": "text/html"});
                response.end('[]');
                fs.writeFileSync('/etc/wetNode.error','wetNode.error\n','utf-8');

            }else if (path === '/readLog'){

                getLog(query,function(err,data){

                    data = data.replace(/[\"]/g, "'").replace(/\n/g, "??");
                    response.writeHead(200,{"Content-Type": "text"});
                    response.write("<br><input type=\'button\' onclick=\"location.href=\'/clearLog\';\" value=\'Clear Log\' /><input type=\'button\' onclick=\"location.href=\'/debug\';\" value=\'Debug\' /><br><br><script type='text/javascript'>var str = \"<p>"+ data +"</p>\"; var res = str.split('??').reverse().join('</p><p>'); document.write(res);</script>");
                    response.end();

                });

            }else if (path === '/readWetNodeError'){

                getWetNodeError(query,function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                });

            }else if ((path === '/os') || (path === '/debug')){

                response.writeHead(200,{"Content-Type": "text/html"});
                response.write(

                    '<strong>' + proj.toUpperCase() + '</strong>' + '<input type=\'button\' onclick=\"location.href=\'/debug\';\" value=\'Refresh\' /><br>'+
                    mainTime + '<br><br>' +

                    '<br><strong>' + (autoMan === 1 ? 'Manual/Hand </strong>Mode' : 'Auto/Schedule </strong>Mode') +
                    '<br>' + (playing === 1 ? 'Playing: ' : 'Last Played: ') +  (show < shows.length ? shows[show].name : 'Must Show Scan! Show ' + show + ' is not in show.txt')+
                    '<br>' + 'Last Time: ' + (deflate === 'nothing' ? '---' : deflate) +
                    '<br>' + 'Next Time: ' + (nxtTime === 0 ? '---' : nxtTime) + 
                    '<br>' + 'Next Show: ' + (nxtShow === 0 ? '---' : nxtShow) + 
                    '<br>' + 'Show Stopping Condition: ' + showStopper +
                    '<br>' +
                    '<br>PLC-MB? <strong>'+plc_client.isConnected()+'</strong>' + '<input type=\'button\' onclick=\"location.href=\'/plcTest\';\" value=\'PLC Test\' />'+
                    '<br>SPM-MB? <strong>'+spm_client.isConnected()+'</strong>'+
                    '<br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readShows\';\" value=\'Shows\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readPlaylists\';\" value=\'Playlists\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readScheduler?1\';\" value=\'Schedule 1\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/readScheduler?2\';\" value=\'Schedule 2\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/readScheduler?3\';\" value=\'Schedule 3\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/readScheduler?4\';\" value=\'Schedule 4\' /><br>' +

                    '<br><input type=\'button\' onclick=\"location.href=\'/readLog\';\" value=\'Read Log\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readStatusLog\';\" value=\'Read StatusLog\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readWetNodeError\';\" value=\'Read WETNodeError\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/userfilesIndex?W3trocks!\';\" value=\'Download System Files\' /><br>' +

                    '<br><br><input type=\'button\' onclick=\"location.href=\'/reboot\';\" value=\'REBOOT\' /><br>');
                    response.end();

            }else if (path === '/mbReadMW'){

                mbReadMW(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbReadM'){

                mbReadM(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbReadReal'){

                mbReadReal(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbWriteMW'){

                query = querystring.parse(query);

                mbWriteMW(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbWriteM'){

                query = querystring.parse(query);

                mbWriteM(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            } else if (path === '/mbWriteReal'){

                query = querystring.parse(query);

                mbWriteReal(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/plcTest'){

                fs.readFile(__dirname+'/plcTest.html','utf-8',function(err,data){

                    if(err){throw err;}
                    var dataString = data.toString();

                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(dataString);

                });

            }else if (path === '/mbReadSPM'){

                mbReadSPM(function(data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/mbWriteSPM'){

                query = querystring.parse(query);

                mbWriteSPM(function(data){

                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);

                },query);
            
            }else if (path === '/userfilesIndex'){

                if(query === "W3trocks!"){
                    
                    download_files.indexOfFiles(response);
                
                }else{
                    
                    response.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
                    response.statusCode = 403;
                    response.end('<html><body>Forbidden</body></html>');
                
                }
            
            }else if (path === '/userfiles'){

                download_files.downloadingFile(response, query);
            
            }else if (path === '/login'){

                response.writeHead(200,{"Content-Type":"text/html"});
                response.write("<script type='text/javascript'>var g = sessionStorage.getItem('WET');window.location.href='./userfilesIndex?'+g;</script>");
            
            }else{

                wants = 'unknown request'+" "+path+" "+query;
                response.end(wants);

            }
        }

        else if((username === proj) && (password === 'logMeIn')){

            var query = url.parse(request.url).query;
            var path = url.parse(request.url).pathname;

            if (path === '/systemStatus'){
                response.writeHead(200,{"Content-Type": "text/html"});
                response.write(

                    '<strong>' + proj.toUpperCase() + '</strong>' + '<input type=\'button\' onclick=\"location.href=\'/systemStatus\';\" value=\'Refresh\' /><br>'+
                    mainTime + '<br><br>' +

                    '<br><strong>' + (autoMan === 1 ? 'Manual/Hand </strong>Mode' : 'Auto/Schedule </strong>Mode') +
                    '<br>' + (playing === 1 ? 'Playing: ' : 'Last Played: ') +  (show < shows.length ? shows[show].name : 'Must Show Scan! Show ' + show + ' is not in show.txt')+
                    '<br>' + 'Last Time: ' + (deflate === 'nothing' ? '---' : deflate) +
                    '<br>' + 'Next Time: ' + (nxtTime === 0 ? '---' : nxtTime) + 
                    '<br>' + 'Next Show: ' + (nxtShow === 0 ? '---' : nxtShow) + 
                    '<br>' +
                    '<br>' + 'Show Stopping Condition: ' + showStopper +
                    '<br>' +
                    '<br>PLC-MB? <strong>'+plc_client.isConnected()+'</strong>' +
                    '<br>SPM-MB? <strong>'+spm_client.isConnected()+'</strong>'+
                    '<br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readLog\';\" value=\'Read Log\' /><br>');

                    response.end(); 
            }

            else{
                wants = 'unknown request'+" "+path+" "+query;
                response.end(wants);
            }

        }

    }

    else{

        response.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
        response.statusCode = 403;
        response.end('<html><body>Forbidden</body></html>');

    }
}

//==================== converts 2 INT values into Rela and vice versa

function back2Real(low, high){

    var fpnum=low|(high<<16);
    var negative=(fpnum>>31)&1;
    var exponent=(fpnum>>23)&0xFF;
    var mantissa=(fpnum&0x7FFFFF);
    
    if(exponent==255){
     
        if(mantissa!==0)return Number.NaN;
        return (negative) ? Number.NEGATIVE_INFINITY :Number.POSITIVE_INFINITY;
    
    }
    
    if(exponent===0)exponent++;
    else mantissa|=0x800000;
    
    exponent-=127;
    var ret=(mantissa*1.0/0x800000)*Math.pow(2,exponent);
    
    if(negative)ret=-ret;
    return ret;
}

function real2Back(value){

    if(isNaN(value))return [0,0xFFC0];
    if(value==Number.POSITIVE_INFINITY || value>=3.402824e38)
      return [0,0x7F80];
    if(value==Number.NEGATIVE_INFINITY || value<=-3.402824e38)
      return [0,0xFF80];

    var negative=(value<0);
    var p,x,mantissa;
    value=Math.abs(value);
  
    if(value==2.0)return [0,0x4000];
  
    else if(value>2.0){
     
        //Positive exponent
        for(var i=128;i<255;i++){
     
            p=Math.pow(2,i+1-127);
     
            if(value<p){
     
                x = Math.pow(2,i-127);
                mantissa = Math.round((value*1.0/x)*8388608);
                mantissa&=0x7FFFFF;
                value = mantissa|(i<<23);
     
                if(negative)value|=(1<<31);
     
                return [value&0xFFFF,(value>>16)&0xFFFF];
            }
        }
        
        //return infinity
        return negative ? [0,0xFF80] : [0,0x7F80];
    
    }else{

        for(var i=127;i>0;i--){
     
            //Negative exponent
            p = Math.pow(2,i-127);
        
            if(value>p){

                x = p;
                mantissa = Math.round(value*8388608.0/x);
                mantissa&=0x7FFFFF;
                value = mantissa|(i<<23);
                if(negative)value|=(1<<31);
                return [value&0xFFFF,(value>>16)&0xFFFF];

            }

        }

        //Subnormal

        x = Math.pow(2,i-126);
        mantissa = Math.round((value*8388608.0/x));
     
        if(mantissa>0x7FFFFF)mantissa=0x800000;
        value = mantissa;
     
        if(negative)value|=(1<<31);
        return [value&0xFFFF,(value>>16)&0xFFFF];
    }
}

//==================== Modbus Functions

function mbReadM(pasd,query){

    plc_client.readCoils(parseInt(query, 10),1,function(resp){

        resp = "<strong>Reading " + resp.coils[0] + "</strong> at <em>%M</em> " + query;
        pasd(resp);

    });
}

function mbReadMW(pasd,query){

    plc_client.readHoldingRegister(parseInt(query, 10),1,function(resp){

        resp = "<strong>Reading " + resp.register[0] + "</strong> at <em>%MW INT</em> " + query;
        pasd(resp);

    });
}

function mbReadReal(pasd,query){

    plc_client.readHoldingRegister(parseInt(query, 10),2,function(resp){

        resp = "<strong>Reading " + back2Real(resp.register[0], resp.register[1]) + "</strong> at <em>%MW Real</em> " + query;
        pasd(resp);

    });
}

function mbWriteM(pasd,query){

    plc_client.writeSingleCoil(parseInt(query.addr, 10),parseInt(query.val, 10),function(resp){

        resp = "<strong>Wrote " + query.val + "</strong> to <em>%M</em> " + query.addr;
        pasd(resp);

    });
}

function mbWriteMW(pasd,query){

    plc_client.writeSingleRegister(parseInt(query.addr, 10),parseInt(query.val, 10),function(resp){

        resp = "<strong>Wrote " + query.val + "</strong> to <em>%MW INT</em> " + query.addr;
        pasd(resp);

    });
}

function mbWriteReal(pasd,query){

    var realNum = real2Back(query.val);

    plc_client.writeSingleRegister(parseInt(query.addr, 10), realNum[0],function(resp){

        plc_client.writeSingleRegister(parseInt(query.addr, 10) + 1, realNum[1],function(resp){

            resp = "<strong>Wrote " + query.val + "</strong> to <em>%MW Real</em> " + query.addr;
            pasd(resp);

        });
    });
}

function mbReadSPM(pasd,query){

    spm_client.readHoldingRegister(parseInt(query, 10),1,function(resp){
        pasd(JSON.stringify(resp));
    });
}

function mbWriteSPM(pasd,query){

    spm_client.writeSingleRegister(parseInt(query.addr, 10),parseInt(query.val, 10),function(resp){
        pasd(JSON.stringify(resp));
    });
}

//==================== Set User Files

function setLights(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setLights');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/lights.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/lightsBkp.txt',query,'utf-8');
        lights = buf;

    }
}

function setWeirPumpSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setWeirPumpSch');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/weirPump.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/weirPumpBkp.txt',query,'utf-8');
        weirPump = buf;

    }
}

function setFireSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setFireSch');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/fireSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/fierSchBkp.txt',query,'utf-8');
        fireSch = buf;

    }
}

function setFilterSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setFilterSch');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/filterSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/filterSchBkp.txt',query,'utf-8');
        filterSch = buf;

    }
}

function setBW(query){

    //watchDog.eventLog('query 1st :' +query);
    query = decodeURIComponent(query);
    query = JSON.parse(query);
    //watchDog.eventLog('query 2nd :' +query);
    var tempBWdata = bwData;
    //watchDog.eventLog('query length :' +query.length +' :: ' +query[0] +' :: ' +query[1] +' :: ' +query[2]);

    if (query.length === 2){
        //tempBWdata.duration = query[0];
        tempBWdata.schDay = query[0];
        tempBWdata.schTime = query[1];
        //watchDog.eventLog('tempBWdata.schTime:' +tempBWdata.schTime);

        var buf = riskyParse(tempBWdata,'setBW');

        if(buf !== 0){
            fs.writeFileSync(__dirname+'/UserFiles/backwash.txt',tempBWdata,'utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/backwashBkp.txt',tempBWdata,'utf-8');
            bwData = buf;
        }
    }
    else{
        watchDog.eventLog('Bad data. No donut for you.');
    }
}

function setScheduler1(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler1');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/schedule1.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule1Bkp.txt',query,'utf-8');
        schedules[0] = buf;

        watchDog.eventLog('changed schedule1');
        alphaconverter.initiate(0);
        updNxt=1;

    }

    callback(null,JSON.stringify(schedules[0]));
}

function setScheduler2(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler2');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/schedule2.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule2Bkp.txt',query,'utf-8');
        schedules[1] = buf;

        watchDog.eventLog('changed schedule2');
        alphaconverter.initiate(0);
        updNxt=1;
    
    }

    callback(null,JSON.stringify(schedules[1]));
}

function setScheduler3(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler3');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/schedule3.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule3Bkp.txt',query,'utf-8');
        schedules[2] = buf;

        watchDog.eventLog('changed schedule3');
        alphaconverter.initiate(0);
        updNxt=1;

    }

    callback(null,JSON.stringify(schedules[2]));
}

function setScheduler4(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler4');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/schedule4.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule4Bkp.txt',query,'utf-8');
        schedules[3] = buf;

        watchDog.eventLog('changed schedule4');
        alphaconverter.initiate(0);
        updNxt=1;

    }

    callback(null,JSON.stringify(schedules[3]));
}

function setShows(query){

    query=decodeURIComponent(query);
    var buf=riskyParse(query,'setShows');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/shows.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/showsBkp.txt',query,'utf-8');
        shows = buf;

    }
}

function setPlaylists(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setPlaylists');
    var status=0;

    if(buf !== 0){

        var playlist = buf;
        status = alphaconverter.certify(playlist[0],playlist[1]);

        if(status === "OK"){

            watchDog.eventLog('SUCCESSFUL PLAYLIST MODIFICATION: '+query);
            alphaconverter.initiate(0);

            var nao = mainTime;
            nao = nao.getHours()*10000 + nao.getMinutes()*100 + nao.getSeconds();

            var future = alphaconverter.seer(nao,0);
            nxtShow=future[1];
            nxtTime=future[0];
            updNxt=0;
            future=null;
            nao=null;

        }

        manFocus = playlist[0];
    }

    status = (status !== 0) ? JSON.stringify(status):JSON.stringify([]);
    callback(null,status);
}

function setTimeTable(query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setTimetable');

    if(buf !== 0){

        //TODO: Try To Eliminate the Backup Files
        fs.writeFileSync(__dirname+'/UserFiles/timetable.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/timetableBkp.txt',query,'utf-8');

        timetable=buf;
        alphaconverter.initiate(0);

        var nao = mainTime;
        nao = nao.getHours()*10000 + nao.getMinutes()*100 + nao.getSeconds();

        var future = alphaconverter.seer(nao,0);
        nxtShow=future[1];
        nxtTime=future[0];
        updNxt=0;
        future=null;
        nao=null;
    }
}

function getLog(query,callback){

    fs.readFile(__dirname+'/UserFiles/logFile.txt','utf-8',function(err,data){

        if(err){
            throw err;
        }

        var dataString = data.toString();
        callback(null,dataString);
    
    });
}

function getWetNodeError(query,callback){

    fs.readFile('/etc/wetNode.error','utf-8',function(err,data){

        if(err){
            throw err;
        }

        var dataString = data.toString();
        callback(null,dataString);
    
    });
}

//==================== Load/Save Settings

//Save the settings to User Files

function saveSettings(parsedData){
    watchDog.eventLog('Server hit with path /saveSettings with query: ');
    //fs.writeFileSync(__dirname+'/UserFiles/'+ parsedData.screen +'.txt',parsedData.settings,'utf-8');
}

//This function loads the settings from User Filers

function loadSettings(callback, query){
    watchDog.eventLog('Server hit with path /loadSettings with query: ' +query);
    // fs.readFile(__dirname+'/UserFiles/'+ query +'.txt','utf-8',function(err,data){

    //     if(err){
    //         throw err;
    //     }
        
    //     var dataString = data.toString();
    //     callback(null,dataString);

    // });
}

//==================== Data Parser
//also used in BW code. Duplicate changes there too.
function riskyParse(text,what,bkp,xsafe){

    var lamb=0;

    try{

        //First we want to make sure there are no extra qiated inside the text while parsing
        text = elminiateExtraQoutes(what,text);
        lamb = JSON.parse(text);

    }catch(e){

        watchDog.eventLog(what + ' Parse Error');
        watchDog.eventLog("Caught this :" +JSON.stringify(e));

    }finally{

        //Check if extra file safety check is desired
        //TODO: Check what is this used for and f we can eliminate it

        if(xsafe){

            if(riskyParse(fs.readFileSync(__dirname+'/UserFiles/'+bkp+'.txt','utf-8'),'xsafe '+what) !== 0){
                //Parsing of Bkp file was successfule, do nothing

            }else if(lamb !== 0){
                fs.writeFileSync(__dirname+'/UserFiles/'+bkp+'.txt',text,'utf-8');

            }
        }

        //Check if parsing to back-up on initial failure is not desired

        if(!bkp || (bkp && lamb !== 0)){
            
            lamb = (lamb === null) ? 0 : lamb;
            return lamb;
        
        }
        else{
            watchDog.eventLog(what+" file recovered and parsed to bkp");
            lamb = fs.readFileSync(__dirname+'/UserFiles/'+bkp+'.txt','utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/'+what+'.txt',lamb,'utf-8');
            return riskyParse(lamb,what);
        }
    }
}

//This function eliminates any extra single quation from a text

function elminiateExtraQoutes(fileName,text){

    if (fileName == "schedule1" || fileName == "schedule2" || fileName == "schedule3" || fileName == "schedule4" || fileName == "setBW"){
        
        text = text.replace("'", '');
        text = text.replace("'", '');

    }

    return text;
}

//==================== Show Scanner

function showScanner(callback,query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'showScanner');

    if(buf !== 0){
        var ss = require(homeD+'/Includes/showScanner.js');
        ss(buf.start,buf.end);
        callback('show scan begun');
    }else{
        callback('improper query or SPM not connected, no shows scanned');
    }

}

//TODO: Try to eliminiate this function

function createBkps(arr){

    for(var k=0; k<arr.length; k++){

        var buf = riskyParse(fs.readFileSync(__dirname+'/UserFiles/'+arr[k]+'.txt','utf-8'),'createBkp'+arr[k]);

        if(buf !== 0){

            fs.writeFileSync(__dirname+'/UserFiles/'+arr[k]+'Bkp.txt',JSON.stringify(buf),'utf-8');
            arr[k]+=1;

        }else if(buf === 0){
            arr[k]+=0;
        }

    }

    return arr;
}

//==================== Logs

function logsToFTP(callback){

    var exec = require("child_process").exec;

    exec('/etc/logMaint.sh',function(error,stdout,stderr){
        callback(error,stdout,stderr);
    });

}

//==================== Wind Scaling

function setWindScalingData(query){

    query=decodeURIComponent(query);
    var buf=riskyParse(query,'setWindScalingData');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/windScalingData.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/windScalingDataBkp.txt',query,'utf-8');
        windScalingData = buf;

    }
}

//==================== Scheduled Interrupts

//Timer Trial
setTimeout(function(){

    setInterval(function(){
            triggerScripts();
            //watchDog.eventLog('Trigger Scripts');
    },200); 

},500);

//==================== Main Script Loader Indicator

var ldate = (moment.getMonth()+1)*100+moment.getDate();

watchDog.eventLog('----------------------------------------------- ' + proj.toUpperCase() + ' MAIN SCRIPT STARTED');
watchDog.eventLog('----------------------------------------------- DATE '+ldate);