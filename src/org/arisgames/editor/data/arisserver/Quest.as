package org.arisgames.editor.data.arisserver
{
	public class Quest
	{
		public var questId:Number;
		public var title:String;
		public var activeText:String;
		public var completeText:String;
		public var fullScreenNotification:Boolean;
		public var activeMediaId:Number;
		public var completeMediaId:Number;
		public var activeIconMediaId:Number;
		public var completeIconMediaId:Number;
		public var exitToTab:String;
		
		public var index:Number;
		
		/**
		 * Constructor
		 */
		public function Quest()
		{
			this.exitToTab = "NONE";
			super();
		}
	}
}