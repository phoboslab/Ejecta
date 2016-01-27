var xhr = new XMLHttpRequest();
var async = !true;
if (async) {
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            console.log(async, "\n", xhr.responseText);
        }
    }
}
xhr.open("GET", "http://baidu.com", async);
xhr.send();
console.log("=======");
console.log(async, "\n", xhr.responseText);
