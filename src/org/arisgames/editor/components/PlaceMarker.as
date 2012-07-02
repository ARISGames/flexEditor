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
import mx.events.DynamicEvent;
import mx.events.FlexMouseEvent;
import mx.rpc.Responder;
import mx.collections.ArrayCollection;

import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.view.PlaceMarkerIcon;



public class PlaceMarker extends Marker
{
    [Bindable] public var placemark:PlaceMark;
    [Bindable] public var map:NavigationMap;
	public var loc:Location;
	public var pme:PlaceMarkerEditorMX;
	public var iwo:InfoWindowOptions
	public var icon:PlaceMarkerIcon;
	public var instanceOfObjectId:Number;
	
	public var imageMatchMediaIdList:ArrayCollection;
	public var imageMatchMediaList:ArrayCollection;
	
	public var imageMatchMediaId:Number;
	public var imageMatchMedia:Media;

    /**
     * Constructor
     * @param latLng
     * @param mo
     */
    public function PlaceMarker(latLng:LatLng, pm:PlaceMark, theMap:NavigationMap)
    {
		var options:MarkerOptions = new MarkerOptions();
		options.draggable = true;
		icon = new PlaceMarkerIcon(pm.name);
		if(pm.objectPalletItemBO){
			if(pm.objectPalletItemBO.iconMedia){
				if(pm.objectPalletItemBO.iconMedia.urlPath){
					icon.setNewIcon(pm.objectPalletItemBO.iconMedia.urlPath+pm.objectPalletItemBO.iconMedia.fileName);
				}
			}
		}
		options.icon = icon;
		this.imageMatchMedia = pm.imageMatchMedia;
		this.imageMatchMediaId = pm.imageMatchMediaId;
		
		super(latLng, options);
		pm.placeMarker = this;
        this.placemark = pm;
        this.placemark.latitude = latLng.lat();
        this.placemark.longitude = latLng.lng();
        this.map = theMap;

        addEventListener(MapMouseEvent.CLICK, handleMouseClickedEvent);
        addEventListener(MapMouseEvent.DRAG_END, handleDragEndEvent);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_HIGHLIGHTOBJECTPALETTEITEM, highlightMe);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_OBJECTPALETTEITEMICONSET, setIcon);
    }
	
	public function highlightMe(evt:DynamicEvent):void {
		trace("Un/Highlighting Stuff");
		trace("I am placemark: " +placemark.id + " of type: " + placemark.contentType + " of contentId: " + placemark.contentId + " and my name is: '" + placemark.name + "'");
		trace(" and this object was clicked: " + evt.objectPaletteItem.id + " with objectId: " + evt.objectPaletteItem.objectId + " of type: " + evt.objectPaletteItem.objectType);
		var sameType:Boolean = false;
		
		//ISSUE WITH NAMING CONSISTENCY \/ \/ \/
		//trace(evt.objectPaletteItem.objectType + " = " + AppConstants.CONTENTTYPE_CHARACTER + " & " + placemark.contentType + " = 1?; " + evt.objectPaletteItem.objectType + " = " + AppConstants.CONTENTTYPE_ITEM + " & " + placemark.contentType + " = 2?; " + evt.objectPaletteItem.objectType + " = " + AppConstants.CONTENTTYPE_PAGE + " & " + placemark.contentType + " = 0?; ");
		//if((evt.objectPaletteItem.objectType == AppConstants.CONTENTTYPE_CHARACTER && placemark.contentType == 1) || (evt.objectPaletteItem.objectType == AppConstants.CONTENTTYPE_ITEM && placemark.contentType == 2) || (evt.objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE && placemark.contentType == 0))
		
		//Below "if" logic SHOULD be replaced by commented out logic above/ Naming inconsistencies prevent this. :(
		if((evt.objectPaletteItem.objectType == "Npc" && placemark.contentType == 1) || (evt.objectPaletteItem.objectType == "Item" && placemark.contentType == 2) || (evt.objectPaletteItem.objectType == "Node" && placemark.contentType == 0) || (evt.objectPaletteItem.objectType == "WebPage" && placemark.contentType == 4) || (evt.objectPaletteItem.objectType == "AugBubble" && placemark.contentType == 5) || (evt.objectPaletteItem.objectType == "PlayerNote" && placemark.contentType == 6))
			sameType = true;
		if(sameType && evt.objectPaletteItem.objectId == placemark.contentId){
			icon.highlight();
		}
		else{
			icon.unHighlight();
		}
	}
	
	public function setIcon(evt:DynamicEvent):void {
		trace("Placemarker: setting Icon");
		var sameType:Boolean = false;
		if((evt.objectPaletteItem.objectType == "Npc" && placemark.contentType == 1) || (evt.objectPaletteItem.objectType == "Item" && placemark.contentType == 2) || (evt.objectPaletteItem.objectType == "Node" && placemark.contentType == 0) || (evt.objectPaletteItem.objectType == "WebPage" && placemark.contentType == 4) || (evt.objectPaletteItem.objectType == "AugBubble" && placemark.contentType == 5))
			sameType = true;
		if(sameType && evt.objectPaletteItem.objectId == placemark.contentId){
			this.placemark.iconURL = evt.iconURL;
			this.icon.setNewIcon(evt.iconURL);
		}
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
                iwo = new InfoWindowOptions();
                pme = new PlaceMarkerEditorMX();
                pme.placeMark = placemark;
				pme.placeMarker = this;
                iwo.customContent = pme;
                iwo.drawDefaultFrame = true;
				iwo.width = 360;
				iwo.height = 400;
				iwo.pointOffset = new Point(0,-30);//Sets window slightly above point clicked
				iwo.tailHeight = 15;
				iwo.hasCloseButton = false;
				
				iwo.fillStyle = new FillStyle({color: 0xFFFFFF,alpha: 0.9});

                openInfoWindow(iwo);
				GameModel.getInstance().deselectPlaceMarks();
				icon.select();
            }
            GameModel.getInstance().currentPlaceMark = placemark;
            StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITORPLACEMARKEDITOR;
        }
    }
	
	public function closePME():void
	{
		trace("PlaceMarker: closing place marker editor");
		if(pme != null){
			pme.closeWithoutSaving();
		}
	}

    public function handleDragEndEvent(event:MapMouseEvent):void
    {
        trace("PlaceMarker: Handle Drag End Event called...");
        placemark.latitude = event.latLng.lat();
        placemark.longitude = event.latLng.lng();
        trace("Updated Latitude: " + placemark.latitude + "; Updated Longitude: " + placemark.longitude);

        // Save Data To Database
        loc = new Location();
        loc.locationId = placemark.id;
        loc.latitude = placemark.latitude;
        loc.longitude = placemark.longitude;
        loc.name = placemark.name;
		loc.errorText = placemark.errorText;
        loc.type = AppUtils.getContentTypeForDatabaseAsString(placemark.contentType);
        loc.typeId = placemark.contentId;
        loc.quantity = placemark.quantity;
        loc.hidden = placemark.hidden;
        loc.forceView = placemark.forcedView;
		loc.quickTravel = placemark.quickTravel;
		loc.wiggle = placemark.wiggle;
		loc.displayAnnotation = placemark.displayAnnotation;
        loc.error = placemark.errorRange;
		loc.qrCode = placemark.qrCode;
        trace("location type looked up = '" + loc.type + "'");

        AppServices.getInstance().saveLocation(GameModel.getInstance().game.gameId, loc, imageMatchMediaId, new Responder(handleUpdateLocation, handleFault));
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
