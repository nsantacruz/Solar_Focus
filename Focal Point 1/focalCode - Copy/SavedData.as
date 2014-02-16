package focalCode {
	
	import flash.net.SharedObject
	
	public class SavedData {
	
		public static var data;
		public static var so:SharedObject;
		
		
		public function SavedData() {
			throw Error('yooooooo!');
		}
		
		public static function init() {
			so = SharedObject.getLocal('datums');
			data = so.data;
			if (!so.data.playedBefore) {
				//trace('firstPost!');
				data.playedBefore = true;
				data.allMirrors = [];
				data.currLevel = 1;
				data.money = 0;
				so.flush();
			} else {
				//trace('been here before...');
				trace('Num Mirrors: ' + data.allMirrors.length);
				trace('Level: ' + data.currLevel);
				trace('Money: ' + data.money);
			}
		}
		
		public static function saveData(mirrors:Array, level:uint, money:int) {
			data.allMirrors = [];
			for (var i = 0; i < mirrors.length; i++) {
				var tm = mirrors[i];
				var obj = {x: tm.x, ai: tm.mirrorAI.aiLevel};
				data.allMirrors.push(obj);
			}
			data.currLevel = level;
			data.money += money;
			so.flush();
		}
	}
}