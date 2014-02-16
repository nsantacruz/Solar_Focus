package focalCode {
	
	public class Score {
		
		public static const UNIT_SCORE:uint = 1;
		public static const ENERGY_CONVERSION_RATE = 0.5; //measured in dollars
		
		
		public static var multiplier:uint = 0;
		public static var score:uint = 0;
		public static var money:uint = 0; //measured in dollars
		
		
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
		
		public static function scoreToMoney() {
			money += Math.round(score * ENERGY_CONVERSION_RATE);
		}
	}
	
}
