package org.arisgames.editor.data.arisserver
{
	
	import mx.collections.ArrayCollection;

	public class PlayerNote
	{
		public var playerNoteId:Number;
		public var ownerId:Number;
		public var title:String;
		public var aveRating:Number;
		public var numRatings:Number;
		public var sharedToNotebook:Boolean;
		public var sharedToMap:Boolean;
		public var iconMediaId:Number;
		public var media:ArrayCollection;
		public var textBlob:String;


		/**
		 * Constructor
		 */
		public function PlayerNote()
		{
			super();
		}
	}
}