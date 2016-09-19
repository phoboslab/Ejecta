// #! /usr/bin/env node

var fs = require('fs');
var Path = require('path');
var glob = require('glob');
var wrench = require('wrench');

var cwd = process.env.PWD || process.cwd();
var root = Path.normalize(cwd + "/../");
console.log(root);

var encrypt = require(root + 'Tools/Encryptor.js');

var arg = process.argv[2];
var encryptJS = !arg || arg === "js" || arg === "all";
var encryptImg = arg === "img" || arg === "all";
var encryptAudio = arg === "audio" || arg === "all";

var secretKey = process.argv[3] || null;

var minAudioSize = 512 * 1024 + 64;

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

// var devPath = root + "App-dev/";
// var devResPath = root + "App-dev/res/";
var devPath = root + "App/";
var devResPath = root + "App/res/";

var distPath = root + "App/";
var distResPath = root + "App/res";


function encryptFiles(files, secretKey, minFileSize) {

    console.log(" Secret Key : ", secretKey);
    var ok = true;
    files.forEach(function(file) {
        if (file.indexOf("index.js") != -1) {
            return;
        }
        var rs = encrypt.encrypt(file, file, secretKey, minFileSize, root);
        ok = ok && rs;
        if (!rs) {
            console.log("Check failed: " + file + " , error byte .");
        }
    });
    return ok;
}

if (!fs.existsSync(distPath)) {
    fs.mkdirSync(distPath);
}

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

if (encryptJS) {
    // encrypt JS
    var files = glob.sync(devPath + "/**/*.js", {});
    var ok = encryptFiles(files, secretKey);
    console.log("encrypt JS : " + ok);
}

if (encryptImg) {
    // encrypt Image
    var files = glob.sync(Path.normalize(distResPath + "/**/*.png"), {});
    files = files.concat(glob.sync(Path.normalize(distResPath + "/**/*.jpg"), {}));
    var ok = encryptFiles(files, secretKey);
    console.log("encrypt Image : " + ok);
}

if (encryptAudio) {
    // encrypt Audio
    var files = glob.sync(Path.normalize(distResPath + "/**/*.mp3"), {});
    files = files.concat(glob.sync(Path.normalize(distResPath + "/**/*.ogg"), {}));
    var ok = encryptFiles(files, secretKey, minAudioSize);
    console.log("encrypt Audio : " + ok);
}



///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////


var n = new Date();
var h = n.getHours(),
    m = n.getMinutes(),
    s = n.getSeconds();
console.log("\n");
console.log('   ' + [h, m < 10 ? "0" + m : m, s < 10 ? "0" + s : s].join(": "))
console.log("\n");

// fs.readFile(tmxFile, function(err, data) {
//     var doc = new xmldoc.XmlDocument(data);
//     parseDoc(doc, function(map) {
//         cb(map, doc, tmxFile);
//     });
// });
