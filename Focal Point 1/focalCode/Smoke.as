package focalCode {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Smoke extends MovieClip {
		
		private static const SMOKE_SCALE_UPDATE = 0.1;
		private static const SMOKE_FLOAT_SPEED = 2;
		
		private var smokeParent;
		
		public function Smoke(par) {
			this.addEventListener(Event.ENTER_FRAME, updateSmoke);
			this.scaleX = 0.1;
			this.scaleY = 0.1;
			this.smokeParent = par;
		}
		
		private function updateSmoke(e:Event):void {
			this.scaleX += SMOKE_SCALE_UPDATE;
			this.scaleY += SMOKE_SCALE_UPDATE;
			this.y -= SMOKE_FLOAT_SPEED;
			this.alpha -= SMOKE_SCALE_UPDATE;
			
			if (this.scaleX >= 1) {
				this.removeEventListener(Event.ENTER_FRAME, updateSmoke);
				smokeParent.dispatchEvent(new Event('remove',true));
			}
		}
	}
	
}
