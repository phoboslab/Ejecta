"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerHeight;

    var chartboost = new Ejecta.Chartboost("56050a2d04b0165979d18668", "c9da6b2e27e6d6fcc8716ecdf271b616af652726");

    chartboost.load("interstitial");
    chartboost.load("rewardedVideo");
    chartboost.load("moreApps");

    var id = setInterval(function() {
        if (showAd()) {
            clearInterval(id);
        }
    }, 2000);

    // showAd();
    function showAd() {
        if (chartboost.isReady("interstitial")) {
            chartboost.show("interstitial");
            return true;
        }
        if (chartboost.isReady("rewardedVideo")) {
            chartboost.show("rewardedVideo");
            return true;
        }
        if (chartboost.isReady("moreApps")) {
            chartboost.show("moreApps");
            return true;
        }
    }
}());
