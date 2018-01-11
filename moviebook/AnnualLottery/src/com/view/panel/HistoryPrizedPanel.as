package com.view.panel 
{
	import adobe.utils.CustomActions;
	import com.view.RoundPhotoMC;
	import com.view.panel.HistoryPrizedPanel;
	import flash.display.StageDisplayState;
	import com.kyo.media.simpleVideo.SimpleVideo;
	import fl.data.DataProvider;
	import flash.display.SimpleButton;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.events.MouseEvent;
	import com.greensock.TweenLite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	//import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import com.event.SoundEvent;
	import com.sound.*;
	
	import com.kyo.event.*;
	import com.kyo.event.simpleVideo.*;
	import com.kyo.media.*;
	
	import com.manager.GlobalManager;
	import com.utils.Log;
	
	/**
	 * ...
	 * @author LiuSheng
	 */
	public class HistoryPrizedPanel extends Sprite 
	{
		
		private var _historyData:Object;
		private var _curMouseOverIdx:int = 0;
		//private var _imagesBmdDataList:Array = [[],[],[]];
		private var _imagesBmdDataList:Object = {level1:[],level2:[],level3:[]};
		private var iconLayer:Sprite;
		private var zoomLayer:Sprite;
		private var zoomPortraitImg:RoundPhotoMC;
		private var totlePeopleNum:int;
		private var loadedYetCount:int = 0;
		
		public function HistoryPrizedPanel(hData:Object) 
		{
			_historyData = hData;
			//_imagesBmdDataList = bmdData;
			for (var i:int = 3; i > 0; i--)
			{
				if (hData["level" + i] && hData["level" + i].length)
				{
					totlePeopleNum += hData["level" + i].length;
				}
			}
			setupPanel();
		}
		
		private function setupPanel():void 
		{
			iconLayer = new Sprite();
			addChild(iconLayer);
			
			zoomLayer = new Sprite();
			addChild(zoomLayer);
			
			//var bmd:BitmapData = new BitmapData(240, 320):
			//zoomPortraitImg = new RoundPhotoMC();
			
			for (var i:int = 3; i > 0; i--)
			{
				if (_historyData["level" + i] && _historyData["level" + i].length)
				{
					var curLevelData:Array = _historyData["level" + i];
					var idx:int = 0;
					for (var j:int = 0; j < curLevelData.length; j++)
					{
						//var obj:Object = curLevelData[j];
						//var mcode:String = obj.mcode;
						
						loadHistoryImage(curLevelData[j], i, j);
						//for each(var imageData:Object in _imagesBmdDataList)
						//{
							//if (obj.mcode == imageData.mcode)
							//{
								//
								//idx++;
								//break;
							//}
						//}
						
						
					}
				}
			}
		}
		
		
		
		
		
		private function loadHistoryImage(data:Object, level:int, index:int):void 
		{
			var loader:Loader = new Loader();
			loader.name = "loader" + level + "_" + index;
			//loader.data = {};
			//loader.load(new URLRequest(_imagesUrlList[curLoadIdx].url), new LoaderContext(false, ApplicationDomain.currentDomain));
			loader.load(new URLRequest(GlobalManager.IMAGES_URL_PREFIX + data.photo), new LoaderContext(false, ApplicationDomain.currentDomain));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadCompleteHandler);
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, onImageLoadErrorHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadErrorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onImageLoadErrorHandler);
		}
		
		
		
		private function onImageLoadCompleteHandler(e:Event):void 
		{
			
			var nameStr:String = e.target.loader.name;
			var str:String = nameStr.substr(6);
			var arr:Array = str.split("_");
			var level:int = arr[0];
			var index:int = arr[1];
			if (_historyData["level" + level] && _historyData["level" + level].length)
			{
				var curLevelData:Array = _historyData["level" + level];
				var curData:Object = curLevelData[index];
				var _code:int = curData.code;
				var _mcode:String = curData.mcode;
			}
			var obj:Object = {code:_code, bmd:e.target.content.bitmapData, mcode:_mcode};
			trace("onImageLoadCompleteHandler():obj.code == " + obj.code);
			_imagesBmdDataList["level" + level].push(obj);
			loadedYetCount++;
			if (loadedYetCount == totlePeopleNum)
			{
				onAllImagesLoaded();
			}
			//loadNext();
		}
		
		private function onAllImagesLoaded():void 
		{
			initPortraitList();
		}
		
		
		private function initPortraitList():void 
		{
			for (var i:int = 3; i > 0; i--)
			{
				var arr:Array = _imagesBmdDataList["level" + i];
				if (arr.length)
				{
					for (var j:int = 0; j < arr.length; j++)
					{
						var photoMC:Sprite = new RoundPhotoMC(arr[j].bmd, 60);
						photoMC.name = "photoMC" + i + "_" + j;
						//photoMC.scaleX = photoMC.scaleY = 0.2;
						photoMC.x = 1300 + 80 * j;
						photoMC.y = 50 + 80 * (3 - i);
						photoMC.mouseChildren = false;
						photoMC.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverPhotoMC);
						photoMC.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutPhotoMC);
						iconLayer.addChild(photoMC);
					}
				}
				
			}
		}
		
		private function onMouseOverPhotoMC(e:MouseEvent):void 
		{
			//if(zoomLayer.contains(zoomPortraitImg))
			if (zoomLayer.numChildren)
			{
				zoomLayer.removeChildren();
			}
			var bmd:BitmapData = (e.target as RoundPhotoMC).bmd;
			zoomPortraitImg = new RoundPhotoMC(bmd, 300);
			zoomPortraitImg.x = 1460;
			zoomPortraitImg.y = 300;
			zoomLayer.addChild(zoomPortraitImg);
		}
		
		private function onMouseOutPhotoMC(e:MouseEvent):void 
		{
			if (zoomLayer.numChildren)
			{
				zoomLayer.removeChildren();
			}
			zoomPortraitImg = null;
		}
		
		private function onImageLoadErrorHandler(e:Event):void 
		{
			trace("Error:" + e.toString());
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "Error:" + e.toString());
			}
		}
		
	}

}