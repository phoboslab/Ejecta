// The AlertView is not same to window.alert , it's non-block.

// var alertView = new Ejecta.AlertView("title","message","cancelTitle");
var alertView = new Ejecta.AlertView("title", "message", "cancelTitle", "b1Title", "b2Title");

alertView.addEventListener("click", function(buttonIndex) {
    console.log("You click button: " + buttonIndex);
});
alertView.addEventListener("dismiss", function(buttonIndex) {
    console.log("You dismiss ALertView via button: " + buttonIndex);
});
alertView.addEventListener("cancel", function() {
    console.log("You cancel AlertView");
});
alertView.show();
