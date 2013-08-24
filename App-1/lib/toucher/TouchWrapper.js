
;(function(scope,undefined){
"use strict";

    var NS=scope.Toucher=scope.Toucher||{};
    var CONST=NS.CONST=NS.CONST||{};

    var TouchWrapper=NS.TouchWrapper = function(identifier){    
        this.identifier=identifier;
        this.id=identifier;
    };


    TouchWrapper.prototype={

        constructor : TouchWrapper ,

        start : function(rawTouch,rawEvent){

            this.type=CONST.START;
            
            this.update(rawTouch,rawEvent);

            this.startPageX = this.lastPageX=this.pageX;
            this.startPageY = this.lastPageY=this.pageY;
            this.startTarget= this.lastTarget=this.target;

            this.startClientX = this.lastClientX=this.clientX;
            this.startClientY = this.lastClientY=this.clientY;

            this.deltaX=0;
            this.deltaY=0;
            this.moveAmountX=0;
            this.moveAmountY=0;

            this.touching=true;
            this.startTime=this.endTime=Date.now();

        },

        move : function(rawTouch,rawEvent){

            this.type=CONST.MOVE;
            
            this.update(rawTouch,rawEvent);

            this.moveTime=Date.now();

        },

        end : function(rawTouch,rawEvent){
                
            this.type=CONST.END;
            
            this.update(rawTouch,rawEvent);

            this.endPageX = this.pageX;
            this.endPageY = this.pageY;
            this.endTarget= this.target;

            this.endClientX = this.clientX;
            this.endClientY = this.clientY;


            this.touching=false;
            this.endTime=Date.now();

        },


        update : function(rawTouch,rawEvent){
            this.rawEvent=rawEvent;
            this.rawTouch=rawTouch;
            
            this.lastPageX=this.pageX;
            this.lastPageY=this.pageY;
            this.lastTarget=this.target;

            this.lastClientX = this.clientX;
            this.lastClientY = this.clientY;

            this.pageX=rawTouch.pageX;
            this.pageY=rawTouch.pageY;
            this.target=rawTouch.target;

            this.clientX = rawTouch.clientX;
            this.clientY = rawTouch.clientY;

            this.deltaX=this.pageX-this.lastPageX;
            this.deltaY=this.pageY-this.lastPageY;
            this.moveAmountX = this.pageX - this.startPageX;
            this.moveAmountY = this.pageY - this.startPageY;

        }


    };


    
})(this);


