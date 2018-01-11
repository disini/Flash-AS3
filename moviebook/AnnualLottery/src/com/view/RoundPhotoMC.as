package com.view 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author LiuSheng
	 */
	public class RoundPhotoMC extends Sprite 
	{
		private var _photoMC:Sprite = new Sprite();
		private var _photoMask:ResultMask2 = new ResultMask2();
		private var _bmp:Bitmap;
		private var _bmd:BitmapData;
		
		public function RoundPhotoMC(bmd:BitmapData, diameter:Number) 
		{
			_bmd = bmd;
			_bmp = new Bitmap(bmd.clone());
			//_bmp.name = "bmp" + obj.mcode;
			
			//_photoMC.name = "photoMC" + idx;
			var scale:Number = diameter / bmd.width;
			_bmp.width = diameter;
			
			_bmp.height = bmd.height * scale;
			_bmp.y = -(_bmp.height - _bmp.width) / 2;
			_photoMC.addChild(_bmp);
			_photoMask.width = _photoMask.height = diameter;
			_photoMask.x = 0;
			//_photoMask.y = (_bmp.height - _bmp.width) / 2;
			_photoMC.addChild(_photoMask);
			_photoMC.mask = _photoMask;
			addChild(_photoMC);
		}
		
		public function get bmd():BitmapData 
		{
			return _bmd;
		}
		
	}

}