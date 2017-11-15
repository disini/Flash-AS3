package com.media.simpleVideo
{
	import flash.events.IEventDispatcher;

	public interface ICommonLoader extends IEventDispatcher
	{
		function get url():String;
		function set url(value:String):void;
		function set loadedFunc(value:Function):void;
		function closeLoader():void;
	}
}