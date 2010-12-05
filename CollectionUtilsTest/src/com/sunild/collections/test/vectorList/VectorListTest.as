package com.sunild.collections.test.vectorList
{
	import com.sunild.collections.VectorList;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	/**
	 * Blah. 
	 * @author sundave
	 * 
	 */	
	public class VectorListTest
	{
		/**
		 * The VectorList under test. 
		 */		
		private var list:VectorList;
		/**
		 * Vic, the vector. A String vector used in the tests.
		 */		
		private var vic:Vector.<String>;
		
		public function VectorListTest()
		{
		}
		
		[Before]
		public function setup():void
		{
			list = new VectorList();
			vic = new Vector.<String>;
			list.vector = vic;
			list.type = Vector.<String> as Class;
		}
		
		[After]
		public function tearDown():void
		{
			list = null;
			vic = null;
		}
		
		[Test]
		public function testAddItem():void
		{
			var s:String = "weeeeeeee!!";
			list.addItem(s);
			assertStringsMatch(s,0);
		}
		
		[Test(async, description="verify CollectionChange event from addItem")]
		public function addItemCollectionChange():void
		{
			var s:String = "new string";
			var passThruData:Object = createPassThruObject("add", [s], 10);
			
			populateStringVector(vic,10);
			Async.handleEvent(this, list, CollectionEvent.COLLECTION_CHANGE,
				handleCollectionChange, 500, passThruData);
			list.addItem(s);
		}
		
		[Test]
		public function testAddItemAt():void
		{
			var s:String = "i'm a lawyer!";
			list.addItem(s);
			assertStringsMatch(s,0);
			// add 200 more elements to the vector
			populateStringVector(vic,200);
			assertSize(201);
			var s2:String = "you are not the boss of me";
			list.addItemAt(s2,100);
			assertStringsMatch(s,0);
			assertStringsMatch(s2,100);
			// the last item should be the string "199"
			// there are 202 elements in the VectorList
			assertStringsMatch("199",201);
		}
		
		[Test(async, description="verify CollectionChange event from addItemAt")]
		public function addItemAtCollectionChange():void
		{
			populateStringVector(vic,100);
			var s:String = "this is a string";
			var passThruData:Object = createPassThruObject("add", [s], 10);
			Async.handleEvent(this, list, CollectionEvent.COLLECTION_CHANGE,
				handleCollectionChange, 500, passThruData);
			list.addItemAt(s,10);
		}
		
		[Test]
		public function testLength():void
		{
			populateStringVector(vic,189);
			assertSize(189);
		}
		
		[Test]
		public function testGetItemAt():void
		{
			populateStringVector(vic,111);
			assertStringsMatch("101",101);
			assertStringsMatch("110",110);
			assertStringsMatch("0",0);
			assertStringsMatch("42",42);
		}
		
		[Test]
		public function testGetItemIndex():void
		{
			var s:String = "i'm the item";
			populateStringVector(vic,999);
			list.addItemAt(s,721);
			assertEquals("item index should be 721", 721, list.getItemIndex(s));
		}
		
		[Test]
		public function testRemoveAll():void
		{
			populateStringVector(vic,499);
			assertSize(499);
			assertStringsMatch("498",498);
			list.removeAll();
			assertSize(0);
		}
		
		[Test (async, description="verify CollectionEvent after removeAll()")]
		public function removeAllCollectionChange():void
		{
			populateStringVector(vic,200);
			assertSize(200);
			var passThruData:Object = createPassThruObject(
				CollectionEventKind.RESET, []);
			Async.handleEvent(this, list, CollectionEvent.COLLECTION_CHANGE,
				handleCollectionChange, 500, passThruData);
			list.removeAll();
			assertSize(0);
		}
		
		[Test]
		public function testRemoveItemAt():void
		{
			populateStringVector(vic,101);
			var o:Object = list.removeItemAt(25);
			// item at index 25 is the String "25"
			assertEquals("removedItem should be the String '25'", "25", o);
			assertSize(100);
			assertTrue("list should not contain the removed item",
				list.getItemIndex("25") == -1);
			
			assertTrue("internal vector should not contain the removed item",
				vic.indexOf("25") == -1);
		}
		
		[Test(async, description="verify CollectionEvent after removeItemAt()")]
		public function removeItemAtCollectionChange():void
		{
			populateStringVector(vic,200);
			assertSize(200);
			var passThruData:Object = createPassThruObject(
				CollectionEventKind.REMOVE, [ list.getItemAt(0) ], 0);
			Async.handleEvent(this, list, CollectionEvent.COLLECTION_CHANGE,
				handleCollectionChange, 500, passThruData);
			list.removeItemAt(0);
		}
		
		[Test]
		public function testSetItemAt():void
		{
			populateStringVector(vic,100);
			var newItem:String = "i'm a new item, baby!";
			var origItem:String = list.setItemAt(newItem,0) as String;
			
			var item:String = list.getItemAt(0) as String;
			assertEquals("these strings should be equal", newItem, item);
			assertEquals("orig string should be '0'", 0, origItem);
		}
		
		[Test]
		public function testToArray():void
		{
			// TODO (this works already, man!)
		}
		
		[Test]
		public function testIterationTime():void
		{
			var size:int = 1000000;
			list.type = Vector.<String> as Class;
			populateStringVector(vic, size);
			list.vector = vic;
			list.addItem("i'm a string!");
			var startTime:Date = new Date();
			
			var item:String;
			
			for (var i:int = 0; i<size; i++)
			{
				item = String( list.getItemAt(i) );
			}
			var endTime:Date = new Date();
			trace("execution time: " + ( endTime.getTime() - startTime.getTime() ) );
			assertEquals("length should be 10001",size+1, vic.length);
		}
		
		/* Utlility methods */
		
		private function populateStringVector(v:Vector.<String>, size:int):void
		{
			for (var i:int = 0; i<size; i++)
			{
				v.push(i.toString());
			}
		}
		
		/**
		 * Verify that that a string, and the value stored at index are equal.
		 * @param string The string to test with
		 * @param index The index to look at
		 */		
		private function assertStringsMatch(string:String, index:int):void
		{
			assertEquals("strings should match", string, list.getItemAt(index));
			assertEquals("string from internal vector should match", string,
				vic[index]);
		}
		
		/**
		 * Verify the size of the VectorList and the internal vector. 
		 * @param size
		 * 
		 */		
		private function assertSize(size:int):void
		{
			assertEquals("list.length should be " + size, size, list.length);
			assertEquals("internal vector.length should be " + size, size,
				vic.length);
		}
		
		private function createPassThruObject(kind:String, items:Array, location:int = -1, oldLocation:int = -1):Object
		{
			return { kind: kind, items: items, location: location, oldLocation: oldLocation };
		}
		
		private function handleCollectionChange(event:CollectionEvent, passThruData:Object):void
		{
			var kind:String = passThruData["kind"];
			var location:int = passThruData["location"];
			var oldLocation:int = passThruData["oldLocation"];
			var items:Array = passThruData["items"];
			
			assertEquals("event.kind should match", kind, event.kind);
			assertEquals("event.location should match", location,
				event.location);
			assertEquals("event.oldLoation should match", oldLocation,
				event.oldLocation);
			
			compareItemArrays(items, event.items);
			
		}
		
		private function compareItemArrays(orig:Array, test:Array):void
		{
			var l:int = orig.length;
			for (var i:int = 0; i<l; i++)
			{
				assertTrue("items should be the same reference",
					orig[i] === test[i] );
			}
		}
	}
}