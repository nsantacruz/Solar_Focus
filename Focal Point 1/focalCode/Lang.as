package focalCode {
	
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class Lang {
		
		public static const EN = 'en';
		public static const HE = 'he';
		
		//strings
		public static const LEVEL_COMPLETE = 'level complete!';
		public static const LEVEL_LOST = 'level failed';
		public static const LOAD_GAME = 'load game';
		public static const NEW_GAME = 'new game';
		public static const LEVEL_SELECT = 'level select';
		public static const CREDITS = 'credits';
		public static const MAIN_MENU = 'main menu';
		public static const RESUME = 'resume';
		public static const BACK = 'back';
		public static const ACCURACY = 'accuracy';
		public static const TIME_BONUS = 'time bonus';
		public static const NUM_MIRRORS = 'num. mirrors';
		public static const HELP_1 = "Welcome! So, you've come to help us with our new technology";
		public static const HELP_2 = "To begin, use 'a' and 'd' keys to rotate this mirror...";
		public static const HELP_3 = "...so the sunlight hits this water tank";
		public static const HELP_4 = "Good Job! Look at the water heat up! When the water boils...";
		public static const HELP_5 = "...the steam travels down this pipe...";
		public static const HELP_6 = "...and spins this turbine to generate clean electricity!";	
		public static const HELP_7 = "We like to call it 'Solar Thermal Energy' because we're using the sun's heat to create energy";
		public static const HELP_8 = "The electric company is expecting us to generate a certain amount of electricity each day";
		public static const HELP_9 = "If you can do it, then we'll be able to grow our facility and fulfil our dream...";
		public static const HELP_10 = "...a future where all our energy is renewable and clean! Good Luck!";
		public static const HELP_13 = "Because of your help, we've been able to grow our energy plant with another mirror!";
		public static const HELP_14 = "The more mirrors aimed at the water tank, the more energy we make!";
		public static const HELP_15 = "Use left and right arrow keys to switch mirrors";
		public static const HELP_16 = "Looks like someone's noticed your hard work...";
		public static const HELP_17 = "The oil company wants to stop us so they get more business. Use you mirrors to take them down!";
		public static const HELP_18 = "Congratulations! Because of you, our energy plant is at full capacity!";
		//new
		public static const LEVEL = 'Level';
		public static const DAY = 'Day';
		public static const START = 'Start!';
		public static const RESTART = 'restart';
		public static const DAY_OVER = 'Day Over';
		public static const NEXT_LEVEL = 'next level';
		public static const PLAY = 'play';
		/*public static const*/
		
		public static var language; //options: en he
		
		private static var heDic:Dictionary = new Dictionary();
		private static var heTFTitle:TextFormat;
		private static var heTFPara:TextFormat;
		private static var heTFHeader:TextFormat;
		private static var heTFBigTitle:TextFormat;
		private static var enTFTitle:TextFormat;
		private static var enTFPara:TextFormat;
		private static var enTFHeader:TextFormat;
		private static var enTFBigTitle:TextFormat;
		private static var heFont:HeFont;
		private static var enFont:EnFont;
		
		public function Lang() {
			throw Error('you suck');
		}
		
		public static function init(lang:String) {
			heFont = new HeFont(), enFont = new EnFont();
			enTFPara = new TextFormat(enFont.fontName,20,0xCCCCCC,null,null,null,null,null,'center');
			enTFTitle = new TextFormat(enFont.fontName,30,0xCCCCCC,null,null,null,null,null,'center');
			enTFHeader = new TextFormat(enFont.fontName,60,0xCCCCCC,null,null,null,null,null,'center');
			enTFBigTitle = new TextFormat(enFont.fontName,40,0xCCCCCC,null,null,null,null,null,'center');
			heTFPara = new TextFormat(heFont.fontName,20,0xCCCCCC,null,null,null,null,null,'center');
			heTFTitle = new TextFormat(heFont.fontName,30,0xCCCCCC,null,null,null,null,null,'center');
			heTFHeader = new TextFormat(heFont.fontName,60,0xCCCCCC,null,null,null,null,null,'center');
			heTFBigTitle = new TextFormat(heFont.fontName,40,0xCCCCCC,null,null,null,null,null,'center');
			
			language = lang;
			if (language == HE) {
				heDic[LEVEL_COMPLETE] = "סיימת שלב זה!";
				heDic[LEVEL_LOST] = "נכשלת הפעם";
				heDic[LOAD_GAME] = "טען משחק";
				heDic[NEW_GAME] = "משחק חדש";
				heDic[LEVEL_SELECT] = "בחר שלב";
				heDic[CREDITS] = "זיכויים";
				heDic[MAIN_MENU] = "תפריט ראשי";
				heDic[RESUME] = "המשך";
				heDic[BACK] = "הקודם";
				heDic[ACCURACY] = "דיוק";
				heDic[TIME_BONUS] = "תוספת זמן";
				heDic[NUM_MIRRORS] = "מס. המראות";
				heDic[HELP_1] = "ברוכים הבאים!  יופי שבאתם לעזור לנו בטכנולוגיה החדשה שלנו";
				heDic[HELP_2] = 'כדי להתחיל, השתמשו במקשים "ש" ו"ג" על מנת לסובב את המראות'; 
				heDic[HELP_3] = "...כדי שקרני השמש וגעות במיכל המים...";
				heDic[HELP_4] = "עבודה יפה!  שימו לב כיצד המים מתחממים.  כאשר המים מגיעים לרתיחה...";
				heDic[HELP_5] = "...הקיטור נע לאורך הצינורות...";
				heDic[HELP_6] = "ומניע את הטורבינה ויוצר חשמל!";
				heDic[HELP_7] = 'אנו אוהבים לקרוא לזה "אנרגיה תרמית-סולארית" מכיוון שאנו משתמשים בחום הטבעי של השמש על מנת ליצור אנרגיה';
				heDic[HELP_8] = "חברת החשמל מצפה מאיתנו ליצור כמות מסוימת של חשמל מדי יום";
				heDic[HELP_9] = "אם תוכלו לעשות זאת, נוכל להגדיל את המתקן שלנו ולהגשים את החלום שלנו...";
				heDic[HELP_10] = "עתיד שבו כל האנרגיה תהיה אנרגיה מתחדשת ונקייה!  בהצלחה!";
				heDic[HELP_13] = "בזכות העזרה שלכם, הצלחנו להגדיל את מפעל האנרגיה שלנו בעוד מראה!";
				heDic[HELP_14] = "ככל שיש יותר מראות מכוונות לעבר מיכל המים, כך נוצרת יותר אנרגיה!";
				heDic[HELP_15] = "השתמשו בחץ הימני והשמאלי על מנת להחליף המראות";
				heDic[HELP_16] = "נראה שמישהו הבחין בעבודה הקשה שלכם...";
				heDic[HELP_17] = "חברת הנפט רוצה לעצור בעדנו כדי להרחיב את העסקים שלה.  השתמשו במראות על מנת להפיל אותם!";
				heDic[HELP_18] = "מזל טוב!  בזכותכם, מפעל האנרגיה שלנו עובד במתכונת מלאה!";
				heDic[LEVEL] = "שלב";
				heDic[DAY] = "יום";
				heDic[START] = "התכל";
				heDic[NEXT_LEVEL] = 'שלב הבא';
				heDic[RESTART] = "התחדש";
				heDic[DAY_OVER] = "סוף היום";
				heDic[PLAY] = 'שחק';
				//heDic[]
			}
		}
		//type can be 'acc' or 'time'
		public static function trans(string, tf:TextField, color = null, format = 'title', type = null, retranslate = false) {
			//TextFormat(font:String = null, size:Object = null, color:Object = null, bold:Object = null, italic:Object = null, underline:Object = null, url:String = null, target:String = null, align:String = null, leftMargin:Object = null, rightMargin:Object = null, indent:Object = null, leading:Object = null)
			if (language == EN) {
				tf.embedFonts = true;
				if (format == 'title') tf.defaultTextFormat = enTFTitle;
				else if (format == 'para') tf.defaultTextFormat = enTFPara;
				else if (format == 'header') tf.defaultTextFormat = enTFHeader;
				else if (format == 'bigTitle') tf.defaultTextFormat = enTFBigTitle;
				
				if(color) tf.textColor = color;
				
				if (!isNaN(Number(string))) {
					if (type == 'acc') string += '%';
					else if (type == 'time') string += 's';
				}
				tf.text = string;
			}
			else if (language == HE) {
				tf.embedFonts = true;
				if (format == 'title') tf.defaultTextFormat = heTFTitle;
				else if (format == 'para') tf.defaultTextFormat = heTFPara;
				else if (format == 'header') tf.defaultTextFormat = heTFHeader;
				else if (format == 'bigTitle') tf.defaultTextFormat = heTFBigTitle;
				
				if (color) tf.textColor = color;
				
				if (!isNaN(Number(string))) {
					if (type == 'acc') string += '%';
					else if (type == 'time') string += '"';
					tf.text = string;
				} else {
					try {
						tf.text = flipText(heDic[string]);
						flipLines(tf);
					} catch (e) {
						tf.defaultTextFormat = enTFTitle;
						tf.text = string;
					}
				}
			}
			else return 'lang not supported';
		}
		
		private static function flipText(text:String):String {
			var firstChar = text.charAt(0);
			var textArray = text.split('');
			textArray.reverse();
			var messedUpText = text.slice(textArray.indexOf(firstChar));
			return textArray.join('');
		}
		
		private static function flipLines(textField:TextField) {
			var ammendedText = '';
			for (var i = textField.numLines-1; i >= 0; i--) {
				ammendedText += textField.getLineText(i);
				if (i != 0) ammendedText+= '\n';
			}
			textField.text = ammendedText;
		}
	}
}