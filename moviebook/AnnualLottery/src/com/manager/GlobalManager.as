package com.manager 
{
	/**
	 * ...
	 * @author LiuSheng
	 */
	public class GlobalManager 
	{
		
		public static const APP_NAME:String = "MovieBook AI System for Recognition";
		public static const VERSION:String = "20180110D";
		//public static const IMAGES_URL_PREFIX:String = "http://172.16.1.10:8500/public/avatar/";
		//public static const IMAGES_URL_PREFIX:String = "http://172.16.1.10:8500/avatar/";
		public static const IMAGES_URL_PREFIX:String = "http://172.16.1.115:8500/avatar/";
		
		//public static const REPORTCURLUCKNUM_URL_PREFIX:String = "http://172.16.1.10:8500/lucky/lucky?macode=";
		public static const REPORTCURLUCKNUM_URL_PREFIX:String = "http://172.16.1.115:8500/lucky/lucky?mcode=";
		
		public static const HISTORY_RECORD_URL:String = "http://172.16.1.115:8500/lucky/beluck";
		
		//private var _listDataReqUrl:String = "http://";
		//private var _listDataReqUrl:String = "../data/imageUrlData2.txt";
		//private var _listDataReqUrl:String = "http://testopen.videoyi.com/webs/pics/AnnualLottery/data/imageUrlData1.txt";
		//private var _listDataReqUrl:String = "http://172.16.1.10:8500/lucky/list";
		public static const LISTDATAREQ_URL:String = "http://172.16.1.115:8500/lucky/list";
		
		
		public static const RESULTLOC_ARR:Array = [[156, 54], [20, 246], [400, 145], [63, 523], [470, 360]];
		public static const MAXPEOPLEOFEACHPRIZE:Object = {level1:2, level2:3, level3:5};
		
		public static const IMAGE_WIDTH:Number = 385;
		public static const IMAGE_HEIGHT:Number = 512;
		
		public function GlobalManager() 
		{
			
		}
		
	}

}