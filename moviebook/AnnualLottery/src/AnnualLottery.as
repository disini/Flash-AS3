package
{
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
	[SWF(width="1920", height="1080", backgroundColor = "0xff6600", frameRate="60")]
	public class AnnualLottery extends Sprite 
	{
		
		
		
		private var _listDataReqUrlLoader:URLLoader;
		
		private var _reportCurLuckNumReqUrl:String;
		private var _reportCurLuckNumReqUrlLoader:URLLoader;
		
		//private var _listDataReqUrl:String = "http://";
		private var _imagesUrlList:Array = [];
		
		
		private var _imagesUrlListCopy:Array = [];
		private var curLoadIdx:int = 0;
		private var _imagesBmdDataList:Array = [];
		
		private var _rollingPanel:MovieClip;
		private var _rollingPanelMask:MaskMC1;
		
		[Embed(source="../assets/ManipButton.swf")]
		public var ManipButtonClass:Class;
		
		//private var _manipButton:ManipulateButton;
		private var _manipButton:*;
		private var _manipButtonLoader:Loader;
		//private var _startButton:StartButton;
		
		private var fullScreenBtn:*;
		
		
		private var passedFrames:int = 0;
		private var rollingSpeed:Number = 10;// 滚动速度
		private var isDown:Boolean = false;// 是否按下了按钮
		private var luckNumber:uint = 2;
		private var state:uint = 1;//状态：1为开始(正在滚动) 2为停止
		
		private var _curShowingSlot:DisplayObject;
		
		private var slot1:DisplayObject;
		private var slot2:DisplayObject;
		
		private var lastSlot1LocY:Number;
		
		private var peopleChosen:Array = [];
		
		private var _curLuckIdxChosen:int;
		private var _curLuckNumChosen:int;
		
		private var _hasCurLuckNumFound:Boolean = false;
		
		private var peopleGotPrizedLayer:Sprite;
		
		private var resultMask:ResultMask;
		
		private var photoFrameLayer:Sprite;
		
		private var videoLayer:Sprite;
		
		private var historyLayer:Sprite;
		
		private var photoFrame:PhotoFrame;
		
		private var buttonLayer:Sprite;
		
		private var menu:ContextMenu = new ContextMenu();
		
		private var bgImage1:*;
		
		
		private var imageScale:Number = 1.0;
		
		private var imageLocX:Number;
		private var imageLocY:Number;
		
		private var resultCount:Number = 0;
		
		// ------------------------------------------ sound -----------------------------------------//
		//private var bgMusic:Sound;
		//private var rollingMusic:Sound;
		//private var stopSound:Sound;
		//private var throwSound:Sound;
		//private var winMusic:Sound;
		//private var plauseMusic:Sound;
		
		private var bgMusic:BgMusic;
		//private var bgMusic2:Sound;
		private var rollingSound:RollingSound;
		private var slowDownSound:SlowDownSound;
		private var throwSound:ThrowSound;
		private var winMusic:WinMusic;
		private var plauseMusic:PlauseSound;
		
		private var isBgMusicPlaying:Boolean = false;
		
		private var bgMusicChannel:SoundChannel;
		private var rollingSoundChannel:SoundChannel;
		private var slowDownSoundChannel:SoundChannel;
		private var throwSoundChannel:SoundChannel;
		private var winMusicChannel:SoundChannel;
		private var plauseMusicChannel:SoundChannel;
		
		private var bgMusicPausePosition:int;
		
		private var curChosenPersonRectPortrait:Bitmap;
		private var curChosenPersonRectPortraitLayer:Sprite;
		private var allFinishedScreenLayer:Sprite;
		
		private var curChosenPersonRoundPortrait:Bitmap;
		private var curChosenPersonRoundPortraitLayer:Sprite;
		
		//private var allFinishedScreenImg:AllFinishedScreen;
		private var allFinishedScreenImg:*;
		
		private const INIT_SPEED:int = 174;
		
		/**
		 * 声音
		 */
		protected var _soundControl:SoundControl;
		
		/**
		 * 显示容器数组
		 */
		protected var _soundContainer:Sprite;
		
		private var curSetResultNum:int = 0;
		
		private var curPrizeLevel:int = 3;
		
		
		
		private var beforeAnimVideo:SimpleVideo;
		private var afterAnimVideo:SimpleVideo;
		
		
		
		
		private var beforeAnimVideoUrl:String = "assets/before.flv";
		//private var beforeAnimVideoUrl:String = "assets/video12-29.flv";
		private var afterAnimVideoUrl:String = "assets/after.flv";
		
		private var videoArr:Vector.<SimpleVideo> = new Vector.<SimpleVideo>;
		//private var videoArr:Vector.<SimpleVideo> = [beforeAnimVideo, afterAnimVideo];
		//private var videoArr:Array = [beforeAnimVideo, afterAnimVideo];
		private var videoUrlArr:Array = [beforeAnimVideoUrl, afterAnimVideoUrl];
		
		//private var beforeAnimVideoLoader:Loader;
		//private var afterAnimVideoLoader:Loader;
		
		//private var mainVideoMetaInfo:Object;
		private var _needAutoPlay:Boolean;
		
		private var choosePrizeCBox:ChoosePrizeLevelCombobox;
		
		private var historyData:Object;
		private var historyPanel:HistoryPrizedPanel;
		
		private var _isFullScreen:Boolean;
		
		
		
		public function AnnualLottery() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			if (stage) onAddedToStage();
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event = null):void 
		{
			this.stage.scaleMode=StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			//stage.addEventListener(Event.RESIZE, onResize);			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			// entry point
			initMenu();
			initUI();
			loadImageListData();
			initVideo();
			initSound();
			//toggleFullScreen();
			//(fullScreenBtn as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function initVideo():void 
		{
			//beforeAnimVideo = new SimpleVideo(false, true);
			beforeAnimVideo = new SimpleVideo(true);
			beforeAnimVideo.autoPlay = true;
			beforeAnimVideo.name = "beforeAnimVideo";
			//afterAnimVideo = new SimpleVideo();
			//afterAnimVideo = new SimpleVideo(false, true);
			afterAnimVideo = new SimpleVideo(true);
			afterAnimVideo.autoPlay = false;
			afterAnimVideo.name = "afterAnimVideo";
			afterAnimVideo.visible = false;
			videoArr.push(beforeAnimVideo, afterAnimVideo);
			
			for (var i:int = 0; i < videoArr.length; i++)
			{
				loadVideo1(i);
			}
		}
		
		private function loadVideo1(i:int):void 
		{
			
			videoArr[i].smoothing = true;
			videoArr[i].volume = 0;
			//					mainVideo.visible = false;
			videoLayer.addChild(videoArr[i]);
			
			
			//videoArr[i].addEventListener(SimpleVideoEvent.LOADING_PROGRESS, mainVideoLoading);//视频加载中
			//videoArr[i].addEventListener(SimpleVideoEvent.PLAYING_PROGRESS, mainVideoPlayingProgress);//视频播放中
			videoArr[i].addEventListener(SimpleVideoEvent.PLAY_COMPLETE, mainVideoPlayComplete);//视频播放完成
			//videoArr[i].addEventListener(SimpleVideoEvent.ON_SEEK_START, mainVideoSeekStart);// seek开始
			//videoArr[i].addEventListener(SimpleVideoEvent.ON_SEEK_COMPLETE, mainVideoSeekComplete);//seek完成
			videoArr[i].addEventListener(SimpleVideoEvent.NS_PLAY_START2, onReadyToPlay);
			videoArr[i].addEventListener(SimpleVideoEvent.LOAD_COMPLETE, onLoadComplete);
			videoArr[i].addEventListener(SimpleVideoEvent.BUFFER_FULL, onBufferfull);
			//videoArr[i].addEventListener(MultiURLsRetryEvent.ALL_GSLB_ERROR, onVideoError);//所有调度失败
			//videoArr[i].addEventListener(RetryEvent.RETRY_FAILED, onVideoError);
			//videoArr[i].addEventListener(SimpleVideoEvent.NS_PAUSED, onVideoPaused);
			//videoArr[i].addEventListener(SimpleVideoEvent.NS_RESUMED, onVideoResumed);
			videoArr[i].addEventListener(SimpleVideoEvent.GOT_METADATA, onGotVideoMetaInfo);
			
			videoArr[i].url = videoUrlArr[i];
			videoArr[i].width = 1920;
			videoArr[i].height = 1080;
			videoLayer.addChild(videoArr[i]);
		}
		
		private function mainVideoPlayComplete(e:SimpleVideoEvent):void 
		{
			/*if (e.target.name == "beforeAnimVideo")
			{
				(e.target as SimpleVideo).replay();
			}*/
		}
		
		private function onReadyToPlay(e:SimpleVideoEvent):void
		{
			
		}
		
		
		protected function onLoadComplete(evt:SimpleVideoEvent):void
		{
			trace("onLoadComplete");
		}
		
		protected function onBufferfull(evt:SimpleVideoEvent):void
		{
			trace("onBufferfull");
		}
		
		
		protected function onGotVideoMetaInfo(evt:SimpleVideoEvent):void
		{
			Log.info("AICorrectionSystem.onGotMainVideoMetaInfo():");
			//var video:SimpleVideo = evt.target as SimpleVideo;
		}	
		
		
		private function onResize(e:Event):void 
		{
			if (_manipButton && _manipButton.parent)
			{
				//_manipButton.x = stage.stageWidth/2;
				_manipButton.x = 960;
				//_manipButton.x = (stage.stageWidth - _manipButton.width) / 2;
				//_manipButton.y = stage.stageHeight - 120;
				//_manipButton.y = 1080 - 120;
				_manipButton.y = 960;
			}
			
			if (photoFrame && photoFrame.parent)
			{
				//photoFrame.x = (stage.stageWidth - photoFrame.width) / 2;
				photoFrame.x = (1920 - photoFrame.width) / 2;
				photoFrame.y = 186;
			}
		}
		
		
		
		private function initMenu():void 
		{
			var nameItem:ContextMenuItem = new ContextMenuItem(GlobalManager.APP_NAME, false, false);
			var versionItem:ContextMenuItem = new ContextMenuItem(GlobalManager.VERSION, false, false);
			menu.customItems.push(nameItem, versionItem);
			menu.hideBuiltInItems();
			this.contextMenu = menu;
			//this.contextMenu.hideBuiltInItems();
		}
		
		
		
		private function loadImageListData():void 
		{
			var _urlReq:URLRequest = new URLRequest(GlobalManager.LISTDATAREQ_URL);
			_listDataReqUrlLoader = new URLLoader();
			//_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_listDataReqUrlLoader.addEventListener(Event.COMPLETE, ImageListLoadCompleteHandler);
			_listDataReqUrlLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
			_listDataReqUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_listDataReqUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			
			_listDataReqUrlLoader.load(_urlReq);
			
		}
		
		
		private function completeHandler(e:Event):void 
		{
			var data:Object = JSON.parse(e.target.data);
			if(!data || data.list)
			_imagesUrlList = data.list;
			loadPics();
		}
		
		private function ImageListLoadCompleteHandler(e:Event):void 
		{
			//var data:Object = JSON.parse(e.target.data);
			//if(!data || data.list)
			//_imagesUrlList = data.list;
			//_imagesUrlList = e.target.data;
			_imagesUrlList = JSON.parse(e.target.data) as Array;
			if (!_imagesUrlList || !_imagesUrlList.length)
				return;
			loadPics();
		}
		
		private function errorHandler(e:Event):void 
		{
			trace("Error:" + e.toString());
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "Error:" + e.toString());
			}
		}
		
		
		private function initSound():void 
		{
			bgMusic = new BgMusic();
			rollingSound = new RollingSound();
			slowDownSound = new SlowDownSound();
			throwSound = new ThrowSound();
			winMusic = new WinMusic();
			plauseMusic = new PlauseSound();
			createSoundControl();
			playBgMusic();
			
		}
		
		private function onBgMusicPlaybackComplete(e:Event):void 
		{
			var sound:* = e.target;
			trace("onPlaybackComplete");
			if (bgMusicChannel && bgMusicChannel.hasEventListener(Event.SOUND_COMPLETE))
			{
				bgMusicChannel.removeEventListener(Event.SOUND_COMPLETE, onBgMusicPlaybackComplete);
			}
			bgMusicChannel = bgMusic.play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, onBgMusicPlaybackComplete);
		}
		
		
		private function loadPics():void
		{
			
			_imagesUrlListCopy = _imagesUrlList.concat();
			loadOne();
		}
		
		
		private function loadOne():void 
		{
			var loader:Loader = new Loader();
			loader.name = "loader" + _imagesUrlList[curLoadIdx].code;
			loader.load(new URLRequest(GlobalManager.IMAGES_URL_PREFIX + _imagesUrlList[curLoadIdx].photo), new LoaderContext(false, ApplicationDomain.currentDomain));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadCompleteHandler);
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, onImageLoadErrorHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadErrorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onImageLoadErrorHandler);
		}
		
		
		
		private function onImageLoadCompleteHandler(e:Event):void 
		{
			
			var nameStr:String = e.target.loader.name;
			var _code:int = int(nameStr.substr(6));
			var _mcode:String;
			for (var i:int = 0; i < _imagesUrlList.length; i++)
			{
				if (_imagesUrlList[i].code == _code)
				{
					_mcode = _imagesUrlList[i].mcode;
					break;
				}
			}
			var obj:Object = {code:_code, bmd:e.target.content.bitmapData, mcode:_mcode};
			trace("onImageLoadCompleteHandler():obj.code == " + obj.code);
			_imagesBmdDataList.push(obj);
			loadNext();
		}
		
		private function loadNext():void 
		{
			curLoadIdx++;
			if (curLoadIdx == _imagesUrlList.length)
			{
				if (_imagesBmdDataList.length != _imagesUrlList.length)
				{
					trace("Warning! Somebody's picture is missing!");
					if (ExternalInterface.available)
					{
						ExternalInterface.call("console.log", "Warning! Somebody's picture is missing!");
					}
					return;
				}
				onAllImagesLoaded();
				
			}
			else
			{
				loadOne();
			}
		}
		
		
		
		private function onImageLoadErrorHandler(e:Event):void 
		{
			trace("Error:" + e.toString());
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "Error:" + e.toString());
			}
		}
		
		
		private function onVideoLoadCompleteHandler(e:Event):void 
		{
			var nameStr:String = e.target.loader.name;
		}
		
		private function onVideoLoadErrorHandler(e:SecurityErrorEvent):void 
		{
			trace("Error:" + e.toString());
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "Error:" + e.toString());
			}
		}
		
		
		private function onAllImagesLoaded():void 
		{
			initRollComponent();
		}
		
		
		private function initUI():void 
		{
			initBackGround();
			initRollingPanel();
			
			//initButtons();
			initResultLayer();
			initAllFinishedScreenLayer();
			initPhotoFrameLayer();
			initVideoLayer();
			initInputArea();
			initCBox();
			initHistoryLayer();
			initButtonLayer();
		}
		
		private function initButtonLayer():void 
		{
			buttonLayer = new Sprite();
			addChild(buttonLayer);
			loadManiButton();
			fullScreenBtn = new FullScreenIcon();
			fullScreenBtn.x = 1880;
			fullScreenBtn.y = 10;
			buttonLayer.addChild(fullScreenBtn);
			fullScreenBtn.mouseChildren = false;
			fullScreenBtn.buttonMode = true;
			fullScreenBtn.addEventListener(MouseEvent.CLICK, toggleFullScreen);
		}
		
		
		
		private function initAllFinishedScreenLayer():void 
		{
			allFinishedScreenLayer = new Sprite();
			addChild(allFinishedScreenLayer);
			//allFinishedScreenImg = new AllFinishedScreen() as DisplayObject;
			allFinishedScreenImg = new AllFinishedScreen();
			//allFinishedScreenImg.width = GlobalManager.IMAGE_WIDTH;
			//allFinishedScreenImg.height = GlobalManager.IMAGE_HEIGHT;
			allFinishedScreenImg.x = _rollingPanelMask.x;
			allFinishedScreenImg.y = _rollingPanelMask.y - 2;
			allFinishedScreenLayer.addChild(allFinishedScreenImg);
		}
		
		private function initCBox():void 
		{
			choosePrizeCBox = new ChoosePrizeLevelCombobox();
			choosePrizeCBox.x = 1700;
			choosePrizeCBox.y = 900;
			//choosePrizeCBox.chooseLevelCBX.scaleX = choosePrizeCBox.chooseLevelCBX.scaleY = 1.5;
			stage.addChild(choosePrizeCBox);
			
			choosePrizeCBox.chooseLevelCBX.width = 200;
			choosePrizeCBox.chooseLevelCBX.height = 48;
			var tft:TextFormat = new TextFormat();
			tft.size = 32;
			//tft.font = 
			choosePrizeCBox.chooseLevelCBX.textField.setStyle("textFormat", tft);
			choosePrizeCBox.chooseLevelCBX.dropdown.setRendererStyle("textFormat", tft);
			
			choosePrizeCBox.chooseLevelCBX.dropdown.rowHeight = 48;
			choosePrizeCBox.chooseLevelCBX.dropdownWidth= 200;
			
			var items:Array = [{label:"请选择奖项:", data:-1},{label:"三等奖", data:3}, {label:"二等奖", data:2}, {label:"一等奖", data:1}];
			choosePrizeCBox.chooseLevelCBX.dataProvider = new DataProvider(items);
			
			choosePrizeCBox.chooseLevelCBX.addEventListener(Event.CHANGE, onChangeCboxData);
		}
		
		private function onChangeCboxData(e:Event):void 
		{
			var level:int = e.target.selectedItem.data;
			//var data:* = e.target.dataProvider.data;
			onChoosePrizeLevel(level);
		}
		
		private function onChoosePrizeLevel(level:int):void 
		{
			curPrizeLevel = level;
			if (curPrizeLevel > 0)
			{
				trace("curPrizeLevel has been set to be " + curPrizeLevel);
				_manipButton.visible = true;
				choosePrizeCBox.visible = false;
			}
			else
			{
				trace("curPrizeLevel has been reset!");
				_manipButton.visible = false;
			}
		}
		
		
		
		private function initInputArea():void 
		{
			(bgImage1.inputArea.numTxt as TextField).restrict = "0-9";
			(bgImage1.inputArea.numTxt as TextField).maxChars = 3;
			(bgImage1.inputArea.enterButton as SimpleButton).addEventListener(MouseEvent.CLICK, onClickNumInputButton);
			bgImage1.inputArea.visible = false;
		}
		
		private function onClickNumInputButton(e:MouseEvent):void 
		{
			curSetResultNum = int(bgImage1.inputArea.numTxt.text);
			if (curSetResultNum)
			{
				_manipButton.visible = true;
				bgImage1.inputArea.enterButton.visible = false;
			}
		}
		
		private function loadManiButton():void 
		{
			_manipButtonLoader = new Loader();
			_manipButtonLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onManiButtonLoadComplete);
			_manipButtonLoader.load(new URLRequest("assets/ManipButton.swf"), new LoaderContext());
		}
		
		private function onManiButtonLoadComplete(e:Event):void 
		{
			_manipButton = e.target.content.btn;
			_manipButton.x = 960;
			_manipButton.y = 920;
			_manipButton.visible = false;
			buttonLayer.addChild(_manipButton);
			_manipButton.addEventListener(MouseEvent.MOUSE_DOWN,onClickManiButton);
			
		}
		
		
		
		private function initBackGround():void 
		{
			bgImage1 = new BackGroundBase();
			addChild(bgImage1);
		}
		
		private function initResultLayer():void 
		{
			peopleGotPrizedLayer = new Sprite();
			addChild(peopleGotPrizedLayer);
			curChosenPersonRectPortraitLayer = new Sprite();
			addChild(curChosenPersonRectPortraitLayer); 
			
			
			curChosenPersonRoundPortraitLayer = new Sprite();
			addChild(curChosenPersonRoundPortraitLayer);
		}
		
		
		private function initPhotoFrameLayer():void 
		{
			photoFrameLayer = new Sprite();
			addChild(photoFrameLayer);
			photoFrame = new PhotoFrame();
			//photoFrame.x = (stage.stageWidth - photoFrame.width) / 2;
			photoFrame.x = (1920 - photoFrame.width) / 2;
			photoFrame.y = 186;
			photoFrameLayer.addChild(photoFrame);
		}
		
		
		private function initVideoLayer():void 
		{
			videoLayer = new Sprite();
			addChild(videoLayer);
		}
		
		private function initHistoryLayer():void 
		{
			historyLayer = new Sprite();
			addChild(historyLayer);
			loadHistoryRecord();
		}
		
		private function loadHistoryRecord():void 
		{
			var urlLoader:URLLoader = new URLLoader();
			var _urlReq:URLRequest = new URLRequest(GlobalManager.HISTORY_RECORD_URL);
			urlLoader.addEventListener(Event.COMPLETE, historyDataCompleteHandler);
			urlLoader.addEventListener(ErrorEvent.ERROR, historyDataErrorHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, historyDataErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, historyDataErrorHandler);
			
			urlLoader.load(_urlReq);
		}
		
		
		private function historyDataCompleteHandler(e:Event):void 
		{
			//historyData = JSON.parse(e.target.data) as Array;
			historyData = JSON.parse(e.target.data);
			//if (!historyData || !historyData.length)
			if (!historyData)
				return;
			historyPanel = new HistoryPrizedPanel(historyData);
			historyLayer.addChild(historyPanel);
		}
		
		private function historyDataErrorHandler(e:ErrorEvent):void 
		{
			
		}
		
		
		private function initRollingPanel():void 
		{
			_rollingPanel = new MovieClip();
			addChild(_rollingPanel);
			_rollingPanelMask = new MaskMC1();
			_rollingPanelMask.width = GlobalManager.IMAGE_WIDTH;
			_rollingPanelMask.height = GlobalManager.IMAGE_HEIGHT;
			//_rollingPanel.x = _rollingPanelMask.x = (stage.stageWidth - _rollingPanelMask.width)/2;
			_rollingPanel.x = _rollingPanelMask.x = (1920 - _rollingPanelMask.width)/2;
			_rollingPanel.y = _rollingPanelMask.y = 234;
			_rollingPanelMask.alpha = 0.2;
			addChild(_rollingPanelMask);
			_rollingPanel.mask = _rollingPanelMask;
		}
		
		private function initButtons():void 
		{
			_manipButton = new ManipulateButton();
			
			var mc:* = new ManipButtonClass();
			_manipButton.name = "_manipButton";
			_manipButton.x = (1920 - _manipButton.width) / 2;
			_manipButton.y = 850;
			addChild(_manipButton);
			_manipButton.addEventListener(MouseEvent.MOUSE_DOWN,onClickManiButton);
		}

		
		//当前的点
		public function onClickManiButton(e:MouseEvent):void
		{
			if (isDown==false)
			{
				//配置速度
				//rollingSpeed = 57;
				rollingSpeed = INIT_SPEED;
				_hasCurLuckNumFound = false;
				_manipButton.gotoAndStop(2);
				state = 1;// 
				addEventListener(Event.ENTER_FRAME, onRolling);
				//pauseBgMusic();
				stopWinMusic();
				playRollingMusic();
				
				if (allFinishedScreenImg.visible)
				{
					hideAllFinishedScreenImg();
				}
				
				if (peopleChosen && peopleChosen.length)
				{
					throwOutCurLuckyPerson(); 
				}
			}
			else
			{
				//按住停止的时候
				_manipButton.gotoAndStop(1);
				state = 2;
				lastSlot1LocY = slot1.y;
				_manipButton.visible = false;
				stopRollingMusic();
			}
			isDown = ! isDown;

		}
		
		private function onRolling(e:Event):void 
		{
			
				
			for (var i:int = 0; i < _rollingPanel.numChildren; i++)
				{
					var slotMC:DisplayObject = _rollingPanel.getChildAt(i);
					
					var bottomHeight:Number = Math.min(500, _rollingPanel.height / 2 - 1);
					if (slotMC && slotMC.y > bottomHeight)
					{
						//slotMC.y -=  2 * slotMC.height;
						slotMC.y = slotMC.name == "slot1"? (slot2.y - slot1.height) : (slot1.y - slot2.height);
					}
					slotMC.y +=  rollingSpeed;
					//点击暂停以后 每隔1 秒以后减速 
					if (state==2)
					{
						//if ((_imagesBmdDataList.length >1 && (slotMC.y + _rollingPanel.y <= _rollingPanelMask.y) && (slotMC.y + slotMC.height + _rollingPanel.y >= _rollingPanelMask.y + _rollingPanelMask.height)) || (_imagesBmdDataList.length == 1 && slotMC.y >= 0 && slotMC.y + slotMC.height <= _rollingPanelMask.height + 2))
						//{
							//_curShowingSlot = slotMC;
							//
							//lastSlot1LocY = _curShowingSlot.y;
						//}
						if (slot1.y - lastSlot1LocY >= GlobalManager.IMAGE_HEIGHT)
						{
							lastSlot1LocY = slot1.y;
							playSlowDownSound();
						}
						
						//if (passedFrames>=30 && rollingSpeed > 5)
						if (passedFrames>=10 && rollingSpeed > 5)
						//if (rollingSpeed >= 0.1)
						{
							rollingSpeed -= 5;
							passedFrames = 0;
						}

						//rollingSpeed = rollingSpeed > 1 ? rollingSpeed:1;

						passedFrames++;
						//if (rollingSpeed >= 0 && rollingSpeed <= 3)
						if (rollingSpeed >= 0 && rollingSpeed <= 5)
						{
							// choose the one that covers the whole mask mc.
							//if ((_imagesBmdDataList.length >1 && (slotMC.y + 200 <= _rollingPanelMask.y) && (slotMC.y + slotMC.height + 200 >= _rollingPanelMask.y + _rollingPanelMask.height)) || (_imagesBmdDataList.length == 1 && slotMC.y >= 0 && slotMC.y + slotMC.height <= _rollingPanelMask.height + 2))
							if ((_imagesBmdDataList.length >1 && (slotMC.y + _rollingPanel.y <= _rollingPanelMask.y) && (slotMC.y + slotMC.height + _rollingPanel.y >= _rollingPanelMask.y + _rollingPanelMask.height)) || (_imagesBmdDataList.length == 1 && slotMC.y >= 0 && slotMC.y + slotMC.height <= _rollingPanelMask.height + 2))
							{
								_curShowingSlot = slotMC;
								//var remainder:int = _curShowingSlot.y % 200;
								var remainder:int = _curShowingSlot.y % GlobalManager.IMAGE_HEIGHT;
								//if (remainder >= -2)
								if (remainder >= -5)
								{
									rollingSpeed = 0;
									removeEventListener(Event.ENTER_FRAME,onRolling);
									
									if (_hasCurLuckNumFound)
										return;
									_hasCurLuckNumFound = true;
									//_curLuckIdxChosen = Math.abs(Math.round(_curShowingSlot.y / 200));
									_curLuckIdxChosen = Math.abs(Math.round(_curShowingSlot.y / GlobalManager.IMAGE_HEIGHT));
									_curLuckNumChosen = _imagesBmdDataList[_curLuckIdxChosen].code;
									//_curLuckNumChosen = 1;
									trace("onRolling():_curLuckNumChosen == " + _curLuckNumChosen);
									if (ExternalInterface.available)
									{
										ExternalInterface.call("console.log", "onRolling():_curLuckNumChosen == " + _curLuckNumChosen + ", _imagesBmdDataList.length == " + _imagesBmdDataList.length);
									}
									playSlowDownSound();
									hideHappyDogs();
									showExcitedDogs();
									findAndReportCurLuckNum();
									prepareNextPrize();
									
								}
							}
							
							
						}
					}

			}
			
		}
		
		private function showHappyDogs():void 
		{
			beforeAnimVideo.visible = true;
			//beforeAnimVideo.replay();
		}
		
		private function showExcitedDogs():void 
		{
			afterAnimVideo.visible = true;
			afterAnimVideo.resumeVideo();
			//afterAnimVideo.replay();
		}
		
		private function hideHappyDogs():void 
		{
			beforeAnimVideo.visible = false;
			//beforeAnimVideo.replay();
		}
		
		private function hideExcitedDogs():void 
		{
			afterAnimVideo.visible = false;
			afterAnimVideo.seek(0);
			afterAnimVideo.stopVideo();
		}
		
		private function throwOutCurLuckyPerson():void 
		{
			trace("threwOutCurLuckPerson():");
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "threwOutCurLuckPerson():");
			}
			
			if (curChosenPersonRectPortrait && curChosenPersonRectPortrait.parent)
			{
				curChosenPersonRectPortrait.visible = false;
			}
			
			//var bmd:BitmapData = (obj.bmd as BitmapData).clone();
			var bmd:BitmapData = curChosenPersonRectPortrait.bitmapData.clone();
			if (!bmd || !bmd.width)
			{
				trace("threwOutCurLuckPerson():bmd is null!");
				if (ExternalInterface.available)
				{
					ExternalInterface.call("console.log", "threwOutCurLuckPerson():bmd is null!");
				}
			}
		
			//var photoMC:Sprite = new RoundPhotoMC(bmd, 160);
			var photoMC:Sprite = new RoundPhotoMC(bmd, 120);
			photoMC.scaleX = photoMC.scaleY = 0.2;
			photoMC.x = _rollingPanelMask.x;
			photoMC.y = _rollingPanelMask.y;
			
			
			peopleGotPrizedLayer.addChild(photoMC);
			
			var completeCallBack:Function = function():void{
				stopThrowSound();
			}
			
			TweenLite.to(photoMC, 1, {x:GlobalManager.RESULTLOC_ARR[peopleChosen.length - 1][0], y:GlobalManager.RESULTLOC_ARR[peopleChosen.length - 1][1], width:120, height:160, rotation:360, onComplete:completeCallBack, ease:Elastic.easeOut});
			//TweenLite.to(bitmap, 1, {x:(peopleChosen.length - 1) * 200, y:600, width:150, height:200, rotation:360});
			//trace("threwOutCurLuckPerson():bitmap.width == " + bitmap.width);
			playThrowSound();
			trace("threwOutCurLuckPerson():curChosenPersonRectPortrait.width == " + curChosenPersonRectPortrait.width);
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "threwOutCurLuckPerson():curChosenPersonRectPortrait.width == " + curChosenPersonRectPortrait.width);
			}
		}
		
		private function findAndReportCurLuckNum():void 
		{
			
			for (var i:int = 0; i < _imagesBmdDataList.length; i++)
			{
				if (_imagesBmdDataList[i].code == _curLuckNumChosen)
				{
					reportCurLuckNum(_imagesBmdDataList[i].mcode);
					return;
				}
			}
		}
		
		private function reportCurLuckNum(code:String):void 
		{
			_reportCurLuckNumReqUrl = GlobalManager.REPORTCURLUCKNUM_URL_PREFIX + code + "&curPrizeLevel=" + curPrizeLevel;
			trace("reportCurLuckNum() : " + _reportCurLuckNumReqUrl);
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "reportCurLuckNum() : " + _reportCurLuckNumReqUrl);
			}
			var _urlReq:URLRequest = new URLRequest(_reportCurLuckNumReqUrl);
			_reportCurLuckNumReqUrlLoader = new URLLoader();
			//_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_reportCurLuckNumReqUrlLoader.addEventListener(Event.COMPLETE, reportLuckNumCompleteHandler);
			_reportCurLuckNumReqUrlLoader.addEventListener(ErrorEvent.ERROR, reportLuckNumErrorHandler);
			_reportCurLuckNumReqUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, reportLuckNumErrorHandler);
			_reportCurLuckNumReqUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, reportLuckNumErrorHandler);
			
			_reportCurLuckNumReqUrlLoader.load(_urlReq);
		}
		
		private function reportLuckNumErrorHandler(e:Event):void 
		{
			trace(e.target.data.toString());
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", e.target.data.toString());
			}
		}
		
		private function reportLuckNumCompleteHandler(e:Event):void 
		{
			trace(e.target.data.toString());
		}
		
		
		
		private function initRollComponent():void 
		{
			_imagesBmdDataList = randomArr(_imagesBmdDataList);
			setTimeout(function():void
			{
				setupRollingPanel();
			}, 1000);
			//setupRollingPanel();
		}
		
		
		
		
		private function setupRollingPanel():void 
		{
			for (var q:int = 0; q < 2; q++)
			{
				//_rollingPanel = new MovieClip();
				var panel:MovieClip = new MovieClip();
				
				for (var i:int = 0; i < _imagesBmdDataList.length; i++)
				{
					var image:ImageMC3 = new ImageMC3();
					var bmp:Bitmap = new Bitmap(_imagesBmdDataList[i].bmd);
					bmp.width = GlobalManager.IMAGE_WIDTH;
					bmp.height = GlobalManager.IMAGE_HEIGHT;
					image.name = "image" + _imagesBmdDataList[i].index;
					image.imageContainer.addChild(bmp);
					image.y = i * image.height;
					panel.addChild(image);
				}
				
				panel.y = panel.height * (-q);
				panel.name = "slot" + (q+1);
				this["slot"+(q+1)] = panel;
				_rollingPanel.addChild(panel);
			}
			
			if (peopleChosen.length && peopleChosen.length < GlobalManager.MAXPEOPLEOFEACHPRIZE["level" + curPrizeLevel])
			{
				setTimeout(function():void
				{
					_manipButton.visible = true;
					hideExcitedDogs();
					showHappyDogs();
					//resumeBgMusic();
				}, 5000);
			}
		}
		
		
		private function prepareNextPrize():void
		{
			trace("prepareNextPrize()");
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", "prepareNextPrize()");
			}
			//_manipButton.mouseEnabled = false;
			
			var hasFound:Boolean = false;
			for (var i:int = _imagesBmdDataList.length-1; i >= 0; i--)
			{
				if (i == 1)
				{
					trace("i == 1!");
				}
				if (hasFound)
					break;
				
				if (_imagesBmdDataList[i].code == _curLuckNumChosen)
				{
					var deleted:Array = _imagesBmdDataList.splice(i, 1);
					peopleChosen.push(deleted[0]);
					_manipButton.visible = false;
					playWinMusic();
					_imagesBmdDataList = randomArr(_imagesBmdDataList);
					setTimeout(function():void
					{
						trace("now I'm going to threwOutCurLuckPerson()");
						if (ExternalInterface.available)
						{
							ExternalInterface.call("console.log", "now I'm going to threwOutCurLuckPerson()");
						}
						showCurLuckyPerson(deleted[0]);
						
						clearRollingPanel();
						setupRollingPanel();
						if (!_imagesBmdDataList.length)
						{
							_manipButton.visible = false;
						}
						resultCount++;
					}, 2000);
					hasFound = true;
					trace("lucky num has been found: index == " + i + ", _curLuckNumChosen == " + _curLuckNumChosen);
					if (ExternalInterface.available)
					{
						ExternalInterface.call("console.log", "lucky num has been found: index == " + i + ", _curLuckNumChosen == " + _curLuckNumChosen);
					}
					
					//if (peopleChosen && peopleChosen.length >= 5)
					if (peopleChosen && peopleChosen.length >= GlobalManager.MAXPEOPLEOFEACHPRIZE["level" + curPrizeLevel])
					//if (peopleChosen && peopleChosen.length)
					{
						setTimeout(function():void
						{
							throwOutCurLuckyPerson();
							showAllFinishedScreenImg();
							hideExcitedDogs();
							showHappyDogs();
							//resumeBgMusic();
						}, 5000);
					}
					break;
				}
				//}
			}

			if (!hasFound)
			{
				trace("finally, hasFound == false! _curLuckNumChosen == " + _curLuckNumChosen);
				if (ExternalInterface.available)
				{
					ExternalInterface.call("console.log", "finally, hasFound == false! _curLuckNumChosen == " + _curLuckNumChosen);
				}
				for (var kk:int = _imagesBmdDataList.length - 1; kk >= 0; kk--)
				{
					var log:String = " kk == " + kk + ", _imagesBmdDataList[kk].code == " + _imagesBmdDataList[kk].code;
					trace(log);
					if (ExternalInterface.available)
					{
						ExternalInterface.call("console.log", log);
					}
				}
				
				
				
			}
		}
		
		private function showAllFinishedScreenImg():void 
		{
			allFinishedScreenImg.visible = true;
		}
		
		private function hideAllFinishedScreenImg():void 
		{
			allFinishedScreenImg.visible = false;
		}
		
		private function showCurLuckyPerson(obj:Object):void 
		{
			if (!curChosenPersonRectPortrait)
			{
				curChosenPersonRectPortrait = new Bitmap(obj.bmd.clone());
			}
			//else if (!curChosenPersonRectPortrait.bitmapData)
			else
			{
				curChosenPersonRectPortrait.bitmapData = obj.bmd.clone();
				curChosenPersonRectPortrait.visible = true;
			}
			curChosenPersonRectPortrait.width = GlobalManager.IMAGE_WIDTH;
			curChosenPersonRectPortrait.height = GlobalManager.IMAGE_HEIGHT;
			if (!curChosenPersonRectPortrait.parent)
			{
				curChosenPersonRectPortrait.x = _rollingPanelMask.x;
				curChosenPersonRectPortrait.y = _rollingPanelMask.y - 2;
				curChosenPersonRectPortraitLayer.addChild(curChosenPersonRectPortrait);
			}
		}
		
		
		
		private function randomArr(inArr:Array):Array 
		{
			trace("start randomize input Array：" + new Date().time);
			//-------------------------------------------------random algorithm 1 ： ------------------------------------------------------//
			//var arr:Array = inArr.concat();
			//function sortF(a:*,b:*):int {
				////return Math.floor(Math.random()*1-1);//
			//}
			//arr.sort(sortF);
			
			//-------------------------------------------------random algorithm 2 ： ------------------------------------------------------//
			var arr:Array = inArr.slice();  
			var q:int = arr.length;
			
			while (q) {     
			   arr.push(arr.splice(int(Math.random()* q--), 1)[0]);     
			}     
			//return arr; 
			
			trace("finish randomize input Array：" + new Date().time);
		
			for (var i:int = 0; i < arr.length; i++)
			{
				trace("randomArr(): arr[" + i + "].code == " + arr[i].code);
			}
			
			return arr;
		}
		
		private function clearRollingPanel():void 
		{
			_rollingPanel.removeChildren();
		}
		
		
		
		/**
		 * 创建声音
		 */
		private function createSoundControl():void
		{
			_soundContainer = new Sprite();
			this._soundControl = new SoundControl();
			//声音显示在第2层
			this._soundContainer.addChild(this._soundControl);
			//this._soundControl.playSound("BgMusic", true, 1);
			//监听播放其它音乐和音效
			this.addEventListener(SoundEvent.BG_SOUND, playBgMusic);
			this.addEventListener(SoundEvent.ROLLING_SOUND, playRollingMusic);
			this.addEventListener(SoundEvent.SLOWDOWN_SOUND, playSlowDownSound);
			this.addEventListener(SoundEvent.THROW_SOUND, playThrowSound);
			this.addEventListener(SoundEvent.PLAUSE_SOUND, playPlauseSound);
			this.addEventListener(SoundEvent.WIN_SOUND, playWinMusic);
		}
		
		//------------------------------------------ Play Sound --------------------------------------------//
		
		private function playBgMusic($evt:Event = null):void
		{
			//this._soundControl.playSound("BgMusic", true, 1);
			//bgMusic.play();
			//bgMusicChannel = bgMusic.play(0, 100);// 如果是多次循环播放 则 Event.SOUND_COMPLETE不起作用。
			bgMusicChannel = bgMusic.play();
			isBgMusicPlaying = true;
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, onBgMusicPlaybackComplete);
			
		}
		private function playRollingMusic($evt:Event = null):void
		{
			//this._soundControl.playSound("rollingMusic", true, 1);
			//rollingMusicChannel = rollingMusic.play(0, 10000);
			rollingSoundChannel = rollingSound.play(0, 10000);
			
		}
		private function playSlowDownSound($evt:Event = null):void
		{
			//this._soundControl.playSound("StopSound", true, 1);
			//slowDownSoundChannel = slowDownSound.play(0, 100);
			slowDownSoundChannel = slowDownSound.play();
			//rollingMusicChannel = rollingMusic.play();
		}
		
		private function playThrowSound($evt:Event = null):void
		{
			//this._soundControl.playSoundEff("ThrowSound");
			throwSoundChannel = throwSound.play();
		}
		
		private function playPlauseSound($evt:Event = null):void
		{
			//this._soundControl.playSound("PlauseSound");
			plauseMusicChannel = plauseMusic.play(0, 100);
		}
		
		private function playWinMusic($evt:Event = null):void
		{
			//this._soundControl.playSound("WinMusic");
			//winMusicChannel = winMusic.play(0, 100);
			winMusicChannel = winMusic.play();
		}
		
		//------------------------------------------ Pause Sound --------------------------------------------//
		
		private function pauseBgMusic():void
		{
			if (bgMusicChannel)
			{
				bgMusicPausePosition = bgMusicChannel.position;
				bgMusicChannel.stop();
				isBgMusicPlaying = false;
			}
		}
		
		//------------------------------------------ Resume Sound --------------------------------------------//
		
		private function resumeBgMusic():void
		{
			if(isBgMusicPlaying)
				return;
			if(bgMusicChannel && bgMusicChannel.hasEventListener(Event.SOUND_COMPLETE))
			{
				bgMusicChannel.removeEventListener(Event.SOUND_COMPLETE, onBgMusicPlaybackComplete);
			}
			bgMusicChannel = bgMusic.play(bgMusicPausePosition);
			//bgMusic.play(bgMusicPausePosition);
			//bgMusicChannel = bgMusic.play();
			bgMusicChannel.addEventListener(Event.SOUND_COMPLETE, onBgMusicPlaybackComplete);
		}
		
		//------------------------------------------ Stop Sound --------------------------------------------//
		
		private function stopRollingMusic($evt:Event = null):void
		{
			//this._soundControl.stopSound();
			if (rollingSoundChannel)
			{
				rollingSoundChannel.stop();
			}
		}
		
		
		private function stopSlowDownSound($evt:Event = null):void
		{
			if (slowDownSoundChannel)
			{
				slowDownSoundChannel.stop();
			}
		}
		
		
		
		private function stopThrowSound($evt:Event = null):void
		{
			if (throwSoundChannel)
			{
				throwSoundChannel.stop();
			}
		}
		
		private function stopPlauseSound($evt:Event = null):void
		{
			if (plauseMusicChannel)
			{
				plauseMusicChannel.stop();
			}
		}
		
		private function stopWinMusic($evt:Event = null):void
		{
			if (winMusicChannel)
			{
				winMusicChannel.stop();
			}
		}
		
		
		private function toggleFullScreen(evt:MouseEvent):void
		{
			if(!stage)
				return;
			if(!_isFullScreen)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
				_isFullScreen = true;
				fullScreenBtn.gotoAndStop(2);
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
				_isFullScreen = false;
				fullScreenBtn.gotoAndStop(1);
			}
			Log.info("toggleFullScreen() : _isFullScreen == " + _isFullScreen);
			
		}
		
		
		/** 当前是否处于全屏状态 */
		public function get isFullScreen():Boolean
		{
			return _isFullScreen;
		}
		
		
		
		
		
		
		
		
	}
	
}