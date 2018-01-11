package com.sound 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Ragged
	 */
	public class GameSound 
	{
		/**
		 * 背景音乐实例
		 */
		private var _bgSound:Sound;
		/**
		 * 声音控制对象
		 */
		private var _channel:SoundChannel;
		/**
		 * 音量，和平移的属性
		 */
		private var _soundTrans:SoundTransform;
		/**
		 * 记录音乐拨翻的位置
		 */
		public var _channelPosition:Number = 0;
		/**
		 * 背景音乐的音量
		 */
		private var _volume:Number;
		/**
		 * 是否循环背景音乐
		 */		
		private var _loop:Boolean = false;
		/**
		 * 播放状态：true可以播放，false暂停播放
		 */
		private var _playState:Boolean = true;
		/**
		 * 音效
		 */
		private var _soundEff:Sound;
		/**
		 * 音效的音量
		 */
		private var _channelEff:SoundChannel;
		/**
		 * 音量，和平移的属性
		 */
		private var _soundTransEff:SoundTransform;
		/**
		 * 是否有声卡驱动：true有，false没有
		 */
		private var _soundDriver:Boolean = true;
		/**
		 * 获取声卡驱动是否安装
		 */
		public function get soundDriver():Boolean
		{
			return this._soundDriver;
		}
		
		
		
		
		
		
		
		public function GameSound() 
		{
			
		}
		/**
		 * 播放背景音乐
		 * @param	$name		音乐的名字
		 * @param	$loop		是否循环播放
		 * @param	$volume		音量大小
		 */
		public function playSound($name:String,$loop:Boolean=false,$volume:Number=1):void
		{
			//如果已经在播放背景音乐，要先暂停和删除
			if(this._bgSound)
			{
				this._channelPosition = 0;
				SoundMixer.soundTransform = new SoundTransform(0);
				this._channel.stop();
				this._channel = null;
				this._bgSound = null;
			}
			//记录是否循环背景音乐
			this._loop = $loop;
			this._volume = $volume;
			var CurClass:Class = getDefinitionByName($name) as Class;
			
			//创建背景音乐
			//this._bgSound = new (getDefinitionByName($name) as Class);
			this._bgSound = new CurClass();
			//如果玩家暂停了声音将不继续
			if (this._playState == false)
			{
				return;
			}
			
			//尝试设置声音的音量
			//如果没有声卡驱动就会出错
			try
			{
				//背景音乐播发，并且把播放放入对象
				play();
			}
			catch(e:Error)
			{
				this._soundDriver = false;
				trace("找不到声卡驱动程序");
			}
		}
		/**
		 * 播放背景音乐
		 */		
		public function play():void
		{
			//声音暂停中
			this._playState = true;
			//设置音量为最大
			SoundMixer.soundTransform=new SoundTransform(this._volume);
			//从刚才停止的位置，恢复播放。
			this._channel = this._bgSound.play(this._channelPosition);
			this._soundTrans = this._channel.soundTransform;
			this._soundTrans.volume = this._volume;
			this._channel.soundTransform = this._soundTrans;
			//是否循环
			if(this._loop)
			{
				this._channel.addEventListener(Event.SOUND_COMPLETE,playEnd);
			}
		}
		/**
		 * 停止背景音乐
		 */			
		public function stop():void
		{
			//声音暂停中
			this._playState = false;
			//
			SoundMixer.soundTransform=new SoundTransform(0);
			//记录当前播放的位置
			this._channelPosition=_channel.position;
			this._channel.stop();
		}
		
		
		/**
		 * 游戏中，播放音效，比如：子弹等音效
		 * @param $name		音效的名字
		 * @param $time		开始播放的时间
		 * @param $volume	播放的音量
		 * @return 
		 * 
		 */		
		public function playSoundEff($name:String,$time:uint=0,$volume:Number=1):void
		{
			if (this._soundDriver == false)
			{
				trace("找不到声卡驱动程序")
				return;
			}
			this._soundEff = new (getDefinitionByName($name) as Class);
			this._channelEff = this._soundEff.play($time);
			try
			{
				this._soundTransEff = this._channelEff.soundTransform;
				this._soundTransEff.volume = $volume;
				this._channelEff.soundTransform = this._soundTransEff;
			}
			catch(evt:ErrorEvent)
			{
				trace("找不到声卡驱动程序")
			}
		}
		
		/**
		 * 背景音乐播放完成后，循环播放
		 * @param $evt
		 */		
		private function playEnd($evt:Event):void
		{
			play();
		}
	}
}