
;(function(scope,undefined){
"use strict";

    var NS=scope.Toucher=scope.Toucher||{};
    var CONST=NS.CONST=NS.CONST||{};

    CONST.EVENT_LIST=["touches","changedTouches","targetTouches"];

    var Listener=NS.Listener = function(cfg){   

        for (var property in cfg ){
            this[property]=cfg[property];
        }

    };

    /* Use to create your custom-listener */
    // It's duck-type, GT-Toucher doesn't care the result of "instanceof" 
    Listener.extend=function(proto){
        var pl=this;
        var con=function(cfg){
            for (var property in cfg ){
                this[property]=cfg[property];
            }
        };
        var pt=pl.prototype;
        for (var property in pt ){
            con.prototype[property]=pt[property];
        }
        for (var property in proto ){
            con.prototype[property]=proto[property];
        }
        con.prototype.constructor=con;
        con.extend=pl.extend;
        return con;
    }

    Listener.prototype={

        constructor : Listener ,
        id : null,
        type : null ,

        offsetLeft : 0 ,
        offsetTop : 0 ,

        order : 1 ,

        beforeInit : function(){},
        init : function(){
            this.beforeInit();
            
            // ... ...
            
            this.onInit();
        },
        onInit : function(){},

        /* Could be overridden by user */
        filterWrappers : function(type,wrappers,event,controller){
            var validWrappers=[];
            for (var i=0,len=wrappers.length;i<len;i++){
                var wrapper=wrappers[i];
                if (this.filterWrapper(type,wrapper,event,controller)){
                    validWrappers.push(wrapper)
                }
            }
            return validWrappers;
        },

        /* Implement by user */
        filterWrapper : function(type,wrapper,event,controller){
            return false;
        },

        /* Implement by user */
        // function(vaildWrappers, event, controller){ } 
        start : null , 

        // function(vaildWrappers, event, controller){ } 
        move : null ,

        // function(vaildWrappers, event, controller){ } 
        end : null 

    };






    
})(this);