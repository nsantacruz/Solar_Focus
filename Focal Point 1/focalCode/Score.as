package focalCode {
	
	public class Score {
		
		public static const UNIT_SCORE:uint = 1;
		
		
		public static var multiplier:uint = 0;
		public static var score:uint = 0;
		public static var timeBonus:Number = 0;
		public static var accuracy:uint = 0;
		
		private static var waterTank:WaterTank;
		
		public function Score() {
			throw Error('fooooool');
		}
		
		public static function updateScore() {
			if (waterTank) { 
				if (waterTank.boiling) score += multiplier * LightRay.lrPower;
			}
			//trace(multiplier);
		}
		
		public static function setMultiplier(mult) {
			multiplier = mult;
		}
		
		public static function setWaterTank(wt:WaterTank) {
			waterTank = wt;
		}
		
		public static function reset() {
			multiplier = 0;
			score = 0;
			timeBonus = 0;
			accuracy = 0;
		}
	}
	
}
