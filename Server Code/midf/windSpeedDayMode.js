function wsdmw(){

    // DEFAULT Wind Scaling Setting setPoints
    // {
    // "windBelowLow" : 0,
    //  "windAboveHi" : 2,
    //  "windNeither" : 1
    // }


    //console.log("wind Speed script triggered");

    var windBelowLow = windScalingData.windBelowLow;
    var windAboveHi = windScalingData.windAboveHi;
    var windNeither = windScalingData.windNeither;
    var dayModeValue = 0;

    if (dayMode == 1){
        dayModeValue = 16;
    }
    else{
        dayModeValue = 0;
    }
    //watchDog.eventLog('DayMode : ' +dayMode);
    //watchDog.eventLog('DayMode Value: ' +dayModeValue);

    var windStatus = sysStatus[0].Wind_Sensors;
    //watchDog.eventLog('Wind Status: ' +windStatus );

    var hiWindMode = windStatus[1] + windStatus[5];
    var loWindMode = windStatus[2] + windStatus[6];

    //watchDog.eventLog('hiWindMode: ' +hiWindMode);
    //watchDog.eventLog('loWindMode: ' +loWindMode);

    //Wind speed Below Loaw
    if (loWindMode === 2){
        //watchDog.eventLog('here1');
        spm_client.writeSingleRegister(1002, windBelowLow + dayModeValue,null);

    }
    
    //Wind Speed Above High

    else if (hiWindMode > 0){
        //watchDog.eventLog('here2');
        spm_client.writeSingleRegister(1002, windAboveHi + dayModeValue,null);

    }

    //Wind Speed Neither
    else{
        //watchDog.eventLog('here3');
        spm_client.writeSingleRegister(1002, windNeither + dayModeValue,null);

    }

}

module.exports=wsdmw;