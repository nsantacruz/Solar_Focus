package focalCode {
	
	import flash.display.MovieClip;
	
	
	public class Bullet extends MovieClip {
		
		public static const SPEED = 15;
		
		public var angle;
		public var target;
		
		public function Bullet(angle,target,d) {
			this.angle = (270 - angle) * Math.PI/180;
			this.target = target;
			this.width = d;
			this.height = d;
		}
	}
	
}
