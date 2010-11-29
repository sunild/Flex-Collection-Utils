package com.sunild.collections.test.util
{
	import mx.utils.UIDUtil;

	public class TestObject
	{
		public var uid:String;
		
		public function TestObject()
		{
			uid = UIDUtil.createUID();
		}
	}
}