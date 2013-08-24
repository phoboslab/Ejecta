

function test1(){
	// var buffer = new ArrayBuffer( 48*48 *2);
	var arr=new Array(48*48)

	var s=Date.now();
	for (var n=0;n<1000;n++){
		for (var i=0,len=arr.length;i<len;i++){
			arr[i]=i;
		}
	}
	console.log('write',Date.now()-s)

	var s=Date.now();
	for (var n=0;n<1000;n++){
		for (var i=0,len=arr.length;i<len;i++){
			var t=arr[i];
		}
	}
	console.log('read',Date.now()-s)
	return arr

}


function test2(){
	var buffer = new ArrayBuffer( 48*48 *2);
	var arr=new Int16Array(buffer)

	var s=Date.now();
	for (var n=0;n<1000;n++){
		for (var i=0,len=arr.length;i<len;i++){
			arr[i]=i;
		}
	}
	console.log('write',Date.now()-s)

	var s=Date.now();
	for (var n=0;n<1000;n++){
		for (var i=0,len=arr.length;i<len;i++){
			var t=arr[i];
		}
	}
	console.log('read',Date.now()-s)
	return arr
}


var a1=test1();
var a2=test2();



