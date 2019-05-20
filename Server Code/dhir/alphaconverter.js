
function initiate(arg){
    var calender_date = mainTime;
    var current_month = calender_date.getMonth()+1;
    var current_date = calender_date.getDate();
    var current_year = calender_date.getYear();

    var current_day = calender_date.getDay();

    var reqDate;
    var reqMonth;

    if(arg === 1){
        var tomorrowDate = mainTime;
        tomorrowDate.setDate(mainTime.getDate() + 1);
        current_day = tomorrowDate.getDay();
        current_month = tomorrowDate.getMonth()+1;
        watchDog.eventLog('alphaconverter: NEW DAY - ' + current_day);
    }

    reqDate = current_date;
    reqMonth = current_month;

    var currentDaylistID = procure(reqDate,reqMonth, current_year) + current_day;
    watchDog.eventLog('current DaylistID: ' + currentDaylistID);

    var getSchedule = extract(currentDaylistID);
    var getCompleteSchedule = [];
    getCompleteSchedule[0] = currentDaylistID;
    getCompleteSchedule[1] = expand(getSchedule);
    getCompleteSchedule = JSON.stringify(getCompleteSchedule);
    fs.writeFileSync(homeD+'/UserFiles/alphabuffer.txt',getCompleteSchedule,'utf-8');
    alphabufferData = JSON.parse(getCompleteSchedule);
}

//// code to determine today's or a target day's daylist ID get_day
function procure(pdate,pmonth, year){
    var schID = 1001;//default value to be returned if none of the secondary schedules are enabled

    var sch = timetable;

    var todays_linear_date = pmonth + pdate/100; 

    var linear_date_sch1_start = sch[0].startMonth + sch[0].startDate/100; 
    var linear_date_sch1_end  = sch[0].endMonth + sch[0].endDate/100; 

    var linear_date_sch2_start = sch[1].startMonth + sch[1].startDate/100; 
    var linear_date_sch2_end  = sch[1].endMonth + sch[1].endDate/100; 

    var linear_date_sch3_start = sch[2].startMonth + sch[2].startDate/100; 
    var linear_date_sch3_end  = sch[2].endMonth + sch[2].endDate/100; 


    if (sch[0].state) {
        if (linear_date_sch1_start <= todays_linear_date && todays_linear_date <= linear_date_sch1_end) {
            schID = 1008;
        }
    }

    if (sch[1].state) {
        if (linear_date_sch2_start <= todays_linear_date && todays_linear_date <= linear_date_sch2_end) {
            schID = 1015;
        }
    }

    if (sch[2].state) {
        if (linear_date_sch3_start <= todays_linear_date && todays_linear_date <= linear_date_sch3_end) {
            schID = 1022;
        }
    }

    return schID;

}

//// once the daylist ID of interest is determined proceed to extract endtime
//// the raw schedule from the alpha (alpha.txt) and expand it into the alpha buffer (alphabuffer.txt)
function extract(did){
    var nth;
    var i;
    var package=[];
    if(1001<=did && did<1008){
        nth=did-1001;
        i=1;
    }
    else if(1008<=did && did<1015){
        nth=did-1008;
        i=2;
    }
    else if(1015<=did && did<1022){
        nth=did-1015;
        i=3;
    }
    else if(1022<=did && did<1029){
        nth=did-1022;
        i=4;
    }
    else{
        nth = 1;
        i = 1;
    }
    var mummy = schedules[i-1];
    for(var t=100*nth;t<100*(nth+1);t++){
        package.push(mummy[t]);
    }
    return package;
}

// expand will be given a daylist array
// which it will convert to showtimes
// and show numbers as the day's schedule
function expand(arry){
    // multiply show times by 100 to add seconds resolution
    for(var k=0;k<arry.length;k+=2){
        arry[k]*=100;
    }
    // explode playlists into constituent shows using sew
    // instead of >100 as qualifying logic, use p
    for(var k=1;k<arry.length;k+=2){
        if(typeof arry[k] === 'string'){
            var t = sew(arry[k-1],arry[k]);
            var first_arry = arry;
            first_arry = first_arry.slice(0,k-1);
            var sec_arry = arry;
            sec_arry = sec_arry.slice(k+1);
            arry = [];
            arry = first_arry.concat(t);
            arry = arry.concat(sec_arry);
        }
    }
    return arry;
}

