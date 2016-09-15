//
// Install NodeJS  and run (  SECRET_KEY is :
// node Encryptor.js  input-original-file-path  output-encryted-file-path  [ SECRET_KEY ]
//

"use strict";

var $fs = require('fs');
var $path = require('path');


var KEY_VAR_NAME = "EJ_SECRET_KEY";
var HEADER_VAR_NAME = "EJ_SECRET_HEADER";

//Please Don't change the value of SECRET_HEADER, unless you understand it.
var SECRET_HEADER = "=S=";
var DEFAULT_SECRET_KEY = "SecretKey (Don't include Breakline)";

var NATIVE_ENCRYPTOR = "Extension/EJBindingDecryptorXOR.h";
var PROJECT_PATH = $path.normalize(__dirname + "/../");

var check = true;

function encrypt(fileName, outputFileName, secretKey, projectPath) {
    secretKey = secretKey || DEFAULT_SECRET_KEY;
    // console.log("File : " + fileName, "  Key : " + secretKey);

    var fileBuffer = $fs.readFileSync(fileName);

    if (isEncoded(fileBuffer)) {
        console.log("Encoded, skip.")
        return true;
    }

    var newBuffer = encode(fileBuffer, secretKey);
    $fs.writeFileSync(outputFileName, newBuffer);

    updateSecretInfo(secretKey, projectPath);

    if (check) {
        var decodedBuffer = decode(outputFileName, secretKey);

        var baseName = $path.basename(fileName);
        if (fileBuffer.length != decodedBuffer.length) {
            console.log("Check failed: " + baseName + " , error length .");
            return false;
        }
        for (var i = 0; i < fileBuffer.length; i++) {
            var b1 = fileBuffer.readInt8(i);
            var b2 = decodedBuffer.readInt8(i);
            if (b1 != b2) {
                console.log("Check failed: " + baseName + " , error byte .");
                return false;
            }
        }
        // console.log("Check OK: " + baseName + " .");
    }
    return true;
}

function unencrypt(fileName, outputFileName, secretKey) {
    secretKey = secretKey || DEFAULT_SECRET_KEY;
    var newBuffer = decode(fileName, secretKey);
    $fs.writeFileSync(outputFileName, newBuffer);
}

function isEncoded(fileBuffer) {
    var encoded = true;

    var headBuffer = new Buffer(SECRET_HEADER, "utf8");
    for (var i = 0, headLen = headBuffer.length; i < headLen; i++) {
        var vA = headBuffer.readInt8(i);
        var vB = fileBuffer.readInt8(i);
        if (vA != vB) {
            encoded = false;
            break;
        }
    }
    return encoded;
}

function encode(file, secretKey) {

    var fileBuffer;
    if (typeof file == "string") {
        fileBuffer = $fs.readFileSync(file);
    } else {
        fileBuffer = file;
    }

    var fileBufferSize = fileBuffer.length;

    var headBuffer = new Buffer(SECRET_HEADER, "utf8");
    var headLen = headBuffer.length;

    var newBuffer = new Buffer(fileBufferSize + headLen);
    for (var i = 0; i < headLen; i++) {
        var hv = headBuffer.readInt8(i);
        newBuffer.writeInt8(hv, i);
    }

    var keyBuffer = new Buffer(secretKey || DEFAULT_SECRET_KEY, "utf8");
    var keyLen = keyBuffer.length;

    for (var i = 0; i < fileBufferSize; i++) {
        var v = fileBuffer.readInt8(i);
        var kv = keyBuffer.readInt8(i % keyLen);
        var newV = v ^ kv;
        newBuffer.writeInt8(newV, i + headLen);
    }

    return newBuffer;
}

function decode(file, secretKey) {

    var fileBuffer;
    if (typeof file == "string") {
        fileBuffer = $fs.readFileSync(file);
    } else {
        fileBuffer = file;
    }

    var fileBufferSize = fileBuffer.length;


    var headBuffer = new Buffer(SECRET_HEADER, "utf8");
    var headLen = headBuffer.length;

    var newBuffer = new Buffer(fileBufferSize - headLen);

    var keyBuffer = new Buffer(secretKey || DEFAULT_SECRET_KEY, "utf8");
    var keyLen = keyBuffer.length;

    for (var i = 0; i < newBuffer.length; i++) {
        var v = fileBuffer.readInt8(i + headLen);
        var kv = keyBuffer.readInt8(i % keyLen);
        var newV = v ^ kv;
        newBuffer.writeInt8(newV, i);
    }

    return newBuffer;
}

function updateSecretInfo(secretKey, projectPath) {
    var nativeFile = $path.normalize((projectPath || PROJECT_PATH) + "/" + NATIVE_ENCRYPTOR);
    if (!$fs.existsSync(nativeFile)) {
        return null;
    }
    var fileBuffer = $fs.readFileSync(nativeFile, "utf8");
    var content = fileBuffer.toString();
    var key = '@"' + escapeQuote(secretKey || DEFAULT_SECRET_KEY) + '"';
    var reg = new RegExp("(\\#define[\\s]+" + KEY_VAR_NAME + "[\\s]+)[^\\n]+", "gm");
    content = content.replace(reg, '$1' + key);

    var newBuffer = new Buffer(content);
    $fs.writeFileSync(nativeFile, newBuffer, "utf8");
    return content;
}

function escapeQuote(str) {
    return str.replace(/(")/g, '\\$1');
}


if (typeof module !== "undefined" && module) {

    var hasExports = false;

    if (typeof exports !== "undefined" && exports) {
        hasExports = true;
        exports.encrypt = encrypt;
        exports.defaultSecretKey = DEFAULT_SECRET_KEY;
        exports.unencrypt = unencrypt;
        exports.isEncoded = isEncoded;
        exports.encode = encode;
        exports.decode = decode;
    }

    if (!module.parent) {
        var argv = process.argv;
        var argsStart = 2;

        (function() {
            var fileName = argv ? argv[argsStart++] : null;
            if (fileName) {
                var outputFileName = argv[argsStart++];
                var secretKey = argv[argsStart++] || DEFAULT_SECRET_KEY;
                var projectPath = argv[argsStart++] || PROJECT_PATH;
                encrypt(fileName, outputFileName, secretKey, projectPath);
            } else if (hasExports) {
                console.log(" *** No fileName *** ");
            }
        })();
    }
}
