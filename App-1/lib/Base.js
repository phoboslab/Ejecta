
function $TODO(msg){
    var line=null;
    try{
        var err = new Error();
        var lines = err.stack.split('\n');
        line=lines[2];
    }catch(e){
        
    }
    if (!$TODO.displayed[msg+line]){
        console[console.error?"error":"log"]("    // TODO : "+msg);
        $TODO.displayed[msg+line]=true;
        line&&console.log(line);
    }
}
$TODO.displayed={};


;(function(scope, undefined){
'use strict';

	var noop=scope.noop=function(){};

	var merger=scope.merger=function(receiver, supplier, override) {
		for (var key in supplier) {
			if (override !== false || !(key in receiver)) {
				receiver[key] =supplier[key];
			}
		}
		return receiver;
	}


	scope.merger( scope ,{

		DEG_TO_RAD : Math.PI / 180,
		RAD_TO_DEG : 180 / Math.PI ,
		HALF_PI : Math.PI /2 ,
		DOUBLE_PI : Math.PI * 2 ,

		random : function(lower, higher) {
			return (higher - lower) * Math.random() + lower;
		},

		randomInt : function(lower, higher) {
			return ((higher - lower + 1) * Math.random() + lower)>>0;
		},
		generateRandomFunction : function (seed) {
		    return function () {
		        seed = (214013 * seed + 2531011) % 0x100000000;
		        return seed / 4294967296;
		    };
		},
		cleanArray : function (list){
			var last=list.length-1;
			for (var i = last ; i >=0; i--) {
				if (list[i]===undefined) {
					list[i]=list[last];
					last--;
				}
			}
			list.length=last+1;
			return list;
		},
		removeItem : function(array,item){
			var idx=array.indexOf(item);
			if (idx!=-1){
				array.splice(idx,1);
				return item;
			}
		},
		arrayShuffle : function (arr){
			for (var i=arr.length-1; i>0; i--) {
				var rnd =(Math.random()*i)>>0;
				var temp=arr[i];
				arr[i] =arr[rnd];
				arr[rnd] =temp;
			}
			return arr;
		},
		randomPick : function(list){
			return list[ Math.random()*list.length>>0 ];
		},
		arrayTo2d : function(array, cols){
			cols = cols||1;
			var array2d=[];
			var rows= Math.floor( (array.length+cols)/cols ) -1 ;
			var r=0,c=0,i=0;
			for ( r = 0; r < rows; r++) {
				array2d[r] = [];
				for ( c = 0; c < cols; c++) {
					array2d[r][c]=array[i++];
				}
			}
			return array2d;
		},

	    insertionSort: function(objs, comparer ) {

	        for(var i = 1, len = objs.length; i < len; i++) {
	            var  t = objs[i];
	            for(var j = i; j > 0 && comparer(t, objs[j - 1]) ; j--){
	                objs[j] = objs[j - 1];
	            }
	            objs[j] = t;
	        }
	    },
	    
		cleanKeyState : function(){
			for (var key in scope.KeyState){
				delete scope.KeyState[key];
			}
		},

		cloneSimple : function(obj){
			return JSON.parse(JSON.stringify(obj));
		},
		
		cloneDeep : function(obj){
			var target = {};
			for (var i in obj) {
				if (typeof(obj) === 'object') {
					target[i] = clone_deep(obj[i]);
				}else {
					target[i] = obj[i];
				}
			}
			return target;
		}

	});




// function KahanSum(input){

//     var sum = 0;
//     var c = 0 ;  
//     for (var i = 0 ;i< input.length ;i++){
//     	var y=input[i]-c;
//     	var t=sum+y;
//     	c= (t - sum) - y;
//     	sum=t;
//     }
//     return sum;
// }


}(this));




