var url = "ws://localhost:8080";
var ws = new WebSocket(url);

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

var no = 1;
setInterval(function(){
    if (ws.readyState === ws.OPEN){
        ws.send("message "+ (no++) );
    }
},1000);
