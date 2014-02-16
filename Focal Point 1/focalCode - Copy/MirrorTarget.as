package focalCode {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.Sprite;
	
	public class MirrorTarget extends MovieClip {
		
		public static const TARGET_ALPHA = 0.5;
		public static const SPOTLIGHT_ALPHA = 0.5;
		public static const KEYBOARD_KEYS = [37,65,39,68]; //a and d
		public static const SMALL_RADIUS = 100;
		public static const LARGE_RADIUS = 100;
		public static const ROTATE_FRAMES = 4;
		public static const MIRROR_FADED = 0.5;
		public static const MT_X = 387.5;
		public static const MT_Y = 480; 
		
		public var currAngle;
		public var currMirror;
		public static var mirrorList:Vector.<Mirror>;
		
		private var currMirrorPoint:Point;
		private var sunRayLeft:Sprite;
		private var sunRayRight:Sprite;
		private var mSPL,mSPR,sSPL,sSPR; //represent four points of sunRay
		
		public function MirrorTarget(stage) {
			currAngle = 0;
			//target.alpha = TARGET_ALPHA;
			spotlight.alpha = SPOTLIGHT_ALPHA;
			spotlight.visible = false; //spotlight might be totally useless
			stage.addEventListener(MouseEvent.CLICK,mouseClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			mirrorList = new Vector.<Mirror>;
			sunRayLeft = new Sprite();
			sunRayRight = new Sprite();
			addChild(sunRayLeft);
			addChild(sunRayRight);
		}
		
		public function updateMirrorTarget() {
			var radians = getMouseAngle();
			currAngle = radians;
			if (currMirror) {
				target.x = Math.cos(radians) * LARGE_RADIUS + currMirrorPoint.x;
				target.y = -Math.sin(radians) * SMALL_RADIUS + currMirrorPoint.y;
				updateSunRay();
			}
		}
		
		private function updateSunRay() {
			var localSunPoint = localToLocal(Mirror.lum,currMirror,Mirror.lum.sun);
			var mirrorSunAngle = -Math.atan2(localSunPoint.y,localSunPoint.x);
			Mirror.lum.sun.rotation = (Math.PI/2-mirrorSunAngle) * 180/Math.PI;
				
			mSPL = localToLocal(currMirror.top,this,currMirror.sunPointList[0]);
			sSPL = localToLocal(Mirror.lum.sun,this,Mirror.lum.sunPointList[0]);
			mSPR = localToLocal(currMirror.top,this,currMirror.sunPointList[1]);
			sSPR = localToLocal(Mirror.lum.sun,this,Mirror.lum.sunPointList[1]);
			removeChild(sunRayLeft);
			removeChild(sunRayRight);
			sunRayLeft = new Sprite();
			sunRayLeft.graphics.moveTo(mSPL.x,mSPL.y);
			sunRayLeft.graphics.lineStyle(3,LightRay.LR_COLOR,currMirror.lightRay.outerSprite.getChildAt(0).alpha);
			sunRayLeft.graphics.lineTo(sSPL.x,sSPL.y);
			addChild(sunRayLeft);
				
			sunRayRight = new Sprite();
			sunRayRight.graphics.moveTo(mSPR.x,mSPR.y);
			sunRayRight.graphics.lineStyle(3,LightRay.LR_COLOR,currMirror.lightRay.outerSprite.getChildAt(0).alpha);
			sunRayRight.graphics.lineTo(sSPR.x,sSPR.y);
			addChild(sunRayRight);
			if (!currMirror.lightRayVisible) sunRayLeft.visible = false, sunRayRight.visible = false;
		}
		
		private function getMouseAngle() {
			if (currMirror) {
				var angle = -Math.atan2(mouseY - currMirrorPoint.y,mouseX - currMirrorPoint.x);
				if (angle < -Math.PI/2) angle = Math.PI;
				if (angle < 0) angle = 0;
				return angle;
			}
		}
		
		private function mouseClick(e:MouseEvent):void {
			if (currMirror) {
				if (currMirror.mirrorAI.aiLevel != MirrorAI.TRACK_ELLIPTICALLY &&
				    currMirror.mirrorAI.aiLevel != MirrorAI.TRACK_LINEARLY) {
					rotateTo(currMirror.top,currMirror.top.rotation,90 - (currAngle * 180/Math.PI));
				}
				currMirror.mirrorAI.updateTracking();
			}
		}
		
		private function keyDown(e:KeyboardEvent):void {
			if (currMirror) {
				var index = mirrorList.indexOf(currMirror);
				if (e.keyCode == KEYBOARD_KEYS[0] ||
					e.keyCode == KEYBOARD_KEYS[1]) { //left
					currMirror.alpha = MIRROR_FADED //set prev to faded
					if (currMirror.mirrorAI) currMirror.mirrorAI.line.visible = false;
					if (index != 0) setCurrMirror(mirrorList[index-1]);
					else setCurrMirror(mirrorList[mirrorList.length-1]); //loop to last mirror
				}
				if (e.keyCode == KEYBOARD_KEYS[2] ||
					e.keyCode == KEYBOARD_KEYS[3]) { //right
					currMirror.alpha = MIRROR_FADED //set prev to faded
					if (currMirror.mirrorAI) currMirror.mirrorAI.line.visible = false;
					if (index != mirrorList.length - 1) setCurrMirror(mirrorList[index+1]);
					else setCurrMirror(mirrorList[0]);
				}
			}
		}
		
		public function addMirror(mirror:Mirror,upgraded=false) {
			mirrorList.push(mirror);
			function sortMirrors(a,b) {
				if (a.x > b.x) return 1;
				if (a.x < b.x) return -1;
				return 0;
			}
			mirrorList.sort(sortMirrors);
			if (!upgraded) {
				for (var i = 0; i < mirrorList.length; i++) {
					mirrorList[i].alpha = MIRROR_FADED;
				}
				setCurrMirror(mirrorList[0]);
			}
		}
		
		private function setCurrMirror(mirror:Mirror) {
			currMirror = mirror;
			if (currMirror) {
				currMirrorPoint = globalToLocal(new Point(currMirror.x, currMirror.y));
				currMirror.alpha = 1;
				spotlight.x = currMirrorPoint.x - spotlight.width/2;
				spotlight.y = currMirrorPoint.y - 30;//??
				if (currMirror.mirrorAI) currMirror.mirrorAI.line.visible = true;
			} 
		}
		
		private function rotateTo(obj,start,end, frames = ROTATE_FRAMES) {
			var delta = end - start;
			var increment = delta/ROTATE_FRAMES;
			var count = 0;
			addEventListener(Event.ENTER_FRAME,enterFrame);
			function enterFrame(e) { 
				obj.rotation += increment;
				count++;
				if (count >= frames) removeEventListener(Event.ENTER_FRAME,enterFrame);
			}
		}
		
		private function localToLocal(currMC,newMC,sprite) {
			var point = new Point(sprite.x,sprite.y);
			return newMC.globalToLocal(currMC.localToGlobal(point));
		}
		
		public function endDay() {
			this.visible = false;
			stage.removeEventListener(MouseEvent.CLICK,mouseClick);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			for (var i = 0; i < mirrorList.length; i++) {
				mirrorList[i].alpha = 1;
			}
		}
		
		public function startDay() {
			this.visible = true;
			stage.addEventListener(MouseEvent.CLICK,mouseClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
			for (var i = 0; i < mirrorList.length; i++) {
				mirrorList[i].alpha = MIRROR_FADED;
			}
			setCurrMirror(mirrorList[0]);
		}
	}
	
}
