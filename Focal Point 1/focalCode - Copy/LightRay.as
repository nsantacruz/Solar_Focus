package focalCode {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class LightRay extends Sprite {
		
		public static const LR_HEIGHT = 900; //height must over shoot stage. width depends on mirror width
		public static const LR_SPRITE_HEIGHT = 937.5;
		public static const LR_ALPHA = 0.6;
		public static const LR_COLOR = 0xffcc00;
		public static const LR_MAX_POWER = 1;
		
		public static var lrPower = LR_MAX_POWER;
		
		public var lrY;
		public var lrX;
		public var outerSprite:Sprite;
		public var lowerSpriteMask:Sprite;
		public var sprite:Sprite;
		public var upperSpriteMask:Sprite;
		public var upperSpriteMaskGraphics;
		public var lowerSprite; 
		public var spriteWidth; //used in Reflection class
		public var spriteY;
		
		public var disabled;
		
		private var lrBoundaries:Array;
		
		public function LightRay(w:Number,h:Number) {    //mirror top's width and height
			spriteWidth = w;
			lrX = 0;
			lrY = -h/2;
			var g;
			//create lightRay...
			outerSprite = new Sprite();
			outerSprite.x = 0, outerSprite.y = 0;
			sprite = new Sprite(),  g = sprite.graphics;
			g.beginFill(LR_COLOR);
			g.drawRect(0,0,w,LR_HEIGHT);
			g.endFill();
			sprite.x = -sprite.width/2, sprite.y = -(sprite.height + h/2); //leave some below mirror so that it can rotate
			sprite.alpha = LR_ALPHA;
			//sprite.visible = false;
			outerSprite.addChild(sprite);
			this.addChild(outerSprite);
			
			
			//create upperSpriteMask...
			upperSpriteMask = new Sprite(), g = upperSpriteMask.graphics;
			g.beginFill(0x000000);
			g.drawRect(0,0,w,LR_HEIGHT);
			g.endFill();
			upperSpriteMask.x = -upperSpriteMask.width/2, upperSpriteMask.y = -(upperSpriteMask.height + h/2);
			outerSprite.addChild(upperSpriteMask);
			sprite.mask = upperSpriteMask;
			spriteY = upperSpriteMask.y;
			
			//create lowerLightRay...
			lowerSprite = new Sprite(), g = lowerSprite.graphics;
			g.beginFill(LR_COLOR);
			g.drawRect(0,0,w,w);
			g.endFill();
			lowerSprite.height -= (w/2 - h/2);
			lowerSprite.x = -lowerSprite.width/2, lowerSprite.y = -h/2;
			lowerSprite.alpha = LR_ALPHA;
			outerSprite.addChild(lowerSprite);
			
			//create lowerSpriteMask...
			lowerSpriteMask = new Sprite();  //change registration point with nested sprites...
			lowerSpriteMask.x = 0, lowerSpriteMask.y = 0;
			var mirrorMask:Sprite = new Sprite();
			g = mirrorMask.graphics;
			g.beginFill(0x000000);
			g.drawRect(0,0,w,w);
			g.endFill();
			mirrorMask.x = -mirrorMask.width/2, mirrorMask.y = -(mirrorMask.height + h/2);
			lowerSpriteMask.addChild(mirrorMask);
			
			addChildAt(lowerSpriteMask,0);
			lowerSprite.mask = lowerSpriteMask;
			
			lrBoundaries = addBoundaryPoints(w,h);
			Reflection.addCollisionObj(this,true);
			disabled = false;
		}
		
		private function addBoundaryPoints(w,h):Array {
			var array = [];
			var positions = [[w/2, -w/2],[-h/2,-LR_HEIGHT]];
			for (var j = 0; j < positions.length; j++) {
				for (var k = 0; k < positions[j].length; k++) {
					var tempSprite = new Sprite();
					array.push(tempSprite); 
					this.outerSprite.addChild(tempSprite);
					tempSprite.x = positions[0][k], tempSprite.y = positions[1][j];
				}
			}
			return array;
		}
		
		public function get boundaries() {
			var array = [];
			for (var i = 0; i < lrBoundaries.length; i++) {
				array.push(this.outerSprite.localToGlobal(new Point(lrBoundaries[i].x,lrBoundaries[i].y)));
			}
			return array;
		}
		
		public function updateLightMover() {
		
		}
		
		public function drawLightMask() {
			var g = upperSpriteMask.graphics;
			g.clear();
			g.beginFill(0x000000);
			g.drawRect(0,0,spriteWidth,LR_HEIGHT);
			g.endFill();
		}
	}
	
}
