// NodeJS  and   node-ws module are required.
//  $ npm install ws
//  $ node websocket-server.js [port]

"use strict";

var WebSocketServer = require('ws').Server;

var port = process.argv[2] || 8082;

var wss = new WebSocketServer({ port: port });

wss.on('connection', function connection(ws) {
    ws.send('{ "state": "connectioned" }');
    ws.on('message', function incoming(message) {
        console.log('received: %s', message);
        ws.send('{ "echo": ' + message + ' }');
    });
});

console.log("WebSocketServer started at " + port + " ...");
