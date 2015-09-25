// NodeJS  and   node-ws module are required.
//  $ npm install ws
//  $ node websocket-server.js

var WebSocketServer = require('ws').Server,
    wss = new WebSocketServer({
        port: 8080
    });


wss.on('connection', function connection(ws) {
    ws.on('message', function incoming(message) {
        console.log('received: %s', message);
    });
    ws.send('something');
});

console.log("WebSocket server is started.");
