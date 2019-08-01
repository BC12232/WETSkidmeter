var fs = require("fs");
var querystring = require("querystring");
var exec = require("child_process").exec;

var indexOfFiles = function(response) {	
	var userfiles = fs.readdirSync(homeD+'/UserFiles');	
	var includes = fs.readdirSync(homeD+'/Includes');	
	tarriFy();
	response.writeHead(200,{"Content-Type":"text/html"});	
	response.write("<a href='/userfiles?dir=&file=superMain.tar.gz'>DOWNLOAD EVERYTHING (tar.gz)</a><br>");        
	response.write("<h4>Main</h4>");	
	response.write("<h4>Includes</h4>");	
	for (var i = 0; i < includes.length; i++) {		
		response.write("<a href='/userfiles?dir=Includes&file=" + includes[i] + "'>" + includes[i] + "</a><br>");	
	}	
	if (userfiles.length === 0) {		
		response.write("<h4>No UserFiles Found</h4>");	
	} 
	else {		
		response.write("<h4>UserFiles</h4>");		
		for (var i = 0; i < userfiles.length; i++) {
			response.write("<a href='/userfiles?dir=UserFiles&file=" + userfiles[i] + "'>" + userfiles[i] + "</a><br>");		
		}	
	}	
	response.end();
};

var downloadingFile = function(response, query) {	
	query = querystring.parse(query);	
	var download;	
	if (query.dir === null){		
		download = fs.readFileSync(homeD + query.file);	
	} 
	else {		
		download = fs.readFileSync(homeD+'/'+ query.dir +'/' + query.file);	
	}	
	response.writeHead(200,{"Content-Disposition": "attachment; filename=" + query.file, "Content-Type": "application/download", "Content-Description": "File Transfer"});	
	response.end(download);
};

var tarriFy = function(){
	exec('rm '+homeD+'/superMain.tar.gz',function(a,b,c){
		exec('tar -cvf superMain.tar '+homeD,
			function(error, stdout, stderr){
				console.log('stdout: '+stdout);
				console.log('stderr: '+stderr);
				if(error!==null){
					console.log('exec err: '+error);
				}
				exec('gzip '+homeD+'/superMain.tar',function(error,stdout,stderr){}); 
			}
		);
	});
}

exports.indexOfFiles = indexOfFiles;
exports.downloadingFile = downloadingFile;