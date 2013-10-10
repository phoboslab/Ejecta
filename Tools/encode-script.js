// #! /usr/bin/env node

/*

JS File Encryption(Encoding) Tool.

-------------------
Command-line
-------------------

    $ node encode-script.js secret-key input-file output-file

Parameters:
    secret-key : The key for encryption(encoding), accepts any string without breakline.
    input-file : The original js file you would like to encrypt (encode).
    output-file : Path to the encrypted(encoded) file. It will overwrite the existing file with the same name.


-------------------
Example
-------------------

Execute the command in terminal:

    $ node encode-script.js TheKeyHardToGuess  game-original.js  ../App/game.js


Load in Ejecta :

    ejecta.include("my-game.js");


Yes, there is NO difference between encrypted(encoded) and original.


-------------------
NOTE
-------------------

This tool will CHANGE the "EJJavaScriptView.h" file.
Because the secret-key must be written into the "EJJavaScriptView.h" for security.


*/


var fs = require('fs');
var path = require('path');


var EJECTA_JSVIEW_FILE = "../Source/Ejecta/EJJavaScriptView.h";
var DEFAULT_SECRET_KEY = "SecretKey (Don't include Breakline)";
//Please Don't change the value of EJECTA_SECRET_PREFIX, unless you understand it.
var SECRET_PREFIX = "=S=";


var argv = process.argv;
var argsStart = 2;

var secretKey = argv[argsStart++] || DEFAULT_SECRET_KEY;
var jsFilename = argv[argsStart++];
var outputFilename = argv[argsStart++];


if (!module.parent) {
    start();
}


function start() {

    if (jsFilename) {
        
        var buffer = fs.readFileSync(jsFilename);
        var script = buffer.toString();
        var scriptEncode = encode(script, secretKey);
        
        if (!outputFilename){
            outputFilename=jsFilename;
            var dirname = path.dirname(jsFilename);
            var filename = "ORIGINAL_" + path.basename(jsFilename);
            var backup=path.join(dirname,filename);
            fs.writeFileSync(backup, buffer);
        }

        fs.writeFileSync(outputFilename, new Buffer(scriptEncode));
        console.log(" ==== Encode OK ==== ");
        console.log(scriptEncode);

        console.log(" ==== Test Decode ==== ");
        var scriptDecode = decode(scriptEncode, secretKey);
        console.log(scriptDecode);
    }


    updateSecretKeyInEjecta(secretKey);

    console.log(" ==== Update SecretKey OK ==== ");

}

function encode(script, key) {
    var keyBuffer = new Buffer(key, "utf8");
    var keyLen = keyBuffer.length;

    var scriptBuffer = new Buffer(script, "utf8");
    var scriptLen = scriptBuffer.length;

    var newBuffer = new Buffer(scriptLen);
    for (var i = 0; i < scriptLen; i++) {
        var v = scriptBuffer.readInt8(i);
        var kv = keyBuffer.readInt8(i % keyLen);
        newBuffer.writeInt8(v ^ kv, i);
    }
    var scriptEncode = SECRET_PREFIX + newBuffer.toString('base64');

    return scriptEncode;
}

function decode(scriptEncode, key) {

    scriptEncode = scriptEncode.substring(SECRET_PREFIX.length);

    var keyBuffer = new Buffer(key, "utf8");
    var keyLen = keyBuffer.length;

    var scriptBuffer = new Buffer(scriptEncode, "base64");
    var scriptLen = scriptBuffer.length;

    var newBuffer = new Buffer(scriptLen);

    for (var i = 0; i < scriptLen; i++) {
        var v = scriptBuffer.readInt8(i);
        var kv = keyBuffer.readInt8(i % keyLen);
        newBuffer.writeInt8(v ^ kv, i);
    }
    var scriptDecode = newBuffer.toString();

    return scriptDecode;
}


function escapeQuote(str) {
    return str.replace(/(")/g, '\\$1');
}

function updateSecretKeyInEjecta(key) {
    var content = fs.readFileSync(EJECTA_JSVIEW_FILE, "utf8");
    var str = content.toString();
    // console.log(str)

    key = '@"' + escapeQuote(key) + '"';

    str = str.replace(/(\#define[\s]+EJECTA_SECRET_KEY[\s]+)[^\n]+/gm, '$1' + key);

    var newContent = new Buffer(str);
    fs.writeFileSync(EJECTA_JSVIEW_FILE, newContent, "utf8");
    return str;
}

exports.encode = encode;
exports.decode = decode;
exports.updateSecretKeyInEjecta = updateSecretKeyInEjecta;
