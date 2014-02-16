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
		public static const MAX_BOILING = ((2*LevelHandler.MAX_MIRRORS-1)/LevelHandler.MAX_MIRRORS) * BOILING;
		public static const TURBINE_ROT_SPEED = 12;
		public static const TANK_TINT = 0xFF0000;
		public static const TANK_TINT_LEVEL = 0.4;
		public static const TANK_SHAKE_DIST = 5;
		public static const QUOTA_COLOR = 0x009900;
		
		public var collided:Boolean;
		public var boiling:Boolean;
		
		private var wtBoundaries;
		private var turbineSpeed;
		private var tankColor:Color;
		private var quotaCircle:Sprite;
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
			quotaCircle = new Sprite();
			this.quota.addChild(quotaCircle);
		}
		
		public function updateWaterTank() {
			if (collided) {
				temperature += TEMPERATURE_INCREASE * Score.multiplier;
				var maxTemp = BOILING * ((Score.multiplier-1)/LevelHandler.MAX_MIRRORS) + BOILING;
				if (temperature > BOILING) boiling = true;
				if (temperature > maxTemp) temperature = maxTemp;
			}
			else {
				if (temperature < BOILING) boiling = false;
				temperature -= TEMPERATURE_INCREASE;
				this.tank.x = 0, this.tank.y = 0;
				if (temperature < 0) temperature = 0;
			}
			updateTurbine();
			updateTank();
			
			var quotaFraction = Score.score/LevelHandler.LEVEL_QUOTAS[Shading.currLevel];
			var qDegs = quotaFraction * 360 - 180;
			if (quotaFraction <= 1) drawScore(quotaCircle,QUOTA_COLOR,0,0,quota.width/2 - 10,-180,qDegs,10);
			else drawScore(quotaCircle,QUOTA_COLOR,0,0,quota.width/2 - 10,-180,180,10);
		}
		
		private function updateTurbine() {
			turbineSpeed = (TURBINE_ROT_SPEED * temperature)/MAX_BOILING;
			this.turbine.rotation += turbineSpeed;
		}
		
		private function updateTank() {
			var tintLevel = (TANK_TINT_LEVEL * temperature)/MAX_BOILING;
			tankColor.setTint(TANK_TINT,tintLevel);
			this.tank.transform.colorTransform = tankColor;
			
			if (boiling) {
				var tempTankShake = (TANK_SHAKE_DIST * temperature)/MAX_BOILING;
				tank.x = (Math.random() * (tempTankShake*2)) - tempTankShake;
				tank.y = (Math.random() * (tempTankShake*2)) - tempTankShake;
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
			this.tank.x = 0;
			this.tank.y = 0;
			tankColor.setTint(TANK_TINT,0);
			this.tank.transform.colorTransform = tankColor;
			temperature = 0;
			collided = false;
			boiling = false;
		}
		
		public function reset() {
			quotaCircle.graphics.clear();
		}
	}
	
}
