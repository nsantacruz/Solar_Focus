package focalCode {
	
	public class LevelHandler {
		
		public static const NUM_LEVELS = 21; //how long game lasts
		public static const NIGHT_LENGTH = 6; //doesn't change
		public static const PRE_LEVEL_SUN_SPEED = 60;
		public static const DAY_FAST_LENGTH = 3;
		public static const FRAME_RATE = 24;
		public static const MAX_MIRRORS = 6;
		public static const DAY_LENGTHS = [50,40,35,30,25,20,15,10];
		//                                       0     1    2     3     4     5     6     7     8     9     10    11   12     13   14    15    16    17    18    19    20    21?  
		public static const DAY_LEN_OFFSET =    [2,    1,   3,    1,    2,    1,    2,    2,    1,    1,    2,    2,   1,     0,   0,    0,    0,    0,    0,    0,    1  ,  0];
		public static const LEVEL_QUOTAS =      [5000, 250, 750,  800,  2000, 2900, 3300, 3500, 4250, 2800, 4800, 4800,8000,  5250,9100, 11400,14700,10300,14600,18400,15000,20000];
		public static const BLIMPS_PER_DAY =    [0,    0,   0,    0,    0,    1,    1,    2,    1,    2,    2,    3,   3,     3,   3,    3,    3,    4,    4,    5,    5  ,  0];
		public static const DAYS_PER_LEVEL =    [1,    1,   2,    1,    2,    2,    2,    2,    3,    1,    2,    2,   3,     1,   2,    3,    4,    2,    3,    4,    4  ,  1 ];
		public static const MIRRORS_PER_LEVEL = [1,    1,   1,    2,    2,    3,    3,    3,    3,    4,    4,    4,   4,     5,   5,    5,    5,    6,    6,    6,    6  ,  6 ];
		
		public function LevelHandler() {
			throw Error('NOOOOO!');
		}
	}
}