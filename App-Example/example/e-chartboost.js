"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerWidth;

    var cb = new Ejecta.Chartboost("4f21c409cd1cb2fb7000001b",
        "92e2de2fd7070327bdeb54c15a5295309c6fcd2d");

    cb.loadInterstitial();
    cb.loadRewardedVideo();
    cb.loadMoreApps();

    cb.addEventListener("loaded", function(event) {
        console.log(event.adType, event.message);
        if (event.adType == "Interstitial") {
            cb.showInterstitial();
        } else if (event.adType == "MoreApps") {
            cb.showMoreApps();
        } else if (event.adType == "RewardedVideo") {
            cb.showRewardedVideo();
        } else {
            console.log(event);
        }
    });

    cb.addEventListener("error", function(event) {
        console.log(event.adType, event.message);
        if (event.adType == "Interstitial") {
            cb.cb.loadInterstitial();
        } else if (event.adType == "MoreApps") {
            cb.cb.loadMoreApps();
        } else if (event.adType == "RewardedVideo") {
            cb.loadRewardedVideo();
        } else {
            console.log(event);
        }
    });

}());
