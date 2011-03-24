package org.arisgames.editor.components
{
import com.google.maps.overlays.Marker;
import com.google.maps.overlays.MarkerOptions;

import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.containers.FormItem;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.Image;
import mx.controls.NumericStepper;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;

import org.arisgames.editor.components.PlaceMarker;
import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.view.RequirementsEditorMX;


public class PlaceMarkerEditorView extends Panel
{
    // GUI
    [Bindable] public var placeMark:PlaceMark;
	[Bindable] public var placeMarker:PlaceMarker;

    // Form Components
    [Bindable] public var locLabel:TextInput;
	[Bindable] public var qrCode:TextInput;
	[Bindable] public var qrImage:Image;
	[Bindable] public var quantityFI:FormItem;
    [Bindable] public var quantity:NumericStepper;
    [Bindable] public var errorRange:NumericStepper;
    [Bindable] public var hidden:CheckBox;
    [Bindable] public var autoDisplay:CheckBox;
	[Bindable] public var quickTravelFI:FormItem;
	[Bindable] public var quickTravel:CheckBox;	
	public var deletePlaceMarkDataButton:Button;
    public var savePlaceMarkDataButton:Button;
    [Bindable] public var openRequirementsEditorButton:Button;

    private var requirementsEditor:RequirementsEditorMX;

    /**
     * Constructor
     */
    public function PlaceMarkerEditorView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, initComponents);
    }

    private function initComponents(evt:FlexEvent):void
    {
        this.title = "PlaceMark Editor (" + placeMark.getContentTypeForPublicDisplayAsString() + ")";

        locLabel.text = placeMark.name;
		qrCode.text = placeMark.qrCode;
		qrImage.addEventListener(MouseEvent.CLICK, handleQRImageClick);

		

		errorRange.value = placeMark.errorRange;
        if (placeMark.getContentTypeForDataBaseAsString() == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            quantityFI.visible = true;
            quantityFI.includeInLayout = true;
            quantityFI.required = true;
            quantity.visible = true;
            quantity.includeInLayout = true;

            quantity.value = placeMark.quantity;
        }
        else
        {
            quantityFI.visible = false;
            quantityFI.includeInLayout = false;
            quantityFI.required = false;
            quantity.visible = false;
            quantity.includeInLayout = false;
        }
        hidden.selected = placeMark.hidden;
        autoDisplay.selected = placeMark.forcedView;
		quickTravel.selected = placeMark.quickTravel;
		
        deletePlaceMarkDataButton.addEventListener(MouseEvent.CLICK, handleDeleteButtonClick);
        savePlaceMarkDataButton.addEventListener(MouseEvent.CLICK, handleSaveDataButtonClick);
        openRequirementsEditorButton.addEventListener(MouseEvent.CLICK, handleOpenRequirementsButtonClick);
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR, closeRequirementsEditor);
    }

	private function handleQRImageClick(event:Event):void
	{
		trace("PlaceMarkerEditorView:handleQRImageClick");
		var url:String = "http://qrcode.kaywa.com/img.php?s=5&d=" + qrCode.text;
		var urlRequest:URLRequest = new URLRequest(url);
		navigateToURL(urlRequest, "_blank");
	}
	
    private function handleOpenRequirementsButtonClick(evt:MouseEvent):void
    {
        trace("Starting handle Open Requirements Button click.");
        this.openRequirementsEditor();
    }
    private function openRequirementsEditor():void
    {
        requirementsEditor = new RequirementsEditorMX();
		requirementsEditor.setRequirementTypeAndId(AppConstants.REQUIREMENTTYPE_LOCATION, placeMark.id);
/*
        mediaPicker.setObjectPaletteItem(objectPaletteItem);
        mediaPicker.setIsIconPicker(isIconMode);
*/
        this.parent.addChild(requirementsEditor);
        // Need to validate the display so that entire component is rendered
        requirementsEditor.validateNow();

        PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
        PopUpManager.centerPopUp(requirementsEditor);
        requirementsEditor.setVisible(true);
        requirementsEditor.includeInLayout = true;
    }

    private function closeRequirementsEditor(evt:DynamicEvent):void
    {
        trace("closeRequirementsEditor called...");
        PopUpManager.removePopUp(requirementsEditor);
        requirementsEditor = null;
    }
    
    private function handleDeleteButtonClick(evt:MouseEvent):void
    {
        trace("Starting handleDeleteButtonClick()...");
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_PLACEMARKREQUESTSDELETION);
        de.placeMark = placeMark;
        AppDynamicEventManager.getInstance().dispatchEvent(de);
        trace("Finished handleDeleteButtonClick()...");
    }

    private function handleSaveDataButtonClick(evt:MouseEvent):void
    {
        trace("Starting handleSaveDataButtonClick()");
        
		// Create a Location Object to update the server
		var loc:Location = new Location();
        loc.locationId = placeMark.id;
        loc.latitude = placeMark.latitude;
        loc.longitude = placeMark.longitude;
        loc.name = locLabel.text;
		loc.qrCode = qrCode.text;
        loc.type = AppUtils.getContentTypeForDatabaseAsString(placeMark.contentType);
        loc.typeId = placeMark.contentId;
        loc.error = errorRange.value;
        if (placeMark.getContentTypeForDataBaseAsString() == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            loc.quantity = quantity.value;
        }
        else
        {
            loc.quantity = 1;
        }
        loc.hidden = hidden.selected;
        loc.forceView = autoDisplay.selected;
		loc.quickTravel = quickTravel.selected;
		AppServices.getInstance().saveLocation(GameModel.getInstance().game.gameId, loc, new Responder(handleUpdateLocation, handleFault));
		
        trace("Finished handleSaveDataButtonClick()");
    }

    public function handleCreateLocation(obj:Object):void
    {
        trace("Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create location (placemark) attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Placemark");
        }
        else
        {
            trace("Create Location (Placemark) was successful");
            Alert.show("This placemark was succesfully created.", "Successfully Created Placemark");
        }
    }

    public function handleUpdateLocation(obj:Object):void
    {
        trace("Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad update location (placemark) attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating Placemark");
        }
        else
        {
            trace("Update Location (Placemark) was successfull, continue updating the model and marker");

			// Update Place Mark Data Model
			placeMark.name = locLabel.text;
			placeMark.qrCode = qrCode.text;
			placeMark.quantity = quantity.value;
			placeMark.hidden = hidden.selected;
			placeMark.forcedView = autoDisplay.selected;
			placeMark.quickTravel = quickTravel.selected;
			placeMark.errorRange = errorRange.value;
			
			//Update the Google Marker
			var options:MarkerOptions = placeMarker.getOptions();
			options.tooltip = locLabel.text;
			placeMarker.setOptions(options);
			
			
            Alert.show("This placemark was succesfully updated.", "Successfully Updated Placemark");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called...");
        Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
    }
}
}