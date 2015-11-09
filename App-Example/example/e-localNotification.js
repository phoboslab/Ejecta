"use strict";

var localNotice = new Ejecta.LocalNotification();
setTimeout(function() {
    localNotice.schedule(1, "title", "message 1", 10);
    localNotice.schedule(1, "title", "message 2", 13);
    console.log("LocalNotification has scheduled, please exit App.");
}, 1200);
