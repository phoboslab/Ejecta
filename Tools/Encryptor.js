"use strict";

var fs = require('fs');
var Path = require('path');


var KEY_VAR_NAME = "EJ_SECRET_KEY";
var HEADER_VAR_NAME = "EJ_SECRET_HEADER";

//Please Don't change the value of SECRET_HEADER, unless you understand it.
var SECRET_HEADER = "=S=";
var DEFAULT_SECRET_KEY = "SecretKey (Don't include Breakline)";

var NATIVE_ENCRYPTOR = "Extension/EJBindingEncryptorXOR.h";
var PROJECT_PATH = "../";

var check = true;

if (!module.parent) {
    var argv = process.argv;
    var argsStart = 2;

    (function() {
        var fileName = argv[argsStart++];
        var outputFileName = argv[argsStart++];
        var secretKey = argv[argsStart++] || DEFAULT_SECRET_KEY;
        var projectPath = argv[argsStart++] || PROJECT_PATH;
        encrypt(fileName, outputFileName, secretKey, projectPath);
    })();
}

function encrypt(fileName, outputFileName, secretKey, projectPath) {

    var orignalBuffer = fs.readFileSync(fileName);
    var newBuffer = encode(orignalBuffer, secretKey);
    fs.writeFileSync(outputFileName, newBuffer);

    updateSecretInfo(secretKey, projectPath);

    if (check) {
        var decodedBuffer = decode(outputFileName, secretKey);

        var baseName = Path.basename(fileName);
        if (orignalBuffer.length != decodedBuffer.length) {
            // console.log("Check failed: " + baseName + " , error length .");
            return false;
        }
        for (var i = 0; i < orignalBuffer.length; i++) {
            var b1 = orignalBuffer.readInt8(i);
            var b2 = decodedBuffer.readInt8(i);
            if (b1 != b2) {
                // console.log("Check failed: " + baseName + " , error byte .");
                return false;
            }
        }
        // console.log("Check OK: " + baseName + " .");
    }
    return true;
}

function unencrypt(fileName, outputFileName, secretKey) {
    var newBuffer = decode(fileName, secretKey);
    fs.writeFileSync(outputFileName, newBuffer);
}

function encode(file, secretKey) {

    var orignalBuffer;
    if (typeof file == "string") {
        orignalBuffer = fs.readFileSync(fileName);
    } else {
        orignalBuffer = file;
    }
    var orignalBufferSize = orignalBuffer.length;


    var headBuffer = new Buffer(SECRET_HEADER, "utf8");
    var headLen = headBuffer.length;

    var newBuffer = new Buffer(orignalBufferSize + headLen);
    for (var i = 0; i < headLen; i++) {
        var hv = headBuffer.readInt8(i);
        newBuffer.writeInt8(hv, i);
    }

    var keyBuffer = new Buffer(secretKey || DEFAULT_SECRET_KEY, "utf8");
    var keyLen = keyBuffer.length;

    for (var i = 0; i < orignalBufferSize; i++) {
        var v = orignalBuffer.readInt8(i);
        var kv = keyBuffer.readInt8(i % keyLen);
        var newV = v ^ kv;
        newBuffer.writeInt8(newV, i + headLen);
    }

    return newBuffer;
}

function decode(fileName, secretKey) {

    var buffer = fs.readFileSync(fileName);
    var bufferSize = buffer.length;


    var headBuffer = new Buffer(SECRET_HEADER, "utf8");
    var headLen = headBuffer.length;

    var newBuffer = new Buffer(bufferSize - headLen);

    var keyBuffer = new Buffer(secretKey || DEFAULT_SECRET_KEY, "utf8");
    var keyLen = keyBuffer.length;

    for (var i = 0; i < newBuffer.length; i++) {
        var v = buffer.readInt8(i + headLen);
        var kv = keyBuffer.readInt8(i % keyLen);
        var newV = v ^ kv;
        newBuffer.writeInt8(newV, i);
    }

    return newBuffer;
}

function updateSecretInfo(secretKey, projectPath) {
    var nativeFile = Path.normalize((projectPath || PROJECT_PATH) + "/" + NATIVE_ENCRYPTOR);
    if (!fs.existsSync(nativeFile)) {
        return null;
    }
    var content = fs.readFileSync(nativeFile, "utf8");
    var str = content.toString();
    var key = '@"' + escapeQuote(secretKey || DEFAULT_SECRET_KEY) + '"';
    var reg = new RegExp("(\\#define[\\s]+" + KEY_VAR_NAME + "[\\s]+)[^\\n]+", "gm");
    str = str.replace(reg, '$1' + key);

    var newContent = new Buffer(str);
    fs.writeFileSync(nativeFile, newContent, "utf8");
    return str;
}

function escapeQuote(str) {
    return str.replace(/(")/g, '\\$1');
}

exports.encrypt = encrypt;
exports.unencrypt = unencrypt;
exports.encode = encode;
exports.decode = decode;
