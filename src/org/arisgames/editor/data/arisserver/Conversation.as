package org.arisgames.editor.data.arisserver
{
	public class Conversation
	{
		public var conversationId:Number;
		public var npcId:Number;
		public var nodeId:Number; //needed for requirements. They are associated with nodes not conversations
		public var linkText:String;
		public var scriptText:String;
		public var index:Number;

		
		
		public function Conversation()
		{
		}
	}
}