package focalCode {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	public class Main extends MovieClip {
		
		private static const MIRROR_INDEX = 8; //?
		private static const SECOND_MIRROR_LEVEL = 3; //for help file
		private static const INIT_BG_VOLUME = 0.5;
		private static const FADE_REPEAT = 10;
		public static var spawnBlimpHelp:Boolean = false;
		
		private var hud:HUD;
		private var sky:Sky;
		private var luminary:Luminaries;
		private var waterTank:WaterTank;
		private var tower:Tower;
		private var mirrorTarget:MirrorTarget;
		private var levelStats:LevelStats;
		private var helpFile:HelpFile;
		private var secondHelpFile:SecondHelp;
		private var thirdHelpFile:ThirdHelp;
		private var fourthHelpFile:FourthHelp;
		private var backgroundMusic:BackgroundMusic;
		private var isMuted:Boolean;
		private var bgInitVolume:SoundTransform;
		private var bgMusicChannel:SoundChannel;
		
		private var soundFadeTimer:Timer;
		private var volumeFade;
		
		private var framesPlayedInLevel:uint; //used for accuracy
		private var sunStopped:Boolean //used in helpFile
		
		private var eventDispatcher;
		public function Main() {
			isMuted = false;
			volumeFade = INIT_BG_VOLUME;
			soundFadeTimer = new Timer(100,FADE_REPEAT);
			backgroundMusic = new BackgroundMusic();
			bgInitVolume = new SoundTransform(INIT_BG_VOLUME,0);
			sunStopped = false;
			eventDispatcher = new Sprite();
			addChild(eventDispatcher);
			Shading.setDispatcher(eventDispatcher);
			addEventListener('startGame',startGame);
			addEventListener('remove',remove);
			addEventListener('toggleSun',toggleSunMovement);
			addEventListener('quit',quitgame);
			addEventListener('nextLevel',startLevel);
			addEventListener('blimpHelpOver',blimpHelpOver);
			addEventListener('firstHelpDone',tutorialOver);
			addEventListener('gameDone',quitgame);
			soundFadeTimer.addEventListener(TimerEvent.TIMER,fadeMusic);
			soundFadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,fadeComplete);
			//SavedData
			SavedData.init();
		}
		
		private function tutorialOver(e) {
			Score.score = LevelHandler.LEVEL_QUOTAS[Shading.currLevel];
		}
		
		private function fadeMusic(e) {
			volumeFade -= INIT_BG_VOLUME/FADE_REPEAT;
			var vol:SoundTransform = new SoundTransform(volumeFade,0);
			bgMusicChannel.soundTransform = vol;
		}
		
		private function fadeComplete(e) {
			volumeFade = INIT_BG_VOLUME;
			bgMusicChannel.stop();
		}
		
		private function blimpHelpOver(e) {
			Blimp.unpause();
			addEventListener(Event.ENTER_FRAME,enterFrame);
		}
		
		private function remove(e) {
			if (this.contains(e.target)) removeChild(e.target);
		}
		
		private function toggleSunMovement(e) {
			if (sunStopped) sunStopped = false;
			else sunStopped = true;
		}
		
		private function startGame(e) {
			//help
			helpFile = new HelpFile();
			secondHelpFile = new SecondHelp();
			thirdHelpFile = new ThirdHelp();
			fourthHelpFile = new FourthHelp();
			//hud
			hud = new HUD();
			//sky 
			sky = new Sky();
			//levelStats
			levelStats = new LevelStats();
			levelStats.x = -levelStats.width;
			//tower
			tower = new Tower();
			tower.x = 325;
			//waterTank
			waterTank = new WaterTank();
			waterTank.x = 325, waterTank.y = 31;
			
			//mirrorTarget
			mirrorTarget = new MirrorTarget(stage);
			mirrorTarget.x = MirrorTarget.MT_X, mirrorTarget.y = MirrorTarget.MT_Y;
			Mirror.setTarget(mirrorTarget);
			Mirror.mirrorHolder.x = 0, Mirror.mirrorHolder.y = 0;
			//luminaries
			luminary = new Luminaries(Luminaries.LUM_X,Luminaries.LUM_Y,mirrorTarget);
			luminary.x = Luminaries.LUM_X, luminary.y = Luminaries.LUM_Y;
			//display list order
			addChild(sky);
			
			
			addChild(luminary);
			addChild(tower);
			addChild(Mirror.mirrorHolder);
			addChild(mirrorTarget);
			addChild(waterTank);
			addChild(hud);
			addChild(levelStats);
			startLevel();
		}
		
		private function loadgame(num = null) {
			if (num) Shading.currLevel = num;
			else Shading.currLevel = SavedData.data.currLevel; 
		}
		
		private function newgame() {
			SavedData.so.clear();
			SavedData.init();
		}
	
		private function quitgame(e=null) {
			removeChild(mirrorTarget);
			removeChild(luminary);
			removeChild(tower);
			removeChild(Mirror.mirrorHolder);
			removeChild(waterTank);
			removeChild(levelStats);
			removeChild(sky);
			removeChild(hud);
			if (this.contains(helpFile)) removeChild(helpFile);
			if (this.contains(secondHelpFile)) removeChild(secondHelpFile);
			if (this.contains(thirdHelpFile)) removeChild(thirdHelpFile);
			if (this.contains(fourthHelpFile)) removeChild(fourthHelpFile);
			Blimp.endDay();
			waterTank.endDay();
			waterTank.reset();
			Score.reset();
			Reflection.reset();
			Reflection.endDay();
			Mirror.reset();
			Shading.reset();
			
			if (e) gotoAndStop('main');
		}
		
		private function setDayText() {
			if (Shading.currLevel == 0 || Shading.currLevel == SECOND_MIRROR_LEVEL) return;
			Lang.trans(Lang.START,hud.levelText,0x009900,'header', null, true);
			animateTo(hud.levelText,1,0,'alpha',48,resetLevelText,24);
			function resetLevelText() {
				hud.levelText.text = '';
				hud.levelText.alpha = 1;
			}
			if (LevelHandler.DAYS_PER_LEVEL[Shading.currLevel] > 1) {
				Lang.trans(Lang.DAY,hud.dayText,0x009900,'header', null, true);
				if (Lang.language == Lang.EN) hud.dayText.appendText(' ' + Shading.currDay + '/' + LevelHandler.DAYS_PER_LEVEL[Shading.currLevel]);
				else if (Lang.language == Lang.HE) hud.dayText.text = Shading.currDay + '/' + LevelHandler.DAYS_PER_LEVEL[Shading.currLevel] + ' ' + hud.dayText.text;
				animateTo(hud.dayText,1,0,'alpha',48,resetDayText,24);
				function resetDayText() {
					hud.dayText.text = '';
					hud.dayText.alpha = 1;
				}
			}
		}
		
		private function setEndDayText() {
			if (LevelHandler.DAYS_PER_LEVEL[Shading.currLevel] > 1) {
				Lang.trans(Lang.DAY_OVER,hud.dayText,0x009900,'header', null, true);
				animateTo(hud.dayText,1,0,'alpha',48,resetDayText,24);
				function resetDayText() {
					hud.dayText.text = '';
					hud.dayText.alpha = 1;
				}
			}
		}
		
		private function startDay(e=null) {
			if (!isMuted) {
				bgMusicChannel = backgroundMusic.play();
				bgMusicChannel.soundTransform = bgInitVolume;
			}
			setDayText();
			var dayLen = LevelHandler.DAY_LENGTHS[Shading.currDay-1 + LevelHandler.DAY_LEN_OFFSET[Shading.currLevel]];
			luminary.setRotSpeed(dayLen);
			if (e) {
				removeEventListener('day',startDay);
			}
			mirrorTarget.startDay();
			Mirror.startDay();
			Blimp.startDay(stage);
			addEventListener('night',endDay);
		}
		
		private function endDay(e=null) {
			soundFadeTimer.start();
			setEndDayText();
			removeEventListener('night',endDay);
			Mirror.endDay();
			mirrorTarget.endDay();
			Blimp.endDay();
			Reflection.endDay();
			waterTank.endDay();
			if (Shading.currDay == LevelHandler.DAYS_PER_LEVEL[Shading.currLevel]) {
				waterTank.reset();
				endLevel();
			} else {  //prepare for next day...
				luminary.setRotSpeed(LevelHandler.NIGHT_LENGTH);
				addEventListener('day',startDay);
			}
		}
		
		private function soundFadeOut(e) {
			
		}
		
		private function startLevel(e=null) {
			animateTo(levelStats,levelStats.x,-levelStats.width,'x',12);
			if (Shading.currLevel == 0) {
				addChild(helpFile);
			} else if (Shading.currLevel == SECOND_MIRROR_LEVEL) {
				secondHelpFile = new SecondHelp();
				addChild(secondHelpFile);
			}
			for (var j = 0; j < LevelHandler.MIRRORS_PER_LEVEL[Shading.currLevel]; j++) {
				var mirror = new Mirror(-90,90,Mirror.MIRROR_SPAWN_POSITIONS[j],Mirror.MIRROR_Y,false,luminary);
			}
			framesPlayedInLevel = 0;
			luminary.setDay(1);  //reset
			if (Shading.currLevel == LevelHandler.NUM_LEVELS) {
				gameOver();
				return;
			}
			addEventListener(Event.ENTER_FRAME, enterFrame);
			luminary.setRotSpeed(LevelHandler.PRE_LEVEL_SUN_SPEED);
			addEventListener('day',startDay);
			hud.total.text = String(LevelHandler.LEVEL_QUOTAS[Shading.currLevel]) + 'kW';
			hud.score.text = '0';
			if (Shading.currLevel != 0 && Shading.currLevel != SECOND_MIRROR_LEVEL) {
				Lang.trans(Lang.LEVEL,hud.levelText,0xCCCCCC,'header',null,true);
				if (Lang.language == Lang.EN) hud.levelText.appendText(' ' + Shading.currLevel);
				else if (Lang.language == Lang.HE) hud.levelText.text = Shading.currLevel + ' ' + hud.levelText.text; 
			}
		}
		
		private function endLevel() {
			for (var j = Mirror.mirrorHolder.numChildren-1; j >= 0; j--) {
				var mirror = Mirror.mirrorHolder.getChildAt(j) as Mirror;
				mirror.remove();
			}
			if (this.contains(helpFile)) removeChild(helpFile);
			else if (this.contains(secondHelpFile)) removeChild(secondHelpFile);
			else if (this.contains(thirdHelpFile)) removeChild(thirdHelpFile);
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			setLevelStats(); //must be before hasWonLevel()
			Reflection.endLevel();
			if (hasWonLevel()) levelWon();
			else levelLost();
			Score.score = 0; //reset for next level
		}
		
		private function enterFrame(e:Event):void {
			if (spawnBlimpHelp) {
				spawnBlimpHelp = false;
				addChild(thirdHelpFile);
				thirdHelpFile.play();
				removeEventListener(Event.ENTER_FRAME,enterFrame);
				Blimp.pause();
			}
			if (!sunStopped) {
				Shading.updateTime();
				luminary.updateLuminaries();
				sky.update(-luminary.degrees);
			} else {
				if (waterTank.boiling) {
					helpFile.dispatchEvent(new Event('good job'));
				} 
			}
			if (mirrorTarget.keyPressed) {
				helpFile.dispatchEvent(new Event('rotated'));
			}
			if (Shading.isDayTime) {
				Mirror.updateAngle();
				mirrorTarget.updateMirrorTarget();
				Reflection.checkCollisions();
				
				Blimp.updateBlimps();
				if (Score.score >= LevelHandler.LEVEL_QUOTAS[Shading.currLevel]) { //reached quota
					luminary.setRotSpeed(LevelHandler.DAY_FAST_LENGTH);
					Reflection.quotaReached = true;
					if (sunStopped) sunStopped = false;
				} else {
					framesPlayedInLevel++;
					Score.updateScore();
					waterTank.updateWaterTank();
				}
				hud.score.text = String(Score.score);
			}
		}
		
		private function hasWonLevel() {
			if (Score.score >= LevelHandler.LEVEL_QUOTAS[Shading.currLevel]) return true;
			else return false;
		}
		
		private function levelLost() {
			Lang.trans(Lang.LEVEL_LOST, levelStats.completedText, 0xCCCCCC, 'header', null, true);
			Lang.trans(Lang.RESTART, levelStats.next_level.text,null,'title', null, true);
		}
		
		private function levelWon() {
			Lang.trans(Lang.LEVEL_COMPLETE, levelStats.completedText, 0xCCCCCC, 'header', null, true);
			Lang.trans(Lang.NEXT_LEVEL, levelStats.next_level.text,null,'title', null, true);
			Shading.currLevel++;
			SavedData.saveData(Shading.currLevel);
		}
		
		private function gameOver() {
			addChild(fourthHelpFile);
			
		}
		
		private function setLevelStats() {
			levelStats.x = -levelStats.width;
			animateTo(levelStats,levelStats.x,0,'x',12);
			Score.accuracy = Math.round((Reflection.totalNumCollisions/(framesPlayedInLevel * LevelHandler.MIRRORS_PER_LEVEL[Shading.currLevel])) * 100);
			var levelTime = framesPlayedInLevel/LevelHandler.FRAME_RATE;
			var maxLevelTime = 0;
			for (var i = 0; i < LevelHandler.DAYS_PER_LEVEL[Shading.currLevel]; i++) {
				maxLevelTime += LevelHandler.DAY_LENGTHS[i + LevelHandler.DAY_LEN_OFFSET[Shading.currLevel]];
			}
			Score.timeBonus = Math.round((maxLevelTime - levelTime)*10)/10;
			if (Shading.currLevel != 0) {
				Lang.trans(Score.accuracy, levelStats.accuracy, null, 'title', 'acc', true);
				Lang.trans(Score.timeBonus, levelStats.timeBonus, null, 'title', 'time', true);
			} else {
				levelStats.accuracy.text = '--%';
				levelStats.timeBonus.text = '--';
			}
		}
		
		private function animateTo(obj,start,end, prop:String,frames,func=null,delay=null) {
			var delta = end - start;
			var increment = delta/frames;
			var count = 0;
			obj.addEventListener(Event.ENTER_FRAME,enterFrame);
			var delayCount = 0;
			function enterFrame(e) {
				if (delay) {
					delayCount++;
					if (delayCount < delay) return;
				}
				obj[prop] += increment;
				count++;
				if (count >= frames) {
					obj.removeEventListener(Event.ENTER_FRAME,enterFrame);
					if (func) func();
				}
			}
		}
	}
	
}
