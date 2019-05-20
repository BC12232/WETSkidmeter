function waterQualityWrapper(){

  //console.log("Water Quality script triggered");

  var date = mainTime;
  var time = date.getFullYear() + "."+  ((date.getMonth() + 1) < 10 ? "0" :"") + (date.getMonth() + 1) + "." + (date.getDate() < 10 ? "0" : "") + date.getDate() + " " + (date.getHours() < 10 ? "0" : "") + date.getHours() + ":" + (date.getMinutes() < 10 ? "0" : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? "0" : "") + date.getSeconds();

  var mw101PH;
  var mw101ORP;
  var mw101TDS;
  var mw101BR;

  if ( (date.getHours() === 0) && (date.getMinutes() === 0) && (date.getSeconds() < 5) ){
    //empty out DAY array at the start of the new day
    mw101WQ_Day["ph"] = [];
    mw101WQ_Day["orp"] = [];
    mw101WQ_Day["tds"] = [];
    mw101WQ_Day["br"] = [];
    mw101WQ_Day["date"] = [];
  }
  else if (PLCConnected){
    plc_client.readHoldingRegister(300, 2, function(resp){
      mw101PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      plc_client.readHoldingRegister(310, 2, function(resp){
        mw101ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        plc_client.readHoldingRegister(320, 2, function(resp){
          mw101TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          plc_client.readCoils(326,1,function(resp){
            mw101BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (mw101WQ_15mins["ph"].length > 900) {
              mw101WQ_15mins["ph"].shift();
              mw101WQ_15mins["orp"].shift();
              mw101WQ_15mins["tds"].shift();
              mw101WQ_15mins["br"].shift();
              mw101WQ_15mins["date"].shift();
            }

            mw101WQ_15mins["ph"].push(mw101PH);
            mw101WQ_15mins["orp"].push(mw101ORP);
            mw101WQ_15mins["tds"].push(mw101TDS);
            mw101WQ_15mins["br"].push(mw101BR);
            mw101WQ_15mins["date"].push(time);

            //"WEEK" data
            //sampling frequency is once every mins 
            if (date.getSeconds() == 0) {
              
             mw101WQ_Day["ph"].push(avg1min(mw101WQ_15mins["ph"]));
             mw101WQ_Day["orp"].push(avg1min(mw101WQ_15mins["orp"]));
             mw101WQ_Day["tds"].push(avg1min(mw101WQ_15mins["tds"]));
             mw101WQ_Day["br"].push(avg1min(mw101WQ_15mins["br"]));
             mw101WQ_Day["date"].push(time);

              //collect and display 24hrs of data (freq 1 min)
              if (mw101WQ_24hrs["ph"].length > 1440) {
                  mw101WQ_24hrs["ph"].shift();
                  mw101WQ_24hrs["orp"].shift();
                  mw101WQ_24hrs["tds"].shift();
                  mw101WQ_24hrs["br"].shift();
                  mw101WQ_24hrs["date"].shift();
              }

             mw101WQ_24hrs["ph"].push(avg1min(mw101WQ_15mins["ph"]));
             mw101WQ_24hrs["orp"].push(avg1min(mw101WQ_15mins["orp"]));
             mw101WQ_24hrs["tds"].push(avg1min(mw101WQ_15mins["tds"]));
             mw101WQ_24hrs["br"].push(avg1min(mw101WQ_15mins["br"]));
             mw101WQ_24hrs["date"].push(time);

            }

          }); 
        });
      });
    });
  }

  if ( (date.getHours() === 23) && (date.getMinutes() === 59) && (date.getSeconds() > 30) ){
      
      //write DAY data to txt file, one shot
      if (writeWQfile === 0){

        watchDog.eventLog("Updated WQ File on the server.");

        var data1 = JSON.stringify(mw101WQ_Day);
        data1+='\n';

        fs.writeFileSync(homeD+'/UserFiles/WQ_' +date.getDay() +'.txt',' @ ' +time +' @ :' +data1,'utf-8');

        writeWQfile = 1;

      }
  }
  else{
    writeWQfile = 0;
  }

function back2Real(low, high){
  var fpnum=low|(high<<16);
  var negative=(fpnum>>31)&1;
  var exponent=(fpnum>>23)&0xFF;
  var mantissa=(fpnum&0x7FFFFF);
  if(exponent==255){
   if(mantissa!==0)return Number.NaN;
   return (negative) ? Number.NEGATIVE_INFINITY :
         Number.POSITIVE_INFINITY;
  }
  if(exponent===0)exponent++;
  else mantissa|=0x800000;
  exponent-=127;
  var ret=(mantissa*1.0/0x800000)*Math.pow(2,exponent);
  if(negative)ret=-ret;
  return ret;
}

function avg1min(totalArray){

  //watchDog.eventLog("totalArray: " +totalArray);
  //watchDog.eventLog("Array Length: " +totalArray.length);
  
  var avg = 0;
  if (totalArray.length > 60){
    for (var i=0; i <= 60 ; i++){
      avg += totalArray[i];
    }
    avg = avg/60;
  }
  else{
    for (var i=0; i <= (totalArray.length-1) ; i++){
      avg += totalArray[i];
    }
    avg = avg/(totalArray.length-1);
  }
  return avg;
}

}

module.exports=waterQualityWrapper;