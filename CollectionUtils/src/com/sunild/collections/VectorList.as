package com.sunild.collections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	
	/**
	 * VectorList implements the IList interface for a Vector. This allows you
	 * to use vectors with Flex list controls or anything else that expects an
	 * IList as a dataProvider.
	 * <p><code><pre>
	 * var vect:Vector.&lt;String&gt; = new Vector.&lt;String&gt;;
	 * var vectorList:VectorList = new VectorList();
	 * vectorList.vector = vect;
	 * vectorList.type = Vector.&lt;String&gt; as Class;
	 * // now you can use the IList interface on vectorList...
	 * // and continue to use the original Vector for read only operations
	 * // use the VectorList to make changes, so CollectionChange events
	 * // will be dispatched...
	 * </pre></code></p>
	 * @author sunilD
	 * 
	 */	
	public class VectorList extends EventDispatcher implements IList
	{
		
		/**
		 * Create a vector and store it in this property.
		 */		
		public var vector:Object;
		
		/**
		 * Specify the type of the vector in this property.
		 */		
		public var type:Class;
		
		/**
		 * Constructor.
		 * @param vector the source vector
		 * @param type the type of vector, cast to a Class
		 * 
		 */		
		public function VectorList(vector:Object = null, type:Class = null)
		{
			this.vector = vector;
			this.type = type;
		}
		
		public function get length():int
		{
			return type( vector ).length;
		}
		
		public function addItem(item:Object):void
		{
//			type( vector ).push(item);
			// there are lots of options here, I think this is the most
			// efficient way to add to the end of the vector (per the gskinner
			// performance tests) ... 
			// TODO: create perf tests to verify all of the IList operations
			// are as efficient as possible
			var length:int = type( vector ).length;
			type( vector )[length] = item;
			internalDispatchEvent(CollectionEventKind.ADD,item,length);
		}
		
		public function addItemAt(item:Object, index:int):void
		{
			type( vector ).splice(index, 0, item);
			internalDispatchEvent(CollectionEventKind.ADD, item, index);
		}
		
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			return type( vector )[index];
		}
		
		public function getItemIndex(item:Object):int
		{
			return type( vector ).indexOf(item);
		}
		
		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
		{
		}
		
		public function removeAll():void
		{
			type( vector ).splice(0,length);
			internalDispatchEvent(CollectionEventKind.RESET);
		}
		
		public function removeItemAt(index:int):Object
		{
			var deletedItemsVector:Object = type( vector ).splice(index,1);
			internalDispatchEvent(CollectionEventKind.REMOVE, type( deletedItemsVector )[0], index);
			return type( deletedItemsVector )[0];
		}
		
		public function setItemAt(item:Object, index:int):Object
		{
			var tmp:Object;
			if (index >=0 && index < length)
			{
				tmp = getItemAt(index);
				type( vector )[index] = item;
			}
			return tmp;
		}
		
		public function toArray():Array
		{
			var tmp:Array = [];
			var l:int = length;
			for (var i:int=0; i<l; i++)
			{
				tmp[i] = type( vector )[i];
			}
			return tmp;
		}
		
		/**
		 * Dispatch CollectionEvent.COLLECTION_CHANGE
		 * 
		 * @param kind The CollectionEventKind of the event
		 * @param item The item that was changed
		 * @param location The index of the item that changed
		 * 
		 */		
		protected function internalDispatchEvent(kind:String, item:Object = null, location:int = -1):void
		{
			if (hasEventListener( CollectionEvent.COLLECTION_CHANGE ) )
			{
				var e:CollectionEvent =
					new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				e.kind = kind;
				e.items.push(item);
				e.location = location;
				dispatchEvent(e);
			}
			
		}
		
	}
}