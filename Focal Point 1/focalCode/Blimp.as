package focalCode {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.display.Sprite;
	import fl.motion.Color;
	
	public class Blimp extends MovieClip {
		
		public static const MAX_SPEED = 5;
		public static const MIN_SPEED = 3;
		public static const MAX_Y = 150;
		public static const MIN_Y = 10;
		public static const MIN_SHOOT_TIME = 1000; //measured in mseconds, delays blimp from shooting right away
		public static const STAGE_WIDTH = 775;
		public static const STAGE_HEIGHT = 480;
		public static const GUN_WIDTH = 11; //can change, so update when needed!!!!!!!!!!!!!!!!
		public static const GUN_HEIGHT = 32;
		public static const BLIMP_HEIGHT = 52;
		public static const BLIMP_FALL_ACCELERATION = 1;
		public static const DEAD_ANGLE = 90;
		public static const SIDES = [1,-1]; //represent direction of blimp
		public static const MAX_HEALTH = 30;
		public static const BLIMP_HELP_DELAY = 32 //measured in frames
		
		private static var blimps:Vector.<Blimp> = new Vector.<Blimp>();
		private static var mirrorList:Array = [];
		private static var blimpTimer:Timer;
		private static var blimpParent;
		private static var blimpHelpDelayCount;
		//pause solution
		private static var oldTime:int;
		private static var newTime:int;
		private static var timeElapsed:int; //Time elapsed between pauses
		private static var defaultTimerTime:int; //What the timer resets to
		private static var timeLeft:int; //How much left before the Timer should fire
		//
		public var collided:Boolean;
		
		private var oldTimeG:int;
		private var newTimeG:int;
		private var timeElapsedG:int; 
		private var defaultTimerTimeG:int; 
		private var timeLeftG:int; 
		
		private var blimpHitColor:Color;
		private var fallRate;
		private var blimpBoundaries;
		private var speed;
		private var Y;
		private var target;
		private var shootTimer;
		private var health;
		private var dead:Boolean;
		private var side:int
		private var shot:Boolean;
		private var bullet:Bullet;
		
		
		public function Blimp() {
			if (!SavedData.data.seenBlimp) {
				SavedData.data.seenBlimp = true;
				SavedData.so.flush();
				blimpHelpDelayCount = 0;
			} 
			blimpHitColor = new Color();
			blimpHitColor.setTint(0xFF0000,0.2);
			side = SIDES[Math.round(Math.random())];
			Reflection.addCollisionObj(this);
			speed = getRandom(MIN_SPEED,MAX_SPEED) * side;
			this.balloon.scaleX = side;
			this.y = getRandom(MIN_Y,MAX_Y);
			if (side == 1) this.x = -this.width/2;
			else if (side == -1) this.x = STAGE_WIDTH + this.width/2;
			setTimer();
			blimps.push(this);
			mirrorList = Mirror.allMirrors;
			collided = false;
			health = MAX_HEALTH;
			dead = false;
			fallRate = 0;
			blimpBoundaries = addBoundaryPoints();
			this.addEventListener('remove',removeSmoke,false,0,true);
			shot = false;
		}
		
		public static function startDay(stage) {
			blimpParent = stage;
			var numBlimps = LevelHandler.BLIMPS_PER_DAY[Shading.currLevel];
			if (numBlimps == 0) return;
			defaultTimerTime = (LevelHandler.DAY_LENGTHS[(Shading.currDay-1) + LevelHandler.DAY_LEN_OFFSET[Shading.currLevel]] * 1000)/(numBlimps+1);
			blimpTimer = new Timer(defaultTimerTime,numBlimps);
			blimpTimer.addEventListener(TimerEvent.TIMER,spawnBlimp);
			blimpTimer.start();
			timeLeft = defaultTimerTime;
			oldTime = getTimer();
		}
			
		public static function pause() {
			if (!Shading.isDayTime) return;
			if (LevelHandler.BLIMPS_PER_DAY[Shading.currLevel] == 0) return;
			newTime = getTimer();
			blimpTimer.reset();
			timeElapsed = newTime - oldTime;
			timeLeft -= timeElapsed;
			try {
				blimpTimer.delay = timeLeft;
			} catch(e) {
				blimpTimer.delay = defaultTimerTime;
			}			
			
			for (var i = 0; i < blimps.length; i++) {
				var tb = blimps[i];
				if (tb.bullet) tb.bullet.removeEventListener(Event.ENTER_FRAME,tb.bulletMover);
				if (tb.shot) continue;
				tb.newTimeG = getTimer();
				tb.shootTimer.reset();
				tb.timeElapsedG = tb.newTimeG - tb.oldTimeG;
				tb.timeLeftG -= tb.timeElapsedG;
				try {
					tb.shootTimer.delay = tb.timeLeftG;
				} catch (e) {
					tb.shootTimer.delay = tb.defaultTimerTimeG;
				}
			}
		}
		
		public static function unpause() {
			if (LevelHandler.BLIMPS_PER_DAY[Shading.currLevel] == 0) return;
			if (!Shading.isDayTime) return;
			blimpTimer.start();
			oldTime = getTimer();
			
			for (var i = 0; i < blimps.length; i++) {
				var tb = blimps[i];
				tb.shootTimer.start();
				tb.oldTimeG = getTimer();
				if (tb.bullet) tb.bullet.addEventListener(Event.ENTER_FRAME,tb.bulletMover);
			}
		}
		
		public static function endDay() {
			for (var i = 0; i < blimps.length; i++) {
				blimpParent.removeChild(blimps[i]);
				Reflection.removeCollisionObj(blimps[i]);
			}
			if (blimpTimer) {
				blimpTimer.removeEventListener(TimerEvent.TIMER,spawnBlimp);
				blimpTimer = null;
			}
			blimps = new Vector.<Blimp>();
		}
		
		private function addBoundaryPoints() {
			var array = [];
			var positions = [[-this.width/2,this.width/2],[0,BLIMP_HEIGHT]];
			for (var i = 0; i < positions.length; i++) {
				for (var j =0; j < positions[i].length; j++) {
					var tempSprite = new Sprite();
					array.push(tempSprite);
					this.addChild(tempSprite);
					tempSprite.x = positions[0][i], tempSprite.y = positions[1][j];
				}
			}
			return array;
		}
		
		public function get boundaries() {
			var array = [];
			for (var i = 0; i < blimpBoundaries.length; i++) {
				array.push(this.localToGlobal(new Point(blimpBoundaries[i].x, blimpBoundaries[i].y)));
			}
			return array;
		}
		
		private static function spawnBlimp(e) {
			blimpTimer.reset();
			blimpTimer.delay = defaultTimerTime;
			timeLeft = defaultTimerTime;
			oldTime = getTimer();
			blimpTimer.start();
			
			blimpParent.addChild(new Blimp());
		}
		
		public static function updateBlimps() {
			if (blimpHelpDelayCount is Number) {
				blimpHelpDelayCount++;
				if (blimpHelpDelayCount >= BLIMP_HELP_DELAY) {
					blimpHelpDelayCount = null;
					Main.spawnBlimpHelp = true;	
				}
			}
			var length = blimps.length;
			var removed = [];
			for (var i = 0; i < length; i++) {
				var tempBlimp = blimps[i];
				if (tempBlimp.dead) {
					tempBlimp.y += tempBlimp.fallRate;
					tempBlimp.fallRate += BLIMP_FALL_ACCELERATION;
					tempBlimp.x += tempBlimp.speed;
					if (tempBlimp.y > STAGE_HEIGHT) {
						tempBlimp.removeEventListener(Event.ENTER_FRAME, tempBlimp.createSmoke);
						blimpParent.removeChild(tempBlimp);
						Reflection.removeCollisionObj(tempBlimp);
						tempBlimp.removeEventListener('remove',tempBlimp.removeSmoke);
						removed.push(tempBlimp);
					}
				} else {
					tempBlimp.x += tempBlimp.speed;
					tempBlimp.aimGun();
					if (tempBlimp.x > STAGE_WIDTH + tempBlimp.width/2 ||
					    tempBlimp.x < -tempBlimp.width/2) {
						tempBlimp.removeEventListener('remove',tempBlimp.removeSmoke);
						blimpParent.removeChild(tempBlimp);
						Reflection.removeCollisionObj(tempBlimp);
						removed.push(tempBlimp);
					}
				}
			}
			for (var j = 0; j < removed.length; j++) {
				blimps.splice(blimps.indexOf(removed[j]),1);
			}
		}
		
		private function aimGun() {
			if (!target) target = mirrorList[Math.round(getRandom(0,mirrorList.length-1))];
			var localMirrorPoint = this.globalToLocal(new Point(target.x,target.y));
			var angle = Math.atan2(gun.y - localMirrorPoint.y, gun.x - localMirrorPoint.x);
			gun.rotation = 90 + (angle * 180/Math.PI);
		}
		
		private function shootGun(e) {
			e.target.removeEventListener(TimerEvent.TIMER,shootGun);
			if (blimpParent.contains(this)) {
				bullet = new Bullet(gun.rotation,target,GUN_WIDTH);
				this.stage.addChild(bullet);
				var gunPoint = gun.localToGlobal(new Point(GUN_WIDTH/2,GUN_HEIGHT));
				bullet.x = gunPoint.x, bullet.y = gunPoint.y;
				bullet.addEventListener(Event.ENTER_FRAME,bulletMover);
			}
			shot = true;
		}
		
		private function bulletMover(e) {
			if (!blimpParent.contains(this)) {
				bullet.removeEventListener(Event.ENTER_FRAME,bulletMover);
				if (blimpParent.contains(bullet)) blimpParent.removeChild(bullet);
				return;
			}
			if (bullet.target.top.hitTestObject(bullet)) {
				bullet.target.dispatchEvent(new Event('mirrorHit'));
				if (blimpParent.contains(bullet)) blimpParent.removeChild(bullet);
				bullet.removeEventListener(Event.ENTER_FRAME,bulletMover);
			}
			bullet.x += Math.cos(bullet.angle) * Bullet.SPEED;
			bullet.y -= Math.sin(bullet.angle) * Bullet.SPEED;
		}
		
		private function setTimer() {
			var screenTime = STAGE_WIDTH/Math.abs(speed); //measured in frames
			screenTime = screenTime/LevelHandler.FRAME_RATE * 1000; //in miliseconds
			screenTime *= 1 - (0.5 * (Shading.currLevel/LevelHandler.NUM_LEVELS));
			defaultTimerTimeG = getRandom(MIN_SHOOT_TIME,screenTime);
			timeLeftG = defaultTimerTimeG;
			shootTimer = new Timer(defaultTimerTimeG,1);
			shootTimer.start();
			shootTimer.addEventListener(TimerEvent.TIMER,shootGun);
			oldTimeG = getTimer();
		}
		
		private function getRandom(min,max) {
			return Math.random() * (max - min) + min;
		}
		
		public function get life() {
			return health;
		}
		
		public function resetTint() {
			var normal = new Color();
			normal.setTint(0xFFFFFF,0);
			this.balloon.transform.colorTransform = normal;
		}
		
		public function set life(newLife) {
			if (health <= 0) {
				kill();
			}
			else {
				health = newLife;
				this.balloon.transform.colorTransform = blimpHitColor;
			}
		}
		
		private function kill() {
			if (!dead) {
				var normalColor:Color = new Color();
				normalColor.setTint(0xFFFFFF,0);
				this.balloon.transform.colorTransform = normalColor;
				dead = true;
				animateTo(this,0,DEAD_ANGLE,'rotation',18);
				shootTimer.removeEventListener(TimerEvent.TIMER,shootGun);
				//addEventListener(Event.ENTER_FRAME, createSmoke,false,0,true);  <--------smoke problem begins here...
			}
		}
		
		private function createSmoke(e) {
			var smoke = new Smoke(this);
			smoke.x = this.x, smoke.y = this.y;
			blimpParent.addChild(smoke);
		}
		
		private function removeSmoke(e) {
			if (blimpParent.contains(e.target)) blimpParent.removeChild(e.target);
		}
		
		private static function animateTo(obj,start,end, prop:String,frames) {
			var delta = end - start;
			var increment = delta/frames;
			var count = 0;
			obj.addEventListener(Event.ENTER_FRAME,enterFrame);
			function enterFrame(e) { 
				obj[prop] += increment;
				count++;
				if (count >= frames) obj.removeEventListener(Event.ENTER_FRAME,enterFrame);
			}
		}
	}
	
}
