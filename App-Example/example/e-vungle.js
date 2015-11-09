"use strict";

(function() {

    var width = window.innerWidth;
    var height = window.innerWidth;

    // var adVungle = new Ejecta.Vungle("phoena");
    var adVungle = new Ejecta.Vungle("5632ff9e2969297047000010");
    adVungle.setLoggingEnabled(true);

    adVungle.addEventListener("close", function(info) {
        console.log(JSON.stringify(info));
    });
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
            Incentivized    boolean
            IncentivizedAlertTitleText      string
            IncentivizedAlertBodyText       string
            IncentivizedAlertCloseButtonText        string
            IncentivizedAlertContinueButtonText     string
            Orientations        string // portrait / landscape / auto
            Placement       string
            User        string
            * ExtraInfoDictionary  (don't support)
        */

        adVungle.show({
            Incentivized: true,
            IncentivizedAlertTitleText: "title",
            IncentivizedAlertBodyText: "body",
            IncentivizedAlertCloseButtonText: "close-button",
            IncentivizedAlertContinueButtonText: "continue-button",
            Orientations: "portrait",
            Placement: "Placement-A",
            // User: "test-user-1",
        });
    }

}());
