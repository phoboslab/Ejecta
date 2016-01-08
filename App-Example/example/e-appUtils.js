"use strict";

var appUtils = new Ejecta.AppUtils();
var resolution = new Ejecta.Resolution();


console.log("version", appUtils.version);
console.log("build", appUtils.build);
console.log("uuid : " + appUtils.uuid);
console.log("udid : " + appUtils.udid);
console.log("systemVersion : " + appUtils.systemVersion);
// <language code>-<region code> , en  zh  ja  fr
console.log("systemLocal : " + appUtils.systemLocal);

console.log("index.js Exists : " + appUtils.fileExists("index.js"));

console.log("dpi", resolution.dpi);

//var fonts = appUtils.getAllFonts();
var hasPingFang = appUtils.hasFontFamily("PingFang SC");
var hasPingFangLight = appUtils.hasFont("PingFangSC-Light");
console.log("hasPingFang", hasPingFang, hasPingFangLight);


appUtils.eval("function abc(){return 'eval >> app version : ' + appUtils.version;}");
console.log(abc());
