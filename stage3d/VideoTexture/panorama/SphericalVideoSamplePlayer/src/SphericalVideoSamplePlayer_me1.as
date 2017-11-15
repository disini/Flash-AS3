package
{
	import com.adobe.media.SphericalVideo1;
	import com.event.simpleVideo.SimpleVideoEvent;
	import com.utils.Log;
	import com.view.bar.PlayControlBar1;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.StaticText;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.setTimeout;
	
	import hires.debug.Stats;
	
	
	/**
	 * 全景视频播放器
	 * @author LiuSheng  QQ:532230294
	 * 创建时间 : 2017-5-11 上午11:06:08
	 *
	 */
	[SWF(frameRate="60", width="960", height="592", backgroundColor="#808080")]
	public class SphericalVideoSamplePlayer_me1 extends Sprite
	{
//		private static const FILE_NAME:String = "../assets/360 Google Spotlight Story- HELP.mp4";
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/3840x2160/360%20Google%20Spotlight%20Story-%20HELP.mp4";
//		private static const FILE_NAME:String = "file:///H:/教程/360degree视频/3840x2160/HELP2.mp4";
//		private static const FILE_NAME:String = "file:///L:/BaiduYunDownload/360度视频/360 Google Spotlight Story- HELP.mp4";
		private static const FILE_NAME:String = "file:///H:/教程/360degree视频/1920x1080/PlayStation VR Worlds- Ocean Descent - 360 Grad-Trailer [PlayStation VR] - YouTube_2.MP4";
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/2560x1440/Ocean%20Descent%20VR%20360%20-%20YouTube_2.MP4";// 2560x1440
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/1920x1080/PlayStation%20VR%20Worlds-%20Ocean%20Descent%20-%20360%20Grad-Trailer%20[PlayStation%20VR]%20-%20YouTube_2.MP4";// 1920x1080
//		private static const FILE_NAME:String = "file:///H:/教程/360degree视频/1920x1080/PlayStation VR Worlds- Ocean Descent - 360 Grad-Trailer [PlayStation VR] - YouTube_2.MP4";// 1920x1080
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/3840x2160/360%20Google%20Spotlight%20Story-%20HELP/1.mp4";
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/3840x2160/360%20Google%20Spotlight%20Story-%20HELP/2.mp4";
//		private static const FILE_NAME:String = "file:///H:/UserData/Personal/Tencent%20Files/532230294/FileRecv/%E6%B5%8B%E8%AF%95%E6%AE%B5%E8%90%BD/%E6%B5%8B%E8%AF%95%E6%AE%B5%E8%90%BD/1.mov";
//		private static const FILE_NAME:String = "file:///M:/%E6%B8%B8%E6%88%8F/CG/%E5%90%84%E5%A4%A7%E6%B8%B8%E6%88%8F%E5%8E%82%E5%95%86%E4%BD%9C%E5%93%81CG/%E9%BE%99%E4%B9%8B%E4%BA%89%E9%9C%B82.mov";
		private static const TITLE:String = "LS Panorama Video Player";
		private static const VERSION:String = "20170607B";
		private static const MIN_FOV_Y:Number = 30;
		private static const FOV_Y:Number = 50;
		private static const MAX_FOV_Y:Number = 60;
		private static const CONTROLBAR_HEIGHT:Number = 52;
//		private static var ADVIDEOS_URL:Array = ["http://testopen.videoyi.com/webs/video/360Video/3840x2160/360 Google Spotlight Story- HELP/1.mp4", 
//			"http://testopen.videoyi.com/webs/video/360Video/3840x2160/360 Google Spotlight Story- HELP/2.mp4"];
		private static var ADVIDEOS_URL:Array = ["http://testopen.videoyi.com/webs/video/透明flv/dcbf33a47b24dd3353f3d42e43cf3769.flv", "http://testopen.videoyi.com/webs/video/360Video/3840x2160/360 Google Spotlight Story- HELP/transparent/1.mov", 
			"http://testopen.videoyi.com/webs/video/360Video/3840x2160/360 Google Spotlight Story- HELP/2.mp4"];
		
		private var fov:Number = FOV_Y;
		private var zNear:Number = 0.1;
		private var zFar:Number = 1000;
		
//		private static const 
//		private static const 
//		private static const 
		
		private var _stats:Stats;
		private var mainVideo:SphericalVideo1;
		private var adVideo:SphericalVideo1;
		private var controlBar:PlayControlBar1;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var totalTime:Number = 0;
		private var oldX:int = 0;
		private var oldY:int = 0;
		private var trackMouseMove:Boolean  =false;
		private var _mainVideoUrl:String;
		private var _urlPrefix:String;
		private var _flashvars:Object;
		
//		private var isSphericalVideo:Boolean = true; 
//		private var 
		// 三轴陀螺仪是分别感应Roll（左右倾斜）、Pitch（前后倾斜）、Yaw（左右摇摆）的全方位动态信息。总之三轴加速器是检测横向加速的，三轴陀螺仪是检测角度旋转和平衡的，合在一起称为六轴传感器
		/** 倾斜 */
		protected var pitch:Number = 0;
		/** 摇摆 */
		protected var yaw:Number = 0;
		/** 翻滚 */
		protected var roll:Number = 0;

//		public var 
//		public var 
//		public var 
		public var curLoadingProgress:Number = 0;
		
		private var _autoPlay:Boolean = false;
	
		
		public function SphericalVideoSamplePlayer_me1()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ENTER_FRAME, onEnterFrm);
			stage.addEventListener(Event.RESIZE, onResize);
			_flashvars = this.loaderInfo.parameters;
//			_mainVideoUrl = _flashvars.videoUrl;
			_mainVideoUrl = FILE_NAME;
			stage.quality = StageQuality.BEST;
			stage.scaleMode = StageScaleMode.NO_SCALE;
//			stage.scaleMode = StageScaleMode.SHOW_ALL;// 设为此类型则监听不到Event.RESIZE事件
			stage.align = StageAlign.TOP_LEFT;
			
			
			initVideo();
			initUI();
			initMenu();
		}
		
		private function initMenu():void
		{
			addContextMenuItem();
		}		
		
		private function addContextMenuItem():void
		{
			var menu:ContextMenu = contextMenu;
			if(!menu)
			{
				menu = new ContextMenu();
			}
			var titleItem:ContextMenuItem = new ContextMenuItem(TITLE, true, true, true);
			var versionItem:ContextMenuItem = new ContextMenuItem("version：" + VERSION, true, true, true);
			
			menu.customItems.push(titleItem);
			menu.customItems.push(versionItem);
			menu.hideBuiltInItems();
			contextMenu = menu;
		}		
		
		private function initUI():void
		{
			initControlBar();
			initStats();
			updateLayout();
		}		
		
		
		private function initVideo():void
		{
			initMainVideo();
//			initAdVideo();
		}
		
		
		
		private function initMainVideo():void
		{
			mainVideo = new SphericalVideo1(stage, 0, 0, 960, 540);
			mainVideo.name = "mainVideo";
//			mainVideo.autoPlay = _flashvars.autoPlay;
			mainVideo.videoUrl = _mainVideoUrl;
//			mainVideo.autoPlay = false;
			("SphericalVideoSamplePlayer_me.initMainVideo() : mainVideo.autoPlay = " + mainVideo.autoPlay);
			mainVideo.volume = 1;
//			mainVideo.addEventListener(SphericalVideo1.AVAILABLE, onSphericalVideoAvailable);
			mainVideo.addEventListener(SimpleVideoEvent.GOT_METADATA, onGotMainVideoMetaDataInfo);
			mainVideo.addEventListener(SimpleVideoEvent.LOADING_PROGRESS, mainVideoLoading);//视频加载中
			mainVideo.addEventListener(SimpleVideoEvent.PLAYING_PROGRESS, mainVideoPlayingProgress);//视频播放中
			mainVideo.addEventListener(SimpleVideoEvent.PLAY_COMPLETE, mainVideoPlayComplete);//视频播放完成
			mainVideo.addEventListener(SimpleVideoEvent.NS_PLAY_START2, onReadyToPlay);
			mainVideo.addEventListener(SimpleVideoEvent.LOAD_COMPLETE, onMainVideoLoadComplete);
			mainVideo.addEventListener(SimpleVideoEvent.BUFFER_FULL, onBufferfull);
//			mainVideo.addEventListener(RetryEvent.RETRY_FAILED, onVideoError);
			mainVideo.addEventListener(SimpleVideoEvent.VIDEO_PAUSED, onVideoPaused);
			mainVideo.addEventListener(SimpleVideoEvent.VIDEO_RESUMED, onVideoResumed);
//			mainVideo.addEventListener(SimpleVideoEvent.GOT_METADATA, onGotMainVideoMetaInfo);
		}
		
		private function initAdVideo():void
		{
			adVideo = new SphericalVideo1(stage, 0, 0, 700, 400);
			adVideo.name = "adVideo";
//			adVideo.autoPlay = false;
			adVideo.autoPlay = true;
			("SphericalVideoSamplePlayer_me.initAdVideo() : adVideo.autoPlay = " + adVideo.autoPlay);
			adVideo.volume = 0;
			adVideo.videoUrl = ADVIDEOS_URL[0];
//			adVideo.addEventListener(SphericalVideo1.AVAILABLE, onSphericalVideoAvailable);
			adVideo.addEventListener(SimpleVideoEvent.GOT_METADATA, onGotAdVideoMetaDataInfo);
//			adVideo.addEventListener(SimpleVideoEvent.LOADING_PROGRESS, adVideoLoading);//视频加载中
//			adVideo.addEventListener(SimpleVideoEvent.PLAYING_PROGRESS, adVideoPlayingProgress);//视频播放中
			adVideo.addEventListener(SimpleVideoEvent.PLAY_COMPLETE, adVideoPlayComplete);//视频播放完成
//			adVideo.addEventListener(SimpleVideoEvent.NS_PLAY_START2, onReadyToPlay);
			adVideo.addEventListener(SimpleVideoEvent.LOAD_COMPLETE, onAdVideoLoadComplete);
//			adVideo.addEventListener(SimpleVideoEvent.BUFFER_FULL, onBufferfull);
			//			adVideo.addEventListener(RetryEvent.RETRY_FAILED, onVideoError);
//			adVideo.addEventListener(SimpleVideoEvent.VIDEO_PAUSED, onVideoPaused);
//			adVideo.addEventListener(SimpleVideoEvent.VIDEO_RESUMED, onVideoResumed);
			setTimeout(function():void
			{
				adVideo.resumeVideo();
			},	20000);
		}
		
		
		private function initControlBar():void
		{
//			controlBar = new PlayControlBar1(mainVideo, this, true, stage.stageWidth);
			controlBar = new PlayControlBar1(mainVideo, this, mainVideo.autoPlay, stage.stageWidth);
//			controlBar.addEventListener("NeedToHidePlayButton", hidePlayButton);
//			controlBar.addEventListener("NeedToShowPlayButton", showPlayButton);
		}
		
		protected function onResize(evt:Event = null):void
		{
			//			ExternalInterface.call("eval","console.log(222)");
			
			Log.info("this.width = " + this.width, " , stage.stageWidth = " + stage.stageWidth + " , stage.stageHeight = " + stage.stageHeight);
			mainVideo.onResize();
			if(controlBar && this.contains(controlBar))
			{
//				this.removeChild(controlBar);
				controlBar.width = stage.stageWidth;
				controlBar.y = stage.stageHeight - CONTROLBAR_HEIGHT;
//				addChild(controlBar);
			}
		}
		
		protected function onEnterFrm(evt:Event):void
		{
			controlBar && controlBar.onEnterFrm(evt);
		}
		
		protected function onSphericalVideoAvailable(e:Event):void
		{
			/*nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			nc.addEventListener(ErrorEvent.ERROR, errorHandler);
			nc.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			ns.addEventListener(ErrorEvent.ERROR, errorHandler);
			ns.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			ns.client = this;
			ns.bufferTime = 2;
			mainVideo.attachNetStream(ns);
			ns.play(FILE_NAME);*/
			mainVideo.url = _mainVideoUrl;
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			Log.info("simpleVideo.netStatusHandler() : event.info.code = " + event.info.code);
			// 顺序依次为：Success --> Start --> Notify --> Full
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					//connectStream();
					break;
				case "NetStream.Play.Start":
					//					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.NS_PLAY_START2));
					//					onReadyToPlay();
					//					if(autoPlay==false ){
					//						pauseVideo();
					//					}else{
					//						isPlaying = true;
					//						onNSPlayStart();
					//					}
					//					isStreamStarted = true;
					break;
				case "NetStream.Play.Stop":
					//					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.PLAY_COMPLETE2));
					//					onPlayComplete();
					if(ExternalInterface.available)
					{
						try
						{
							ExternalInterface.call("console.log", "SimpleVideo.netStatusHandler(): NetStream.Play.Stop!");
						} 
						catch(error:Error) 
						{
							
						}
						
					}
					/*setTimeout(function():void{
					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.PLAY_COMPLETE2));
					onPlayComplete();
					}, TIME_DELAY_TO_FINISH * 1000);*/
					break;
				case "NetStream.Play.Complete":
					//					isPlaying = false;
					//					_isVideoPlayStarted = false;
					break;
				case "NetStream.Unpause.Notify":
					//					onResumed();
					break;
				case "NetStream.Seek.Notify":
					//					_isVideoPlayStarted = false;
					break;
				case "NetStream.SeekStart.Notify":
					
					break;
				case "NetStream.Buffer.Flush":
					//					onVideoPlayStart();
					//数据已完成流式加载，并且剩余缓冲区被清空。
					//onBufferFlush();
					break;
				case "NetStream.Buffer.Empty":
					//					onBuffering();//缓冲状态
					break;
				case "NetStream.Buffer.Full":
					//					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.BUFFER_FULL2));
					//					if(_isPlaying)
					//						onVideoPlayStart();
					
					//缓冲区已满，流开始播放。
					//					onBufferFull();
					break;
				case "NetStream.Play.NoSupportedTrackFound":
				case "NetStream.Play.StreamNotFound":
					if(ExternalInterface.available)
					{
						try
						{
							ExternalInterface.call("console.log", "SimpleVideo.netStatusHandler(): NetStream.Play.StreamNotFound!");
						} 
						catch(error:Error) 
						{
							
						}
					}
					
					ioErrorHandler();
					break;
			}
		}
		
		private function updateLayout():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function initStats():void
		{
			// TODO Auto Generated method stub
			_stats = new Stats();
			addChild(_stats);
		}
		
