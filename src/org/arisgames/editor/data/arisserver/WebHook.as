package org.arisgames.editor.data.arisserver
{
	public class WebHook
	{
		public var name:String;
		public var webHookId:Number;
		public var incoming:Boolean; //true if incoming, false if outgoing
		public var url:String;
		public var appendage:String;
		
		public function WebHook(name:String, id:Number, url:String, incoming:Boolean):void
		{
			this.name = name;
			this.webHookId = id;
			this.url = url;
			this.incoming = incoming;
		}
	}
}