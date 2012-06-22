package org.arisgames.editor.view
{
import com.google.maps.LatLng;

import flash.events.MouseEvent;

import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.NumericStepper;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.managers.PopUpManager;


import org.arisgames.editor.components.RequirementsEditorMap;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class LocationPickerView extends Panel
{
    [Bindable] public var reMap:RequirementsEditorMap;
    [Bindable] public var radius:NumericStepper;
    [Bindable] public var mapCloseButton:Button;

    private var latitude:Number;
    private var longitude:Number;
	public var delegate:Object;

    /**
     * Constructor
     */
    public function LocationPickerView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        mapCloseButton.addEventListener(MouseEvent.CLICK, handleMouseCloseButtonClick);
        if (!isNaN(latitude) && !isNaN(longitude))
        {
            trace("latitude and longitude exist in onComplete, so will update the placemark location from here");
            reMap.setMarkerLatLon(new LatLng(latitude, longitude), 0);
        }
    }

    public function setPlacemarkLocation(lat:Number, lon:Number, zoom:Number):void
    {
        this.latitude = lat;
        this.longitude = lon;
        if (reMap != null)
        {
            trace("reMap isn't null, so can update the marker location here.");
            reMap.setMarkerLatLon(new LatLng(latitude, longitude), zoom);
        }
    }

    private function handleMouseCloseButtonClick(evt:MouseEvent):void
    {
        trace("handleMouseCloseButtonClick() called...");
		
		delegate.setLatLon(reMap.getMarkerLat(), reMap.getMarkerLon());
		PopUpManager.removePopUp(this);
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called with message: " + obj.fault.faultString);
        Alert.show("Error occurred: " + obj.fault.faultString, "Problem In Requirements Editor Map");
    }
}
}