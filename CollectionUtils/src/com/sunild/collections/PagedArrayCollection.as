////////////////////////////////////////////////////////////////////////////////
//
//  Copyright(c) 2008 HelloGroup A/S, some rights reserved.
//  Your reuse is governed by the Creative Commons Attribution 3.0 Denmark
//  License.
//
//  Original code from:
//  http://thecomcor.blogspot.com/2008/07/adobe-flex-pageable-arraycollection.html
//
//  Optimized by Sunil D., copyright whatever :)
//
////////////////////////////////////////////////////////////////////////////////

package com.sunild.collections
{
	import com.sunild.collections.interfaces.IPagedArrayCollection;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	/**
	 * PagedArrayCollection is an ArrayCollection with a built in filterFunction
	 * that paginates the data. The filterFunction hides collection elements
	 * that are not on the current page. Consumers of this collection, therefore
	 * are only see the current page's elements.
	 */	
	public class PagedArrayCollection extends ArrayCollection implements IPagedArrayCollection
	{
		/**
		 * The CollectionEventKind constant that indicates
		 * CollectionEvent.COLLECTION_CHANGE was dispatched due to the current
		 * page being changed.
		 */
		public static const CURRENT_PAGE_CHANGE:String = "currentPageChange";
		
		/**
		 * The CollectionEventKind constant that indicates 
		 * CollectionEvent.COLLECTION_CHANGE was dispatched due to the page
		 * size being changed.
		 */
		public static const PAGE_SIZE_CHANGE:String = "pageSizeChange";
		
		/**
		 * The CollectionEventKind constant that indicates 
		 * CollectionEvent.COLLECTION_CHANGE was dispatched due to the number of
		 * pages being changed.
		 */
		public static const NUMBER_OF_PAGES_CHANGE:String = "numberOfPagesChange";
		
		/**
		 * A map of the collection elements to indexes. The key is the element,
		 * the value is the element's index. This is used by the filterFunction
		 * that paginates the data.
		 * <p>It may be more efficient to use this instead of the contains()
		 * method. However, if the item you look up is at index 0, this test
		 * will return false: if ( collection.elementMap[ itemAtIndex0 ] ) ...
		 */		
		public var elementMap:Dictionary;
		
		private var _currentPage:int = 1;
		private var _numberOfPages:int = 1;
		private var _pageSize:int = 10;
		
		private var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		public function PagedArrayCollection(source:Array=null)
		{
			super( source );
			
			elementMap = new Dictionary(true);
			updateElementMapFromList();
			filterFunction = filterData;
			refresh();
			addEventListener( CollectionEvent.COLLECTION_CHANGE, onChange );
		}
		
		private var _enablePagination:Boolean = true;
		/**
		 * If true, a filterFunction is applied on the collection, making only
		 * the elements on the current page "visible" in the collection.
		 * @default true 
		 */		
		public function get enablePagination():Boolean
		{
			return _enablePagination;
		}
		/**
		 * @private 
		 */		
		public function set enablePagination(value:Boolean):void
		{
			if (value == _enablePagination)
				return;
			_enablePagination = value;
			filterFunction = value ? filterData : null;
			refresh();
		}

		/**
		 * Adds an item to the collection at the specified index. 
		 * 
		 * <p>When paginated, items are added with respect to the currentPage.
		 * If currentPage is 2, addItemAt(0) inserts the item where page 2
		 * would occur in the overall collection. Adding to the end of the
		 * page with addItem(), adds the item to the end of the entire
		 * collection.</p>
		 * 
		 * <p>When paginated, you cannot add to an index that is greater
		 * than the pageSize.</p>
		 * 
		 * <p>This method overrides the super class, and does not call
		 * super.addItemAt() on purpose....
		 * @param item Item to be added
		 * @param index Index of the item to be added
		 */
		override public function addItemAt(item:Object, index:int):void
		{
//			super.addItemAt( item, index );
//			// update elementMap for this item and the items that it was
//			// inserted before
//			updateElementMapFromList( list.getItemIndex(item) );
			
			if (index < 0 || !list || index > length)
			{
				var message:String = resourceManager.getString(
					"collections", "outOfBounds", [ index ]);
				throw new RangeError(message);
			}
			
			var listIndex:int = index;
			//if we're sorted addItemAt is meaningless, just add to the end
			if (localIndex && sort)
			{
				listIndex = list.length;
			}
			else if (localIndex && filterFunction != null)
			{
				// if end of filtered list, put at end of source list
				if (listIndex == localIndex.length)
					listIndex = list.length;
					// if somewhere in filtered list, find it and insert before it
					// or at beginning
				else 
					listIndex = list.getItemIndex(localIndex[index]);
			}
			elementMap[item] = listIndex;
			// if the item was added to the currentPage
			updateElementMapBeforeInsert(listIndex);
			list.addItemAt(item, listIndex);
		}
		
		/**
		 * Removes the item from the collection at the specified index
		 * @param index Index of the item to be removed
		 * @return The item removed
		 * Note: Needs to be overridden in order to trigger refresh
		 */
		override public function removeItemAt(index:int):Object
		{
			delete elementMap[ list.getItemAt(index) ];
			updateElementMapBeforeRemove(index + 1);
			var removedItem:Object = super.removeItemAt( index );
			refresh();
			return removedItem;
		}
		
		protected function onChange(event:CollectionEvent):void
		{
			if( _numberOfPages != numberOfPages )
			{
				_numberOfPages = numberOfPages;
				onPagingChange(NUMBER_OF_PAGES_CHANGE);
			}
		}
		
		protected function onPagingChange(kind:String):void
		{
			dispatchEvent( new CollectionEvent( CollectionEvent.COLLECTION_CHANGE, false, false, kind ) ); 
		}
		
		[ChangeEvent("collectionChange")]
		public function get currentPage():int
		{
			return _currentPage;
		}
		
		public function set currentPage(value:int):void
		{   _currentPage = value;
			refresh();
			onPagingChange(CURRENT_PAGE_CHANGE);
		}
		
		[ChangeEvent("collectionChange")]
		public function get numberOfPages():int
		{
			var result:Number = source.length / pageSize;
			result = Math.ceil( result );
			return result;
		}
		
		[ChangeEvent("collectionChange")]
		public function get pageSize():int
		{
			return _pageSize;
		}
		
		public function set pageSize(value:int):void
		{
			_pageSize = value;
			refresh();
			onPagingChange(PAGE_SIZE_CHANGE);
		}
		
		[ChangeEvent("collectionChange")]
		public function get lengthTotal():int
		{
			return source.length;
		}
		
		private function filterData(item:Object):Boolean
		{
			var dataWindowCeiling:int = pageSize * currentPage;
			var dataWindowFloor:int = dataWindowCeiling - pageSize;
			var itemIndex:int = -1;
			if (elementMap[item] != null)
			{
				itemIndex = elementMap[item];
			}
			else
			{
				trace("Should not get here");
				itemIndex = -1;
			}
			return (dataWindowFloor <= itemIndex && itemIndex < dataWindowCeiling);
		}
		
		/**
		 * Update/populate the element map from a specified starting index. This
		 * uses the ArrayCollection's source property (an Array). TODO: determine
		 * if this or the IList version below is better.
		 * @param startIndex the index to start updating form, default is 0
		 */		
		protected function updateElementMapFromSource(startIndex:int = 0):void
		{
			var l:int = source.length;
			for ( ; startIndex < l; startIndex++)
			{
				elementMap[ source[startIndex] ] = startIndex;
			}
		}
		
		/**
		 * Update/populate the element map from a specified index.
		 * This use the IList that the collection wraps. TODO: determine if
		 * this or the Array version above is better.
		 * @param startIndex the index to start updating form, default is 0
		 * 
		 */		
		protected function updateElementMapFromList(startIndex:int = 0):void
		{
			var l:int = list.length;
			for ( ; startIndex < l; startIndex++)
			{
				elementMap[ list.getItemAt(startIndex) ] = startIndex;
			}
		}
		
		/**
		 * Increment the index of each item in the map, before an update. 
		 * @param startIndex
		 * 
		 */		
		protected function updateElementMapBeforeInsert(startIndex:int):void
		{
			var l:int = list.length;
			for ( ; startIndex < l; startIndex++)
			{
				elementMap[ list.getItemAt(startIndex) ] = startIndex + 1;
			}
		}
		
		protected function updateElementMapBeforeRemove(startIndex:int):void
		{
			var l:int = list.length;
			for ( ; startIndex < l; startIndex++)
			{
				elementMap[ list.getItemAt(startIndex) ] = startIndex - 1;
			}
		}
	}
}