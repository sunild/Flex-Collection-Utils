package com.sunild.collections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.Dictionary;
	
	import mx.collections.IList;
	
	
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
		
		public function VectorList()
		{
		}
		
		public function get length():int
		{
			return type( vector ).length;
		}
		
		public function addItem(item:Object):void
		{
			type( vector ).push(item);
		}
		
		public function addItemAt(item:Object, index:int):void
		{
			type( vector ).splice(index, 0, item);
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
		}
		
		public function removeItemAt(index:int):Object
		{
			var deletedItemsVector:Object = type( vector ).splice(index,1);
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
		
	}
}