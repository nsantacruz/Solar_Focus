package focalCode {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.geom.ColorTransform;
	
	public class Mirror extends MovieClip {
		public static const MIRROR_WIDTH = 75;
		public static const MIRROR_HEIGHT = 20;
		public static const TOP_HEIGHT = 20;
		public static const MIRROR_X_POSITIONS = [62,162,262,512,612,712];
		public static const MIRROR_SPAWN_POSITIONS = [62,712,262,512,162,612];
		public static const MIRROR_Y = 415;
		public static const ROTATE_FRAMES = 4;
		public static const MIRROR_DISABLED_TIME = 48 //in frames
		public static const MAX_ROT_SPEED = 2;
		public static const ROT_ACCELERATION = 0.2;
		
		public static var allMirrors:Array = [];
		public static var lum:Luminaries;
		public static var currLum;
		public static var mirrorTarget:MirrorTarget;
		public static var mirrorHolder:Sprite = new Sprite();
		
		public var lLimit:Number;
		public var rLimit:Number;
		public var lightRay:LightRay;
		public var mirrorAI:MirrorAI;
		public var sunPointList:Vector.<Sprite>;
		public var lightRayVisible:Boolean;
		public var rotateSpeed:Number;
		
		private var disableCount:uint;
		
		public function Mirror(leftLimit:Number=-90,rightLimit:Number=90,x=0,y=0,upgraded=false,lumi:Luminaries=null) {
			this.x = x;
			this.y = y;
			lLimit = leftLimit;
			rLimit = rightLimit;
			lightRay = new LightRay(MIRROR_WIDTH,TOP_HEIGHT), addChild(lightRay), lightRay.x = 0, lightRay.y = 0;
			if (lumi) lum = lumi; //used in SaveData class
			allMirrors.push(this);
			mirrorHolder.addChild(this);
			sunPointList = addSunRayPoints();
			mirrorTarget.addMirror(this,upgraded);
			mirrorAI = new MirrorAI(this,lum);
			setAI(MirrorAI.TRACK_NONE);
			lightRay.sprite.alpha = 0, lightRay.lowerSprite.alpha = 0;
			lightRayVisible = false;
			currLum = lum.sun;
			if (upgraded) {
				lightRay.sprite.alpha = 0, lightRay.lowerSprite.alpha = 0;
				lightRayVisible = false;
			}
			this.addEventListener('mirrorHit',mirrorDisable);
			this.top.goo.alpha = 0;
			rotateSpeed = 0;
			disableCount = 0;
		}
		
		private function mirrorDisable(e) {
			this.top.goo.alpha = 1;
			this.lightRay.sprite.alpha = 0, this.lightRay.lowerSprite.alpha = 0;
			lightRayVisible = false;
			this.lightRay.disabled = true;
		}
		
		private function mirrorEnable() {
			this.lightRay.visible = true;
			this.lightRay.disabled = false;
			animateTo(this.top.goo,1,0,'alpha',4);
		}
		
		public static function updateAngle() {
			for (var i = 0; i < allMirrors.length; i++) {
				var tm = allMirrors[i]; //tempMirror
				if (tm.lightRay.disabled) {
					tm.disableCount++;
					if (tm.disableCount >= MIRROR_DISABLED_TIME) {
						tm.disableCount = 0;
						tm.mirrorEnable();
					}
				}
				updateLightRay(tm,tm.lightRay);
				if (!tm.lightRayVisible) tm.top.gotoAndStop(1);
				else tm.top.gotoAndStop(2);
				tm.mirrorAI.track();
			}
		}
		
		public static function setTarget(mt:MirrorTarget) {
			mirrorTarget = mt;
		}
		
		public static function updateLightRay(mirror:Mirror, lightRay:LightRay) {
			if (!lightRay.disabled) {
				lightRay.outerSprite.rotation = getLightRayAngle(mirror,mirror.top.rotation);
				lightRay.lowerSpriteMask.rotation = mirror.top.rotation;
				var mirrorRot = mirror.top.rotation * Math.PI/180;
				var combinedRot = mirrorRot - lightRay.outerSprite.rotation * Math.PI/180;
				var SinCR = Math.sin(combinedRot);
				var CosCR = Math.cos(combinedRot);
				var tempSprite = lightRay.upperSpriteMask;
				var tempLowerSprite = lightRay.outerSprite.getChildAt(2);
				var prevY = tempSprite.y;
				var deltaY = 0;
				if (combinedRot >= 0) {
					lightRay.spriteY = (-MIRROR_WIDTH/2 + 10) * SinCR - (LightRay.LR_HEIGHT + MIRROR_HEIGHT/2);
					deltaY = prevY - ((-MIRROR_WIDTH/2 + 10) * SinCR - (LightRay.LR_HEIGHT + MIRROR_HEIGHT/2));
				
				} else if (combinedRot < 0) { 
					lightRay.spriteY = (MIRROR_WIDTH/2 - 10) * SinCR - (LightRay.LR_HEIGHT + MIRROR_HEIGHT/2);
					deltaY = prevY - ((MIRROR_WIDTH/2 - 10) * SinCR - (LightRay.LR_HEIGHT + MIRROR_HEIGHT/2));
				}
				tempSprite.y = lightRay.spriteY;
				lightRay.spriteWidth = (MIRROR_WIDTH) * CosCR;
				tempSprite.width = lightRay.spriteWidth;
				tempSprite.x = -tempSprite.width/2 + ((MIRROR_HEIGHT/2) * SinCR);
				tempLowerSprite.width = (MIRROR_WIDTH) * CosCR;
				tempLowerSprite.x = -tempSprite.width/2 + ((MIRROR_HEIGHT/2) * SinCR);
				tempLowerSprite.height += deltaY;				
				tempLowerSprite.y -= deltaY;
				lightRay.sprite.alpha = CosCR * LightRay.LR_ALPHA, tempLowerSprite.alpha = CosCR * LightRay.LR_ALPHA;
				if (!fuzzyEquals(tempLowerSprite.y,tempSprite.y + LightRay.LR_HEIGHT)) {
					tempLowerSprite.y = tempSprite.y + LightRay.LR_HEIGHT;
				}
				if(fuzzyEquals(tempSprite.width,0,-1)) tempSprite.width = 0, tempLowerSprite.width = 0, mirror.lightRayVisible = false;
				else mirror.lightRayVisible = true;
			
			}
		}
		
		public static function getLightRayAngle(target,rotation) {
			var sunPoint:Point = new Point(currLum.x,currLum.y);
			var localSunPoint = target.globalToLocal(lum.localToGlobal(sunPoint));
			var sunAngle = -Math.atan2(localSunPoint.y,localSunPoint.x);  //angle of sun relative to mirror
			var transformedSunAngle = Math.PI/2 - sunAngle; //transform so that up is 0 degrees and goes clockwise
			var relativeSunAngle = transformedSunAngle - toRadians(rotation);
			var relativeLRAngle = 2*Math.PI - relativeSunAngle;
			var lrAngle = relativeLRAngle + toRadians(rotation);
			//trace('sun: ' + Math.round(toDegrees(sunAngle)) + ' lr: ' + Math.round(toDegrees(Math.PI/2 - lrAngle)) + ' mirror: ' + Math.round(90 - rotation));
			return toDegrees(lrAngle);
		}
		
		private static function fuzzyEquals(number1:Number, number2:Number, precision:int = 2):Boolean {
			var difference:Number = number1 - number2;
			var range:Number = Math.pow(10, -precision);
			return difference < range && difference > -range;
		}
		
		private static function reduceAngle(angle) {
			var multiple = Math.round(angle/(2*Math.PI));
			return angle - (multiple * 2 * Math.PI);
		}
		
		private static function toRadians(degs) {
			return degs * Math.PI/180;
		}
		
		private static function toDegrees(rads) {
			if (rads >= 2*Math.PI) rads -= 2*Math.PI;
			if (rads < 0) rads += 2*Math.PI;
			return rads * 180/Math.PI;
		}
		
		public function setAI(level) {
			mirrorAI.aiLevel = level;
		}
		
		private function addSunRayPoints() {
			var points = [[-MIRROR_WIDTH/2,MIRROR_WIDTH/2],[-MIRROR_HEIGHT/2]];
			var vector:Vector.<Sprite> = new Vector.<Sprite>();
			for (var i = 0; i < points[0].length; i++) {
				for (var j = 0; j < points[1].length; j++) {
					var sprite = new Sprite();
					top.addChild(sprite);
					sprite.x = points[0][i];
					sprite.y = points[1][j];
					vector.push(sprite);
				}
			}
			return vector;
		}
		
		private static function animateTo(obj,start,end, prop:String,frames = ROTATE_FRAMES) {
			var delta = end - start;
			var increment = delta/frames;
			var count = 0;
			obj.addEventListener(Event.ENTER_FRAME,enterFrame);
			function enterFrame(e) { 
				obj[prop] += increment;
				count++;
				if (count >= frames) obj.removeEventListener(Event.ENTER_FRAME,enterFrame);
			}
		}
		
		public static function startDay() {
			
		}
		
		public static function endDay() {
			for (var i = 0; i < allMirrors.length; i++) {
				var tm = allMirrors[i];
				tm.lightRay.sprite.alpha = 0, tm.lightRay.lowerSprite.alpha = 0;
				tm.lightRayVisible = false;
				animateTo(tm.top,tm.top.rotation,0,"rotation");
				tm.top.gotoAndStop(1);
				tm.rotateSpeed = 0;
			}
		}
		
		public static function reset() {
			allMirrors = [];
			mirrorHolder = new Sprite();
			MirrorTarget.mirrorList = new Vector.<Mirror>();
		}
		
		public function remove() {
			allMirrors.splice(allMirrors.indexOf(this),1);
			mirrorTarget.removeMirror(this);
			mirrorHolder.removeChild(this);
			Reflection.removeCollisionObj(lightRay,true);
		}
	}
	
}
