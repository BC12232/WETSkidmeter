// Show Scanner
function nameOf(here,there){
	if(here<=there){
		spm_client.writeSingleRegister(1002,32768,function(resp){
			spm_client.writeSingleRegister(1005,here,function(resp){
				spm_client.writeSingleRegister(1004,0,function(resp){
					spm_client.writeSingleRegister(1004,8,function(resp){
						spm_client.readHoldingRegister(2003,1,function(resp){
							if(resp.register[0] !== here){
								if(here < shows.length){
									shows[here]={"name":"-","number":here,"duration":0,"color":1};
								}
								nameOf(here+1,there);
							}
							else{
								spm_client.readHoldingRegister(6000,24,function(resp){
									var nem='';
									resp.register.every(function(elem){if(elem>0){oddByte(elem).every(function(elem1){nem+=String.fromCharCode(elem1);return true})}return true});
									console.log('show No '+here+' '+'is '+nem);
									nameOf(here+1,there);
									// adds spacer shows to show array, if needed
									for(var k=shows.length; k<=here; k++){
										shows.push({"name":"-","number":k,"duration":0,"color":1});
									}
									shows[here].name=nem;
									spm_client.readHoldingRegister(2014,2,function(resp){
										var a = oddByte(resp.register[0]);
										var b = oddByte(resp.register[1]);
										shows[here].duration=a[1] + b[0]*60 + b[1]*3600;
										console.log('duration of '+here+' '+(a[1] + b[0]*60 + b[1]*3600));
										console.log(JSON.stringify(resp));
									});
								}); // read loaded show's name
							}
						}); // check if loaded show is equal to target
					}); // issue load show command to load show register
				}); // zero-out load show register to accomodate high edge
			}); // indicate show number
		}); // disable outputs

	}
	// once the basecase has been reached do this bracket instead
	else{
		spm_client.writeSingleRegister(1002,2,function(resp){ 
			spm_client.writeSingleRegister(1005,0,function(resp){
				spm_client.writeSingleRegister(1004,0,function(resp){
					spm_client.writeSingleRegister(1004,8,function(resp){
						spm_client.readHoldingRegister(2003,1,function(resp){
							console.log('outputs enabled, show 0 played... loaded show is '+ resp.register[0]);
							fs.writeFileSync(homeD+'/UserFiles/shows.txt',JSON.stringify(shows),'utf-8');
							fs.writeFileSync(homeD+'/UserFiles/showsBkp.txt',JSON.stringify(shows),'utf-8');
						});
					}); // load show 0
				}); // zero-out load register to accomodate high edge
			}); // indicate show number 0
		}); // enable outputs, set to medium wind
	}
}

// returns the value of the bth bit of n
function nthBit(n,b){
    var here = 1 << b;
    if (here & n){
        return 1;
    }
    return 0;
}

// converts up to 16-bit binary (including 0 bit) to decimal 
function oddByte(fruit){
    var low=0;
    var high=0;
    for (k=0;k<8;k++){
        if(nthBit(fruit,k)){low+=Math.pow(2,k);}
    }
    for (k=8;k<16;k++){
        if(nthBit(fruit,k)){high+=Math.pow(2,k-8);}
    }
    return [low,high];
}

module.exports=nameOf;
