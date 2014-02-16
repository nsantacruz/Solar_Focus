package focalCode {
	
	import flash.geom.Point;
	import flash.display.Sprite;
	
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
		
		public var aiLevel;
		public var line:Sprite;
		
		public function MirrorAI(mirror:Mirror,lumi:Luminaries) {
			this.mirror = mirror;
			aiLevel = TRACK_NONE;
			lum = lumi;
			updateTracking();
			waterTankPoint = mirror.globalToLocal(WaterTank.WT_POINT);
			waterTankAngle = -Math.atan2(waterTankPoint.y,waterTankPoint.x);
			
			currAngle = 0;
			
			line = new Sprite();
			mirror.addChildAt(line,0);
			line.graphics.moveTo(0,0);
			line.graphics.lineStyle(2,0xFFFFFF);
			line.graphics.lineTo(0,-900);
			line.visible = false;
			line.mouseEnabled = false;
		}
		
		public function track() {
			framesPassed++;
			currAngle = Mirror.mirrorTarget.currAngle;
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
			line.visible = true;
			line.rotation = 90 - (currAngle*180/Math.PI);
		}
		
		private function trackLRAngle() {
			line.visible = true;
			line.rotation = Mirror.getLightRayAngle(mirror,90 - (currAngle*180/Math.PI));
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
			mirror.top.rotation = 90 - (average*180/Math.PI);
		}
		
	}
}