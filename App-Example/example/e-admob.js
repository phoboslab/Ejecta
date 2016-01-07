"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerHeight;

    var adMob = new Ejecta.AdMob("a15318cc08698ce");

    adMob.load("banner", {
        onLoad: function() {
            console.log("banner loaded");
            if (adMob.isReady("banner")){
                adMob.show("banner");
            };
        }
    });

    adMob.load("interstitial", {
        onLoad: function() {
            console.log("interstitial loaded");
            if (adMob.isReady("interstitial")){
                adMob.show("interstitial", {
                    onDisplay: function(){
                        console.log("interstitial onDisplay")
                    }
                });
            };
        }
    });

    console.log("AdMob Test.");

}());
