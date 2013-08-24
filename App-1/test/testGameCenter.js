
var gc=new Ejecta.GameCenter();

console.log("1 authed : "+gc.authed)
gc.authenticate(function(event){
                console.log("authenticate : "+JSON.stringify(event)+"----"+gc.authed);
                if (gc.authed){
                    console.log( JSON.stringify(gc.localPlayer) );
                }
                
})

gc.softAuthenticate();

console.log("2 authed : "+gc.authed)
