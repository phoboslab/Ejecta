"use strict";

(function() {

    var width = window.innerWidth;
    var height = window.innerHeight;

    var appodeal = new Ejecta.Appodeal("101b42e17b72058ee41c21ac172e734d814dd0f947a22cf4");
    appodeal.setDebugEnabled(true);

    function startCheck() {
        var id = setInterval(function() {
            if (appodeal.isReady("videoOrInterstitial")) {
                clearInterval(id);
                showAd();
            }
        }, 1500);
    }

    function showAd() {

        appodeal.show("videoOrInterstitial", {
            afterClose: function() {
                startCheck();
            }
        });
    }


    startCheck();

}());
