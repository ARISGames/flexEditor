package org.arisgames.editor.components
{
import com.google.maps.InfoWindowOptions;
import com.google.maps.LatLng;
import com.google.maps.MapMouseEvent;
import com.google.maps.overlays.Marker;
import com.google.maps.overlays.MarkerOptions;
import com.google.maps.styles.FillStyle;

import flash.geom.Point;

import mx.controls.Alert;
import mx.rpc.Responder;

import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.view.PlaceMarkerIcon;


public class PlaceMarker extends Marker
{
    [Bindable] public var placemark:PlaceMark;
    [Bindable] public var map:NavigationMap;


    /**
     * Constructor
     * @param latLng
     * @param mo
     */
    public function PlaceMarker(latLng:LatLng, pm:PlaceMark, theMap:NavigationMap)
    {
		var options:MarkerOptions = new MarkerOptions();
		options.draggable = true;
		var icon:PlaceMarkerIcon = new PlaceMarkerIcon(pm.name);
		options.icon = icon;
		
		super(latLng, options);
        this.placemark = pm;
        this.placemark.latitude = latLng.lat();
        this.placemark.longitude = latLng.lng();
        this.map = theMap;
        addEventListener(MapMouseEvent.CLICK, handleMouseClickedEvent);
        addEventListener(MapMouseEvent.DRAG_END, handleDragEndEvent);
    }
	

    public function handleMouseClickedEvent(event:MapMouseEvent):void
    {
        trace("Marker clicked...");
        if (StateModel.getInstance().currentState == StateModel.VIEWGAMEEDITORPLACEMARKEDITOR)
        {
            trace("StateModel equals PlaceMarkEditor so setting back to ViewGameEditor.");
            StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITOR;
        }
        else
        {
            trace("StateModel does NOT equal PlaceMarkEditor so setting to ViewGameEditorPlaceMarkEditor.");
            if (placemark == null)
            {
                trace("marker data is null");
            }
            else
            {
                trace("marker data is NOT null: " + placemark);
                var iwo:InfoWindowOptions = new InfoWindowOptions();
                var pme:PlaceMarkerEditorMX = new PlaceMarkerEditorMX();
                pme.placeMark = placemark;
				pme.placeMarker = this;
                iwo.customContent = pme;
                iwo.drawDefaultFrame = true;
				iwo.width = 360;
				iwo.height = 360;
				iwo.pointOffset = new Point(0,0);
				iwo.tailHeight = 15;
				iwo.hasCloseButton = false;
				
				iwo.fillStyle = new FillStyle({color: 0xFFFFFF,alpha: 0.9});

                openInfoWindow(iwo);
            }
            GameModel.getInstance().currentPlaceMark = placemark;
            StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITORPLACEMARKEDITOR;
        }
    }

    public function handleDragEndEvent(event:MapMouseEvent):void
    {
        trace("PlaceMarker: Handle Drag End Event called...");
        placemark.latitude = event.latLng.lat();
        placemark.longitude = event.latLng.lng();
        trace("Updated Latitude: " + placemark.latitude + "; Updated Longitude: " + placemark.longitude);

        // Save Data To Database
        var loc:Location = new Location();
        loc.locationId = placemark.id;
        loc.latitude = placemark.latitude;
        loc.longitude = placemark.longitude;
        loc.name = placemark.name;
        loc.type = AppUtils.getContentTypeForDatabaseAsString(placemark.contentType);
        loc.typeId = placemark.contentId;
        loc.quantity = placemark.quantity;
        loc.hidden = placemark.hidden;
        loc.forceView = placemark.forcedView;
		loc.quickTravel = placemark.quickTravel;
        loc.error = placemark.errorRange;
		loc.qrCode = placemark.qrCode;
        trace("location type looked up = '" + loc.type + "'");

        AppServices.getInstance().saveLocation(GameModel.getInstance().game.gameId, loc, new Responder(handleUpdateLocation, handleFault));
        trace("Done with Drag PlaceMarker event.");
    }

    public function handleUpdateLocation(obj:Object):void
    {
        trace("handleUpdateLocation Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad update location (placemark) attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating Placemark");
        }
        else
        {
            trace("Update Location (Placemark) was successfull.");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called...");
        Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
    }
}
}
