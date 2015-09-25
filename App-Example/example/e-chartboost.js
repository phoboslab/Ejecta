"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerWidth;

    var cb = new Ejecta.Chartboost("56050a2d04b0165979d18668",
        "c9da6b2e27e6d6fcc8716ecdf271b616af652726");

    cb.loadInterstitial();
    cb.loadMoreApps();
    cb.loadRewardedVideo();

    cb.addEventListener("loaded", function(event) {
        if (event.adType == "Interstitial") {
            cb.showInterstitial();
        } else if (event.adType == "MoreApps") {
            cb.showMoreApps();
        } else if (event.adType == "RewardedVideo") {
            cb.shaowRewardedVideo();
        }
    });

}());