//		public function onMetaData(info:Object):void
		public function onGotMainVideoMetaDataInfo(evt:Event):void
		{
			Log.info("onGotMainVideoMetaDataInfo");
			
			mainVideo.setProjectionType();
			
			
			mainVideo.setFOV(fov, zNear, zFar);
		
//			stage.addEventListener(MouseEvent.CLICK, onMouseClick);
//			mainVideo.addEventListener(MouseEvent.CLICK, onMouseClick);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			
		}
		
		
		public function onGotAdVideoMetaDataInfo(info:Object):void
		{
			Log.info("onGotAdVideoMetaDataInfo");
			
			adVideo.setProjectionType();
			adVideo.setFOV(fov, zNear, zFar);
		}
		
		
		protected function onMouseClick(evt:MouseEvent):void
		{
//			controlBar.onClickBtn();
			evt.stopImmediatePropagation();
			controlBar.switchPlaying();
//			controlBar.playButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
//			controlBar.playBtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}		
		
		
		protected function onMouseDown(evt:MouseEvent):void
		{
//			if(evt.stageY >= intera)
			trackMouseMove = true;
			oldX = evt.stageX;
			oldY = evt.stageY;
		}
		
		protected function onMouseMove(evt:MouseEvent):void
		{
			if(!trackMouseMove)
				return;
			
			var newX:Number = evt.stageX;
			var newY:Number = evt.stageY;
			var deltaX:Number = (newX - oldX) * FOV_Y / 360;
			var deltaY:Number = (newY - oldY) * FOV_Y / 360;
			
			oldX = newX;
			oldY = newY;
			
			pitch += deltaY;
			if(pitch < -90)
				pitch = -90;
			else if(pitch > 90)
				pitch = 90;
			
			yaw += deltaX;
			if(yaw< -180)
				yaw = 180;
			else if(yaw > 180)
				yaw = -180;
			
			mainVideo && mainVideo.setCameraView(pitch, yaw, 0);
			adVideo && adVideo.setCameraView(pitch, yaw, 0);
			
		}
		
		protected function onMouseUp(evt:MouseEvent):void
		{
			trackMouseMove = false;
		}	
		
		protected function onMouseWheel(evt:MouseEvent):void
		{
			// TODO Auto-generated method stub
			fov -= evt.delta;
			if(fov < MIN_FOV_Y)
			{
				fov = MIN_FOV_Y;
				return;
			}
			else if(fov > MAX_FOV_Y)
			{
				fov = MAX_FOV_Y;
				return;
			}
			mainVideo && mainVideo.setFOV(fov, zNear, zFar);
			adVideo && adVideo.setFOV(fov, zNear, zFar);
		}
		
		protected function onRollOut(event:MouseEvent):void
		{
			trackMouseMove = false;
		}
		
		public function onCuePoint(info:Object):void
		{
			Log.info("onCuePoint");
		}
		
		
		public function onXMPData(info:Object):void
		{
			Log.info("onXMPData");
		}
		
		
		public function onPlayStatus(info:Object):void
		{
			Log.info("onPlayStatus");
		}
		
		
		protected function errorHandler(event:ErrorEvent = null):void
		{
			// TODO Auto-generated method stub
			Log.info("errorHandler() : " + event);
		}
		
		protected function ioErrorHandler(event:IOErrorEvent = null):void {
			//			_isStreamFound = false;
			//			Log.info("Unable to locate video: " + _url);
			//			Log.info("SimpleVideo.ioErrorHandler() : Unable to locate video: " + _url);
			Log.info("ioErrorHandler() : " + event);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent = null):void {
			Log.info("securityErrorHandler: " + event);
			//			Log.info("SimpleVideo.securityErrorHandler() : Unable to locate video: " + _url);
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent = null):void {
			//ignore metadata error message
			//Log.info(this + "	asyncErrorHandler->>"+event.text);
			Log.info("asyncErrorHandler() : " + event);
		}
		
		private function onReadyToPlay(e:SimpleVideoEvent):void
		{
			//			originVideoWidth = mainVideo.width;
			//			originVideoHeight = mainVideo.height;
			//			onResize();
		}	
		
		private function mainVideoLoading(e:SimpleVideoEvent): void {
			//			Log.info("mainVideoLoading" + e.toString() + " , " +　e.data);
			curLoadingProgress = e.data / 100;
		}
		
		
		private function mainVideoPlayingProgress(e:SimpleVideoEvent): void {
			Log.info("mainVideoPlayingProgress" + e.toString() + " , " +　e.data);
			//			curLoadingProgress = e.data / 100;
			//			videoEMC && videoEMC["changeVideoTime"](e.data);
			//			controlBar.updateBar(e.data);
		}
		
		
		
		private function mainVideoPlayComplete(e:SimpleVideoEvent): void {
			//			this.stopAd();
			//			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
			//			controlBar.playButton.mouseEnabled = false;
			controlBar.onPlayComplete();
		}
		
		private function adVideoLoading(e:SimpleVideoEvent): void {
			//			Log.info("mainVideoLoading" + e.toString() + " , " +　e.data);
			curLoadingProgress = e.data / 100;
		}
		
		
		private function adVideoPlayingProgress(e:SimpleVideoEvent): void {
			//			Log.info("mainVideoLoading" + e.toString() + " , " +　e.data);
			//			curLoadingProgress = e.data / 100;
			//			videoEMC && videoEMC["changeVideoTime"](e.data);
			//			controlBar.updateBar(e.data);
		}
		
		
		
		private function adVideoPlayComplete(e:SimpleVideoEvent): void {
			Log.info("SphericalVideoSamplePlayer_me.adVideoPlayComplete() : ");
			//			this.stopAd();
			//			dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
			//			controlBar.playButton.mouseEnabled = false;
//			controlBar.onPlayComplete();
		}
		
		private function onVideoPaused(evt:Event):void
		{
			//			videoEMC && videoEMC["pauseAd"]();
//			GlobalManager.onVideoPaused();
		}
		
		private function onVideoResumed(evt:Event):void
		{
			//			videoEMC && videoEMC["resumeAd"]();
//			GlobalManager.onVideoResumed();
		}	
		
		protected function onMainVideoLoadComplete(evt:SimpleVideoEvent):void
		{
			Log.info("onMainVideoLoadComplete");
		}
		
		protected function onAdVideoLoadComplete(evt:SimpleVideoEvent):void
		{
			Log.info("onAdVideoLoadComplete");
		}
		
		
		
		protected function onBufferfull(evt:SimpleVideoEvent):void
		{
			Log.info("onBufferfull");
		}
		
		
	}
}