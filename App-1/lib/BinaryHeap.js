
"use strict";

function BinaryHeap(scoreFunction) {
    this.content = [];
    this.scoreFunction = scoreFunction ||
    function(node) {
        return node
    };
}

BinaryHeap.prototype = {

    clear: function() {
        this.length = this.content.length = 0;
    },

    size: function() {
        return this.content.length;
    },

    indexOf: function(node) {
        return this.content.indexOf(node);
    },
    push: function(element) {
        this.content.push(element);
        this.bubbleUp(this.content.length - 1);
        this.length = this.content.length;
    },

    pop: function() {
        var result = this.content[0];
        var end = this.content.pop();
        if(this.content.length > 0) {
            this.content[0] = end;
            this.sinkDown(0);
        }
        this.length = this.content.length;
        return result;
    },

    remove: function(node) {
        var len = this.content.length;
        var nodeScore = this.scoreFunction(node);
        for(var i = 0; i < len; i++) {
            if(this.content[i] == node) {
                var end = this.content.pop();
                this.length = this.content.length;
                if(i != len - 1) {
                    this.content[i] = end;
                    if(this.scoreFunction(end) < nodeScore) {
                        this.bubbleUp(i);
                    }else{
                        this.sinkDown(i);
                    } 
                }
                return;
            }
        }
        throw new Error("Node not found.");
    },

    resortElement: function(node) {
        var index = this.content.indexOf(node);
        index = this.bubbleUp(index);
        index = this.sinkDown(index < 0 ? 0 : index);
        return index;
    },

    bubbleUp: function(n) {
        var element = this.content[n];

        while(n > 0) {
            var parentN = ((n + 1) >> 1) - 1;
            var parent = this.content[parentN];
            if(this.scoreFunction(element) < this.scoreFunction(parent)) {
                this.content[parentN] = element;
                this.content[n] = parent;
                n = parentN;
            } else {
                break;
            }
        }
        return n;
    },

    sinkDown: function(n) {
        // Look up the target element and its score.
        var length = this.content.length,
            element = this.content[n];

        if(!element) {
            debugger
        }
        var elemScore = this.scoreFunction(element);
        while(true) {

            var swap = null;

            var child2N = (n + 1) << 1,
                child1N = child2N - 1;

            if(child1N < length) {
                var child1 = this.content[child1N],
                    child1Score = this.scoreFunction(child1);
                if(child1Score < elemScore) swap = child1N;
            }
            if(child2N < length) {
                var child2 = this.content[child2N],
                    child2Score = this.scoreFunction(child2);
                if(child2Score < (swap === null ? elemScore : child1Score)) swap = child2N;
            }

            if(swap === null) {
                break;
            }
            this.content[n] = this.content[swap];
            this.content[swap] = element;
            n = swap;

        }

        return n;
    }
};