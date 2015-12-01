"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerHeight;

    var chartboost = new Ejecta.Chartboost("56050a2d04b0165979d18668", "c9da6b2e27e6d6fcc8716ecdf271b616af652726");

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
