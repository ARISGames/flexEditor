package org.arisgames.editor.data.arisserver
{
	public class PlayerNoteMedia // "Extends" the type of object required for multimedia picker... not officially or anything... but... yeah
	{
		public var playerNoteId:Number;
		public var text:String;
		public var id:Number;
		public var media:Media;
		public var index:Number;
		public var name:String;
		
		/**
		 * Constructor
		 */
		public function PlayerNoteMedia(mId:Number, text:String, index:Number)
		{
			super();
			this.id = mId;
			this.text = text;
			this.index = index;
		}
	}
}