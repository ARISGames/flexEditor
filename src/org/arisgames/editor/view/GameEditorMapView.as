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
import org.arisgames.editor.util.AppConstants;

// WB: Handles GeoSearch Events for The Map, passes them along to NavigationMap for FlyTo. 
public class GameEditorMapView extends VBox
{
    // Map and Control Pane
    [Bindable] public var theMap:NavigationMap;

    [Bindable] public var mapControlBar:ApplicationControlBar;
    [Bindable] public var mapSearchText:TextInput;
    [Bindable] public var mapGoButton:Button;

    /**
     * Constructor
     */
    public function GameEditorMapView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        mapGoButton.addEventListener(MouseEvent.CLICK, onMapGoButtonClick);
        addEventListener(AppConstants.DYNAMICEVENT_GEOSEARCH, handleGeoSearchEvent);
    }

    private function onMapGoButtonClick(evt:MouseEvent):void
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

    public function handleGeoSearchEvent(evt:DynamicEvent):void
    {
        trace("GameEditorView is going to try a doFlyTo()");
        theMap.doFlyTo(evt.geoSearchText);
    }
}
}