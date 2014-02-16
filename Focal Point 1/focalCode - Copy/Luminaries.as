package focalCode {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Luminaries extends MovieClip {
		
		public static const LUM_X = 387.5;
		public static const LUM_Y = 380;
		
		public var largeRadius:Number;
		public var smallRadius:Number;
		public var sunPointList:Vector.<Sprite>;
		public var rotationSpeed;
		
		private var currDegrees:Number;
		
		public function Luminaries(a:Number,b:Number) {
			rotationSpeed = -1;
			sunPointList = addSunRayPoints();
			largeRadius = a;
			smallRadius = b;
			currDegrees = 0;
			sun.x = largeRadius, sun.y = 0;
			moon.x = -largeRadius, moon.y = 0;
			Shading.luminaries = this;
			MirrorAI.setSunSpeed(rotationSpeed,largeRadius,smallRadius);
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
			//moon.rotation = moonDegrees - 90; //make moon always face center
			//trace('x: ' + posX + ' y: ' + posY);
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
		
		private function addSunRayPoints() {
			var points = [[-sun.width/2,sun.width/2],[0]];
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
		
		public function setRotSpeed(length) {
			rotationSpeed = -180/(length*LevelHandler.FRAME_RATE);
		}
		
		public function setDay(dayNum:int) {
			currDegrees = (dayNum-1) * -360;
			Shading.setDay(dayNum);
		}
	}
	
}
