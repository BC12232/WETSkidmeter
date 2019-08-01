var net         = require('net'),
    handler 	= require('./handler');

var log = function () { };

exports.setLogger = function (logger) {
  log = logger;
  handler.setLogger(logger);
};

exports.createTCPClient = function (port, host, cb) {
  port = port.toString();
  var net 		         = require('net'),
      tcpClientModule    = require('./tcpClient'),
      serialClientModule = require('./serialClient');

  tcpClientModule.setLogger(log);
  serialClientModule.setLogger(log);

  var socket    = net.connect(port, host),
      tcpClient = tcpClientModule.create(socket);

  socket.on('error', function (e) {
      console.log('socket creation by net failed');
      if (!cb) {
          return;
      }

      cb(e);

  });

  socket.on('connect', function () {
      console.log('socket connection by net successful');
      if (!cb) {
          return;
      }

      cb();

  });

  var client = serialClientModule.create(
	tcpClient,
	handler.Client.ResponseHandler);

  client.reconnect = function () {
    socket.connect(port, host);
  };

  client.destroy = function () {
    socket.destroy();
  };

  return client;

};


exports.createTCPServer = function (port, host, cb) {

  var net 	             = require('net'),
      tcpServerModule    = require('./tcpServer'),
      serialServerModule = require('./serialServer');

  tcpServerModule.setLogger(log);
  serialServerModule.setLogger(log);

  var socket = net.createServer().listen(port, host);

  socket.on('error', function (e) { cb(e); });
  socket.on('connection', function (s) {

    var tcpServer = tcpServerModule.create(s);

    var server = serialServerModule.create(
			tcpServer,
			handler.Server.RequestHandler,
			handler.Server.ResponseHandler);

    cb(null, server);

  });

};
