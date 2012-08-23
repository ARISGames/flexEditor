package org.arisgames.editor.view
{

import flash.events.MouseEvent;

import mx.containers.ApplicationControlBar;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;

import org.arisgames.editor.components.NavigationMap;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;


// WB: Handles GeoSearch Events for The Map, passes them along to NavigationMap for FlyTo. 
public class GameEditorMapView extends VBox
{
    // Map and Control Pane
    [Bindable] public var theMap:NavigationMap;

    [Bindable] public var mapControlBar:ApplicationControlBar;
    [Bindable] public var mapSearchText:TextInput;
    [Bindable] public var mapGoButton:Button;
	[Bindable] public var centerMapButton:Button;
	[Bindable] public var refreshButton:Button;

    /**
     * Constructor
     */
    public function GameEditorMapView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.APPLICATIONDYNAMICEVENT_CENTERMAP, onCenterMapButtonClick);

    }

    private function onComplete(event:FlexEvent): void
    {
        mapGoButton.addEventListener(MouseEvent.CLICK, onMapGoButtonClick);
		centerMapButton.addEventListener(MouseEvent.CLICK, onCenterMapButtonClick);
		refreshButton.addEventListener(MouseEvent.CLICK, onRefreshButtonClick);

        addEventListener(AppConstants.DYNAMICEVENT_GEOSEARCH, handleGeoSearchEvent);
    }

    private function onMapGoButtonClick(evt:Event):void
    {
        trace("process map search...");
        if (mapSearchText.text == null || mapSearchText.text.length < 1)
        {
            Alert.show("Nothing was entered into the search box.  Please enter a geographic term to search form.", "No Text Entered");
        }
        else
        {
            trace("Going to try to lookup: '" + mapSearchText.text + "'");

            var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_GEOSEARCH);
            de.geoSearchText = mapSearchText.text;
            dispatchEvent(de);
        }
    }

	private function onCenterMapButtonClick(evt:Event):void
	{
		trace("GameEditorMapView: Center Map Button Clicked!");
		if(theMap && theMap.isSoReady) theMap.centerMapOnData(true);
	}
	
	private function onRefreshButtonClick(evt:MouseEvent):void
	{
		trace("GameEditorMapView: Refresh Button Clicked!");
		GameModel.getInstance().loadLocations(); //Refresh Map Locations
		//theMap.centerMapOnData(false); //Center Map
		var de:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE); //Refresh Side Palette
		AppDynamicEventManager.getInstance().dispatchEvent(de);
	}

	
    public function handleGeoSearchEvent(evt:DynamicEvent):void
    {
        trace("GameEditorView is going to try a doFlyTo()");
        theMap.doFlyTo(evt.geoSearchText);
    }
}
}