
;(function(exports, undefined){

"use strict";

	var LinkedList = exports.LinkedList = function(){
		this.head={};
		this.tail={};
		this.clear();
	};

	var proto={

		length : 0,

		// TODO : push pop  unshift shift 
		

		clear : function(){
			this.head._next=this.tail;
			this.tail._prev=this.head;
			this.length=0;
		},

		replace: function(node1, node2){
			node2._next = node1._next;
			node2._prev = node1._prev;
			node2._next._prev = node2;
			node2._prev._next = node2;
			return node1;
		},

		swap : function(node1, node2){
			node1._prev._next = node2;
			var tmp = node2._prev;
			node2._prev = node1._prev;
			node1._prev = tmp;
			tmp._next = node1;

			node1._next.prev = node2;
			tmp = node2._next;
			node2._next = node1._next;
			node1._next = tmp;
			tmp._prev = node1;

		},

		addNode : function(node){
			node._prev = this.tail._prev;
			node._next = this.tail;
			node._prev._next = this.tail._prev = node;
			this.length++;
		},

		addNodes : function( args ){
			for (var i=0,len=arguments.length;i<len;i++){
				this.addNode(arguments[i]);
			}
		},

		removeNode: function(node){
			node._prev._next = node._next;
			node._next._prev = node._prev;
			node._next = node._prev = null;
			this.length--;
		},

		removeLast : function(n){
			var node=this.tail._prev;
			while(n>0){
				node=node._prev;
				n--;
			}
			node._next = this.tail;
			this.tail._prev = node;
			this.length-=n;
		},

		moveAfter : function(node,afterNode){
			node._prev._next = node._next;
			node._next._prev = node._prev;

			node._next = afterNode._next;
			node._prev = afterNode;
			node._next._prev=afterNode._next = node;
		},

		moveBefore : function(node,afterNode){
			node._prev._next = node._next;
			node._next._prev = node._prev;

			node._prev = beforeNode._prev;
			node._next = beforeNode;
			node._prev._next=beforeNode._prev = node;
		},

		insertAfter : function(node,afterNode){
			node._next = afterNode._next;
			node._prev = afterNode;
			node._next._prev=afterNode._next = node;
			this.length++;
		},

		insertBefore : function(node,beforeNode){
			node._prev = beforeNode._prev;
			node._next = beforeNode;
			node._prev._next=beforeNode._prev = node;
			this.length++;
		},

		indexOf : function(nodeI){
			var node=this.head;
			var idx=0;
			while( (node=node._next)!=this.tail ){
				if (nodeI===node){
					return idx;
				}
				idx++;
			}
			return -1;
		},

		isHead : function(node){
			return node===this.head;
		},
		
		isTail : function(node){
			return node===this.tail;
		},

		first : function(){
			return this.head._next;
		},

		last : function(){
			return this.tail._prev;
		},

		isFirst : function(node){
			return node==this.first();
		},

		isLast : function(node){
			return node==this.last();
		},

		circle : function(){
			this.last()._next=this.first();
		},

		uncircle : function(){
			this.last()._next=this.tail;
		},

		getNodeByIndex : function(index){
			index||0;
			var node=this.head;
			for (var i=0;i<index;i++){
				node=node._next;
			}
			return node;
		},
		
		forEach : function(fn){
			var rsList=[];
			var node=this.head;
			var idx=0;
			while( (node=node._next)!=this.tail ){
				var rs=fn(node,idx,this);
				rsList.push(rs);
				if (rs===false){
					break;
				}
				idx++;
			}
			return rsList;
		},

		toArray : function(clean){
			var arr=[];
			clean=!!clean;
			this.forEach(function(node){
				arr.push(node);
			});
			if (clean){
				arr.forEach(function(node){
					delete node._prev;
					delete node._next;
				});
			}
			return arr;
		}
	};

	for (var p in proto){
		LinkedList.prototype[p]=proto[p];
	}


	LinkedList.createNode = function(data){
		return {
			data : data ,
			_prev : null,
			_next : null
		};
	}

}( typeof exports=="undefined" ? this : exports ) );





