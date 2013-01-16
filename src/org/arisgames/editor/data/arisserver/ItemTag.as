package org.arisgames.editor.data.arisserver
{
	public class ItemTag
	{
		public var tag:String;
		public var tag_id:int;
		public var tagged:String; //Not actually inherent to the 'tag'. Gets set in relation to whatever item is currently being talked about. Yes, bad practice- This editor is getting completely remade anyways. Calm down. It's fine.
		
		public function ItemTag(tag_id:int, tag:String):void
		{
			this.tag_id = tag_id;
			this.tag = tag;
			this.tagged = "";
		}
	}
}