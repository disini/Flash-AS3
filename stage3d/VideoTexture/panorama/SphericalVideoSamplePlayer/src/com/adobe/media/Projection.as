package com.adobe.media
{
	public class Projection
	{
		public static const DATA_PER_VERTEX:int = 5;
		
		protected var vertices:Vector.<Number> = new Vector.<Number>();
		protected var indices:Vector.<uint> = new Vector.<uint>();
		
		public function Projection()
		{
			generateVertices();
			generateIndices();
		}
		
		public function getVertices():Vector.<Number>
		{
			return vertices;
		}
		
		public function getIndices():Vector.<uint> 
		{
			return indices;
		}
		
		protected function generateVertices():void
		{
			// TODO Auto Generated method stub
			
		}
		
		protected function generateIndices():void
		{
			// TODO Auto Generated method stub
			
		}
	}
}