"use strict";

(function() {

    var width = window.innerWidth;
    var height = window.innerHeight;

    // var unityAds = new Ejecta.Vungle("phoena");
    var unityAds = new Ejecta.UnityAds("1012821");
    // unityAds.debug = true;

    var id = setInterval(function() {
        console.log("unityAds.isReady", unityAds.isReady("video"));
        if (unityAds.isReady("video")) {
            showAd();
            clearInterval(id);
        }
    }, 2000);

    // showAd();
    function showAd() {
        unityAds.show("video", {
            onDisplay: function() {
                console.log("rewardedVideo onDisplay");
            },
            onClose: function(info) {
                console.log("rewardedVideo onClose", JSON.stringify(info));
            },
            onFinish: function(info) {
                console.log("rewardedVideo onFinish", JSON.stringify(info));
            },
        });
    }

}());