// returns an array of showtimes and show numbers
// when given a start time and playlist number
function sew(st,pn){
    pn=parseInt(pn.replace(/^\D+/g,''))-1;
    var sewn=[st];
    for(var q=0;q<playlists[pn].contents.length;q+=2){
        var sn = playlists[pn].contents[q];
        var lc = playlists[pn].contents[q+1];
        for(var k=lc;k>0;k--){
            if(showNoShow(sn)){
                sewn.push(sn);
                sewn.push(endtime(sewn[sewn.length-2],shows[sn].duration));
            }
        }
    }
    return sewn.slice(0,-1);
}

function certify(playlistID,contents){
    var clash = []; // array which stores all clash points
    var schedule = [];
    //get show and playlist details details
    var newPLDuration = 0;
    for (var k=0; k<20; k=k+2){
        if(showNoShow(contents[k])){
            newPLDuration = newPLDuration + shows[contents[k]].duration*contents[k+1];
        }
    }
    // make a duplicate of the original playlist array for analysis
    var myPlaylist={};
    myPlaylist.duration = newPLDuration;
    myPlaylist.contents = contents.slice();

    //get Schedule 1
    schedule = schedules[0];
    //check
    check(playlistID,1);
    //get Schedule 2
    schedule = schedules[1];
    //check
    check(playlistID,2);
    //get Schedule 3
    schedule = schedules[2];
    //check
    check(playlistID,3);
    //get Schedule 4
    schedule = schedules[3];
    //check
    check(playlistID,4);

    if (clash.length === 0){//no clash, ok to write information back into database and reflect in global variable
        playlists[playlistID-1].contents=myPlaylist.contents.slice();
        playlists[playlistID-1].duration=myPlaylist.duration;
        var plistBuf = JSON.stringify(playlists);
        fs.writeFileSync(homeD+'/UserFiles/playlists.txt',plistBuf,'utf-8');
        clash = "OK";
    }
    return clash;//send empty array to iPad or send clash info

    function check(ID,set){
        for (var i = 1; i <= 699; i = i+2){
            if (schedule[i] === ID){
                var et = endtime(schedule[i-1]*100,myPlaylist.duration);//mult by 100 to include seconds
                var nextST;
                if(schedule[i+1]%100===0 || schedule[i+1]===0){nextST = 240000;}
                else{nextST = schedule[i+1]*100;}//Mult by 100 to include seconds
                if(et>nextST){
                    var dayNumber = Math.floor(i/100);
                    var day;
                    switch (dayNumber){
                        case 0:
                            day = "SUN";
                            break;
                        case 1:
                            day = "MON";
                            break;
                        case 2:
                            day = "TUE";
                            break;
                        case 3:
                            day = "WED";
                            break;
                        case 4:
                            day = "THU";
                            break;
                        case 5:
                            day = "FRI";
                            break;
                        case 6:
                            day = "SAT";
                            break;
                    }
                    watchDog.eventLog("Collision at Schedule" +set +" on " +day);
                    watchDog.eventLog("NEXT "+nextST+"ENDTIME"+et);
                    var clashData = "Collision at Schedule" +set +" on " +day;
                    clash.push(clashData);//schedule number
                    i = (100*(Math.floor(i/100) + 1))+1;//jump to next day so that information is not repeated
                }
            }
        }
    }
}

function endtime(show_starttime, show_duration){
    var startHour = Math.floor(show_starttime/10000);
    var startMin = Math.floor((show_starttime-startHour*10000)/100);
    var startSec = show_starttime-startHour*10000-startMin*100;

    var durHour = Math.floor(show_duration/3600);
    var durMin = Math.floor((show_duration-durHour*3600)/60);
    var durSec = show_duration-durHour*3600-durMin*60;

    var endSec = startSec+durSec;
    var endMin = startMin+durMin;
    var endHour = startHour+durHour;

    endMin += Math.floor(endSec/60);
    endSec = endSec%60;

    endHour += Math.floor(endMin/60);
    endMin = endMin%60;

    return endHour*10000+endMin*100+endSec;
}

function seer(now,which){
    var a = 0;
    var b = 0;
    var hit=0;

    var schedulen;
    if(which){
        schedulen = betabufferData;
    }
    else{
        schedulen = alphabufferData[1];
    }

    for(var g=schedulen.length-2;g>=0;g-=2){
        if(now>=schedulen[g]&&schedulen[g]>0){
            a = schedulen[g+2];
            b = schedulen[g+3];
            hit++;
            break;
        }
    }
    // if now is still earlier than the first item in the alphabuffer
    if(hit===0){
        a = schedulen[0];
        b = schedulen[1];
    }

    return [a,b];
}

