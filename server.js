/*var io = require('socket.io').listen(8081);
io.set('log level', 1);


io.sockets.on('connection', function (socket) {
  socket.on("config", function (obj) {
    console.log('Config: ', obj);
  });
});*/

var server=require('node-http-server');

console.log(server);

server.deploy(
    {
        port:8000,
        root:'./public/'
    }
); 