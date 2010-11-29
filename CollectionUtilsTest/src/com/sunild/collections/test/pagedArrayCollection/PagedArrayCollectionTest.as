package com.sunild.collections.test.pagedArrayCollection
{
	import com.sunild.collections.PagedArrayCollection;
	import com.sunild.collections.test.util.TestObject;
	
	import mx.utils.UIDUtil;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	public class PagedArrayCollectionTest
	{
		private var collection:PagedArrayCollection;
		
		public function PagedArrayCollectionTest()
		{
		}
		
		[Before]
		public function setup():void
		{
			collection = new PagedArrayCollection();
		}
		
		[After]
		public function tearDown():void
		{
			collection = null;
		}
		
		[Test]
		public function testEnablePagination():void
		{
			collection = createTestObjectsCollection(101);
			// default pageSize is 10
			assertNumberOfPages(11);
			assertCollectionSizes(10,101);
			collection.enablePagination = false;
			assertCollectionSizes(101,101);
			collection.pageSize = 100;
			collection.enablePagination = true;
			assertCollectionSizes(100,101);
			assertNumberOfPages(2);
		}
		
		[Test]
		public function testNumberOfPages():void
		{
			var t:TestObject = new TestObject();
			
			// default pageSize is 10
			collection = createTestObjectsCollection(10);
			assertNumberOfPages(1);
			collection.addItem(t);
			assertNumberOfPages(2);
			
			collection = createTestObjectsCollection(99);
			assertNumberOfPages(10);
			collection.addItem(t);
			assertNumberOfPages(10);
			collection.addItem(t);
			assertNumberOfPages(11);
			
			// remove the first 10 items
			for (var i:int = 0; i<10; i++)
			{
				collection.removeItemAt(0);
			}
			assertNumberOfPages(10);
			assertCollectionSizes(10,91);
		}
		
		[Test]
		public function testAddItem():void
		{
			var t:TestObject = new TestObject();
			var uid:String = t.uid;
			
			assertCollectionSizes(0,0);
			collection.addItem(t);
			assertCollectionSizes(1,1);
			assertUidMatches( uid, TestObject( collection.getItemAt(0) ) );
			assertElementIndex(t,0);
			
			// test add item to an exixsting collection
			collection = createTestObjectsCollection(42);
			collection.addItem(t);
			assertCollectionSizes(10,43);
			assertElementIndex(t,42);
		}
		
		[Test]
		public function testAddItemAtPageBoundary():void
		{
			collection = createTestObjectsCollection(10);
			assertCollectionSizes(10, 10);
			assertNumberOfPages(1);
			
			collection.addItem( new TestObject() );
			
			assertCollectionSizes(10,11);
			assertNumberOfPages(2);
		}
		
		[Test]
		public function testAddItemAfterPageBoundary():void
		{
			collection = createTestObjectsCollection(11);
			assertCollectionSizes(10,11);
			
			var t:TestObject = new TestObject();
			var uid:String = t.uid;
			collection.addItem(t);
			
			assertCollectionSizes(10,12);
			
			// The new item should have been added to page 2 of the collection,
			// since currentPage is 1, the new item should be filtered out
			assertFalse("collection should not contain new item",
				collection.contains(t));
		}
		
		[Test]
		public function testAddItemAt():void
		{
			collection = createTestObjectsCollection(10);
			
			var origItemAtIndex3:TestObject = TestObject( collection.getItemAt(3) );
			var origUid:String = origItemAtIndex3.uid;
			var t:TestObject = new TestObject();
			var newUid:String = t.uid;
			
			assertTrue("uid's should not be equal", origUid != newUid);
			collection.addItemAt(t,3);
			
			// default pageSize is 10, so collection.length should be 10
			// and collection.lengthTotal should be 11
			assertCollectionSizes(10,11);
			
			assertEquals("item at index 3 should have newUid", newUid,
				TestObject( collection.getItemAt(3) ).uid );
			
			assertElementIndex(t,3);
			
			assertEquals("item at index 4 should have origUid", origUid,
				TestObject( collection.getItemAt(4) ).uid );
			
			assertElementIndex(origItemAtIndex3,4);
			
			
		}
		
		private function createTestObjectsCollection(collectionSize:int):PagedArrayCollection
		{
			var tmp:Array = [];
			for (var i:int=0; i<collectionSize; i++)
			{
				tmp.push( new TestObject() );
			}
			return new PagedArrayCollection(tmp);
		}
		
		/**
		 * Verify the length and lengthTotal properties of the collection. 
		 * @param length length of the filtered collection (aka the length of
		 * the current page)
		 * @param lengthTotal the actual length of the (unfiltered) collection
		 * 
		 */		
		private function assertCollectionSizes(length:int, lengthTotal:int):void
		{
			assertEquals("collection.length should be " + length, length,
				collection.length);
			
			assertEquals("collection.lengthTotal should be " + lengthTotal,
				lengthTotal, collection.lengthTotal);
		}
		
		private function assertNumberOfPages(numPages:int):void
		{
			assertEquals("collection.numberOfPages should be " + numPages,
				numPages, collection.numberOfPages);
		}
		
		private function assertElementIndex(element:Object, index:int):void
		{
			assertEquals("element index should be " + index, index,
				collection.elementMap[element]);
		}
		
		private function assertUidMatches(uid:String, t:TestObject):void
		{
			assertEquals("uid should match uid from element", uid, t.uid);
		}
	}
}