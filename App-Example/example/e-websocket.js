var url = "ws://localhost:8081";
var ws = new Ejecta.WebSocket(url);

ws.onmessage = function(event) {
    var data = event.data;
    console.log(data);
};

ws.onopen = function(event) {
    console.log("ws opened");
};

ws.onclose = function(event) {
    console.log("ws closed");
};

ws.onerror = function(event) {
    console.log("ws error:");
    var data = event.data;
    console.log(data);
};
