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


appUtils.eval("function abc(){return 'eval >> app ver : ' + appUtils.ver;}");
console.log(abc());
