package org.arisgames.editor.data.arisserver	
{
	import org.arisgames.editor.util.AppConstants;

	public class PlayerStateChange
	{
		public var playerStateChangeId:Number;
		public var eventType:String; //Needs to be PLAYERSTATECHANGE_EVENTTYPE_
		public var eventDetail:Number; //Usally the Id of the thing
		public var action:String; //Needs to be PLAYERSTATECHANGE_ACTION_
		public var actionDetail:Number; //Usally the Id of the thing
		public var actionAmount:Number; //The amount to give or take
		
		public function PlayerStateChange()
		{
			super();
		}
	}
}