var gameCenter = new Ejecta.GameCenter();

loginGameCenter(false, function() {
    loadFriends();
    setTimeout(function() {
        showGameCenter();
    }, 1000);
});



function isAuthedGameCenter() {
    return gameCenter.authed;
}

function loginGameCenter(soft, cb) {
    var methodName = soft ? "softAuthenticate" : "authenticate";
    gameCenter[methodName](function() {
        console.log("GameCenter authed: " + gameCenter.authed);
        if (gameCenter.authed) {
            var localPlayer = gameCenter.getLocalPlayerInfo();
            console.log("getLocalPlayerInfo: " + JSON.stringify(localPlayer));
            cb && cb();
        }
    });
}

function showGameCenter() {
    if (isAuthedGameCenter()) {
        gameCenter.showGameCenter();
    } else {
        console.log("GameCenter not authed! Try later.");
    }
}

function loadFriends() {
    if (isAuthedGameCenter()) {
        gameCenter.loadFriends(function(error, friends) {
            if (error) {
                console.log("error: ", error);
                return;
            }
            console.log("loadFriends: " + JSON.stringify(friends));
        });
    }
}
