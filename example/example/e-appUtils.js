var appUtils = new Ejecta.AppUtils();


console.log("ver : " + appUtils.ver);
console.log("uuid : " + appUtils.uuid);
console.log("udid : " + appUtils.udid);
console.log("systemVersion : " + appUtils.systemVersion);
console.log("systemLocal : " + appUtils.systemLocal);


appUtils.eval("function abc(){return 'eval >> app ver : ' + appUtils.ver;}");
console.log(abc());
