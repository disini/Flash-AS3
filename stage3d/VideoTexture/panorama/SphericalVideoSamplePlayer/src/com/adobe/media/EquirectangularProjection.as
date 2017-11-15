package com.adobe.media
{
	public class EquirectangularProjection extends Projection
	{
		private static const COLUMNS:Number = 80;// 列数（横向）
		
		private static const ROWS:Number = 40;// 行数（纵向）
		
		
		public function EquirectangularProjection()
		{
//			super();
		}
		
		override protected function generateVertices():void
		{
			var deltaA:Number = Math.PI / ROWS;
			var deltaB:Number = 2 * Math.PI / COLUMNS;
			
			for (var row:int = 0; row <= ROWS; row++)
			{
				var a:Number = row * deltaA;
				var y:Number = Math.cos(a);
				var tv:Number = row / ROWS;// uv中的v（垂直，纵向）
				
				for(var col:int = 0; col <= COLUMNS; col++)
				{
					var b:Number = col * deltaB - (0.5 * Math.PI);// Need to pre-rotate -90 degree
					var x:Number = Math.sin(a) * Math.cos(b);
					var z:Number = Math.sin(a) * Math.sin(b);
					var tu:Number = (COLUMNS - col) / COLUMNS;
					vertices.push(x, y, z, tu, tv);
				}
			}
			
			// 当 COLUMNS = 20， ROWS = 10时， vertices.length = 1155 = （20+1）* （10 + 1） * 5 = 21*11*5 = 231*5，共231个顶点

		}
		
		override protected function generateIndices():void
		{
			for(var row:uint = 1; row <= ROWS; row++)
			{
				var topIndex:uint = (COLUMNS + 1) * row;//  某一纬线圈的上纬线顶点索引，从81开始
				var bottomIndex:uint = (COLUMNS + 1) * (row - 1);//  某一纬线圈的下纬线顶点索引，从0开始
				for(var col:uint = 0; col <= COLUMNS;col++)
				{
					var tl:uint = topIndex +col;// 其中的一个矩形的左上角顶点索引（top left）
					var tr:uint = topIndex + ((col+1) % (COLUMNS + 1));// 右上角顶点索引（top right）
					var bl:uint = bottomIndex + col;// (bottom left)
					var br:uint = bottomIndex + ((col+1) % (COLUMNS + 1));// (bottom right)
					indices.push(tl, tr, bl);// 左上三角形，顶点顺序为顺时针
					indices.push(br, bl, tr);// 右下三角形
				}
			}
			
			// 当 COLUMNS = 20， ROWS = 10时， indices.length = 1260 = （20+1）* 10  * (2*3) = 210*6 = 1260, 210个矩形，每个矩形是2个三角形，共6个值
		}
		
		
	}
}