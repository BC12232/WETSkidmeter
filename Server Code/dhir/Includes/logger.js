var logger = function() {
 
    var fs = require('fs');
 
    var XMLHttpRequest = require("XMLHttpRequest").XMLHttpRequest;
    var xhr = new XMLHttpRequest();
    var file = '/visudata/public/Scripts/UserFiles/logFile.txt';
    var project = 'wetsochi';
    var db_ip = '50.63.244.14';
   
    fs.watch(file, function (curr, prev) {
      fs.stat(file, function (err, stats) {
        console.log(stats.size);
        if (stats.size > 10) {
                            fs.readFile(file, 'utf8', function(err, log){
                                    log = encodeURIComponent(log);
                                    xhr.open("GET", "http://wetdesign.tv/logger/logger-datetime.php?project=" + project + "&db_ip=" + db_ip + "&log=" + log);
                                    xhr.send();
                                    fs.writeFile(file, '', function(){});
                            });
                    }
      });
    });
};

 
exports.logger = logger;

