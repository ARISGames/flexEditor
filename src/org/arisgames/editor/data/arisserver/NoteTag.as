package org.arisgames.editor.data.arisserver
{
	public class NoteTag
	{
		public var tag:String;
		public var tag_id:int;
		public var player_created:int;
		
		public function NoteTag(tag_id:int, tag:String, player_created:int):void
		{
			this.tag_id = tag_id;
			this.tag = tag;
			this.player_created = player_created;
		}
	}
}