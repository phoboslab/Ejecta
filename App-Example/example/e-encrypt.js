var decryptor = new Ejecta.DecryptorXOR();
decryptor.enable();

ejecta.include("example/encryption/encrypted-test-log.js");

(function() {

    var img = new Image();
    img.src = "example/encryption/encrypted-ejecta-logo.png";
    img.onload = function() {
        context.drawImage(img, 100, 100);
    }
}());
