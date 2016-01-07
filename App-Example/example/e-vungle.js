"use strict";

(function() {

    var width = window.innerWidth;
    var height = window.innerHeight;

    // var adVungle = new Ejecta.Vungle("phoena");
    var adVungle = new Ejecta.Vungle("5632ff9e2969297047000010");
    adVungle.debug = true;

    var id = setInterval(function() {
        console.log("adVungle.isReady", adVungle.isReady("video"));
        if (adVungle.isReady("video")) {
            showAd();
            clearInterval(id);
        }
    }, 2000);

    // showAd();
    function showAd() {
        /* Options  :
            incentivized    boolean
            incentivizedAlertTitleText      string
            incentivizedAlertBodyText       string
            incentivizedAlertCloseButtonText        string
            incentivizedAlertContinueButtonText     string
            orientations        string // portrait / landscape / auto
            placement       string
            user        string
            beforeShow function
            afterClose function
            * extraInfoDictionary  (don't support)
        */

        // adVungle.show("video", {
        //     orientations: "landscape",
        //     placement: "Placement-A",
        //     // user: "test-user-1",
        //     onDisplay: function() {
        //         console.log("video onDisplay");
        //     },
        //     onClose: function(info) {
        //         console.log("video onClose", JSON.stringify(info));
        //     },
        //     onFinish: function(info) {
        //         console.log("video onFinish", JSON.stringify(info));
        //     },
        // });

        adVungle.show("video", {
            incentivized: true,
            incentivizedAlertTitleText: "title",
            incentivizedAlertBodyText: "body",
            incentivizedAlertCloseButtonText: "close-button",
            incentivizedAlertContinueButtonText: "continue-button",

            orientations: "landscape",
            placement: "Placement-A",
            // user: "test-user-1",
            onDisplay: function() {
                console.log("rewardedVideo onDisplay");
            },
            onClose: function(info) {
                console.log("rewardedVideo onClose", JSON.stringify(info));
            },
            onFinish: function(info) {
                console.log("rewardedVideo onFinish", JSON.stringify(info));
            },
        });
    }

}());
