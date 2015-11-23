"use strict";

(function() {

    var width = window.innerWidth;
    var height = window.innerHeight;

    // var adVungle = new Ejecta.Vungle("phoena");
    var adVungle = new Ejecta.Vungle("5632ff9e2969297047000010");
    adVungle.setLoggingEnabled(true);

    //    adVungle.addEventListener("close", function(info) {
    //        console.log(JSON.stringify(info));
    //    });
    adVungle.addEventListener("closeProductSheet", function() {
        console.log("closeProductSheet");
    });
    var id = setInterval(function() {
        console.log("adVungle.isReady", adVungle.isReady);
        if (adVungle.isReady) {
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

        adVungle.show({
            incentivized: true,
            incentivizedAlertTitleText: "title",
            incentivizedAlertBodyText: "body",
            incentivizedAlertCloseButtonText: "close-button",
            incentivizedAlertContinueButtonText: "continue-button",
            orientations: "portrait",
            placement: "Placement-A",
            // User: "test-user-1",
            beforeShow: function() {
                console.log("beforeShow");
            },
            afterClose: function(info) {
                console.log("afterClose", JSON.stringify(info));
            },
        });
    }

}());
