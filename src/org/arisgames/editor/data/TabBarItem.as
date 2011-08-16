package org.arisgames.editor.data
{
	public class TabBarItem
	{
		public var type:String;
		public var index:int;
		public var enabled:Boolean;
		
		public function TabBarItem(type:String, index:int, enabled:Boolean)
		{
			this.type = type;
			this.index = index;
			this.enabled = enabled;
			
			super();
		}
	}
}