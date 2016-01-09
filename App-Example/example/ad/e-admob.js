"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerHeight;

    // var adMob = new Ejecta.AdMob("a15318cc08698ce");
    var adMob = new Ejecta.AdMob("ca-app-pub-9274896770936398/1763781865");
    adMob.load("interstitial");
    // adMob.load("banner");

    var id = setInterval(function() {
        if (showAd()) {
            // clearInterval(id);
        }
    }, 2000);

    // showAd();
    var bannerDisplayed;
    var interstitialDisplayed;

    function showAd() {
        if (!bannerDisplayed && adMob.isReady("banner")) {
            adMob.show("banner", {
                onDisplay: function() {
                    bannerDisplayed = true;
                    console.log("banner onDisplay");

                },
                onClose: function() {
                    bannerDisplayed = false;
                    console.log("banner onClose");
                }
            });
        }
        if (!interstitialDisplayed && adMob.isReady("interstitial")) {
            adMob.show("interstitial", {
                onDisplay: function() {
                    interstitialDisplayed = true;
                    console.log("interstitial onDisplay");
                },
                onClose: function() {
                    interstitialDisplayed = false;
                    console.log("interstitial onClose");
                }
            });
        }
    }

    // adMob.load("banner", {
    //     onLoad: function() {
    //         console.log("banner loaded");
    //         if (adMob.isReady("banner")){
    //             adMob.show("banner");
    //         };
    //     }
    // });

    // adMob.load("interstitial", {
    //     onLoad: function() {
    //         console.log("interstitial loaded");
    //         if (adMob.isReady("interstitial")){
    //             adMob.show("interstitial", {
    //                 onDisplay: function(){
    //                     console.log("interstitial onDisplay")
    //                 }
    //             });
    //         };
    //     }
    // });

    console.log("AdMob Test.");

}());
