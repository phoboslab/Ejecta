
;(function(){

    function _loadCSSFileSync(css){
        if (!css){
            return;
        }
        var rp=rootPath||"";
        document.write('<link rel="stylesheet" href="'+rp+css+'"/>');
    }

    function _loadJSFileSync(js){
        if (!js){
            return;
        }
        var rp=rootPath||"";
        document.write('<script src="'+rp+js+'"></scr' + 'ipt>');
    }


    var cssList,jsList;


//common
    cssList=[
        "lib/style.css",
        "ui/css/ui-base.css",
        "ui/css/ui-base-cmp.css",
        
        "ui/css/soldier-icon.css",

        // "ui-base.css",
        // "ui.css",
        // "ui-icon.css",
        // "ui-tools.css"
    ];
    cssList.forEach(function(css){
        _loadCSSFileSync(css);
    });

    jsList=[

        "lib/Base.js",
        "lib/DomBase.js",

        "lib/toucher/Controller.js",
        "lib/toucher/TouchWrapper.js",
        "lib/toucher/Listener.js",
        "lib/toucher/gesture/Tap.js",
        "lib/toucher/gesture/Pan.js",
        "lib/toucher/gesture/Swipe.js",
        "lib/toucher/gesture/Scale.js",

        "ui/js/gesture.js",
        "ui/js/ScrollArea.js",
        "ui/js/Component.js",
        "ui/js/Panel.js",
        "ui/js/ListView.js",

        "ui/js/ui-ctrl.js",

        // "js/ui/gesture.js",
        // "js/ui/ArmyBar.js",
        // "js/ui/BuildingToolbar.js",
        // "js/ui/HeroPanel.js",
        // "js/ui/UpgradePanel.js",
        // "js/ui/ResPromptPanel.js",
        // "js/ui/ShopPage.js",
        // "js/ui/TrainPanel.js",
        // "js/ui/BattleResult.js",

    ];
    jsList.forEach(function(js){
        _loadJSFileSync(js);
    });


// Web  or  App's WebView

    var url=window.location+"";
    var isApp=url.indexOf("?app=")>0;
    isWeb=!isApp;

    if (isWeb){
        cssList=[];
        jsList=[

            "init-web.js",
            "boot.js",

           
        ];
    }else{
        cssList=["view.css"];
        jsList=[
            "init-web.js",
            
            "lib/Slider.js",
            "lib/ViewBridge.js",

            "js/common/constant.js",
            "js/common/config/MarketUIConfig.js",
            "js/common/config/BuildingUIConfig.js",
            "js/common/config/SoldierUIConfig.js",
            "js/common/config/SoldierBaseInfo.js",
            "js/common/config/SoldierInfo.js",
            "js/common/config/HeroBaseInfo.js",
            "js/common/config/HeroInfo.js",

            // "ui/js/ui-action-proxy.js",

            "view.js"
        ];

    }
    cssList.forEach(function(css){
        _loadCSSFileSync(css);
    });
    jsList.forEach(function(js){
        _loadJSFileSync(js);
    });

    //TODO : preload some images in UI

}());