function displaySchWrapper(){

    //console.log("Filter Pump Schedule script triggered");
    
    var moment = new Date();
    var current_day = moment.getDay();      //0-6
    var current_hour = moment.getHours();   //0-23
    var current_min = moment.getMinutes();  //0-59
    var current_time = (current_hour*100)+current_min;
    var day_ID = 0;

    //6am + 1
    if (current_hour >= (6+1)){

        day_ID = current_day;
    
    }else{
        
        day_ID = current_day - 1;

        if (day_ID < 0){
            day_ID = 6;
        }
        
    }

    var weirPumpSchData = weirPumpSch;
    var on_time = weirPumpSchData[(3*day_ID)+1];
    var off_time = weirPumpSchData[(3*day_ID)+2];

    if ((current_time > 600)&&(off_time <= 600)){
        off_time = 2400;
    }
    else if ((current_time <= 600)&&(off_time <=600)){
        if (on_time >= 600){
            on_time = 0;
        }
    }
    else{
        //So nothing
    }

    if ((current_time >= on_time)&&(current_time < off_time)){
        //turn ON
        plc_client.writeSingleCoil(2111,1,function(resp){
                    //watchDog.eventLog('Display Sch IF' +on_time +' off ' +off_time);
        });

    }
    else{
        //turn OFF
        plc_client.writeSingleCoil(2111,0,function(resp){
                    //watchDog.eventLog('Display Sch ELSE' +on_time +' off ' +off_time);
        });

    }
}

module.exports = displaySchWrapper;