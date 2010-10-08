package org.arisgames.editor.forms
{

import flash.events.MouseEvent;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.NumericStepper;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.FlexEvent;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.util.AppConstants;

// WB I don't think this class is used anymore, replaced by components.PlaceMarkEditorView.as
public class PlaceMarkEditorFormView extends Panel
{
    // Content Types
    public var contentTypes:Array;

    // Form Items
    [Bindable] public var pmContentType:ComboBox;
    [Bindable] public var pmName:TextInput;
    [Bindable] public var pmDescription:TextArea;
    [Bindable] public var pmQuantity:NumericStepper;
    [Bindable] public var pmHidden:CheckBox;
    [Bindable] public var pmForcedView:CheckBox;

    // Value types to get around original runtime binding timing issue when using components directly
    [Bindable] public var pmContentTypeVal:Number;
    [Bindable] public var pmNameVal:String;
    [Bindable] public var pmDescriptionVal:String;
    [Bindable] public var pmQuantityVal:Number;
    [Bindable] public var pmHiddenVal:Boolean;
    [Bindable] public var pmForcedViewVal:Boolean;

    // Control Buttons
    [Bindable] public var savePlaceMarkButton:Button;
    [Bindable] public var removePlaceMarkButton:Button;

    /**
     * Constructor
     */
    public function PlaceMarkEditorFormView()
    {
        super();
        trace("PlaceMarkEditorFormView constructor called...");
        contentTypes = new Array(AppConstants.CONTENTTYPE_CHARACTER, AppConstants.CONTENTTYPE_ITEM, AppConstants.CONTENTTYPE_PAGE);
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        savePlaceMarkButton.addEventListener(MouseEvent.CLICK, onSavePlaceMarkButtonClick);
        removePlaceMarkButton.addEventListener(MouseEvent.CLICK, onRemovePlaceMarkButtonClick);
//        StateModel.getInstance().addEventListener(AppConstants.APPLICATIONDYNAMICEVENT_CURRENTSTATECHANGED, handlePlaceMarkSelected);
    }

/*
    public function handlePlaceMarkSelected(evt:DynamicEvent):void
    {
        trace("handling PlaceMark Selected DynamicEvent");
        var pm:PlaceMark = GameModel.getInstance().currentPlaceMark;
        if (pm != null)
        {
            pmContentType.selectedItem = pm.contentType;
            trace("content type = " + pm.contentType);
            pmName.text = pm.name;
            trace("name = " + pm.name);
            pmDescription.text = pm.description;
            trace("description = " + pm.description);
            pmQuantity.value = pm.quantity;
            trace("quatity = " + pm.quantity);
            pmHidden.selected = pm.hidden;
            trace("hidden = " + pm.hidden);
            pmForcedView.selected = pm.forcedView;
            trace("forced view = " + pm.forcedView);
        }
        else
        {
            trace("placemark from gamemodel was null, so didn't rebind the components.");
        }
    }
*/

    private function onSavePlaceMarkButtonClick(evt:MouseEvent):void
    {
        trace("Save PlaceMark clicked...");
        GameModel.getInstance().currentPlaceMark.contentType = pmContentType.selectedIndex;
        GameModel.getInstance().currentPlaceMark.name = pmName.text;
        GameModel.getInstance().currentPlaceMark.description = pmDescription.text;
        GameModel.getInstance().currentPlaceMark.quantity = pmQuantity.value;
        GameModel.getInstance().currentPlaceMark.hidden = pmHidden.selected;
        GameModel.getInstance().currentPlaceMark.forcedView = pmForcedView.selected;
    }

    private function onRemovePlaceMarkButtonClick(evt:MouseEvent):void
    {
        trace("Remove PlaceMark clicked...");
        Alert.show("Not implemented yet.");
    }
}
}