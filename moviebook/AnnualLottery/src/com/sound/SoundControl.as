package com.sound
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * 
	 */
	public class SoundControl extends Sprite
	{
		/**
		 * 声音按钮
		 */
		private var _soundBtn:MovieClip;
		/**
		 * 声音类
		 */
		private var _gameSound:GameSound;
		
		
		
		
		public function SoundControl()
		{
			//创建声音类
			this._gameSound = new GameSound();
			//创建按钮
			this._soundBtn = new SoundResoures();
			this._soundBtn.x = 580;
			this._soundBtn.y = 10;
			this._soundBtn.buttonMode = true;
			this._soundBtn.mouseChildren = false;
			this.addChild(this._soundBtn);
			//有驱动
			this._soundBtn.gotoAndStop(1);
			this._soundBtn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		/**
		 * 声音类，实现方法为传入声音名字和音量
		 * @param $name			声音名字
		 * @param $loop			是否循环
		 * @param $volume		音量
		 */
		public function playSound($name:String,$loop:Boolean=false,$volume:Number=1):void
		{
			if (this._gameSound.soundDriver)
			{
				//有驱动
				this._gameSound.playSound($name, $loop, $volume);
			}
			else
			{
				//无驱动
				this._soundBtn.gotoAndStop(2);
				this._soundBtn.removeEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		
		//public function stopSound($name:String,$loop:Boolean=false,$volume:Number=1):void
		//public function stopSound():void
		//{
			//if (this._gameSound.soundDriver)
			//{
				////有驱动
				////this._gameSound.stop($name, $loop, $volume);
				//this._gameSound.stop();
			//}
			//else
			//{
				////无驱动
				//this._soundBtn.gotoAndStop(2);
				//this._soundBtn.removeEventListener(MouseEvent.CLICK, onClick);
			//}
		//}
		
		
		
		/**
		 * 播放音效
		 * @param	$name
		 * @param	$time
		 * @param	$volume
		 */
		public function playSoundEff($name:String,$time:uint=0,$volume:Number=1):void
		{
			this._gameSound.playSoundEff($name,$time,$volume);
		}
		/**
		 * 声音按钮被点击
		 * @param	$evt
		 */
		private function onClick($evt:MouseEvent):void
		{
			if (this._soundBtn.currentFrame == 1)
			{
				//暂停
				this._soundBtn.gotoAndStop(2);
				this._gameSound.stop();
			}
			else if (this._soundBtn.currentFrame == 2)
			{
				//播放
				this._soundBtn.gotoAndStop(1);
				this._gameSound.play();
			}
		}
	}
}