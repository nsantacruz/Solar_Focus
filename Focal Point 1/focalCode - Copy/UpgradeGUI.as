package focalCode {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	public class UpgradeGUI extends MovieClip {
		private static const MOVE_FRAMES = 4;
		private static const LEFT = 37, RIGHT = 39, UP = 38, DOWN = 40;
		private static const A = 65, D = 68, W = 87, S = 83;
		private static const ENTER = 13;
		private static const SELECT_ALPHA = 0.5;
		private static const UPGRADE_TINT = 0x6666ff;
		private static const MAX_MIRRORS = LevelHandler.MAX_MIRRORS;
		private static const UPGRADE_Y_POSITIONS = [265,180,95,10];
		private static const UPGRADE_COST = [100,500,1000,1500];
		private static const MAX_UPGRADES = 4;
		
		private var currMirror:uint;
		private var currUpgrade:uint;
		private var mirrorUpgradeLevels = [];
		private var guiParent;
		
		public function UpgradeGUI(stage) {
			this.guiParent = stage;
		}
		
		public function activate() {
			guiParent.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			this.mover.x = Mirror.MIRROR_X_POSITIONS[0] - this.mover.width/2;
			currMirror = 0;
			currUpgrade = 0;
			info.price.text = UPGRADE_COST[currUpgrade];
			
			for (var i = 0; i < MAX_MIRRORS; i++) {
				var found = false
				for (var j = 0; j < MirrorTarget.mirrorList.length && !found; j++) {
					var tm = MirrorTarget.mirrorList[j];
					if (tm.x == Mirror.MIRROR_X_POSITIONS[i]) {
						mirrorUpgradeLevels.push(tm.mirrorAI.aiLevel+1); 
						found = true;
					}
				}
				if (!found) mirrorUpgradeLevels.push(0);
			}
			showUpgrades();
			cash.text = String(Score.money);
		}
		
		public function deactivate() {
			guiParent.removeEventListener(KeyboardEvent.KEY_DOWN,keyDown);
		}
		
		private function showUpgrades() {
			for (var j = 1; j <= MAX_UPGRADES; j++) {
				mover['upgrade'+j].alpha = SELECT_ALPHA;
			}
			for (var i = 1; i <= mirrorUpgradeLevels[currMirror]; i++) {
				mover['upgrade'+i].alpha = 1;
			}
		}
		
		private function keyDown(e:KeyboardEvent):void {
			if (e.keyCode == LEFT || e.keyCode == A) {
			
				if (currMirror == 0) currMirror = MAX_MIRRORS-1;
				else currMirror--;
				
			} else if (e.keyCode == RIGHT || e.keyCode == D) {
			
				if (currMirror == MAX_MIRRORS-1) currMirror = 0;
				else currMirror++;
				
			} else if (e.keyCode == UP || e.keyCode == W) {
			
				if (currUpgrade == MAX_UPGRADES-1) currUpgrade = 0;
				else currUpgrade++;
			
			} else if (e.keyCode == DOWN || e.keyCode == S) {
				
				if (currUpgrade == 0) currUpgrade = MAX_UPGRADES-1;
				else currUpgrade--;
			
			} else if (e.keyCode == ENTER) {
				
				if (mirrorUpgradeLevels[currMirror] == currUpgrade &&
				    Score.money >= UPGRADE_COST[currUpgrade]) {
					buy();
				} 
			};
			moveTo(mover,mover.x,Mirror.MIRROR_X_POSITIONS[currMirror] - this.mover.width/2,'x');
			moveTo(mover.select,mover.select.y,UPGRADE_Y_POSITIONS[currUpgrade],'y');
			info.box.gotoAndStop('upgrade'+(currUpgrade+1));
			if (currUpgrade < mirrorUpgradeLevels[currMirror]) info.price.text = 'purchased';
			else info.price.text = '$' + UPGRADE_COST[currUpgrade];
			cash.text = String(Score.money);
			showUpgrades();
		}
		
		private function buy() {
			Score.money -= UPGRADE_COST[currUpgrade];
			mirrorUpgradeLevels[currMirror] += 1;
			if (currUpgrade == 0) {
				var mirror = new Mirror(-90,90,Mirror.MIRROR_X_POSITIONS[currMirror],Mirror.MIRROR_Y,true);
				mirror.setAI(MirrorAI.TRACK_NONE);
			} else {
				MirrorTarget.mirrorList[getMirrorIndex()].setAI(currUpgrade);
			}
		}
		
		private function getMirrorIndex():uint {
			var count:uint = 0;
			for (var i = 0; i < currMirror; i++) {
				if (mirrorUpgradeLevels[i] == 0) count++
			}
			return currMirror -  count;
		}
		
		private static function moveTo(obj,start,end,property:String,frames = MOVE_FRAMES) {
			var delta = end - start;
			var increment = delta/MOVE_FRAMES;
			var count = 0;
			obj.addEventListener(Event.ENTER_FRAME,enterFrame);
			function enterFrame(e) { 
				obj[property] += increment;
				count++;
				if (count >= frames) obj.removeEventListener(Event.ENTER_FRAME,enterFrame);
			}
		}
	}
	
}
