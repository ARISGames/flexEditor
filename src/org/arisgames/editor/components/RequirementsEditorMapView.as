package org.arisgames.editor.components
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

import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class RequirementsEditorMapView extends Panel
{
    [Bindable] public var requirement:Requirement;
    [Bindable] public var reMap:RequirementsEditorMap;
    [Bindable] public var radius:NumericStepper;
    [Bindable] public var mapCloseButton:Button;

    private var latitude:Number;
    private var longitude:Number;

    /**
     * Constructor
     */
    public function RequirementsEditorMapView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        mapCloseButton.addEventListener(MouseEvent.CLICK, handleMouseCloseButtonClick);
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_SAVEREQUIREMENTDUETOMAPDATACHANGE, handleSaveRequirementDynamicRequest);
        if (!isNaN(latitude) && !isNaN(longitude))
        {
            trace("latitude and longitude exist in onComplete, so will update the placemark location from here");
            reMap.setMarkerLatLon(new LatLng(latitude, longitude), 0);
        }
        reMap.requirement = requirement;
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
        var de:DynamicEvent;
        trace("Original Radius = '" + requirement.requirementDetail1 + "'; UI Radius Value = '" + radius.value + "'");
        if (parseInt(requirement.requirementDetail1) != radius.value)
        {
            trace("Original Radius and UI Radius value are different so fire a save event.");
            de = new DynamicEvent(AppConstants.DYNAMICEVENT_SAVEREQUIREMENTDUETOMAPDATACHANGE);
            de.requirementId = requirement.requirementId;
            de.radius = radius.value;
            AppDynamicEventManager.getInstance().dispatchEvent(de);
        }

        de = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITORMAP);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleSaveRequirementDynamicRequest(evt:DynamicEvent):void
    {
        trace("handleSaveRequirementDynamicRequest() called...  Going to use Local Requirement ID = '" + requirement.requirementId + "'; Event's Requirement ID = '" + evt.requirementId + "'");

        if (requirement.requirementId != evt.requirementId)
        {
            trace("The two requirement ids don't match up, so return without doing a save.");
            return;
        }
        
        var shouldSave:Boolean = false;

        if (evt.latitude)
        {
            requirement.requirementDetail3 = evt.latitude;
            shouldSave = true;
        }
        if (evt.longitude)
        {
            requirement.requirementDetail4 = evt.longitude;
            shouldSave = true;
        }
        if (evt.radius)
        {
            requirement.requirementDetail1 = evt.radius;
            shouldSave = true;
        }

        if (shouldSave)
        {
            trace("shouldSave is true, so save the Requirement.");
            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, requirement, new Responder(handleUpdateLocation, handleFault));
        }
    }

    public function handleUpdateLocation(obj:Object):void
    {
        trace("handleUpdateLocation Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad update requirement attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating Requirement Placemark");
        }
        else
        {
            trace("Update Requirement Placemark was successfull.");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called with message: " + obj.fault.faultString);
        Alert.show("Error occurred: " + obj.fault.faultString, "Problem In Requirements Editor Map");
    }
}
}