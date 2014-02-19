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

    ejectaUtils.include("my-game.js");


Yes, there is NO difference between encrypted(encoded) and original.


-------------------
NOTE
-------------------

This tool will CHANGE the "EJJavaScriptView.h" file.
Because the secret-key must be written into the "EJJavaScriptView.h" for security.


*/


var fs = require('fs');
var Path = require('path');

var ROOT = "../";
var DEFAULT_NATIVE_FILE = "Extension/EJBindingAppUtils.h";
var DEFAULT_SECRET_KEY = "SecretKey (Don't include Breakline)";
//Please Don't change the value of EJECTA_SECRET_PREFIX, unless you understand it.
var SECRET_PREFIX = "=S=";



if (!module.parent) {
    var argv = process.argv;
    var argsStart = 2;

    var secretKey = argv[argsStart++] || DEFAULT_SECRET_KEY;
    var jsFilename = argv[argsStart++];
    var outputFilename = argv[argsStart++];

    encrypt(jsFilename, ROOT, secretKey, outputFilename);
}


function encrypt(jsFile, projectPath, secretKey, outFile) {

    if (jsFile) {

        var buffer = fs.readFileSync(jsFile);
        var script = buffer.toString();
        var scriptEncode = encode(script, secretKey);

        if (!outFile) {
            outFile = jsFile;
            var dirname = Path.dirname(jsFile);
            var filename = "ORIGINAL_" + Path.basename(jsFile);
            var backup = Path.join(dirname, filename);
            fs.writeFileSync(backup, buffer);
        }

        fs.writeFileSync(outFile, new Buffer(scriptEncode));
        console.log(" ==== Encode OK ==== ");
        console.log(scriptEncode);

        console.log(" ==== Test Decode ==== ");
        var scriptDecode = decode(scriptEncode, secretKey);
        console.log(scriptDecode);
    }

    var nativeFile = Path.normalize(projectPath + "/" + DEFAULT_NATIVE_FILE);
    updateSecretKeyInNative(nativeFile, secretKey);

    console.log(" ==== Update SecretKey OK ==== ");

}

function encode(script, key) {
    key = key || DEFAULT_SECRET_KEY;

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
    key = key || DEFAULT_SECRET_KEY;

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

function updateSecretKeyInNative(file, key) {
    key = key || DEFAULT_SECRET_KEY;

    var content = fs.readFileSync(file, "utf8");
    var str = content.toString();
    // console.log(str)

    key = '@"' + escapeQuote(key) + '"';

    str = str.replace(/(\#define[\s]+EJECTA_SECRET_KEY[\s]+)[^\n]+/gm, '$1' + key);

    var newContent = new Buffer(str);
    fs.writeFileSync(file, newContent, "utf8");
    return str;
}

exports.encrypt = encrypt;
exports.encode = encode;
exports.decode = decode;
exports.updateSecretKeyInNative = updateSecretKeyInNative;
