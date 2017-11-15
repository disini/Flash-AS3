package com.view.bar
{
	import com.adobe.media.SphericalVideo1;
	import com.event.ControlBarEvent;
	import com.media.simpleVideo.SimpleVideo;
	import com.utils.Log;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import ui.volume.VolumeUI;
	
	import utils.Utils;

	/**
	 * 主视频的播放控件 
	 * @author LiuSheng  QQ:532230294
	 * 创建时间 : 2016-12-22 上午11:03:31
	 *
	 */
	public class PlayControlBar1 extends PlayControlBar_Clip
	{
//		private var _video:SimpleRetryVideo;
//		private var _video:SimpleVideo;
		private var _video:SphericalVideo1;
		private var _container:Sprite;
		private var _barWidth:Number;
		private  var _isDragging:Boolean = false;
		private  var _onVideoEnd:Boolean = true;
		/** 当前拖动滚动条的位置占整个视频长度的百分比 */
		private var curMousePercent:Number = 0;
		/** 当前拖动滚动条的位置所在的视频的时刻 */
		private var curMouseTime:Number = 0;
		/** 当前已经加载的视频的长度 */
		//		public var curLoadedVideoTime:Number = 0;
		
		private var _bgLayer:Sprite;
		
		public static const CONTROLBAR_HEIGHT:Number = 52;
		
		private static const HORIZON_MARGIN:Number = 66;
		
		private var _totalVideoTime:Number;
		
		private var originalBarMcWidth : Number;
		private var originalBarMcHeight : Number;
		private var originalSeekHotAreaWidth : Number;
		private var widthScale:Number;
		
		private var volumeMC:VolumeUI;
		
		private var _isFullScreen:Boolean;
		
		private var updateUITimer:Timer;
		/** 上一次移动鼠标的时刻（单位毫秒） */
		private var _lastMouseMoveTimePoint:Number;
		/** 当前控制条是否沉下去了 */
		private var _isControlBarDropped:Boolean = false;
		
		private var _needAutoPlay:Boolean;
		
//		public function PlayControlBar(video:SimpleRetryVideo, container:Sprite, autoPlay:Boolean, barWidth:Number = 0)
//		public function PlayControlBar(video:SimpleVideo, container:Sprite, autoPlay:Boolean, barWidth:Number = 0)
		public function PlayControlBar1(video:SphericalVideo1, container:Sprite, autoPlay:Boolean, barWidth:Number = 0)
		{
			_video = video;
			_needAutoPlay = autoPlay;
			_onVideoEnd = !autoPlay;
			_totalVideoTime = video.duration;
			_container = container;
			//			_barWidth = barWidth ? barWidth : video.width;
			_barWidth = barWidth ? barWidth : stage.stageWidth;
			initPlayControlBar();
			setupSize();
			//			initTimer();
		}
		
		/*private function initTimer():void
		{
		updateUITimer = new Timer(500);
		updateUITimer.addEventListener(TimerEvent.TIMER, onTimerHandler);
		updateUITimer.start();
		}
		
		protected function onTimerHandler(evt:TimerEvent):void
		{
		//			updateBar();
		checkIsMouseMoving();
		}
		
		private function checkIsMouseMoving():void
		{
		var _timeNow:Number = new Date().time;
		
		if(_timeNow - _lastMouseMoveTimePoint > 7000)
		{
		if(!_isControlBarDropped)
		{
		dropDownControlBar();
		}
		}
		}*/
		
		/**
		 * 将播放控制条向下隐藏 
		 * 
		 */		
//		private function dropDownControlBar():void
//		{
//			//			this.y = stage.stageHeight;
//			TweenLite.to(this, 0.5, {y:stage.stageHeight});
//			_isControlBarDropped = true;
//		}
		
		/**
		 * 将播放控制条向上升起 
		 * 
		 */		
//		private function raiseUpControlBar():void
//		{
//			//			this.y = stage.stageHeight - CONTROLBAR_HEIGHT;
//			if(stage)
//			{
//				TweenLite.to(this, 0.5 ,{y:stage.stageHeight - CONTROLBAR_HEIGHT});
//				_isControlBarDropped = false;
//			}
//		}
		
		public function get isDragging():Boolean
		{
			return _isDragging;
		}
		
		private function initPlayControlBar():void
		{
//			videoELogoMC.visible = false;
			originalSeekHotAreaWidth = barMc.seekHotArea.width;
			originalBarMcWidth = barMc.width;
			originalBarMcHeight = barMc.height;
			barMc.barBG_Orange.width = barMc.barBG_White.width = 0;
			_bgLayer = new Sprite();
			_bgLayer.graphics.beginFill(0);
			_bgLayer.graphics.drawRect(0, 0, originalBarMcWidth, CONTROLBAR_HEIGHT);
			_bgLayer.graphics.endFill();
			_bgLayer.x = - HORIZON_MARGIN / 2;
			addChildAt(_bgLayer, 0);
			barMc.btnClickAndDrag.buttonMode = true;
			barMc.btnClickAndDrag.mouseChildren = false;
			barMc.timeTxt.visible = false;
			barMc.timeTxt.mouseEnabled = false;
			(barMc.timeTxt as TextField).selectable = true;
			barMc.seekHotArea.buttonMode = true;
			barMc.btnClickAndDrag.addEventListener(MouseEvent.MOUSE_DOWN, onDragMouseDown);
			barMc.seekHotArea.addEventListener(MouseEvent.MOUSE_MOVE, onSeekMouseMove);
			barMc.seekHotArea.addEventListener(MouseEvent.MOUSE_OVER, onSeekMouseOver);
			barMc.seekHotArea.addEventListener(MouseEvent.MOUSE_OUT, onSeekMouseOut);
			//			barMc.seekHotArea.addEventListener(MouseEvent.CLICK, onSeekMouseClick);
			//		barMc.btnClickAndDrag.addEventListener(MouseEvent.MOUSE_MOVE, onDragMouseMove);
			//			barMc.barBG_ClickArea.addEventListener(MouseEvent.CLICK, onClickToSeek);
			barMc.seekHotArea.addEventListener(MouseEvent.CLICK, onClickToSeek);
			//			VolumeUI.initUI(volumeMC);
			volumeMC = new VolumeUI();
			addChild(volumeMC);
			volumeMC.addEventListener(ControlBarEvent.SET_VOLUME, onSetVolume);
			volumeMC.y = 16;
			//			volumeMC.panel.visible = false;
			//			volumeMC.tip.visible = false;
			scaleMC.panel.visible = false;
//			scaleMC.visible = false;
			scaleMC.icon.addEventListener(MouseEvent.CLICK, onSwitchFullScreen);
			// 播放按钮
			playButton.buttonMode = true;
			var targetFrame:int = _needAutoPlay?1:2;
			playButton.gotoAndStop(targetFrame);
//			playButton.mouseChildren = false;
			playButton.addEventListener(MouseEvent.CLICK, onClickBtn);
			videoELogoMC.addEventListener(MouseEvent.CLICK, onClickVideoyiLogo);
			videoELogoMC.buttonMode = true;
			//			playButton.addEventListener(MouseEvent.CLICK, onClickBtn);
//			btnReplay.visible = false;
			btnReplay.addEventListener(MouseEvent.CLICK, onClickBtn);
			//			addEventListener(Event.ENTER_FRAME, onEnterFrm);
			_container.addChild(this);
			this.x = HORIZON_MARGIN / 2;
			//			this.x = stage.stageWidth;
			//			this.y = video.height - 60;
			this.y = stage.stageHeight - CONTROLBAR_HEIGHT;
		}
		
		protected function onClickVideoyiLogo(event:MouseEvent):void
		{
			navigateToURL(new URLRequest("http://www.moviebook.tv/"));
		}
		
		private function onSetVolume(e:ControlBarEvent):void
		{
			_video.volume = e.dataProvider.value;
		}
		
		private function setupSize():void
		{
			barMc.seekHotArea.width = barMc.barBG_ClickArea.width = barMc.barBG_Black.width = _barWidth - HORIZON_MARGIN;
			widthScale = barMc.seekHotArea.width / originalSeekHotAreaWidth;
			_bgLayer.width = _barWidth;
			//			_bgLayer.x = 0;
			/*if(_video)
			{
			barMc.barBG_Orange.width = 0;
			}
			else
			{
			barMc.barBG_Orange.width = barMc.btnClickAndDrag.x = barMc.barBG_Black.width * (_video.currentTime / _video.duration);
			}*/
			barMc.barBG_Orange.x = 0;
			scaleMC.x = barMc.barBG_Black.width - 30;
			btnReplay.x = barMc.barBG_Black.width - 50;
			volumeMC.x = barMc.barBG_Black.width - 100;
			videoELogoMC.x = barMc.barBG_Black.width - 300;
			Log.info("setupSize() : videoELogoMC.x = " + videoELogoMC.x + ", videoELogoMC.y = " + videoELogoMC.y);
		}
		
		override public function set width(value:Number):void
		{
			_barWidth = value;
			setupSize();
		}
		
		private function onClickToSeek(evt:MouseEvent):void
		{
			curMousePercent = evt.target.mouseX / 600;
			//			trace("onClickToSeek : curMousePercent = " + curMousePercent);
			//			barMc.timeTxt.visible = true;
			curMouseTime = _video.duration * curMousePercent;
			//			curLoadedVideoTime = this.root["curLoadingProgress"] * _video.duration;
			//			_video.seek(Math.min(curMouseTime, curLoadedVideoTime));
			_video.seek(curMouseTime);
//			this.root["onSeekTo"]();
			//			_video.resumeVideo();
			if(curMousePercent < 1)
			{
				//				playButton.mouseEnabled = true;
				_video.isPlaying = true;
				_onVideoEnd = false;
				playButton.gotoAndStop(1);
			}
		}
		
		public function onEnterFrm(evt:Event):void
		{
			//			SystemMessage.update();
			//			Tween.update();
//			if((!_video) || (!_video.isPlaying) || _isDragging)
			if((!_video) || _isDragging)
				return;
			//			curLoadedVideoTime = this.root["curLoadingProgress"] * _video.duration;
			//			trace("_video.currentTime = " + _video.currentTime + " , stage.frameRate = " +  stage.frameRate);
			barMc.barBG_Orange.width = barMc.btnClickAndDrag.x = barMc.barBG_Black.width * (_video.currentTime / _video.duration);
			barMc.barBG_White.width = barMc.barBG_Black.width * (_video.curLoadedPercent / 100);
			//			barMc.btnClickAndDrag.timeTxt.text = _video.currentTime.toFixed(2);
			//			barMc.timeTxt.text = _video.currentTime;
			
			var curTimeStr:String = Utils.getTimeStr1(_video.currentTime * 1000);
			var totalTimeStr:String = Utils.getTimeStr1(_video.duration * 1000);
			
			_curTimeTxt.text = curTimeStr + "/" + totalTimeStr;
			if(this.parent)
			{
				//				this.parent["updateCurTime"](_video.currentTime.toFixed(2));
//				this.parent["updateCurTime"](_video.currentTime);
			}
		}
		
		private function onClickBtn(evt:MouseEvent = null):void
		{
			evt.stopImmediatePropagation();
			switch(evt.target.name)
			{
				//				case "playButton":
				case "playButton_frame1":
				case "playButton_frame2":
				{
					if(_onVideoEnd)
					{
						onReplayVideo();
					}
					else
					{
						switchPlaying();
					}
					break;
				}
					
				case "btnReplay":
				{
					onReplayVideo();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		public function switchPlaying():void
		{
			// TODO Auto Generated method stub
			if(!_video)
				return;
			if(_video.isPlaying)
			{
				_video.pauseVideo();
			}
			else
			{
				_video.resumeVideo();
			}
			var targetFrame:int = playButton.currentFrame == 1 ? 2 : 1;
			playButton.gotoAndStop(targetFrame);
		}
		
		public function onReplayVideo():void
		{
			_video.seek(0);
			_video.replay();
			_onVideoEnd = false;
			playButton.gotoAndStop(1);
//			_container.hidePlayButton();
			dispatchEvent(new Event("NeedToHidePlayButton"));
		}
		
		public function onPlayComplete():void
		{
			_onVideoEnd = true;
			playButton.gotoAndStop(2);
			dispatchEvent(new Event("NeedToShowPlayButton"));
		}
		
		private function onSeekMouseOver(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
			barMc.timeTxt.visible = true;
			//			barMc.timeTxt.x = evt.localX;
		}
		
		private function onSeekMouseOut(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
			barMc.timeTxt.visible = false;
			//			barMc.timeTxt.x = evt.localX;
		}
		
		private function onSeekMouseMove(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
			//			barMc.timeTxt.visible
			barMc.timeTxt.x = evt.localX * widthScale - barMc.timeTxt.width/2;
			var mousePct:Number = evt.localX / originalSeekHotAreaWidth;
			var curMouseTime:Number = _video.duration * mousePct;
			barMc.timeTxt.text = Utils.getTimeStr1(Number(curMouseTime.toFixed(3)) * 1000, false);
		}
		
		private function onDragMouseDown(evt:MouseEvent):void {
			evt.stopImmediatePropagation();
			barMc.timeTxt.visible = true;
			var rect:Rectangle = new Rectangle(0, 0, barMc.barBG_Black.width, 0);
			barMc.btnClickAndDrag.startDrag(false, rect);
			barMc.btnClickAndDrag.addEventListener(MouseEvent.MOUSE_UP, onDragMouseUp);
			_isDragging = true;
		}
		
		private function onDragMouseUp(evt:MouseEvent = null):void {
			evt && evt.stopImmediatePropagation();
			barMc.timeTxt.visible = false;
			barMc.btnClickAndDrag.removeEventListener(MouseEvent.MOUSE_UP, onDragMouseUp);
			barMc.btnClickAndDrag.stopDrag();
			_isDragging = false;
			//			curLoadedVideoTime = this.root["curLoadingProgress"] * _video.duration;
			//			_video.seek(Math.min(curMouseTime, curLoadedVideoTime));
			_video.seek(curMouseTime);
//			this.root["onSeekTo"]();
			_video.resumeVideo();
		}
		
		public function onDragMouseMove(evt:MouseEvent = null):void
		{
			if(!_isDragging)
			{
				//				raiseUpControlBar();
				//				if(_video)
				//				{
				//					_lastMouseMoveTimePoint = new Date().time;
				//				}
				return;
			}
			//			trace("onDragMouseMove");
			if(_video.isPlaying)
			{
				_video.pauseVideo();
			}
			curMousePercent = barMc.btnClickAndDrag.x / barMc.barBG_Black.width;
			curMouseTime = _video.duration * curMousePercent;
			barMc.timeTxt.text = Utils.getTimeStr1(Number(curMouseTime.toFixed(3)) * 1000, false);
			if(this.parent)
			{
				this.parent["updateCurTime"](curMouseTime.toFixed(3));
			}
			barMc.barBG_Orange.width = barMc.btnClickAndDrag.x;
			barMc.timeTxt.x = barMc.btnClickAndDrag.x - barMc.timeTxt.width/2;
			if(curMousePercent < 1)
			{
				//				playButton.mouseEnabled = true;
				_video.isPlaying = true;
				_onVideoEnd = false;
				playButton.gotoAndStop(1);
			}
		}
		
		public function onPauseVideo():void{
			playButton.gotoAndStop(2);
		}
		
		public function onResumeVideo():void{
			playButton.gotoAndStop(1);
		}
		
		private function onSwitchFullScreen(evt:MouseEvent):void
		{
			if(!stage)
				return;
			if(!_isFullScreen)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
				_isFullScreen = true;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
				_isFullScreen = false;
			}
		}
		
		public function forceStopDrag():void
		{
			if(_isDragging)
			{
				onDragMouseUp();
			}
		}
		
		/** 当前是否处于全屏状态 */
		public function get isFullScreen():Boolean
		{
			return _isFullScreen;
		}
		
		/**
		 * 更新各个显示条 
		 * @param data
		 * 
		 */		
		public function updateBar(curTime:Number = -1):void
		{
			barMc.barBG_Orange.width = barMc.btnClickAndDrag.x = barMc.barBG_Black.width * (_video.currentTime / _video.duration);
			barMc.barBG_White.width = barMc.barBG_Black.width * (_video.curLoadedPercent / 100);
		}
		
		public function get playBtn():MovieClip
		{
			return playButton;
		}
	}
}