(function(exports){

var NO_SUCH_METHOD = -90001;
var TYPE_SEND = -1;
var TYPE_PING = -0x10;
var TYPE_PONG = -0x11;

SteamPunkClient.formatters = {
  'JSON': {
    toBuff : JSON.stringify,
    toObj : JSON.parse
  }
}

// NOTE
function strToBlob (str) {
  return new Blob([str], {type: 'text/plain;charset=UTF-8'})
}

function SteamPunkClient(ws, format, DEBUG){
  this.ws = ws;
  format = this.format = format && format.toUpperCase() || 'JSON';
  var formatter = SteamPunkClient.formatters[format];
  var toBuff = this.toBuff = formatter.toBuff;
  var toObj = this.toObj = formatter.toObj;
  this.timeout = 5000;
  this.reqid = 0;
  this.pingid = 0;
  this.pongHandlers = [];

  var awatingCallbacks = this.awatingCallbacks = {};
  var msgListeners = this.msgListeners = {};
  var self = this;
  this._DEBUG = DEBUG;
  ws.onmessage = function(event) {
    var data = event.data;
    var msg = toObj(data);
    var id = msg[0];
    if(id == TYPE_SEND) {
      // msg = [-1, msgKey, data]
      var msgKey = msg[1];
      var listeners = msgListeners[msgKey];
      if(listeners) {
        if(DEBUG) console.log(" ### recv ",msgKey,msg.slice(2));
        listeners.forEach(function(lis) {
            lis.apply(null, msg.slice(2));
        });
      } else {
        if(DEBUG) console.warn('no listeners found for ', msg[1]);
      }
    } else if (id == TYPE_PING) {
      msg[0] = TYPE_PONG;
      self.sendMsg(msg);
    } else if (id == TYPE_PONG) {
      var onPong = self.pongHandlers[msg[1]];
      onPong && onPong();
    } else if(id >= 0) {
      // msg = [id, data]
      var resCallback = awatingCallbacks[id];
      if(resCallback) {
        if(DEBUG) console.log(" ******** back ",resCallback.cmd,msg.slice(1));
        resCallback.apply(null, msg.slice(1));
      }
      delete awatingCallbacks[id];
    } else {
      console.error('wrong type of handler', msg);
    }
  }

  ws.onerror = function(err){
    self.onerror && self.onerror(err);
  }

  ws.onclose = function() {
    self.onclose && self.onclose();
  }
}

var sp = SteamPunkClient.prototype;
var WS_OPEN = 1;

// 
sp.sendMsg = function(msg) {
  this.ws.send(this.toBuff(msg) /*, {binary: true} */);
}

sp.ready = function(fn) {
  if(this.ws.readyState == WS_OPEN) {
    fn();
  } else {
    this.ws.onopen = fn;
  }
}

// var login = sp.cmd('login');
sp.cmd = function(cmd) {
  return sp.req.bind(this, cmd);
}

sp.req = function(/* cmd, arg0, arg1, ... callback*/){
  var args = Array.prototype.slice.call(arguments);
  var reqid = this.reqid ++;
  if(reqid > 255) reqid = this.reqid = 1;
  args.unshift(reqid);

  var callback=args.pop();
  this.awatingCallbacks[reqid] = callback;
  this.sendMsg(args);

  callback.cmd=args[1];
  if(this._DEBUG) console.log(" *** call ",callback.cmd, args.slice(2));
}

sp.recv = function(msgKey, fn) {
  (this.msgListeners[msgKey] || (this.msgListeners[msgKey] = [])).push(fn);
}

sp.unrecv = function(msgKey, fn) {
  var listeners = this.msgListeners[msgKey];
  if(!listeners) return;
  if(fn) {
    this.msgListeners[msgKey] = listeners.splice(listeners.indexOf(fn), 1);
  } else {
    this.msgListeners[msgKey] = null;
  }
}

sp.send = function(/* cmd, arg0, arg1, ... */) {
  var args = Array.prototype.slice.call(arguments);
  args.unshift(TYPE_SEND);
  this.sendMsg(args);
}

sp.setTimeout = function(timeout) {
  this.timeout = timeout;
}

sp.close = function() {
  this.ws.close();
}

// Only one ping exist on time.
sp.ping = function(size, pongFn) {
  var self = this;
  var id = self.pingid ++;
  if(self.pingid >= 255) {
    self.pingid = 0;
  }
  var startTime = Date.now();
  // timeout for ping.
  var pongTimer = setTimeout(function(){
      // emit timeout
      self.ontimeout && self.ontimeout(startTime);
      // prevent memory leak
      self.pongHandlers[id] = null;
  }, self.timeout);
  function onPong() {
    clearTimeout(pongTimer);
    pongFn && pongFn(Date.now() - startTime);
  }
  self.pongHandlers[id] = onPong;

  // send ping message
  self.sendMsg([TYPE_PING, id, size && new Array(size + 1).join('.')]);
}

exports.SteamPunkClient = SteamPunkClient;

})(typeof exports == 'undefined' ? window : exports);
