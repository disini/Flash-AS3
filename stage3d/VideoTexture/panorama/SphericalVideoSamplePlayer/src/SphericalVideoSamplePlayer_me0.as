package
{
	import com.adobe.media.SphericalVideo;
	import com.view.bar.PlayControlBar;
	
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
	
	import hires.debug.Stats;
	
	
	[SWF(frameRate="60", width="960", height="560", backgroundColor="#808080")]
	public class SphericalVideoSamplePlayer_me0 extends Sprite
	{
//		private static const FILE_NAME:String = "../assets/360 Google Spotlight Story- HELP.mp4";
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/3840x2160/360%20Google%20Spotlight%20Story-%20HELP.mp4";
		private static const FILE_NAME:String = "file:///H:/教程/360degree视频/3840x2160/Ocean Descent VR 360 - YouTube.MP4";
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/3840x2160/360%20Google%20Spotlight%20Story-%20HELP/1.mp4";
//		private static const FILE_NAME:String = "file:///H:/%E6%95%99%E7%A8%8B/360degree%E8%A7%86%E9%A2%91/3840x2160/360%20Google%20Spotlight%20Story-%20HELP/2.mp4";
//		private static const FILE_NAME:String = "file:///H:/UserData/Personal/Tencent%20Files/532230294/FileRecv/%E6%B5%8B%E8%AF%95%E6%AE%B5%E8%90%BD/%E6%B5%8B%E8%AF%95%E6%AE%B5%E8%90%BD/1.mov";
//		private static const FILE_NAME:String = "file:///M:/%E6%B8%B8%E6%88%8F/CG/%E5%90%84%E5%A4%A7%E6%B8%B8%E6%88%8F%E5%8E%82%E5%95%86%E4%BD%9C%E5%93%81CG/%E9%BE%99%E4%B9%8B%E4%BA%89%E9%9C%B82.mov";
//		private static const 
//		private static const 
		private static const MIN_FOV_Y:Number = 40;
		private static const FOV_Y:Number = 50;
		private static const MAX_FOV_Y:Number = 60;
		
		private var fov:Number = FOV_Y;
		private var zNear:Number = 0.1;
		private var zFar:Number = 1000;
		
//		private static const 
//		private static const 
//		private static const 
		
		private var _stats:Stats;
		private var sphericalVideo:SphericalVideo;
		private var controlBar:PlayControlBar;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var totalTime:Number = 0;
		private var oldX:int = 0;
		private var oldY:int = 0;
		private var trackMouseMove:Boolean  =false;
		
//		private var isSphericalVideo:Boolean = true; 
//		private var 
		// 三轴陀螺仪是分别感应Roll（左右倾斜）、Pitch（前后倾斜）、Yaw（左右摇摆）的全方位动态信息。总之三轴加速器是检测横向加速的，三轴陀螺仪是检测角度旋转和平衡的，合在一起称为六轴传感器
		/** 倾斜 */
		protected var pitch:Number = 0;
		/** 摇摆 */
		protected var yaw:Number = 0;
		/** 翻滚 */
		protected var roll:Number = 0;

		
		public function SphericalVideoSamplePlayer_me0()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.quality = StageQuality.BEST;
//			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.align = StageAlign.TOP_LEFT;
			
			sphericalVideo = new SphericalVideo(stage, 0, 0, 960, 540);
			sphericalVideo.addEventListener(SphericalVideo.AVAILABLE, onSphericalVideoAvailable);
			
			updateLayout();
			initStats();
			
		}
		
		protected function onSphericalVideoAvailable(e:Event):void
		{
			nc = new NetConnection();
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
			sphericalVideo.attachNetStream(ns);
			ns.play(FILE_NAME);
		}
		
		protected function onNetStatus(event:NetStatusEvent):void
		{
			trace("simpleVideo.netStatusHandler() : event.info.code = " + event.info.code);
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
		
		public function onMetaData(info:Object):void
		{
			trace("onMetaData");
			
			sphericalVideo.setProjectionType();
			
			
			sphericalVideo.setFOV(fov, zNear, zFar);
		
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			
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
			
			sphericalVideo.setCameraView(pitch, yaw, 0);
			
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
			sphericalVideo.setFOV(fov, zNear, zFar);
		}
		
		public function onCuePoint(info:Object):void
		{
			trace("onCuePoint");
		}
		
		
		public function onXMPData(info:Object):void
		{
			trace("onXMPData");
		}
		
		
		public function onPlayStatus(info:Object):void
		{
			trace("onPlayStatus");
		}
		
		
		protected function errorHandler(event:ErrorEvent = null):void
		{
			// TODO Auto-generated method stub
			trace("errorHandler() : " + event);
		}
		
		protected function ioErrorHandler(event:IOErrorEvent = null):void {
			//			_isStreamFound = false;
			//			trace("Unable to locate video: " + _url);
			//			trace("SimpleVideo.ioErrorHandler() : Unable to locate video: " + _url);
			trace("ioErrorHandler() : " + event);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent = null):void {
			trace("securityErrorHandler: " + event);
			//			trace("SimpleVideo.securityErrorHandler() : Unable to locate video: " + _url);
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent = null):void {
			//ignore metadata error message
			//trace(this + "	asyncErrorHandler->>"+event.text);
			trace("asyncErrorHandler() : " + event);
		}
	}
}