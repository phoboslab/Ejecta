"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerHeight;

    // var adMob = new Ejecta.AdMob("a15318cc08698ce");

    // banner
    var adMobBanner = new Ejecta.AdMob("ca-app-pub-9274896770936398/4438046668");
    adMobBanner.load("banner");

    // image
    // var adMob = new Ejecta.AdMob("ca-app-pub-9274896770936398/4856849060");
    // video
    // var adMob = new Ejecta.AdMob("ca-app-pub-9274896770936398/3380115869");
    // image & video
    var adMob = new Ejecta.AdMob("ca-app-pub-9274896770936398/1763781865");
    adMob.load("interstitial");

    var id = setInterval(function() {
        if (showAd()) {
            // clearInterval(id);
        }
    }, 3000);

    // showAd();
    var bannerDisplayed;
    var interstitialDisplayed;

    function showAd() {
        if (!bannerDisplayed && adMobBanner.isReady("banner")) {
            adMobBanner.show("banner", {
                onDisplay: function() {
                    bannerDisplayed = true;
                    console.log("banner onDisplay");

                },
                onClose: function() {
                    bannerDisplayed = false;
                    adMobBanner.load("banner");
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
                    adMob.load("interstitial");
                    console.log("interstitial onClose");
                }
            });
        }
    }


    console.log("AdMob Test.");

}());
