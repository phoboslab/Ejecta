
window.Config={
	width : 960,
	height : 640,
}


if (typeof exports == "undefined") {
    var exports = window;
}
if (typeof require == "undefined") {
    var require = function(url) {
        console.log("require : ", url);
        return exports;
    };
}

window.Web = true;
window.prames=getUrlParams();

window.getUDID = function() {
	return window.prames.user||"test_devid_0";
}

window.getUUID = function() {
	return window.prames.user||"test_devid_0";
}
window.getAppVer = function() {
    return 1;
}

window.loadJSFiles = function(files, cb) {
    var total=files.length;
    function loadNext(e){
        loaded++;
        if (loaded<total){
            var js=files[loaded];
            if (js){
                includeJS(window.rootPath+js, loadNext, false);
            }else{
                loadNext({});
            }
        }else if(cb){
            setTimeout(function(){
                cb();
            },10);
        }
    }
    var loaded=-1;
    loadNext({});
}

// calcWindowSize();

