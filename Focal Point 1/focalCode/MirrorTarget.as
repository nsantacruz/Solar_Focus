package focalCode {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.Sprite;
	
	public class MirrorTarget extends MovieClip {
		
		
		public static const SPOTLIGHT_ALPHA = 0.5;
		public static const SWITCH_KEYS = [37,39]; //left and right arrows
		public static const ROTATE_KEYS = [65,68]; //a and d
		public static const SMALL_RADIUS = 100;
		public static const LARGE_RADIUS = 100;
		public static const ROTATE_FRAMES = 4;
		public static const MIRROR_FADED = 0.5;
		public static const MT_X = 387.5;
		public static const MT_Y = 480; 
		
		public var currMirror;
		public static var mirrorList:Vector.<Mirror>;
		
		private var currMirrorPoint:Point;
		
		public var keyPressed:Boolean;
		private var keySide:int;
		
		public function MirrorTarget(stage) {
			spotlight.visible = false;
			mirrorList = new Vector.<Mirror>();
			
			
			keyPressed = false;
			keySide = 1;
		}
		
		public function updateMirrorTarget() {
			if (currMirror) {
				if (keyPressed) {
					currMirror.rotateSpeed += Mirror.ROT_ACCELERATION * keySide;
					if (currMirror.rotateSpeed >= Mirror.MAX_ROT_SPEED) {
						currMirror.rotateSpeed = Mirror.MAX_ROT_SPEED;
					} else if (currMirror.rotateSpeed <= -Mirror.MAX_ROT_SPEED) {
						currMirror.rotateSpeed = -Mirror.MAX_ROT_SPEED;
					}
				} else {
					currMirror.rotateSpeed = 0;
				}
				currMirror.top.rotation += currMirror.rotateSpeed;
				if (currMirror.top.rotation >= currMirror.rLimit) currMirror.top.rotation = currMirror.rLimit;
				if (currMirror.top.rotation <= currMirror.lLimit) currMirror.top.rotation = currMirror.lLimit;
			}
			
		}
		
		
		
		private function keyDown(e:KeyboardEvent):void {
			if (currMirror && currMirror.mirrorAI.aiLevel != MirrorAI.TRACK_ELLIPTICALLY) {
				var index = mirrorList.indexOf(currMirror);
				if (e.keyCode == SWITCH_KEYS[0]) { //left
					disableMirror(currMirror); //set prev to faded
					if (index != 0) setCurrMirror(mirrorList[index-1]);
					else setCurrMirror(mirrorList[mirrorList.length-1]); //loop to last mirror
				}
				else if (e.keyCode == SWITCH_KEYS[1]) { //right
					disableMirror(currMirror); //set prev to faded
					if (index != mirrorList.length - 1) setCurrMirror(mirrorList[index+1]);
					else setCurrMirror(mirrorList[0]);
				}
				else if (e.keyCode == ROTATE_KEYS[0]) {
					keyPressed = true;
					keySide = -1;
				}
				else if (e.keyCode == ROTATE_KEYS[1]) {
					keyPressed = true;
					keySide = 1;
				}
			}
		}
		
		private function disableMirror(mirror:Mirror) {
			mirror.lightRay.alpha = MIRROR_FADED;
			mirror.stand.alpha = MIRROR_FADED;
		}
		
		private function enableMirror(mirror:Mirror) {
			mirror.lightRay.alpha = 1;
			mirror.stand.alpha = 1;
		}
		
		private function keyUp(e:KeyboardEvent) {
			keyPressed = false;
		}
		
		public function addMirror(mirror:Mirror,upgraded=false) {
			mirrorList.push(mirror);
			mirrorList.sort(sortMirrors);
			if (!upgraded) {
				for (var i = 0; i < mirrorList.length; i++) {
					disableMirror(mirrorList[i]);
				}
				setCurrMirror(mirrorList[0]);
			}
		}
		
		public function removeMirror(mirror:Mirror) {
			mirrorList.splice(mirrorList.indexOf(mirror),1);
			mirrorList.sort(sortMirrors);
			for (var i = 0; i < mirrorList.length; i++) {
				disableMirror(mirrorList[i]);
			}
			if (mirrorList.length >= 1) setCurrMirror(mirrorList[0]);
			else {
				currMirror = null;
				currMirrorPoint = null;
			}
		}
		
		private function sortMirrors(a,b) {
			if (a.x > b.x) return 1;
			if (a.x < b.x) return -1;
			return 0;
		}
		
		private function setCurrMirror(mirror:Mirror) {
			currMirror = mirror;
			if (currMirror) {
				currMirrorPoint = globalToLocal(new Point(currMirror.x, currMirror.y));
				enableMirror(currMirror);
				spotlight.x = currMirrorPoint.x - spotlight.width/2;
				spotlight.y = currMirrorPoint.y - 30;//??
			} 
		}
		
		
		
		public function endDay() {
			this.visible = false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUp);
			keyPressed = false
			for (var i = 0; i < mirrorList.length; i++) {
				enableMirror(mirrorList[i]);
			}
		}
		
		public function startDay() {
			this.visible = true;
			if (LevelHandler.MIRRORS_PER_LEVEL[Shading.currLevel] <= 1) this.spotlight.visible = false;
			else this.spotlight.visible = true;
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUp);
			for (var i = 0; i < mirrorList.length; i++) {
				disableMirror(mirrorList[i]);
			}
			if (mirrorList.length >= 1) setCurrMirror(mirrorList[0]);
		}
	}
	
}
