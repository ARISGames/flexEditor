package org.arisgames.editor.data.arisserver
{
	public class CustomMap
	{
		public var name:String;
		public var customMapId:Number;
		public var index:Number;
		public var tileFolder:String;
		public var zipUploaded:Boolean;
		
		public function CustomMap(name:String, id:Number, index:Number):void
		{
			this.name = name;
			this.customMapId = id;
			this.index = index;
			zipUploaded = false;
		}
	}
}
