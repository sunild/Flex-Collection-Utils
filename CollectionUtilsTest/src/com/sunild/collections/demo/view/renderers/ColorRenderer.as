package com.sunild.collections.demo.view.renderers
{
	import com.sunild.collections.demo.model.ColorVO;
	
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.supportClasses.ItemRenderer;
	import spark.primitives.Rect;
	
	public class ColorRenderer extends ItemRenderer
	{
		public function ColorRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			if (value && value is ColorVO)
			{
				if (background)
					setupChildren( ColorVO(data) );
			}
		}
		
		protected function setupChildren(color:ColorVO):void
		{
			var c:uint = color.color;
			fill.color = c;
			this.toolTip = "#" + c.toString(16).toUpperCase();
		}
		
		/**
		 * The background.
		 */		
		protected var background:Rect;
		/**
		 * The background's fill. 
		 */		
		protected var fill:SolidColor;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!background)
			{
				background = new Rect();
				background.top = 0;
				background.bottom = 0;
				background.left = 0;
				background.right = 0;
				fill = new SolidColor();
				background.fill = fill;
				addElement(background);
			}
			if (data && data is ColorVO)
				setupChildren( ColorVO(data) );
		}
	}
}