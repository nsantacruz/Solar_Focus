package focalCode {
	
	import flash.geom.Point;
	
	public class Reflection {
		
		public static var collisionList = []; //list of objects that need to detect collision of light ray for
		public static var lightRayList:Vector.<LightRay> = new Vector.<LightRay>(); //list of all lightRays to see if they've collided
		
		public static var collidedList:Vector.<Object> = new Vector.<Object>();
		private static var wtHitCount:int = 0;
		
		public function Reflection() {
			throw Error('Cannot instantiate!! >:(');
		}
		
		public static function checkCollisions() {
			//trace(collisionList.length);
			//trace(lightRayList.length);
			//checkLineIntersection([new Point(0,0),new Point(1,1)],[new Point(0,1),new Point(1,-1)]);
			for (var i = 0; i < collisionList.length; i++) {
				var tempObj = collisionList[i];
				for (var j = 0; j < lightRayList.length; j++) {
					var tempLR = lightRayList[j];
					var collisionPoint = calculateCollision(tempObj,tempLR);
					if (collisionPoint && !tempLR.disabled) { //collided
						addCollision(tempObj,tempLR);
						drawLight(tempLR.upperSpriteMask,tempObj.hitZone,10,tempLR.spriteWidth,tempLR.spriteY,LightRay.LR_HEIGHT,70);
					} else {
						removeCollision(tempObj,tempLR);
					}
				}
			}
		}
		
		private static function calculateCollision(obj,lr:LightRay) {
			lr = lr as LightRay;
			var lrVectorPairs = getVectorPairs(lr.boundaries,true);
			var objVectorPairs = getVectorPairs(obj.boundaries);
			for (var k = 0; k < obj.boundaries.length; k++) {
				//trace(obj.boundaries[k].y);
			}
			//trace();
			for (var i = 0; i < lrVectorPairs.length; i++) {
				var tempLRVP = lrVectorPairs[i];
				for (var j = 0; j < objVectorPairs.length; j++) {
					var tempObjVP = objVectorPairs[j];
					var collPoint = checkLineIntersection(tempLRVP,tempObjVP);
					if (collPoint) return collPoint;
				}
			}
			return;
		}
		
		//returns lines that represent borders of object. gets them in p + r form where p and r are vectors
		private static function getVectorPairs(points,isLightRay = false) {
			var vectorPairs = [];
			var bottomPoint:Point;
			var topPoint:Point;
			var baseVector:Point;
			var addedVector:Point;
			if (isLightRay) {
				for (var j = 0; j < points.length/2; j++) {
					bottomPoint = points[j];
					topPoint = points[j+2];
					baseVector = bottomPoint;
					addedVector = new Point(topPoint.x - baseVector.x, topPoint.y - baseVector.y);
					vectorPairs.push([baseVector,addedVector]);
				}
			} else {
				for (var k = 0; k < points.length; k++) {
					for (var l = k+1; l < points.length; l++) {
						bottomPoint = points[k];
						topPoint = points[l];
						if (bottomPoint.x != topPoint.x && bottomPoint.y != topPoint.y) continue; //points are not on the same line!
						baseVector = bottomPoint;
						addedVector = new Point(topPoint.x - baseVector.x, topPoint.y - baseVector.y);
						vectorPairs.push([baseVector,addedVector]);
					}
				}
			}
			return vectorPairs;
		}
		
		//vp stands for vector pair
		//find line intersection when:
		// p + tr = q + us
		private static function checkLineIntersection(vp1,vp2,isVP=true) {
			var p = vp1[0], q = vp2[0], r, s;
			if (isVP) r = vp1[1], s = vp2[1];
			else r = new Point(vp1[1].x - vp1[0].x, vp1[1].y - vp1[0].y), s = new Point(vp2[1].x - vp2[0].x, vp2[1].y - vp2[0].y);
			if (r.x * s.y - r.y * s.x != 0) {//parralel
				var t = ((q.x - p.x) * s.y - (q.y - p.y) * s.x)/(r.x * s.y - r.y * s.x);
				var u = ((q.x - p.x) * r.y - (q.y - p.y) * r.x)/(r.x * s.y - r.y * s.x);
				if (t > 0 && t <= 1 && u > 0 && u <= 1) { 
					if (fuzzyEquals(p.x + t * r.x,q.x + u * s.x)) {
						if (fuzzyEquals(p.y + t * r.y,q.y + u * s.y)) {
							var collisionPoint = new Point(p.x + t * r.x, p.y + t * r.y);
							return collisionPoint;
						}
					}
				}
			}
			return;
		}
		
		public static function addCollisionObj(obj,isLightRay = false) {
			if (isLightRay) lightRayList.push(obj);
			else collisionList.push(obj);
		}
		
		public static function removeCollisionObj(obj,isLightRay = false) {
			var index = -1;
			if (isLightRay) {
				index = lightRayList.indexOf(obj);
				if (index == -1) throw Error('Cannot find object...');
				else lightRayList.splice(index,1);
			} else {
				index = collisionList.indexOf(obj);
				if (index == -1) throw Error('Cannot find object...');
				else collisionList.splice(index,1);
			}
		}
		
		public static function addCollision(obj,lightRay:LightRay) {
			if (obj is Blimp) {
				obj.life -= LightRay.lrPower;
			}
			if (collidedList.indexOf(obj) == -1) {
				if (obj is WaterTank) {
					obj.collided = true;
					wtHitCount++;
					Score.setMultiplier(wtHitCount);
				}
				collidedList.push(obj);
			}
		}
		
		public static function removeCollision(obj,lightRay:LightRay) {
			var index = collidedList.indexOf(obj);
			if (index != -1) {
				collidedList.splice(index,1);
				if (obj is WaterTank) {
					wtHitCount--;
					if (wtHitCount <= 0) obj.collided = false;
					Score.setMultiplier(wtHitCount);
				}
				lightRay.outerSprite.getChildAt(0).height = LightRay.LR_SPRITE_HEIGHT;
				lightRay.drawLightMask();
			}
		}
		
		private static function fuzzyEquals(number1:Number, number2:Number, precision:int = 5):Boolean {
			var difference:Number = number1 - number2;
			var range:Number = Math.pow(10, -precision);
			return difference < range && difference > -range;
		}
		
		private static function drawLight(sprite,obj,numLines,lrWidth,Y,lrHeight,checkNum,dontCheck=false) {
			var startY = 900;
            var checkNumMin = checkNum;
            var checkNumMax = 150;
            var lineStep = lrWidth/numLines;
            var checkStep = lrHeight/checkNum;
			var skipY = 230;
			var skipJ = Math.round(skipY/checkStep);
            var g = sprite.graphics;
            g.clear();
			g.beginFill(0x000000,1), g.lineStyle(0,0xffff00), g.moveTo(0,startY);
            for (var i = 0; i <= lrWidth; i += lineStep) {
                var hitX = i;
                var hitY = -lrHeight + startY;
                checkNum = checkNumMin; //reset checkNum
                checkStep = lrHeight/checkNum;
                for (var j = skipJ; j <= checkNum && !dontCheck; j++) {
                    hitX = i;
                    hitY = -checkStep * j + startY;
                    var hitPoint = sprite.localToGlobal(new Point(hitX,hitY));
					//trace(hitPoint);
                    if (obj.hitTestPoint(hitPoint.x,hitPoint.y,true)) {
                        if (checkNum < checkNumMax) { //first collision
                            j = Math.floor((j-1)*checkNumMax/checkNum); //proportionally update j
                            checkNum = checkNumMax; //make checkNum much higher because now you're close to a collision
                            checkStep = lrHeight/checkNum; //update checkStep
                            
                        } else break;
                        //found a collision. stop incrementing y and draw line to collision
                    }
                }
                g.lineTo(hitX,hitY);
            }
            g.lineTo(lrWidth,startY), g.lineTo(0,startY), g.endFill();
		}
	}
	
}
