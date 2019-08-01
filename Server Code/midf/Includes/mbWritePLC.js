module.exports = function (val,addr,callback){    
    plc_client.writeSingleRegister(addr,val,function(resp){        
        if(typeof callback !== 'undefined'){callback();    
        }});
};