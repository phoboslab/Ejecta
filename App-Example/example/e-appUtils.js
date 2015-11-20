"use strict";

var appUtils = new Ejecta.AppUtils();


console.log("ver : " + appUtils.ver);
console.log("uuid : " + appUtils.uuid);
console.log("udid : " + appUtils.udid);
console.log("systemVersion : " + appUtils.systemVersion);
// <language code>-<region code> , en  zh  ja  fr
console.log("systemLocal : " + appUtils.systemLocal);

console.log("index.js Exists : " + appUtils.fileExists("index.js"));


appUtils.eval("function abc(){return 'eval >> app ver : ' + appUtils.ver;}");
console.log(abc());
