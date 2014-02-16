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
				data.playedBefore = true;
				data.seenBlimp = false;
				data.currLevel = 0;
				for (var i = 1; i < LevelHandler.NUM_LEVELS; i++) {
					data['_'+i] = new Object();
					data['_'+i].won = false;
					data['_'+i].accuracy = '--';
					data['_'+i].timeBonus = '--';
				}
				so.flush();
				Shading.currLevel = data.currLevel;
			} else {
				Shading.currLevel = data.currLevel;
			}
		}
		
		public static function saveData(level:uint) {
			data.currLevel = level;
			if ((level-1) != 0) { //level 0 should not be saved
				data['_'+(level-1)].won = true;
				if (Score.accuracy > data['_'+(level-1)].accuracy || data['_'+(level-1)].accuracy == '--') {
					data['_'+(level-1)].accuracy = Score.accuracy;
				}
				if (Score.timeBonus > data['_'+(level-1)].timeBonus || data['_'+(level-1)].timeBonus == '--') {
					data['_'+(level-1)].timeBonus = Score.timeBonus;
				}
			}
			so.flush();
		}
	}
}