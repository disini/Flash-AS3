package com.adobe.media
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.event.simpleVideo.SimpleVideoEvent;
	import com.manager.GlobalManager;
	import com.media.simpleVideo.VideoCallbackClient;
	import com.utils.Log;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.VideoTexture;
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	public class SphericalVideo extends EventDispatcher
	{
		public static const AVAILABLE:String = "Available";
		public static const PROJECTION_NONE:int = 0;
//		public static const  
//		public static const  
		
		private var texture:VideoTexture;
		private var tempTexture:Texture;
		private var texture1:VideoTexture;
		private var projection:Projection;
		
		private var stage3D:Stage3D; 
		private var context3D:Context3D;
		private var program:Program3D;
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
//		private var 
//		private var 
		
		private const VERTEX_SHADER:String = 
			"m44 op, va0, vc0\n" + // copy position to output 
			"mov v0, va1"// copy uv to varying variable v0
		private const FRAGMENT_SHADER:String = 
//			"tex oc, v0, fs0 <2d, clamp, nomip>\n";//tex"在source1所指定的u,v坐标上，对source2中的纹理进行采样，只能用于片段着色器
//			fs0为 纹理寄存器，2d 是说明纹理格式是2D的；
//			"tex oc, v0, fs0 <2d>\n";
//			"tex oc, v0, fs0 <2d, linear>\n";
//			"tex oc, v0, fs0 <2d, nearest>\n";
			"tex oc, v0, fs0 <2d, linear, clamp, nomip>\n";// 对纹理进行线性插值，减少放大失真（马赛克）
//			"tex oc, v0, fs0 <2d, linear, wrap, nomip>\n";// 黑屏
//			"tex oc, v0, fs0 <2d, linear, repeat, nomip>\n";// 黑屏
		
		private var vertexAssembly:AGALMiniAssembler = new AGALMiniAssembler();
		private var fragmentAssembly:AGALMiniAssembler = new AGALMiniAssembler();
		private var nc:NetConnection;
		private var ns:NetStream; 
		private var callbackClient:VideoCallbackClient;
		private var playingStatusTimer:Timer;
		private var _hasInited:Boolean = false;
		
		protected var viewTransform:Matrix3D = new Matrix3D();
		protected var projectionTransform:Matrix3D = new Matrix3D();
		

		
//		private var stageWidth:int;
//		private var stageHeight:int;
		private var videoArea:Rectangle = new Rectangle();
		private var textureReady:Boolean = false; 
//		private var 
//		private var 
		private var _autoPlay:Boolean = true;
		
		private var _loadComplete:Boolean = false;
		
		private var _url:String;
		
		public var isAutoSize:Boolean = false;
		
		private var _isPlaying:Boolean = false;
		private var _isVideoPlayStarted:Boolean = false;
		public var duration:Number = 0;
		
		public var isStreamStarted:Boolean = false;
		
		public var metaDataInfo:Object;
		private var _curLoadedPercent:int = 0;
		
		private var _curLoadedVideoTime:Number = 0;
		
		public static const TIME_DELAY_TO_FINISH:Number = 0.2;// 单位：s
		
		private var _needReloadingVideoAfterPlayComplete:Boolean = false;
		private var _loadedFunc:Function;
		
		/**
		 * 一般情况下，发现是同样的url值，就不要加载，在特殊情况下也可以设置为false，免除相同值检测
		 */		
		public var isRefuseSameURL:Boolean = true;
		
		private var _isStreamFound:Boolean = false;
		
		private var _bufferTime:Number = 0.8;
		
		public var loadIdx:int;
		/** 是否在播放完成后停止视频 */		
		public var isCloseAfterPlayComplete:Boolean = false;
		
		/**
		 * 是否报告播放状态，默认为true。如果是false，则playingStatusTimer不要初始化，不主动报告播放进度
		 */		
		public var isReportPlayingStatus:Boolean = true;
		
		private var loadingStatusTimer:Timer;
		
		/**
		 * 报告当前时间的间隔值。默认为0.5，单位为秒
		 */		
		public var reportStatusInterval:Number = 0.5;
		
		private var _videoUrl:String;
		
		
		private var _stage:Stage;
		
		public var name:String;
		
		private var nsVec:Vector.<NetStream> = new Vector.<NetStream>;
		
		private var _volume:Number;


		
//		public function SphericalVideo(target:IEventDispatcher=null)
		public function SphericalVideo(stage:Stage, x:int, y:int, width:int, height:int):void
		{
//			super(target);
			_stage = stage;
//			stageWidth = width;
//			stageHeight = height;
			
			texture = null;
			texture1 = null;
//			projection = null;
			context3D = null;
//			stage3D = stage.stage3Ds[0];
			var obj:Object = {};
			var statusArr:Array = GlobalManager.stage3DsStatus;
			for(var i:int = 0; i < stage.stage3Ds.length;i++)
			{
//				if(!stage.stage3Ds[i].context3D)
				if(!statusArr.length || !statusArr[i] || !statusArr[i].used)
//				if(!statusArr.length || !statusArr[i] || !statusArr[i].used)
				{
					stage3D = stage.stage3Ds[i];
					if(!statusArr.length)
					{
//						var obj:Object = {};
						obj.used = true;
						statusArr.push(obj);
					}
					else
					{
						if(statusArr[i])
						{
							statusArr[i].used = true;
						}
						else
						{
//							var obj:Object = {};
							obj.used = true;
							statusArr.push(obj);
						}
					}
					break;
				}
			}
			
			stage3D.x = x;
			stage3D.y = y;
			
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContect3DCreated);
			stage3D.requestContext3D("auto", Context3DProfile.BASELINE_EXTENDED);
//			stage3D.
//			stage3D.requestContext3DMatchingProfiles(
		}
		
	
		
		private function snapVideoToTexture():void
		{
//			bitmapData.lock();
//			bitmapData.fillRect(_clippingRect, 0);
//			bitmapData.draw(_player.container, null, null, null, _clippingRect);
//			bitmapData.unlock();
		}
		
		public function attachNetStream(ns:NetStream):void
		{
			if(texture)
				texture.attachNetStream(ns);
			
			// Reset internal variables that need to be newly set for new stream
			//			projection = null;
			
			viewTransform.identity();
			projectionTransform.identity();
			textureReady = false;
			
		}
		
		
		public function attachNetStreams(nsVec:Vector.<NetStream>):void
		{
			if(texture)
				texture.attachNetStream(ns);
			
			// Reset internal variables that need to be newly set for new stream
			//			projection = null;
			viewTransform.identity();
			projectionTransform.identity();
			textureReady = false;
			
		}
		
		public function setFOV(fovY:Number, zNear:Number, zFar:Number):void
		{
			var fovX:Number = _stage.stageWidth / _stage.stageHeight * fovY;
			var xScale:Number = 1.0 / Math.tan((fovX / 2 ) * Math.PI/180);
			var yScale:Number = 1.0 / Math.tan((fovY / 2) * Math.PI / 180);
			
			projectionTransform.copyRawDataFrom(Vector.<Number>([// vector 要从中复制数据的 Vector 对象。
				//				index
				//				transpose:是否转置
				xScale, 0.0, 0.0, 0.0,
				0.0, yScale, 0.0, 0.0,
				0.0, 0.0, zFar / (zFar - zNear), 1.0,// zScale
				0.0, 0.0, (zNear * zFar) / (zNear - zFar), 0.0
			]));
			
			if(textureReady)
				renderFrame();
		}
		
		public function setCameraView(pitch:Number, yaw:Number, roll:Number):void
		{
			viewTransform.identity();
			viewTransform.appendRotation(roll, Vector3D.Z_AXIS);
			viewTransform.appendRotation(yaw, Vector3D.Y_AXIS);
			viewTransform.appendRotation(pitch, Vector3D.X_AXIS);
			
			if(textureReady)
				renderFrame();
		}
		
		
		
		public function setProjectionType():void
		{
			if(!context3D || !texture)
				return;
			projection = new EquirectangularProjection();
			
			// Compile shaders
			vertexAssembly.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER, false);
			fragmentAssembly.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER, false);
			
			// Upload and set shader programs
			program = context3D.createProgram();
			program.upload(vertexAssembly.agalcode, fragmentAssembly.agalcode);
			context3D.setProgram(program);
			
			// Update indices and vertices data from Projection
			indexBuffer = context3D.createIndexBuffer(projection.getIndices().length);
			indexBuffer.uploadFromVector(projection.getIndices(), 0, projection.getIndices().length);
			vertexBuffer = context3D.createVertexBuffer(projection.getVertices().length / Projection.DATA_PER_VERTEX, Projection.DATA_PER_VERTEX);
			vertexBuffer.uploadFromVector(projection.getVertices(), 0, projection.getVertices().length / Projection.DATA_PER_VERTEX);
			
			// Identify vertex data inputs for vertex program
			context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);// va0 is position
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);// va1 is uv
			
			// Set texture
			context3D.setTextureAt(0, texture);