// next=start time (HHMMSS) of next show, end=end time (HHMMSS) of current show,
// duration=seconds of activity user wants to check if it can squeeze between
function squeez(next,end,duration){
    var endHour = Math.floor(end/10000);
    var endMin = Math.floor((end - endHour*10000)/100);
    var endSec = (end - endHour*10000 - endMin*100);

    var nextHour = Math.floor(next/10000);
    var nextMin = Math.floor((next - nextHour*10000)/100);
    var nextSec = (next - nextHour*10000 - nextMin*100);

    var gap=0;
    if(nextHour>endHour){
        gap += (nextHour-endHour-1)*3600;
        gap += (60-endMin-1)*60;
        gap += (60-endSec);

        gap += nextMin*60;
        gap += nextSec;
    }
    else{
        gap += (nextMin - endMin -1)*60;
        gap += (60 - endSec);

        gap += nextSec;
    }

    if (duration <= gap){
        return 1;
    }
    else{
        return 0;
    }
}

// determines if a show number is 'safe' to access
// properties from
function showNoShow(sn){
    if(sn < shows.length){
        if(shows[sn].duration > 0){
            return 1;
        }
        else{
            return 0;
        }
    }
    else{
        return 0;
    }
}

// checks if a sn with st can be added to the schedule
function checkInsert(st,sn,dayID){
    // st - proposed start time in HHMM
    // sn - show number
    // dayID - Sunday=1, Monday=2, Tuesday=3, Wed=4, Thur=5, Fri=6 and Sat=7
    // this function can be called by the iPad to check if the show can be scheduled
    // function returns boolean value, 1 - ok to insert, 0 - not ok to insert. if returns 2, then bug in the code

    var InsertOK = 0;//not OK to insert by default

    var localSch = [];
    localSch = expand(extract(1000+dayID));
    var et = getEndtime(st,sn);
    st = st*100;
    et = et*100;

    if (localSch[0] === 0){//no shows scheduled
        InsertOK = 1;
        //watchDog.eventLog("Here because no shows scheduled");
    }
    else if (localSch[2] === 0){//only 1 show scheduled
        //watchDog.eventLog("Here because only 1 show is scheduled");
        if( (et<=localSch[0])||(st>=getEndtime(localSch[0],localSch[1])) ){
            InsertOK = 1;
        }
        else{
            InsertOK = 0;
        }
    }
    else if (st < localSch[0]){//st is earlier than the first scheduled show
        //watchDog.eventLog("Here because st is earlier than the first scheduled show" +st +" :: " +localSch[0] +"::" +et);
        if(et <= localSch[0]){
            InsertOK = 1;
        }
        else{
            InsertOK = 0;
        }
    }
    else{//multiple shows
        //watchDog.eventLog("Here because multiple shows");
        var arrLen= (localSch.length)-2;
        for(var t=0;t<arrLen;t=t+2){
            if (localSch[t+2] === 0){//no show after the current show
                if( st >= getEndtime(localSch[t],localSch[t+1]) ){
                    InsertOK = 1;
                    //watchDog.eventLog("Here because last show was already played");
                    break;
                }
                else{
                    InsertOK = 0;
                    break;
                }
            }
            else{
                if( ( st >= getEndtime(localSch[t],localSch[t+1]) ) &&  ( et <= getEndtime(localSch[t+2],localSch[t+3]) ) ){
                    InsertOK = 1;
                    //watchDog.eventLog("Here because i sense a gap!");
                    break;
                }
                else{
                    //test the next iteration till a break point is encountered
                }
            }
        //if for loop run through its entire loop without hitting a break point, then leave InsertOK at 0
        }

    }
    return InsertOK;
}

function getEndtime(st,sn){
    var dur = 0;
    var et = 0;
    // sn - can be reg Show or Playlist or BW

    if ( isNaN(sn) ){//playlist
        var pn=parseInt(sn.replace(/^\D+/g,''))-1;
        dur = playlists[pn].duration; 
    }

    else if (sn === 999){//check BW code.
        dur = bwData.duration;
    }

    else{
        dur = shows[sn].duration;
    }
    et = endtime(st,dur);
    return et;
}

module.exports.extract=extract;
module.exports.expand=expand;
module.exports.sew=sew;
module.exports.initiate=initiate;
module.exports.procure=procure;
module.exports.certify=certify;
module.exports.endtime=endtime;
module.exports.seer=seer;
module.exports.squeez=squeez;
module.exports.showNoShow=showNoShow;
module.exports.checkInsert=checkInsert;
module.exports.getEndtime=getEndtime;