package org.arisgames.editor.data
{
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.DynamicEvent;
import mx.rpc.Responder;

import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;



[Bindable]
public class Game
{
    public var gameId:int;
    public var name:String;
    public var description:String;
    public var placeMarks:ArrayCollection;
    public var gameObjects:ArrayCollection;
	
	public var noteShareToMap:Boolean;
	public var noteShareToBook:Boolean;
	public var playerCreateTags:Boolean;
	public var allowtrading:Boolean;
	public var playerCreateComments:Boolean;
	public var playerLikesNotes:Boolean;
	public var isLocational:Boolean;
	public var readyForPublic:Boolean;
	public var showPlayerOnMap:Boolean;
	
	public var iconMediaId:int;
	public var pcMediaId:int;
	public var introNodeId:int;
	public var completeNodeId:int;
	public var inventoryCap:int;
	
	//Variables for GameDetailsEditor media uploads
	public var mediaId:Number;
	public var media:Media;
	public var iconMedia:Media;


	
    public function Game()
    {
        super();
        placeMarks = new ArrayCollection();
        gameObjects = new ArrayCollection();
    }
	
	public function saveOnServer():void
	{
		AppServices.getInstance().saveGame(this, new Responder(handleSave, handleFault));
	}
	
	public function deleteOnServer():void
	{
		AppServices.getInstance().deleteGame(this, new Responder(handleDelete, handleFault));
	}
	
	private function handleDelete(obj:Object):void
	{
	}
	
	private function handleSave(obj:Object):void
	{
		trace("In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
		if (obj.result.returnCode != 0)
		{
			trace("Bad save page content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Saving Page");
		}
		else
		{
			trace("Save page content was successful, now close the editor and update the object palette.");
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
			
			var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
			AppDynamicEventManager.getInstance().dispatchEvent(uop);
		}
		trace("Finished with handleSaveContent().");
	}

	public function handleFault(obj:Object):void
	{
		trace("Game: handleFault");
		Alert.show(obj.fault.faultString, "Error Saving Changes");
	}	
	
}
}