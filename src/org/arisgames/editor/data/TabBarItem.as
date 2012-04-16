package org.arisgames.editor.data
{
	import org.arisgames.editor.util.AppUtils;
	public class TabBarItem
	{
		public var type:String;
		public var human:String;
		public var index:int;
		public var enabled:Boolean;
		public var append:String;
		
		public function TabBarItem(type:String, index:int, enabled:Boolean, append:String)
		{
			this.type = type;
			this.human = AppUtils.convertGameTabDatabaseLabelToHumanLabel(type);
			this.index = index;
			this.enabled = enabled;
			this.append = append;
			
			super();
		}
	}
}