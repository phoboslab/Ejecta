"use strict";

var url = "ws://192.168.5.101:8082";
var ws;

function testWS() {
    if (ws && ws.readyState !== WebSocket.CLOSING && ws.readyState !== WebSocket.CLOSED) {
        ws.close();
    }

    ws = new WebSocket(url, undefined);
    ws.binaryType = "arraybuffer";

    ws.onmessage = function(event) {
        var data = event.data;
        console.log(data);
    };

    ws.onopen = function(event) {
        console.log("ws opened", event.message);
    };

    ws.onclose = function(event) {
        console.log("ws closed");
    };

    ws.onerror = function(event) {
        console.log("ws error:");
        var data = event.data;
        console.log(data);
    };
}


testWS();

var no = 1;
setInterval(function() {
    if (!ws) {
        return;
    }
    if (ws.readyState === WebSocket.OPEN) {
        ws.send("message " + (no++));
    } else {
        console.log("readyState: ", ws.readyState);
    }
}, 1000);
