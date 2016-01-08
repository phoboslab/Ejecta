"use strict";

(function() {

    var width = window.innerWidth;
    var height = window.innerHeight;

    var zones = [
        "vz31b549794672442889", // Test
        "vze12a0248564b49fc93", // video
        "vzc1be88f0d438475c84", // rewardedVideo
    ];
    var debug = true;
    var adColony = new Ejecta.AdColony("appc3f406f4c59344238f", zones, debug);


    var id = setInterval(function() {
        console.log("adColony.isReady", adColony.isReady("video", {
            zone: "vz31b549794672442889"
        }));
        if (adColony.isReady("video", {
                zone: "vz31b549794672442889"
            })) {
            showAd();
            clearInterval(id);
        }
    }, 2000);

    // showAd();
    function showAd() {
        adColony.show("video", {
            zone: "vz31b549794672442889",

            onDisplay: function() {
                console.log("video onDisplay");
            },
            onClose: function(info) {
                console.log("video onClose", JSON.stringify(info));
            },
            onFinish: function(info) {
                console.log("video onFinish", JSON.stringify(info));
            },
        });
    }

}());
