package org.arisgames.editor.models
{
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;

import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;



public class GameModel
{
    // Singleton Pattern
    public static var instance:GameModel;

    // Data
    [Bindable] public var game:Game;
    [Bindable] public var currentPlaceMark:PlaceMark;

    /**
     * Singleton constructor... will throw error if accessed directly
     */
    public function GameModel()
    {
        if (instance != null)
        {
            throw new Error("GameModel is a singleton, can only be accessed by calling getInstance() function.");
        }
        instance = this;
        game = new Game();
    }

    public static function getInstance():GameModel
    {
        if (instance == null)
        {
            instance = new GameModel();
        }
        return instance;
    }

    public function addPlaceMark(pm:PlaceMark):void
    {
        if (!game.placeMarks.contains(pm))
        {
            game.placeMarks.addItem(pm);
        }
    }

    public function removePlaceMark(pm:PlaceMark):void
    {
        var index:int = game.placeMarks.getItemIndex(pm);
        if (index != -1)
        {
            game.placeMarks.removeItemAt(index);    
        }
    }
	
	public function removeOpenPlaceMarkEditors():void 
	{
		if(game.placeMarks.length > 0){
			var pm:PlaceMark;
			//Go through all datapoints, closing editors if they are open (if not, closePME() does nothing)
			for (var j:Number = 0; j < game.placeMarks.length; j++)
			{
				pm = game.placeMarks.getItemAt(j) as PlaceMark;
				if(pm.placeMarker) 
					pm.placeMarker.closePME();
			}
		}
	}
	
	public function deselectPlaceMarks():void 
	{
		if(game.placeMarks.length > 0){
			var pm:PlaceMark;
			//Go through all datapoints, closing editors if they are open (if not, closePME() does nothing)
			for (var j:Number = 0; j < game.placeMarks.length; j++)
			{
				pm = game.placeMarks.getItemAt(j) as PlaceMark;
				pm.placeMarker.icon.deSelect();
			}
		}
	}
	
	
	public function loadLocations():void
	{
		trace("GameModel: loadLocations() called...");

		AppServices.getInstance().getLocationsByGameId(game.gameId, new Responder(handleLoadLocations, handleFault));
	}
	
	private function handleLoadLocations(obj:Object):void
	{
		trace("GameModel: handleLoadLocations() called...");
		var tmpPlacemarks:ArrayCollection;
		tmpPlacemarks = new ArrayCollection();
		var dup:Boolean;
		if(obj.result.data != null){
			for (var j:Number = 0; j < obj.result.data.list.length; j++)
			{
				dup = false;
				var pm:PlaceMark = new PlaceMark();
				pm.id = obj.result.data.list.getItemAt(j).location_id;
				pm.latitude = obj.result.data.list.getItemAt(j).latitude;
				pm.longitude = obj.result.data.list.getItemAt(j).longitude;
				pm.name = obj.result.data.list.getItemAt(j).name;
				pm.errorText = obj.result.data.list.getItemAt(j).fail_text;
				pm.qrCode = obj.result.data.list.getItemAt(j).code;
				pm.contentType = AppUtils.getContentTypeValueByName(obj.result.data.list.getItemAt(j).type);
				pm.contentId = obj.result.data.list.getItemAt(j).type_id;
				pm.quantity = obj.result.data.list.getItemAt(j).item_qty;
				pm.hidden = obj.result.data.list.getItemAt(j).hidden ? (obj.result.data.list.getItemAt(j).hidden == '1' ? true : false) : false;
				pm.forcedView = obj.result.data.list.getItemAt(j).force_view ? (obj.result.data.list.getItemAt(j).force_view == '1' ? true : false) : false;
				pm.errorRange = obj.result.data.list.getItemAt(j).error;
				pm.quickTravel = obj.result.data.list.getItemAt(j).allow_quick_travel ? (obj.result.data.list.getItemAt(j).allow_quick_travel == '1' ? true : false) : false;
				pm.wiggle = obj.result.data.list.getItemAt(j).wiggle ? (obj.result.data.list.getItemAt(j).wiggle == '1' ? true : false) : false;
				pm.displayAnnotation = obj.result.data.list.getItemAt(j).show_title ? (obj.result.data.list.getItemAt(j).show_title == '1' ? true : false) : false;
				pm.imageMatchMediaId = obj.result.data.list.getItemAt(j).match_media_id;
				pm.isFountain = obj.result.data.list.getItemAt(j).is_fountain == 1;

				for each (var p:PlaceMark in tmpPlacemarks){
					if(pm.id == p.id){
						dup = true;
					}
				}
				if(!dup) tmpPlacemarks.addItem(pm);
			}
		}
		
		GameModel.getInstance().game.placeMarks.removeAll();
		GameModel.getInstance().game.placeMarks.addAll(tmpPlacemarks);
		trace("Done loading and casting the locations.  Size = " + tmpPlacemarks.length);
		
		trace("Dispatching APPLICATIONDYNAMICEVENT_GAMEPLACEMARKSLOADED");
		var de:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_GAMEPLACEMARKSLOADED);
		AppDynamicEventManager.getInstance().dispatchEvent(de);
		
		trace("Finished with handleLoadLocations.");
			
	}	
	
	public function handleFault(obj:Object):void
	{
		trace("Fault called.  The error is: " + obj.fault.faultString);
		Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
	}
	
	
}
}