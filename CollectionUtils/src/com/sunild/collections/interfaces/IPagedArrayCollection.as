////////////////////////////////////////////////////////////////////////////////
//
//  Copyright(c) 2008 HelloGroup A/S, some rights reserved.
//  Your reuse is governed by the Creative Commons Attribution 3.0 Denmark
//  License.
//
//  Original code from:
//  http://thecomcor.blogspot.com/2008/07/adobe-flex-pageable-arraycollection.html
//
//  Further optimized by Sunil D.
//
////////////////////////////////////////////////////////////////////////////////

package com.sunild.collections.interfaces
{	
	/**
	 * PagedArrayCollection interface.
	 */	
	public interface IPagedArrayCollection
	{
		/**
		 * The current page number that the paginated collection is "showing".
		 */		
		function get currentPage():int;
		/**
		 * @private 
		 */		
		function set currentPage(value:int):void;

		/**
		 * The total number of pages in the paginated collection.
		 */		
		function get numberOfPages():int;
		
		/**
		 * The page size to use when paginating the collection. 
		 */		
		function get pageSize():int;
		
		/**
		 * @private
		 */		
		function set pageSize(value:int):void;
		
		/**
		 * The total length of the collection. When the collection is paginated,
		 * the length property of the collection reflects the number of items on
		 * the current page. Use lengthTotal to get the actual, unfiltered,
		 * collection size.
		 */		
		function get lengthTotal():int;
	}
}