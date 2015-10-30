"use strict";

(function() {


    var width = window.innerWidth;
    var height = window.innerWidth;

    var adVungle = new Ejecta.Vungle("5632ff9e2969297047000010");

    var id = setInterval(function() {
        console.log("adVungle.isReady", adVungle.isReady);
        if (adVungle.isReady) {
            adVungle.show();
            clearInterval(id);
        }
    }, 1000);


}());
