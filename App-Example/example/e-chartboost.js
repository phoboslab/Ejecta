"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerWidth;

     // var cb = new Ejecta.Chartboost("4f21c409cd1cb2fb7000001b", "92e2de2fd7070327bdeb54c15a5295309c6fcd2d");
     var cb = new Ejecta.Chartboost("563399dfc909a662da96644e", "37d6219e4bff1a7ba6033d0e13e82ebb1be53214");

    cb.loadInterstitial();
    cb.loadRewardedVideo();
    cb.loadMoreApps();

    cb.addEventListener("loaded", function(event) {
        console.log(event.adType, event.message);
        if (event.adType == "Interstitial") {
            cb.showInterstitial();
        } else if (event.adType == "RewardedVideo") {
            cb.showRewardedVideo();
        } else if (event.adType == "MoreApps") {
            cb.showMoreApps();
        } else {
            console.log(event);
        }
    });

    cb.addEventListener("error", function(event) {
        console.log(event.adType, event.message);
        if (event.adType == "Interstitial") {
            cb.loadInterstitial();
        } else if (event.adType == "RewardedVideo") {
            cb.loadRewardedVideo();
        } else if (event.adType == "MoreApps") {
            cb.loadMoreApps();
        } else {
            console.log(event);
        }
    });

}());
