package focalCode {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import fl.motion.Color;
	
	public class WaterTank extends MovieClip {
		
		public static const WT_X = 387.5;
		public static const WT_Y = 106;
		public static const WT_POINT = new Point(WT_X,WT_Y);
		public static const TEMPERATURE_INCREASE = 4;
		public static const BOILING = 100;
		public static const TURBINE_ROT_SPEED = 15;
		public static const TANK_TINT = 0xFF0000;
		public static const TANK_TINT_LEVEL = 0.3;
		public static const TANK_SHAKE_DIST = 2;
		public static const QUOTA_COLOR = 0x00ff00;
		public static const OVER_QUOTA_COLOR = 0x0000ff;
		
		public var collided:Boolean;
		public var boiling:Boolean;
		
		private var wtBoundaries;
		private var turbineSpeed;
		private var tankColor:Color;
		private var quotaCircle:Sprite;
		private var overQuotaCircle:Sprite
		private var quotaPoint:Point;
		
		public var temperature:int;
		
		
		public function WaterTank() {
			Reflection.addCollisionObj(this);
			Score.setWaterTank(this);
			wtBoundaries = addBoundaryPoints();
			collided = false;
			boiling = false;
			temperature = 0;
			turbineSpeed = 0;
			tankColor = new Color();
			
			quotaPoint = localToLocal(this.quota,this,0,0);
			quotaCircle = new Sprite(), overQuotaCircle = new Sprite();
			this.quota.addChild(quotaCircle), this.quota.addChild(overQuotaCircle);
		}
		
		public function updateWaterTank() {
			if (collided) {
				temperature += TEMPERATURE_INCREASE * Score.multiplier;
				if (temperature > BOILING) temperature = BOILING, boiling = true;
			}
			else {
				temperature -= TEMPERATURE_INCREASE;
				boiling = false;
				this.tank.x = 0, this.tank.y = 0;
				if (temperature < 0) temperature = 0;
			}
			
			updateTurbine();
			updateTank();
			
			var quotaFraction = Score.score/LevelHandler.LEVEL_QUOTAS[Shading.currDay-1];
			var qDegs = quotaFraction * 360 - 180;
			if (quotaFraction <= 1) drawScore(quotaCircle,QUOTA_COLOR,0,0,quota.width/2,-180,qDegs,10);
			else {
				//drawScore(quotaCircle,QUOTA_COLOR,0,0,quota.width/2,-180,180);
				drawScore(overQuotaCircle,OVER_QUOTA_COLOR,0,0,quota.width/2,-180,qDegs-360,10);
			}
		}
		
		private function updateTurbine() {
			turbineSpeed = (TURBINE_ROT_SPEED * temperature)/BOILING
			this.turbine.rotation += turbineSpeed;
		}
		
		private function updateTank() {
			var tintLevel = (TANK_TINT_LEVEL * temperature)/BOILING;
			tankColor.setTint(TANK_TINT,tintLevel);
			this.tank.transform.colorTransform = tankColor;
			
			if (boiling) {
				tank.x = (Math.random() * (TANK_SHAKE_DIST*2)) - TANK_SHAKE_DIST;
				tank.y = (Math.random() * (TANK_SHAKE_DIST*2)) - TANK_SHAKE_DIST;
			}
		}
		
		private function addBoundaryPoints() {
			var array = [];
			var positions = [[0,this.tank.width],[0,this.tank.height]];
			for (var j = 0; j < positions.length; j++) {
				for (var k = 0; k < positions[j].length; k++) {
					var tempSprite = new Sprite();
					array.push(tempSprite); 
					this.addChild(tempSprite);
					tempSprite.x = positions[0][k], tempSprite.y = positions[1][j];
				}
			}
			return array;	
		}
		
		public function get boundaries() {
			var array = [];
			for (var i = 0; i < wtBoundaries.length; i++) {
				array.push(this.localToGlobal(new Point(wtBoundaries[i].x,wtBoundaries[i].y)));
			}
			return array;
		}
		
		private function drawScore(target:Sprite, color, x:Number, y:Number, r:Number, aStart, aEnd, step:Number = 1):void {
			// More efficient to work in radians
			var degreesPerRadian:Number = Math.PI / 180;
			aStart *= degreesPerRadian;
			aEnd *= degreesPerRadian;
			step *= degreesPerRadian;
		
			// Draw the segment
			var g = target.graphics;
			g.clear();
			g.beginFill(color);
			g.moveTo(x, y);
			for (var theta:Number = aStart; theta < aEnd; theta += Math.min(step, aEnd - theta)) {
				g.lineTo(x + r * Math.cos(theta), y + r * Math.sin(theta));
			}
			g.lineTo(x + r * Math.cos(aEnd), y + r * Math.sin(aEnd));
			g.lineTo(x, y);
			g.endFill();
		}
		
		private function localToLocal(currMC,newMC,x,y) {
			var point = new Point(x,y);
			return newMC.globalToLocal(currMC.localToGlobal(point));
		}
		
		public function endDay() {
			quotaCircle.graphics.clear();
			overQuotaCircle.graphics.clear();
		}
	}
	
}
