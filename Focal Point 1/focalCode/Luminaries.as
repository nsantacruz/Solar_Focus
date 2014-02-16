package focalCode {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Luminaries extends MovieClip {
		
		public static const LUM_X = 387.5;
		public static const LUM_Y = 440;
		public static const PRE_LEVEL_ANGLE = 15;
		public static const HALF_SUN_WIDTH = 50;
		public static const SUN_RAY_COLOR = 0xffff00;
		
		public var largeRadius:Number;
		public var smallRadius:Number;
		public var sunPointList:Vector.<Sprite>;
		public var rotationSpeed;
		public var mirrorTarget:MirrorTarget;
		private var sunRay:Sprite;
		private var mSPL,mSPR,sSPL,sSPR; //represent four points of sunRay
		private var currDegrees:Number;
		
		public function Luminaries(a:Number,b:Number,mirrorTarget=null,isBackground=false) {
			rotationSpeed = -1;
			sunPointList = addSunRayPoints();
			largeRadius = a;
			smallRadius = b;
			currDegrees = 0;
			sun.x = largeRadius, sun.y = 0;
			moon.x = -largeRadius, moon.y = 0;
			this.mirrorTarget = mirrorTarget;
			sunRay = new Sprite();
			addChild(sunRay);
			if (!isBackground) {
				Shading.luminaries = this;
				MirrorAI.setSunSpeed(rotationSpeed,largeRadius,smallRadius);
			}
		}
		
		public function updateLuminaries():void {
			currDegrees += rotationSpeed;
			var radians:Number = getRadians(currDegrees);
			sun.x = Math.cos(radians) * largeRadius;
			sun.y = Math.sin(radians) * smallRadius;
			//sun.rotation = currDegrees - 90;
			
			var moonDegrees = currDegrees - 180;
			var mRadians:Number = getRadians(moonDegrees);
			moon.x = Math.cos(mRadians) * largeRadius;
			moon.y = Math.sin(mRadians) * smallRadius;
			
			if (mirrorTarget != null) updateSunRay();
		}
		
		private function getRadians(degrees:Number):Number {
			return degrees * Math.PI / 180;
		} 
		
		public function get degrees() {
			return currDegrees;
		}
		
		public function set degrees(degs) {
			currDegrees = degs;
		}
		
		private function addSunRayPoints():Vector.<Sprite> {
			var points = [[-HALF_SUN_WIDTH,HALF_SUN_WIDTH],[0]];
			var vector:Vector.<Sprite> = new Vector.<Sprite>();
			for (var i = 0; i < points[0].length; i++) {
				for (var j = 0; j < points[1].length; j++) {
					var sprite = new Sprite();
					sun.addChild(sprite);
					sprite.x = points[0][i];
					sprite.y = points[1][j];
					vector.push(sprite);
				}
			}
			return vector;
		}
		
		private function updateSunRay() {
			var localSunPoint = localToLocal(this,mirrorTarget.currMirror,sun);
			var mirrorSunAngle = -Math.atan2(localSunPoint.y,localSunPoint.x);
			sun.rotation = (Math.PI/2-mirrorSunAngle) * 180/Math.PI;
				
			mSPL = localToLocal(mirrorTarget.currMirror.top,mirrorTarget,mirrorTarget.currMirror.sunPointList[0]);
			sSPL = localToLocal(sun,mirrorTarget,sunPointList[0]);
			mSPR = localToLocal(mirrorTarget.currMirror.top,mirrorTarget,mirrorTarget.currMirror.sunPointList[1]);
			sSPR = localToLocal(sun,mirrorTarget,sunPointList[1]);
			removeChild(sunRay);
			sunRay = new Sprite();
			sunRay.mouseEnabled = false;
			var g = sunRay.graphics;
			g.beginFill(SUN_RAY_COLOR,mirrorTarget.currMirror.lightRay.sprite.alpha * 0.5);
			g.moveTo(mSPL.x,mSPL.y);
			g.lineTo(sSPL.x,sSPL.y);
			g.lineTo(sSPR.x,sSPR.y);
			g.lineTo(mSPR.x,mSPR.y);
			g.lineTo(mSPL.x,mSPL.y);
			g.endFill();
			addChildAt(sunRay,0);
			sunRay.y += 40;
			if (!mirrorTarget.currMirror.lightRayVisible) sunRay.visible = false;
		}
		
		private function localToLocal(currMC,newMC,sprite) {
			var point = new Point(sprite.x,sprite.y);
			return newMC.globalToLocal(currMC.localToGlobal(point));
		}
		
		//length is measured in seconds
		public function setRotSpeed(length:Number):void {
			rotationSpeed = -180/(length*LevelHandler.FRAME_RATE);
		}
		
		public function setDay(dayNum:int):void {
			currDegrees = (dayNum-1) * -360 + PRE_LEVEL_ANGLE;
			Shading.setDay(dayNum);
		}
	}
	
}
