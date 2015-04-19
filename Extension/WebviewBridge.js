"use strict";


var WebviewBridge = {

    ID: 1,
    protocol: "eval",

    frameCount: 5,

    _init: function() {
        this.callId = 1;
        this.awaitingCallbacks = {};
    },
    // initInWeb: function(native) {
    initInWeb: function() {
        this._init();
        // this.native = native || this.native;
        this.inWeb = true;
        this.remoteName = "evalNative";
        var Me = this;
        this.evalNative = function(script) {
            evalIframes[iframeIndex].src = Me.protocol + "://script/?" + script;
            iframeIndex = iframeIndex < Me.frameCount ? iframeIndex + 1 : 0;
        }

        var evalIframes = [];
        var iframeIndex = 0;
        for (var i = 0; i <= this.frameCount; i++) {
            var iframe = document.createElement("iframe");
            evalIframes.push(iframe);
            iframe.width = iframe.height = 0;
            iframe.style.display = 'none';
        }

        function initExecIframes() {
            if (document.body && document.body.appendChild) {
                evalIframes.forEach(function(iframe) {
                    document.body.appendChild(iframe);
                })
            } else {
                setTimeout(initExecIframes, 1);
            }
        }
        initExecIframes();

    },

    initInNative: function(webview) {
        this._init();
        webview = this.webview = webview || this.webview;
        this.inNative = true;
        this.remoteName = "evalWeb";
        this.evalWeb = function(script) {
            webview.eval(script);
        }

    },

    evalRemote: function(script) {
        this[this.remoteName](script);
    },

    evalRemoteWithArgs: function(func, args) {
        args = Array.prototype.slice.call(args, 0);
        var str = JSON.stringify(args);
        this[this.remoteName](func + "(" + str.substring(1, str.length - 1) + ")");
    },


    callRemote: function(cmd, args, callback) {
        var args = Array.prototype.slice.call(arguments, 1);
        var callId = this.callId++;
        if (callId >= 1024) callId = this.callId = 1;
        this.awaitingCallbacks[callId] = args.pop(); //callback
        var _cb = "function _cb(){WebviewBridge.callbackRemote(" + callId + ",arguments);}";
        var a;
        if (args.length > 0) {
            a = JSON.stringify(args);
            a = a.substring(1, a.length - 1) + ",";
        } else {
            a = "";
        }
        this[this.remoteName](cmd + "(" + a + _cb + ")");
    },

    callbackRemote: function(callId, args) {
        args = Array.prototype.slice.call(args, 0);
        this.evalRemote("WebviewBridge.callback(" + callId + "," + JSON.stringify(args) + ")");
    },

    callback: function(callId, args) {
        var cb = this.awaitingCallbacks[callId];
        delete this.awaitingCallbacks[callId];
        if (cb) {
            return cb.apply(null, args);
        }
    }

}
