"use strict";

(function() {

 
    var width = window.innerWidth;
    var height = window.innerWidth;

    var adBanner = new Ejecta.AdMobBanner("a15318cc08698ce");
    adBanner.type = "banner";
    // adBanner.type = height > 640 ? "fullbanner" : "banner";
    adBanner.x = 0;
    adBanner.y = 0;
    adBanner.onload = function() {
        adBanner.loading = false;
        adBanner.x = (width - adBanner.width) >> 1;
        console.log("loaded adBanner", adBanner.type, adBanner.x, adBanner.y, adBanner.width, adBanner.height);
        adBanner.show();
    }
    adBanner.onclose = function() {
        console.log("close adBanner");
        setTimeout(function(){
            console.log("auto load adBanner again");
             adBanner.load();
        },2000)
    }
    adBanner.onclick = function() {
        console.log("click adBanner")
    }
    adBanner.load();

///////////////////////////////

    var adPage = new Ejecta.AdMobPage("a15318cc08698ce");
    adPage.onload = function() {
        adPage.loading = false;
        console.log("loaded adPage");
        adPage.show();
    }
    adPage.onclose = function() {
        console.log("close adPage")
        setTimeout(function(){
            console.log("auto load adPage again");
            adPage.load();
        },1000)
    }
    adPage.onclick = function() {
        console.log("click adPage")
    }

    console.log("start");
    setTimeout(function() {
       adPage.load();
    }, 500);

}());
