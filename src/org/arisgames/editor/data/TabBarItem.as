package org.arisgames.editor.data
{
	public class TabBarItem
	{
		public var type:String;
		public var index:int;
		public var enabled:Boolean;
		public var append:String;
		
		public function TabBarItem(type:String, index:int, enabled:Boolean, append:String)
		{
			this.type = type;
			this.index = index;
			this.enabled = enabled;
			this.append = append;
			
			super();
		}
	}
}