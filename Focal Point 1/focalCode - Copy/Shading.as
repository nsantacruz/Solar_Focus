package focalCode {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Shading {
		
		public static const HOURS_IN_DAY = 24;
		public static const TIME_ACCURACY = 100; //how accurate should time be? currently: 100th place
		public static const DAWN = 6;
		public static const SUNSET = 18;
		
		public static var isDayTime:Boolean = true;
		public static var currDay = 1;
		public static var daysHeldBack = 0;
		
		private static var currTime;
		private static var lum:Luminaries;
		private static var eventDispatcher;
		
		public function Shading() {
			throw Error('Cannot instantiate!! >:(');
		}
		//Must be set before anything else
		public static function set luminaries(lumi:Luminaries) {
			lum = lumi;
		}
		
		public static function updateTime() {
			calculateTime();
			return currTime;
		}
		
		private static function calculateTime() {
			var tempTime = ((-1 * lum.degrees * HOURS_IN_DAY)/360 + DAWN)*TIME_ACCURACY/TIME_ACCURACY;
			currDay = Math.ceil(tempTime/HOURS_IN_DAY);
			tempTime -= HOURS_IN_DAY * (currDay - 1);
			currTime = tempTime;
			//trace(currDay);
			nightOrDay();
		}
		
		private static function nightOrDay() {
			if (isDayTime) {
				if (currTime >= SUNSET) {
					isDayTime = false;
					dispatchEvent(new Event('night',true));
				}
			} else {
				if (currTime >= DAWN && currTime < SUNSET) { 
					isDayTime = true;
					dispatchEvent(new Event('day',true));
				}
			}
		}
		
		private static function dispatchEvent(event:Event):Boolean {
            return eventDispatcher.dispatchEvent(event);
        }
		
		public static function setDispatcher(dispatcher) {
			eventDispatcher = dispatcher;
		}
		
		public static function setDay(dayNum:int) {
			currDay = dayNum;
		}
	}
	
}
