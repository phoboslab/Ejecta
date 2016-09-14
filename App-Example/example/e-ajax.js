var testAjax = function(url, async) {

    var output = function() {
        console.log("==== start ====");
        console.log(url, async, "\n", xhr.responseText);
        console.log("==== end ====");
    };

    var xhr = new XMLHttpRequest();
    if (async) {
        xhr.onreadystatechange = function() {
            if (xhr.readyState == 4) {
                output();
            }
        }
    }
    xhr.open("GET", url, async);
    xhr.send();

    if (!async) {
        output();
    }

};


testAjax("http://www.apple.com", false);
testAjax("http://www.apple.com", true);

testAjax("http://www.one-404-page-123.com:8000/abc", false);
testAjax("http://www.one-404-page-123.com:8000/cde", true);
