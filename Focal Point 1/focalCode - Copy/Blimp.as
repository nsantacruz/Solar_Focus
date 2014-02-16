package focalCode {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Sprite;
	
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
		public static const DEAD_ANGLE = 50;
		public static const SIDES = [1,-1]; //represent direction of blimp
		public static const MAX_HEALTH = 35;
		
		private static var blimps:Vector.<Blimp> = new Vector.<Blimp>();
		private static var mirrorList:Array = [];
		private static var blimpTimer:Timer;
		private static var blimpParent;
		
		public var collided:Boolean;
		
		private var fallRate;
		private var blimpBoundaries;
		private var speed;
		private var Y;
		private var target;
		private var shootTimer;
		private var health;
		private var dead:Boolean;
		private var side:int
		
		public function Blimp() {
			side = SIDES[Math.round(Math.random())];
			Reflection.addCollisionObj(this);
			speed = getRandom(MIN_SPEED,MAX_SPEED) * side; //workin on which side blimp will spawn on, future Noah :)
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
		}
		
		public static function startDay(stage) {
			blimpParent = stage;
			var numBlimps = LevelHandler.BLIMP_NUMS[Shading.currDay-1];
			var interval = (LevelHandler.DAY_LENGTH_LIST[Shading.currDay-1] * 1000)/(numBlimps+1);
			blimpTimer = new Timer(interval,numBlimps);
			blimpTimer.addEventListener(TimerEvent.TIMER,spawnBlimp);
			blimpTimer.addEventListener(TimerEvent.TIMER_COMPLETE,timerComplete);
			blimpTimer.start();
		}
		
		public static function endDay() {
			for (var i = 0; i < blimps.length; i++) {
				blimpParent.removeChild(blimps[i]);
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
			blimpParent.addChild(new Blimp());
		}
		
		private static function timerComplete(e) {
			blimpTimer.removeEventListener(TimerEvent.TIMER,spawnBlimp);
			blimpTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,timerComplete);
		}
		
		public static function updateBlimps() {
			var length = blimps.length;
			var removed = [];
			for (var i = 0; i < length; i++) {
				var tempBlimp = blimps[i];
				if (tempBlimp.dead) {
					tempBlimp.y += tempBlimp.fallRate;
					tempBlimp.fallRate += BLIMP_FALL_ACCELERATION;
					tempBlimp.x += tempBlimp.speed;
					if (tempBlimp.y > STAGE_HEIGHT) {
						blimpParent.removeChild(tempBlimp);
						removed.push(tempBlimp);
					}
				} else {
					tempBlimp.x += tempBlimp.speed;
					tempBlimp.aimGun();
					if (tempBlimp.x > STAGE_WIDTH + tempBlimp.width/2 ||
					    tempBlimp.x < -tempBlimp.width/2) {
						blimpParent.removeChild(tempBlimp);
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
				
			
				var bullet = new Bullet(gun.rotation,target,GUN_WIDTH);
				this.stage.addChild(bullet);
				var gunPoint = gun.localToGlobal(new Point(GUN_WIDTH/2,GUN_HEIGHT));
				bullet.x = gunPoint.x, bullet.y = gunPoint.y;
				bullet.addEventListener(Event.ENTER_FRAME,bulletMover);
			}
		}
		
		private function bulletMover(e) {
			var bullet = e.target;
			if (bullet.target.top.hitTestObject(bullet)) {
				bullet.target.dispatchEvent(new Event('mirrorHit'));
				blimpParent.removeChild(bullet);
				bullet.removeEventListener(Event.ENTER_FRAME,bulletMover);
			}
			bullet.x += Math.cos(bullet.angle) * Bullet.SPEED;
			bullet.y -= Math.sin(bullet.angle) * Bullet.SPEED;
		}
		
		private function setTimer() {
			var screenTime = STAGE_WIDTH/Math.abs(speed); //measured in frames
			screenTime = screenTime/LevelHandler.FRAME_RATE * 1000; //in miliseconds
			var shootTime = getRandom(MIN_SHOOT_TIME,screenTime);
			shootTimer = new Timer(shootTime,1);
			shootTimer.start();
			shootTimer.addEventListener(TimerEvent.TIMER,shootGun);
		}
		
		private function getRandom(min,max) {
			return Math.random() * (max - min) + min;
		}
		
		public function get life() {
			return health;
		}
		
		public function set life(newLife) {
			if (health <= 0) kill();
			else health = newLife;;
		}
		
		private function kill() {
			dead = true;
			animateTo(this,0,DEAD_ANGLE,'rotation',24);
			shootTimer.removeEventListener(TimerEvent.TIMER,shootGun);
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
