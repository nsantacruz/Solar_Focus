package focalCode {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	
	public class Main extends MovieClip {
		
		private static const MIRROR_INDEX = 8;
	
		private var luminary:Luminaries;
		private var waterTank:WaterTank;
		private var mirrorTarget:MirrorTarget;
		private var upgradeGUI:UpgradeGUI;
		private var currLevel = 1;
		
		private var eventDispatcher;
		public function Main() {
			eventDispatcher = new Sprite();
			addChild(eventDispatcher);
			addChild(new FPSCounter());
			Shading.setDispatcher(eventDispatcher);
			init();
		}
		
		private function init() {
			//tower
			var tower = new Tower();
			tower.x = 325;
			//waterTank
			waterTank = new WaterTank();
			waterTank.x = 325, waterTank.y = 31;
			//upgradeGUI
			upgradeGUI = new UpgradeGUI(stage);
			//luminaries
			luminary = new Luminaries(387.5,380);
			luminary.x = Luminaries.LUM_X, luminary.y = Luminaries.LUM_Y;
			//mirrorTarget
			mirrorTarget = new MirrorTarget(stage);
			mirrorTarget.x = MirrorTarget.MT_X, mirrorTarget.y = MirrorTarget.MT_Y;
			Mirror.setTarget(mirrorTarget);
			//SavedData
			SavedData.init();
			if (!SavedData.data.playedBefore) {
				for (var i = 0; i < SavedData.data.allMirrors.length; i++) {
					trace(SavedData.data.allMirrors[i]);
					var tm = SavedData.data.allMirrors[i];
					var temp = new Mirror(-90,90,tm.x,Mirror.MIRROR_Y,false,luminary);
					temp.setAI(tm.ai);
				}
				Score.money = SavedData.data.money+10000;
				currLevel = SavedData.data.currLevel;
				luminary.setDay(currLevel); 
			} else {
				//first mirror
				for (var j = 2; j < 4; j++) {
					var mirror = new Mirror(90,-90,Mirror.MIRROR_X_POSITIONS[j],Mirror.MIRROR_Y,false,luminary);
					mirror.setAI(MirrorAI.TRACK_ELLIPTICALLY);
				}
			}
			Mirror.mirrorHolder.x = 0, Mirror.mirrorHolder.y = 0;
			//display list order
			addChild(luminary);
			addChild(tower);
			addChild(Mirror.mirrorHolder);
			addChild(mirrorTarget); 
			addChild(waterTank);
			trace(getChildIndex(Mirror.mirrorHolder));
			startLevel();
			addEventListener('remove',removeChildren);
		}
		
		private function startLevel(e=null) {
			currLevel = Shading.currDay;
			luminary.setRotSpeed(LevelHandler.DAY_LENGTH_LIST[currLevel-1]);
			addEventListener(Event.ENTER_FRAME,enterFrame);
			
			if (hasWon()) gameWon();
			if (e) {
				removeChild(upgradeGUI);
				upgradeGUI.deactivate();
				setChildIndex(Mirror.mirrorHolder,MIRROR_INDEX);
				removeEventListener('day',startLevel);
				mirrorTarget.startDay();
			}
			Blimp.startDay(stage);
			levelTxt.text = currLevel;
			addEventListener('night',endLevel);
		}
		
		private function endLevel(e=null) {
			if (e) {
				addChild(upgradeGUI);
				setChildIndex(Mirror.mirrorHolder,this.numChildren-1);
				upgradeGUI.activate();
				luminary.setRotSpeed(LevelHandler.NIGHT_LENGTH);
				removeEventListener('remove',removeChildren);
				removeEventListener('night',endLevel);
				Mirror.endDay();
				mirrorTarget.endDay();
				Blimp.endDay();
				waterTank.endDay();
				Score.scoreToMoney();
				if (currLevel == LevelHandler.NUM_LEVELS) gameOver(); //gameOver, duh
				else {
					if (hasWonLevel()) levelWon();
					else levelLost();
				}
				Score.score = 0; //reset for next day
				
			}
			addEventListener('day',startLevel);
		}
		
		private function enterFrame(e:Event):void {
			Shading.updateTime();
			luminary.updateLuminaries();
			if (Shading.isDayTime) {
				Mirror.updateAngle();
				mirrorTarget.updateMirrorTarget();
				Reflection.checkCollisions();
				Score.updateScore();
				waterTank.updateWaterTank();
				Blimp.updateBlimps();
				score.text = String(Score.score);
			}
		}
		
		private function removeChildren(e) {
			trace('yo');
			if (this.contains(e.target)) removeChild(e.target);
			else trace('rejected');
		}
		
		private function hasWonLevel() {
			if (Score.score >= LevelHandler.LEVEL_QUOTAS[currLevel-1]) return true;
			else return false;
		}
		
		private function levelLost() {
			trace('level lost');
			luminary.degrees += 360; //go back one day so that you repeat previous day. loser
		}
		
		private function levelWon() {
			trace('level won');
			SavedData.saveData(Mirror.allMirrors,currLevel,Score.money);
		}
		
		private function gameOver() {
			trace('gameOver sucker');
			//removeEventListener(Event.ENTER_FRAME,enterFrame);
			
		}
		
		private function gameWon() {
			trace('yay');
		}
		
		private function hasWon() {
			if (Mirror.allMirrors.length == LevelHandler.MAX_MIRRORS) {
				for (var i = 0; i < Mirror.allMirrors.length; i++) {
					if (Mirror.allMirrors[i].mirrorAI.aiLevel != MirrorAI.TRACK_ELLIPTICALLY) {
						//not at highest ai level
						return false;
					}
				}
			} else return false;
			return true;
		}
	}
	
}
