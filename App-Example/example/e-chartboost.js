"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerHeight;

    // var chartboost = new Ejecta.Chartboost("4f21c409cd1cb2fb7000001b", "92e2de2fd7070327bdeb54c15a5295309c6fcd2d");
    var chartboost = new Ejecta.Chartboost("563399dfc909a662da96644e", "37d6219e4bff1a7ba6033d0e13e82ebb1be53214");

    //    chartboost.loadInterstitial();
    chartboost.loadRewardedVideo();
    //    chartboost.loadMoreApps();

    //     chartboost.addEventListener("loaded", function(event) {
    //         console.log(event.adType, event.message);
    //         if (event.adType == "Interstitial") {
    //             chartboost.showInterstitial();
    //         } else if (event.adType == "RewardedVideo") {
    //             chartboost.showRewardedVideo();
    //         } else if (event.adType == "MoreApps") {
    //             chartboost.showMoreApps();
    //         } else {
    //             console.log(event);
    //         }
    //     });
    //

   chartboost.addEventListener("error", function(event) {
       console.log(event.adType, event.message);
       if (event.adType == "Interstitial") {
           chartboost.loadInterstitial();
       } else if (event.adType == "RewardedVideo") {
           chartboost.loadRewardedVideo();
       } else if (event.adType == "MoreApps") {
           chartboost.loadMoreApps();
       } else {
           console.log(event);
       }
   });

    var id = setInterval(function() {
        if (showAd()) {
            clearInterval(id);
        }
    }, 2000);

    // showAd();
    function showAd() {
        if (chartboost.hasInterstitial()) {
            chartboost.showInterstitial();
            return true;
        }
        if (chartboost.hasRewardedVideo()) {
            chartboost.showRewardedVideo();
            return true;
        }
        if (chartboost.hasMoreApps()) {
            chartboost.showMoreApps();
            return true;
        }
    }
}());