//			context3D.totalGPUMemory
//			context3D.
//			context3D.setRenderToBackBuffer()
		}
		
		protected function onContect3DCreated(e:Event):void
		{
			if(!Context3D.supportsVideoTexture)
				return;
			
			context3D = stage3D.context3D;
			
			context3D.setCulling(Context3DTriangleFace.BACK);
//			context3D.configureBackBuffer(stageWidth, stageHeight, 8, true, true, true);
//			context3D.configureBackBuffer(_stage.stageWidth*2, _stage.stageHeight*2, 16, true, true, true);
			context3D.configureBackBuffer(_stage.stageWidth, _stage.stageHeight, 16, true, true, true);
//			context3D.configureBackBuffer(2*stageWidth, 2*stageHeight, 16, true, true, true);
			
			texture = context3D.createVideoTexture();
			texture.addEventListener(Event.TEXTURE_READY, onTextureReady);
			
//			tempTexture = context3D.createTexture(1920, 1080, Context3DTextureFormat.BGRA, true);
			tempTexture = context3D.createTexture(2048, 2048, Context3DTextureFormat.BGRA, true);

			if(hasEventListener(AVAILABLE))
				dispatchEvent(new Event(AVAILABLE));
			url = videoUrl;
			
		}
		
		protected function onTextureReady(event:Event):void
		{
			textureReady = true;
			renderFrame();
		}		
		
		
		private function renderFrame():void
		{
			var m:Matrix3D = new Matrix3D();
			
			m.append(viewTransform);
			m.append(projectionTransform);
			
			context3D.clear(0, 0, 0, 0);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			context3D.drawTriangles(indexBuffer);
			
			//context3D.setRenderToTexture(tempTexture);
//			context3D.setRenderToBackBuffer();
			context3D.present();
//			context3D.drawToBitmapData(
		}		
		
		
		public function get bufferTime():Number
		{
			return _bufferTime;
		}
		
		public function set bufferTime(value:Number):void
		{
			_bufferTime = value;
		}
		
		public function get loadedFunc():Function
		{
			return _loadedFunc;
		}
		
		public function set loadedFunc(value:Function):void
		{
			_loadedFunc = value;
		}
		
		
		public function get isPlaying():Boolean
		{
			return _isPlaying && _isVideoPlayStarted;
		}
		
		public function set isPlaying(value:Boolean):void
		{
			_isPlaying = value;
			
			//			initPlayingStatusTimer();
		}
		
		public function get url():String{
			return _url;
		}
		/** 加载视频素材 */
		public function set url(value:String):void{
			if(!value)return;
			
			if(isRefuseSameURL && value==_url){//如果需要杜绝同样的值，则检查之
				return;
			}
			
			//EIUtil.logTrace(this+" set url "+_url);
			
			if(value && value!="" ){
				_url = value;
				if(_url==""){
					closeVideo();
				}else{
					loadVideo();
				}
			}else{
				closeVideo();
			}
		}
		
		/*public function changeSize(w:Number, h:Number):void{
		width = w;
		height = h;
		dispatchEvent(new CommonControlsEvent(CommonControlsEvent.RESIZE));
		}
		*/
		protected function loadVideo():void{
			_loadComplete = false;
			_isStreamFound = true;
//			var nc:NetConnection;
//			var ns:NetStream; 
//			var callbackClient:VideoCallbackClient;
			if(!nc)
				nc = new NetConnection();
			
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.addEventListener(ErrorEvent.ERROR, errorHandler);
			nc.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			nc.connect(null);
			if(!ns){
				ns = new NetStream(nc);
				updateVideoVol();
			}
			ns.bufferTime=_bufferTime;
			ns.checkPolicyFile = true;
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			ns.addEventListener(ErrorEvent.ERROR, errorHandler);
			ns.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			ns.play(_url);
			
			if(!callbackClient)
				callbackClient = new VideoCallbackClient(this);
			
			ns.client = callbackClient;
//			var videoObj:Object = {];
//			videoObj.nc = nc;
//			videoObj.ns = ns;
//			videoObj.nc = nc;
			attachNetStream(ns);
//			initLoadingStatusTimer();
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.LOAD_START, { url: _url}));
			CONFIG::debug
				{
					if(!_hasInited)
					{
						//				Log.info("SimpleVideo.loadVideo() : loadVideo Again!"); 
						Log.info("SimpleVideo.loadVideo() : loadVideo " + loadIdx + " first time! url = " + _url); 
					}
					else
					{
						Log.info("SimpleVideo.loadVideo() : loadVideo " + loadIdx + " Again! url = " + _url); 
					}
				}
		}
		
		private function initLoadingStatusTimer():void{
			if(!loadingStatusTimer)
				loadingStatusTimer = new Timer(reportStatusInterval*1000, 0);
			loadingStatusTimer.start();
			loadingStatusTimer.addEventListener(TimerEvent.TIMER, reportLoadingStatus);
		}
		
		private function reportLoadingStatus(e:TimerEvent):void{
			if(!ns){
				return;
			}
			//			var pct:int = int(ns.bytesLoaded/ns.bytesTotal * 100);
			_curLoadedPercent = int(ns.bytesLoaded/ns.bytesTotal * 100);
			_curLoadedVideoTime = ns.bytesLoaded/ns.bytesTotal * duration;
			if(_curLoadedPercent ==100){
				_loadComplete = true;
				stopLoadingStatusTimer();
				if(_isStreamFound){//如果视频文件没找到，也就是服务器返回错误信息，则不要派发加载完成的事件
					onLoadComplete();
				}
			}
			
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.LOADING_PROGRESS, _curLoadedPercent));
		}
		
		private function stopLoadingStatusTimer():void{
			if(loadingStatusTimer){
				loadingStatusTimer.stop();
				loadingStatusTimer.removeEventListener(TimerEvent.TIMER, reportLoadingStatus);
				loadingStatusTimer = null;
			}
		}
		
		public function resumeVideo():void{
			Log.info("SimpleVideo.resumeVideo() : ns = " + ns);
			if(!ns)
				return;
			//			Log.info("SimpleVideo.resumeVideo() : ");
			//ns.seek(ns.time);
			ns.resume();
			initPlayingStatusTimer();
			isPlaying = true;
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.VIDEO_RESUMED));
		}
		
		public function pauseVideo():void{
			if(ns){
				
				ns.pause();
			}else{
				
			}
			isPlaying = false;
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.VIDEO_PAUSED));
		}
		
		public function closeLoader():void{
			//EIUtil.logTrace(this+"closeLoader()");
			closeVideo();
		}
		
		public function closeVideo():void{
			Log.info("SimpleVideo.closeVideo()"); 
			this.volume = 0;
			closeNCAndNS();
			stopVideo();
//			this.clear();
//			if(_needReloadingVideoAfterPlayComplete)
//			{
//				setTimeout(function():void
//				{
//					//					clear();
//					loadVideo();
//				}, 500);
//			}
		}
		
		private function closeNCAndNS():void{
			if(ns){
				//ns.client = this;
//				ns.close();
				ns.dispose();
				ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
				ns.removeEventListener(ErrorEvent.ERROR, errorHandler);
				ns.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				ns.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				ns = null;
				Log.info("SimpleVideo.closeNCAndNS(): now ns == null!"); 
			}
			/*if(callbackClient){
			callbackClient.destroy();
			callbackClient = null;
			}*/
			if(nc){
				nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				nc.removeEventListener(ErrorEvent.ERROR, errorHandler);
				nc.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				nc.close();
				nc = null;
			}
			
		}
		
		public function stopVideo():void{
			//EIUtil.logTrace(this+" stopVideo()");
			isPlaying = false;
			_isVideoPlayStarted = false;
			stopPlayingStatusTimer();
			stopLoadingStatusTimer();
			/*seek(0);
			if(ns){
			ns.pause();
			}*/
			//			setTimeout(this.clear, 500);
			
			//			this.clear();
			//			Log.info("SimpleVideo.stopVideo() : seek(0)"); 
			Log.info("SimpleVideo.stopVideo()"); 
		}
		
		
		
		public function set volume(value:Number):void {
			_volume = value;
			updateVideoVol();
		}
		
		private function updateVideoVol():void {
			if(!ns)return;
			var st:SoundTransform = ns.soundTransform;
			st.volume = _volume;
			ns.soundTransform = st;
		}
		
		public function get volume():Number {
			if(ns)
				_volume = ns.soundTransform.volume;
			
			return _volume;
		}
		
		private function initPlayingStatusTimer():void{
			if(!isReportPlayingStatus) 
				return;
			if(!playingStatusTimer){
				reportPlayingStatus();
				playingStatusTimer = new Timer(reportStatusInterval*1000, 0);
			}
			if(!playingStatusTimer.running){
				playingStatusTimer.start();
				playingStatusTimer.addEventListener(TimerEvent.TIMER, reportPlayingStatus);
			}
		}
		
		private function stopPlayingStatusTimer():void{
			if(playingStatusTimer){
				playingStatusTimer.stop();
				playingStatusTimer.removeEventListener(TimerEvent.TIMER, reportPlayingStatus);
				playingStatusTimer = null;
			}
		}
		
		private function reportPlayingStatus(e:TimerEvent=null):void{
			//if(ns)
			//EIUtil.logTrace(this+" reportPlayingStatus() "+ns.time+" duration:"+duration);
			if(duration==0)return;
			if(ns)
				dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.PLAYING_PROGRESS, ns.time));
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			//ignore metadata error message
			//trace(this + "	asyncErrorHandler->>"+event.text);
		}
		
		public function onLoadComplete():void{
			//EIUtil.logTrace(this + " onLoadComplete")
			CONFIG::debug
				{
					Log.info("SimpleVideo.onLoadComplete() : video loading " + loadIdx + " complete!" + "  _url = " + _url);
				}
				if(!_hasInited)
				{
					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.LOAD_COMPLETE, ns.time));
					if(_loadedFunc!=null){
						_loadedFunc.apply();
					}
					_hasInited = true;
				}
		}
		/**
		 * 缓冲中
		 * 
		 */	
		public function onBuffering():void{
			//trace(this + " onBuffering");
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.BUFFER_EMPTY));
		}
		
		protected function onBufferFull():void{
			//trace(this +" onBufferFull");
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.BUFFER_FULL));
		}
		
		protected function onBufferFlush():void{
			//EIUtil.logTrace(this +" onBufferFlush - isPlaying"+isPlaying);
			if(_isPlaying){//如果是正在播放状态，却遇到了Flush的情况，则可能导致异常暂停，所以在此强行继续播放
				//EIUtil.logTrace("如果是正在播放状态，却遇到了Flush的情况，则可能导致异常暂停，所以在此强行继续播放");
				//resumeVideo();
			}
			//var delayResume:DelayFuncionCall = new DelayFuncionCall(resumeAfterFlush, 1000);
		}
		
		private function resumeAfterFlush():void{
			//trace("确保在异常暂停情况下继续播放视频");
		}
		
		protected function onResumed():void{
			//trace(this +" onResumed");
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.NS_RESUMED));
			if(isStreamStarted){
				onNSPlayStart();
			}
		}
		
		/**
		 * 播放完成后调度
		 * 
		 */		
		public function onPlayComplete():void{
			
			//EIUtil.logTrace(this+" onPlayComplete" +this.ns.time);
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.PLAY_COMPLETE, this.ns.time));
			if(isCloseAfterPlayComplete){//如果播放完毕，需要自我销毁，就直接关闭视频，否则只是断开连接，但最后一帧画面不消失
				Log.info("SimpleVideo.onPlayComplete() : closeVideo()");
				closeVideo();
			}else{
				Log.info("SimpleVideo.onPlayComplete() : stopVideo()");
				stopVideo();
			}
			//			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.PLAY_COMPLETE, this.ns.time));
		}
		
		protected function onNSPlayStart():void{
			dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.NS_PLAY_START));
		}
		
		
		
		protected function onVideoPlayStart():void{
			if(_isVideoPlayStarted == false){
				dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.VIDEO_PLAY_START));
				_isVideoPlayStarted = true;
				//				_isPlaying = true;
			}
		}
		
		/**
		 *  
		 * @param event
		 * 
		 */		
		private function netStatusHandler(event:NetStatusEvent):void {
			//PAPManager.instance().log(this+" netStatusHandler:"+event.info.code)
			//if(ns){
			//trace("已经加载：" + (ns.bytesLoaded/ns.bytesTotal * 100) + "%");
			//trace("bufferLength " + ns.bufferLength +" bufferTime:"+ ns.bufferTime);
			//}
			Log.info("simpleVideo.netStatusHandler() : event.info.code = " + event.info.code + ", this.name = " + this.name);
			// 顺序依次为：Success --> Start --> Notify --> Full
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					//connectStream();
					break;
				case "NetStream.Play.Start":
					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.NS_PLAY_START2));
					//trace(url+"Start [" + ns.time.toFixed(3) + " seconds] autoPlay"+autoPlay);
					onReadyToPlay();
					if(autoPlay==false ){
						pauseVideo();
					}else{
						isPlaying = true;
						onNSPlayStart();
					}
					isStreamStarted = true;
					break;
				case "NetStream.Play.Stop":
					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.PLAY_COMPLETE2));
					//					//EIUtil.logTrace("Stop [" + ns.time.toFixed(3) + " seconds]");
					//					//isPlaying = false;
					onPlayComplete();
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
					isPlaying = false;
					_isVideoPlayStarted = false;
					break;
				case "NetStream.Unpause.Notify":
					onResumed();
					break;
				case "NetStream.Seek.Notify":
					_isVideoPlayStarted = false;
					break;
				case "NetStream.SeekStart.Notify":
					
					break;
				case "NetStream.Buffer.Flush":
					//					onVideoPlayStart();
					//数据已完成流式加载，并且剩余缓冲区被清空。
					//onBufferFlush();
					break;
				case "NetStream.Buffer.Empty":
					onBuffering();//缓冲状态
