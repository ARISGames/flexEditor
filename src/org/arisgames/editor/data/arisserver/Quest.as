package org.arisgames.editor.data.arisserver
{
  public class Quest
  {
    public var questId:Number;
    public var title:String;
	
	public var activeMediaId:Number;
	public var activeIconMediaId:Number;
	public var activeNotifMediaId:Number;
	public var completeMediaId:Number;
	public var completeIconMediaId:Number;
	public var completeNotifMediaId:Number;
	
    public var activeText:String;
    public var completeText:String;
	
	public var activeNotifFullScreen:Boolean;
	public var completeNotifFullScreen:Boolean;
   
	public var activeGoFunc:String;
	public var completeGoFunc:String;
	
    public var index:Number;

    public function Quest()
    {
		this.questId= 0;
		this.title = "New Quest";
		
		this.activeMediaId = 0;
		this.activeIconMediaId = 0;
		this.activeNotifMediaId = 0;
		this.completeMediaId = 0;
		this.completeIconMediaId = 0;
		this.completeNotifMediaId = 0;
		
		this.activeText = "";
		this.completeText = "";
		
		this.activeNotifFullScreen = false;
		this.completeNotifFullScreen = false;
		
		this.activeGoFunc = "NONE";
		this.completeGoFunc = "NONE";	
		
		this.index = 9999999;

      super();
    }
  }
}
