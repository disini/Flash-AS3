package com.manager 
{
	/**
	 * ...
	 * @author LiuSheng
	 */
	public class GlobalManager 
	{
		
		public static const APP_NAME:String = "MovieBook AI System for Recognition";
		public static const VERSION:String = "20180116A";
		public static const IMAGES_URL_PREFIX:String = "http://172.16.1.115:8500/avatar/";
		public static const REPORTCURLUCKNUM_URL_PREFIX:String = "http://172.16.1.115:8500/lucky/lucky?mcode=";
		public static const HISTORY_RECORD_URL:String = "http://172.16.1.115:8500/lucky/beluck";
		public static const LISTDATAREQ_URL:String = "http://172.16.1.115:8500/lucky/list";
		//public static const RESULTLOC_ARR:Array = [[156, 54], [20, 246], [400, 145], [63, 523], [470, 360]]; 
		public static const RESULTLOC_ARR:Array = [[66, 34], [370, 20], [217, 145], [34, 210], [452, 226], [267, 330], [48, 396], [517, 454], [148, 556], [39, 670]];
		public static const MAXPEOPLEOFEACHPRIZE:Object = {level1:10, level2:10, level3:10};
		public static const IMAGE_WIDTH:Number = 385;
		public static const IMAGE_HEIGHT:Number = 512;
		
		public function GlobalManager() 
		{
			
		}
		
	}

}