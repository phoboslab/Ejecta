

// GeomUtils
// 
;(function(scope, undefined){
"use strict";

	scope.merger( scope ,{


		checkPolyCollide : function(poly1, poly2) {
			var len1 = poly1.length,
				len2 = poly2.length;

			var p,q,v;

			var inverted=false;
			while(true){
				p=poly1[len1 - 1];
				var px = p[0];
				var py = p[1];
				for (var i = 0; i < len1; i++) {
					q=poly1[i];
					var qx = q[0];
					var qy = q[1];
					var nx = qy - py;
					var ny = px - qx;

					var NdotP = nx * px + ny * py;
					var allOutside = true;
					for (var j = 0; j < len2; j++) {
						v=poly2[j];
						var vx = v[0];
						var vy = v[1];
						var det = nx * vx + ny * vy - NdotP;
						if (det<0) {
							allOutside = false;
							break;
						}
					}

					if (allOutside){
						return false;
					}

					px = qx;
					py = qy;
				}
				if (len2<2){
					return true;
				}
				if (inverted){
					break;
				}
				len1^=len2;
				len2^=len1;
				len1^=len2;
				p=poly1;
				poly1=poly2;
				poly2=p;
				inverted=true;
			};

			return true;
		},

		checkPolyCircleCollide : function(poly, cx, cy, radius) {
			var len = poly.length;
			var rr = radius * radius;
			var closestPoint, minPCdotPC = Infinity;
			var p = poly[len - 1], 
				px = p[0], py = p[1];
			for (var i = 0; i < len; i++) {
				var q = poly[i], 
					qx = q[0], qy = q[1];
				var nx = qy - py, ny = px - qx;
				var pcx = cx - px, pcy = cy - py;
				var PCdotN = pcx * nx + pcy * ny;
				if (PCdotN >= 0) {
					var NdotN = nx * nx + ny * ny;
					if (PCdotN * PCdotN >= rr * NdotN)
						return false;
				}
				var PCdotPC = pcx * pcx + pcy * pcy;
				if (PCdotPC <= rr){
					return true;
				}else if (PCdotPC <= minPCdotPC) {
					minPCdotPC = PCdotPC;
					closestPoint = p;
				}

				px = qx;
				py = qy;
			}
			var nx = closestPoint[0] - cx, 
				ny = closestPoint[1] - cy;
			var rhs = Math.sqrt(nx * nx + ny * ny) * radius;

			var CdotN = cx * nx + cy * ny;
			for (var i = 0; i < len; i++) {
				var p = poly[i], px = p[0], py = p[1];
				var CPdotN = px * nx + py * ny - CdotN;
				if (CPdotN < rhs)
					return true;
			}

			return false;
		},

		checkPointInPoly : function (x, y, poly) {
			var len = poly.length;
			var p = poly[len - 1], px = p[0] , py = p[1];
			var found = 0;

			for (var i = 0; i < len; i++) {
				var q = poly[i], qx = q[0], qy = q[1];

				var minX, maxX;
				if (px < qx) {
					minX = px;
					maxX = qx;
				}else {
					minX = qx;
					maxX = px;
				}

				if (x >= minX && x <= maxX) {
					var det = (qy - py) * (x-px)+ (px - qx) * (y-py);
					if (det >= 0) {
						return false;
					}
					if (found == 1){
						return true;
					}
					found++;
				}

				px = qx;
				py = qy;
			}

			return false;
		},
		
		calPolyAABB : function (poly){
			var minX=Infinity, minY=Infinity;
			var maxX=-minX, maxY=-minY;
			var len=poly.length;
			var left,right ;
			for(var i = 0; i < len; i++){
				var p=poly[i];
				if (p[0]<minX){
					minX=p[0];
					left=p;
				}
				if (p[0]>maxX){
					maxX=p[0];
					right=p;
				}
				if (p[1]<minY){
					minY=p[1];
				}
				if (p[1]>maxY){
					maxY=p[1];
				}
				if (p[0]==minX){
					left=p[1]>left[1]?p:left;
				}
				if (p[0]==maxX){
					right=p[1]>right[1]?p:right;
				}
			}
			return [minX,minY, maxX,maxY, left,right ];
		},		
		// entity :  {
		// 		collidable : property , boolean
		// 		getHitBox : function , array
		// 		isCollidedWith : function, boolean
		// 		onCollided : function , boolean
		// }
		checkEntitiesCollide : function(enties, gridSize, gridCol) {	

			var grid = {};
			for( var e = 0; e < enties.length; e++ ) {
				var entiyA = enties[e];
				
				if (!entiyA.collidable){
					continue;
				}

				var box1=entiyA.getHitBox();
				var	colMin = Math.floor( box1.x1/gridSize ) ,
					rowMin = Math.floor( box1.y1/gridSize ) ,
					colMax = Math.floor( box1.x2/gridSize ) ,
					rowMax = Math.floor( box1.y2/gridSize ) ;
				
				var checked = {};
				var startIdx=rowMin*gridCol+colMin;
	
				for( var row = rowMin; row <= rowMax; row++ ) {
					var idx=startIdx;
					for( var col = colMin; col <= colMax; col++ ) {
						var group=grid[idx];
						if( !group ) {
							grid[idx] = [entiyA];
						}else {
							for( var c = 0, len=group.length; c<len; c++ ) {
								var entiyB=group[c];
								var box2=entiyB.getHitBox();
								if( !checked[entiyB.id] 
									&& entiyA.isCollidedWith(entiyB) ) {
									entiyA.onCollided(entiyB);
									checked[entiyB.id] = true;
								}
							}
							group.push(entiyA);
						}
						idx++;
					}
					startIdx+=gridCol;
				}
			}
		},

		checkBoxCollide : function( box1, box2){

			return  box1.x1<box2.x2
					&& box1.x2>box2.x1
					&& box1.y1<box2.y2 
					&& box1.y2>box2.y1 ;
		},

		checkWillCollide : function( box1, dx, dy, box2){
			return  box1.x1+dx<box2.x2
					&& box1.x2+dx>box2.x1
					&& box1.y1+dy<box2.y2 
					&& box1.y2+dy>box2.y1 ;
		},	

		checkBlockX : function(box, dx, blockBox){
			if (box.x2<=blockBox.x1){
				dx=blockBox.x1-box.x2;
			}else if (box.x1>=blockBox.x2){
				dx=blockBox.x2-box.x1;
			}
			return dx;
		},

		checkBlockY : function(box, dy, blockBox){
			if (box.y2<=blockBox.y1){
				dy=blockBox.y1-box.y2;
			}else if (box.y1>=blockBox.y2){
				dy=blockBox.y2-box.y1;
			}
			return dy;
		},

		checkMoveX : function(box, dx, moveBox){
			if (box.x2<=moveBox.x1){
				dx=box.x2+dx-moveBox.x1;
			}else if (box.x1>=moveBox.x2){
				dx=box.x1+dx-moveBox.x2;
			}
			return dx;
		},

		checkMoveY : function(box, dy, moveBox){
			if (box.y2<=moveBox.y1){
				dy=box.y2+dy-moveBox.y1;
			}else if (box.y1>=moveBox.y2){
				dy=box.y1+dy-moveBox.y2;
			}
			return dy;
		}

	});

}(this));