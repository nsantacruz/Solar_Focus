package focalCode {
	
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class MirrorAI {
		
		public static const TRACK_NONE = 0;
		public static const TRACK_MIRROR_ANGLE = 1;
		public static const TRACK_LR_ANGLE = 2;
		public static const TRACK_ELLIPTICALLY = 3;
		public static const TRACK_LINEARLY = 4;
		
		
		private static var sunSpeed;
		private static var lum:Luminaries;
		
		private var sunPoint:Point;
		private var sunAngle;
		private var waterTankAngle;
		private var waterTankPoint:Point; 
		private var framesPassed;
		private var mirror:Mirror;
		private var currAngle;
		private var firstRotation:Boolean;
		private var animating:Boolean;
		public var aiLevel;
		
		public function MirrorAI(mirror:Mirror,lumi:Luminaries) {
			firstRotation = true;
			animating = false;
			this.mirror = mirror;
			aiLevel = TRACK_NONE;
			lum = lumi;
			updateTracking();
			waterTankPoint = mirror.globalToLocal(WaterTank.WT_POINT);
			waterTankAngle = -Math.atan2(waterTankPoint.y,waterTankPoint.x);
			
			currAngle = 0;
		}
		
		public function track() {
			framesPassed++;
			//currAngle = Mirror.mirrorTarget.currAngle;  CRITICAL - for MirrorAI to work, need to add currAngle prop to mirrorTarget
			if (aiLevel == TRACK_NONE) return;
			else if (aiLevel == TRACK_LINEARLY) trackLinearly();
			else if (aiLevel == TRACK_MIRROR_ANGLE && isActive()) trackMirrorAngle();
			else if (aiLevel == TRACK_LR_ANGLE && isActive()) trackLRAngle();
			else if (aiLevel == TRACK_ELLIPTICALLY) trackElliptically();
		}
		
		//calculate distance sun travels in one frame
		public static function setSunSpeed(rotationSpeed,largeRadius,smallRadius) {
			var rads = rotationSpeed * Math.PI/180;
			sunSpeed = Math.sqrt(Math.pow(largeRadius - (largeRadius * Math.cos(rads)),2) +
								 Math.pow(smallRadius * Math.sin(rads),2));
		}
		
		public function updateTracking() {
			sunPoint = mirror.globalToLocal(lum.localToGlobal(new Point(lum.sun.x,lum.sun.y)));
			sunAngle = (lum.degrees - 90)*Math.PI/180;
			framesPassed = 0;
		}
		
		private function isActive():Boolean {
			if (Mirror.mirrorTarget.currMirror == mirror) return true;
			else return false;
		}
		
		private function trackLinearly() {
			if(!sunSpeed) return;
			var deltaX = sunSpeed * Math.cos(sunAngle);
			var deltaY = sunSpeed * Math.sin(sunAngle);
			var newX = deltaX*framesPassed + sunPoint.x;
			var newY = deltaY*framesPassed + sunPoint.y;
			getMirrorAngle(new Point(newX,newY));
		}
		
		private function trackMirrorAngle() {
		
		}
		
		private function trackLRAngle() {
			
		}
		
		private function trackElliptically() {
			if (!sunSpeed) return;
			var newSunPoint = mirror.globalToLocal(lum.localToGlobal(new Point(lum.sun.x,lum.sun.y)));
			getMirrorAngle(newSunPoint);
		}
		
		//works backwards (kinda) from Mirror.getLightRayAngle() to find mirror angle
		//equations don't make sense logically, only mathematically 
		private function getMirrorAngle(newSunPoint:Point) {
			var mirrorSunAngle = -Math.atan2(newSunPoint.y,newSunPoint.x);
			var mirrorWaterTankAngle = -Math.atan2(waterTankPoint.y,waterTankPoint.x);
			var average = (mirrorSunAngle + mirrorWaterTankAngle)/2;
			if (firstRotation) {
				firstRotation = false;
				animateTo(mirror.top,mirror.top.rotation,90 - (average*180/Math.PI),'rotation',6);
				animating = true;
			} else if (!animating) mirror.top.rotation = 90 - (average*180/Math.PI);
		}
		
		private function animateTo(obj,start,end, prop:String,frames) {
			var delta = end - start;
			var increment = delta/frames;
			var count = 0;
			obj.addEventListener(Event.ENTER_FRAME,enterFrame);
			function enterFrame(e) { 
				obj[prop] += increment;
				count++;
				if (count >= frames) obj.removeEventListener(Event.ENTER_FRAME,enterFrame), animating = false;
			}
		}
	}
}