//					onPlayComplete();
					break;
				case "NetStream.Buffer.Full":
					dispatchEvent(new SimpleVideoEvent(SimpleVideoEvent.BUFFER_FULL2));
					if(_isPlaying)
						onVideoPlayStart();
					
					//缓冲区已满，流开始播放。
					onBufferFull();
					break;
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
		
		protected function errorHandler(event:ErrorEvent = null):void
		{
			// TODO Auto-generated method stub
			Log.info("SimpleVideo.onErrorHandler() : " + event);
		}
		
		protected function ioErrorHandler(event:IOErrorEvent = null):void {
			_isStreamFound = false;
			//trace("Unable to locate video: " + _url);
			Log.info("SimpleVideo.ioErrorHandler() : Unable to locate video: " + _url);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent = null):void {
			//trace("securityErrorHandler: " + event);
			Log.info("SimpleVideo.securityErrorHandler() : Unable to locate video: " + _url);
		}
		
		public function get currentTime():Number{
			if(ns)
				return ns.time;
			else
				return 0;
		}
		
		protected function onReadyToPlay():void{
			
		}
		
		public function replay():void{
			seek(0);
			Log.info("SimpleVideo.replay() :  ns.time = " + ns.time);
			resumeVideo();
			//			playVideo();
		}
		
		public function seek(offset:Number, needPlay:Boolean = true):void{
			trace(this+" seek()"+offset);
			if(ns)
			{
				ns.seek(offset);
				//				ns.play2();
				if(needPlay)
				{
					ns.resume();
				}
			}
		}
		
		/** 当前已经加载到的视频流的时长 */
		public function get curLoadedVideoTime():Number
		{
			return _curLoadedVideoTime;
		}
		
		/** 当前已经加载的视频流的百分比 */
		public function get curLoadedPercent():int
		{
			return _curLoadedPercent;
		}
		
		public function get loadComplete():Boolean
		{
			return _loadComplete;
		}
		
		public function get hasInited():Boolean
		{
			return _hasInited;
		}
		
		
		
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
		
		public function set autoPlay(value:Boolean):void// 在 VideoLoadEvent.createVideo()里赋值
		{
			_autoPlay = value;
		}
		
			
		
		
		
		public function onResize():void
		{
			context3D.configureBackBuffer(_stage.stageWidth, _stage.stageHeight, 16, true, true, true);
//			context3D.configureBackBuffer(_stage.stageWidth*2, _stage.stageHeight*2, 16, true, true, true);
		}

		public function get videoUrl():String
		{
			return _videoUrl;
		}

		public function set videoUrl(value:String):void
		{
			_videoUrl = value;
		}

	}
}