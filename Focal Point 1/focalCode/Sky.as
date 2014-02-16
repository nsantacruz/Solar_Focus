package  focalCode {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	
	public class Sky extends Sprite {
		
		
		public static const SKY_WIDTH = 775;
		public static const SKY_HEIGHT = 480;
		public static const UP_HEX_RANGES = [0x00001a,0x00001a,0x00005d,0x004db8,0x0095ff,0x44adf7,0x0095ff,0x004db8,0x00005d,0x00001a,0x00001a];
		public static const DOWN_HEX_RANGES = [0x00001a,0x700000,0xc24b01,0xe7922c,0xe7bc2c,0xb2d9f5,0xe7bc2c,0xc24b01,0x700000,0x00001a];
		public static const ANGLE_RANGES = [345,355,0,10,40,90,140,170,180,185,195];
		
		public function Sky() {
			
		}
		
		public function update(currAngle) {
			currAngle = getRoundedAngle(currAngle);
			var currRange = findCurrRange(currAngle);
			if (currRange == -1) return;
			var currHexTop = calculateHex(currAngle,ANGLE_RANGES[currRange],ANGLE_RANGES[currRange+1]
												   ,UP_HEX_RANGES[currRange],UP_HEX_RANGES[currRange+1]);
			var currHexBottom = calculateHex(currAngle,ANGLE_RANGES[currRange],ANGLE_RANGES[currRange+1]                                          ,DOWN_HEX_RANGES[currRange],DOWN_HEX_RANGES[currRange+1]);
			//trace(currHexTop.toString(16));
			drawGradient(currHexTop,currHexBottom);
		}
		
		private function getRoundedAngle(currAngle:Number):Number {
			if (currAngle >= 360) {
				currAngle -= Math.floor(currAngle/360) * 360;
			} else if (currAngle < 0) {
				currAngle += 360;
			}
			return currAngle;
		}
		
		private function findCurrRange(currAngle:Number):int {
			for (var i = 0; i < ANGLE_RANGES.length-1; i++) {
				if (currAngle > ANGLE_RANGES[i] && currAngle <= ANGLE_RANGES[i+1]) {
					return i;
				}
			}
			return -1;
		}
		
		private function getRGB(hex:Number):Object {
			var R = hex >> 16;
			var G = (hex >> 8) & 0xff;
			var B = hex & 0xff;
			return {r: R, g: G, b :B};
		}

		private function calculateHex(currAngle,startAngle,endAngle,startHex,endHex):uint {
			var deltaAngle = endAngle - startAngle;
			var startRGB = getRGB(startHex);
			var endRGB = getRGB(endHex);
			var deltaR = endRGB.r - startRGB.r;
			var deltaG = endRGB.g - startRGB.g;
			var deltaB = endRGB.b - startRGB.b;
	
			var currR = ((currAngle - startAngle) * deltaR)/deltaAngle + startRGB.r;
			var currG = ((currAngle - startAngle) * deltaG)/deltaAngle + startRGB.g;
			var currB = ((currAngle - startAngle) * deltaB)/deltaAngle + startRGB.b;
			return (currR << 16) + (currG << 8) + currB;
		}
		
		private function drawGradient(topHex,bottomHex):void {
			this.graphics.clear();
			
			var m:Matrix = new Matrix();
			m.createGradientBox(SKY_WIDTH, SKY_HEIGHT, Math.PI/2, 0, 0);
			this.graphics.beginGradientFill(GradientType.LINEAR, [topHex, bottomHex], [1, 1], [175, 255], m, SpreadMethod.PAD);
			this.graphics.drawRect(0,0,SKY_WIDTH,SKY_HEIGHT);
		}
	}
	
}


