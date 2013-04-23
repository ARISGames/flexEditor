package org.arisgames.editor.view
{
import flash.events.Event;
import flash.events.MouseEvent;

import mx.containers.FormItem;
import mx.containers.HBox;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.NumericStepper;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.validators.Validator;
import mx.managers.PopUpManager;

import org.arisgames.editor.components.ItemEditorMediaDisplayMX;
import org.arisgames.editor.view.SpawnableEditorMX;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.util.AppDynamicEventManager;

public class ObjectEditorItemView extends Panel
{
    // Data Object
    public var objectPaletteItem:ObjectPaletteItemBO;

    // GUI
	[Bindable] public var theName:TextInput;
	[Bindable] public var type:ComboBox;
	[Bindable] public var url:TextInput;
	[Bindable] public var urlFI:FormItem;
	[Bindable] public var weight:NumericStepper;
	[Bindable] public var weightFI:FormItem;
    [Bindable] public var description:TextArea;
    [Bindable] public var dropable:CheckBox;
	[Bindable] public var dropableFI:FormItem;
	[Bindable] public var tradeable:CheckBox;
	[Bindable] public var tradeableFI:FormItem;
	[Bindable] public var destroyable:CheckBox;
	[Bindable] public var destroyableFI:FormItem;
	[Bindable] public var attribute:CheckBox;
	[Bindable] public var attributeFI:FormItem;
	[Bindable] public var maxQty:NumericStepper;	
    [Bindable] public var cancelButton:Button;
    [Bindable] public var saveButton:Button;
    [Bindable] public var hbox:HBox;
    [Bindable] public var mediaDisplay:ItemEditorMediaDisplayMX;
	[Bindable] public var descLabel:FormItem;
	[Bindable] public var spawnablePopupButton:Button;
	
	[Bindable] public var itemTagsButton:Button;

    [Bindable] public var v1:Validator;
    [Bindable] public var v2:Validator;
	
	private var spawnablePopup:SpawnableEditorMX;

    /**
     * Constructor
     */
    public function ObjectEditorItemView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
		attribute.setVisible(false);
		attribute.includeInLayout = false;
		attributeFI.setVisible(false);
		attribute.includeInLayout = false;

		handleTypeChange(null);
		
        trace("ItemEditorItemView: handleInit");
		itemTagsButton.addEventListener(MouseEvent.CLICK, itemTagsButtonOnClick);
        saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		type.addEventListener(flash.events.Event.CHANGE, handleTypeChange);
		spawnablePopupButton.addEventListener(MouseEvent.CLICK, handleSpawnableButton);
    }
	
	private function itemTagsButtonOnClick(evt:MouseEvent):void
	{
		trace("itemTagsButtonOnClick() started... ");
		var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_OPENITEMTAGSEDITOR);
		AppDynamicEventManager.getInstance().dispatchEvent(de);	
	}
	
	private function handleSpawnableButton(evt:MouseEvent):void
	{
		trace("ObjectEditorItemView: handleSpawnableButton() called...");
		spawnablePopup = new SpawnableEditorMX();
		spawnablePopup.setObjectPaletteItem(objectPaletteItem);
		spawnablePopup.delegate = this;
		this.spawnablePopupButton.label = "Edit Spawn Settings";
		PopUpManager.addPopUp(spawnablePopup, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(spawnablePopup);
	}

	public function duplicateObject(evt:Event):void {
		AppServices.getInstance().duplicateObject(GameModel.getInstance().game, objectPaletteItem.id, new Responder(handleDupedObject, handleFault));
	}
	
	public function handleTypeChange(evt:Event):void {
		if(type.selectedIndex == 0){ //Normal
			url.setVisible(false);
			url.includeInLayout = false;
			urlFI.setVisible(false);
			urlFI.includeInLayout = false;
			attribute.selected = false;
			dropable.setVisible(true);
			dropable.includeInLayout = true;
			dropableFI.setVisible(true);
			dropableFI.includeInLayout = true;
			tradeable.setVisible(true);
			tradeable.includeInLayout = true;
			tradeableFI.setVisible(true);
			tradeableFI.includeInLayout = true;
			destroyable.setVisible(true);
			destroyable.includeInLayout = true;
			destroyableFI.setVisible(true);
			destroyableFI.includeInLayout = true;
			weightFI.includeInLayout = true;
			weightFI.setVisible(true);
			weight.includeInLayout = true;
			weight.setVisible(true);
			mediaDisplay.hideMediaPicker(false);
			descLabel.label = "Description";
		}
		else if(type.selectedIndex == 1){ //Web Item
			url.setVisible(true);
			url.includeInLayout = true;
			urlFI.setVisible(true);
			urlFI.includeInLayout = true;
			attribute.selected = false;
			dropable.setVisible(true);
			dropable.includeInLayout = true;
			dropableFI.setVisible(true);
			dropableFI.includeInLayout = true;
			tradeable.setVisible(true);
			tradeable.includeInLayout = true;
			tradeableFI.setVisible(true);
			tradeableFI.includeInLayout = true;
			destroyable.setVisible(true);
			destroyable.includeInLayout = true;
			destroyableFI.setVisible(true);
			destroyableFI.includeInLayout = true;
			weightFI.includeInLayout = true;
			weightFI.setVisible(true);
			weight.includeInLayout = true;
			weight.setVisible(true);
			mediaDisplay.hideMediaPicker(true);
			descLabel.label = "Description";
		}
		else if(type.selectedIndex == 2){ //Attribute
			url.setVisible(false);
			url.includeInLayout = false;
			urlFI.setVisible(false);
			urlFI.includeInLayout = false;
			attribute.selected = true;
			dropable.setVisible(false);
			dropable.includeInLayout = false;
			dropableFI.setVisible(false);
			dropableFI.includeInLayout = false;
			tradeable.setVisible(false);
			tradeable.includeInLayout = false;
			tradeableFI.setVisible(false);
			tradeableFI.includeInLayout = false;
			destroyable.setVisible(false);
			destroyable.includeInLayout = false;
			destroyableFI.setVisible(false);
			destroyableFI.includeInLayout = false;
			//.value = 0;
			weightFI.includeInLayout = false;
			weightFI.setVisible(false);
			weight.includeInLayout = false;
			weight.setVisible(false);
			mediaDisplay.hideMediaPicker(true);
			descLabel.label = "Description";
		}
		else if(type.selectedIndex == 3){ //Note
			url.setVisible(false);
			url.includeInLayout = false;
			urlFI.setVisible(false);
			urlFI.includeInLayout = false;
			attribute.selected = false;
			dropable.setVisible(true);
			dropable.includeInLayout = true;
			dropableFI.setVisible(true);
			dropableFI.includeInLayout = true;
			tradeable.setVisible(true);
			tradeable.includeInLayout = true;
			tradeableFI.setVisible(true);
			tradeableFI.includeInLayout = true;
			destroyable.setVisible(true);
			destroyable.includeInLayout = true;
			destroyableFI.setVisible(true);
			destroyableFI.includeInLayout = true;
			//.value = 0;
			weightFI.includeInLayout = true;
			weightFI.setVisible(true);
			weight.includeInLayout = true;
			weight.setVisible(true);
			mediaDisplay.hideMediaPicker(true);
			descLabel.label = "Text";
		}
		
	}
	
    public function getObjectPaletteItem():ObjectPaletteItemBO
    {
        return objectPaletteItem;
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("ObjectEditorItemView: Setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorItemView");
        objectPaletteItem = opi;
		if(opi.isSpawnable) this.spawnablePopupButton.label = "Edit Spawn Settings";
		else this.spawnablePopupButton.label = "Make Spawn";
        mediaDisplay.setObjectPaletteItem(opi);
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
        theName.text = objectPaletteItem.item.name;
        description.text = objectPaletteItem.item.description;
        dropable.selected = objectPaletteItem.item.dropable;
		tradeable.selected = objectPaletteItem.item.tradeable;
		destroyable.selected = objectPaletteItem.item.destroyable;
		attribute.selected = objectPaletteItem.item.isAttribute;
		maxQty.value = objectPaletteItem.item.maxQty;
		weight.value = objectPaletteItem.item.weight;
		url.text = objectPaletteItem.item.url;
		if(objectPaletteItem.item.type == AppConstants.ITEM_TYPE_NORMAL) type.selectedIndex = 0;
		if(objectPaletteItem.item.type == AppConstants.ITEM_TYPE_ATTRIBUTE) type.selectedIndex = 2;
		if(objectPaletteItem.item.type == AppConstants.ITEM_TYPE_URL) type.selectedIndex = 1;
		if(objectPaletteItem.item.type == AppConstants.ITEM_TYPE_NOTE) type.selectedIndex = 3;
		handleTypeChange(null);
    }

    private function isFormValid():Boolean
    {
        return (Validator.validateAll([v1, v2]).length == 0)
    }

    private function handleCancelButton(evt:MouseEvent):void
    {
        trace("ItemEditorItemView: Cancel button clicked...");
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleSaveButton(evt:MouseEvent):void
    {
        trace("ItemEditorItemView: Save button clicked...");

        if (!isFormValid())
        {
            trace("ItemEditorItemView: Form is not valid, stop save processing.");
            return;
        }

        // Save Item Data
        objectPaletteItem.item.name = theName.text;
        objectPaletteItem.item.description = description.text;
        objectPaletteItem.item.dropable = dropable.selected;
		objectPaletteItem.item.tradeable = tradeable.selected;
		objectPaletteItem.item.destroyable = destroyable.selected;
		objectPaletteItem.item.isAttribute = attribute.selected;
		objectPaletteItem.item.maxQty = maxQty.value;
		objectPaletteItem.item.weight = weight.value;
		objectPaletteItem.item.url = url.text;
		if(type.selectedIndex == 0) objectPaletteItem.item.type = AppConstants.ITEM_TYPE_NORMAL;
		if(type.selectedIndex == 1) objectPaletteItem.item.type = AppConstants.ITEM_TYPE_URL;
		if(type.selectedIndex == 2) objectPaletteItem.item.type = AppConstants.ITEM_TYPE_ATTRIBUTE;
		if(type.selectedIndex == 3) objectPaletteItem.item.type = AppConstants.ITEM_TYPE_NOTE;
		AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveItem, handleFault));

        // Save ObjectPaletteItem
        objectPaletteItem.name = objectPaletteItem.item.name;
        AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault))
    
		// Close down the panel
		var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
		AppDynamicEventManager.getInstance().dispatchEvent(de);
	
	}

    private function handleSaveItem(obj:Object):void
    {
        trace("ItemEditorItemView: In handleSaveItem() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorItemView: Bad save item attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Item");
        }
        else
        {
            trace("ItemEditorItemView:  Save item was successful, wait on saveContent now to close the editor and update the object palette.");
        }
        trace("ItemEditorItemView: Finished with handleSaveItem().");
    }

    private function handleSaveContent(obj:Object):void
    {
        trace("ItemEditorItemView: In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorItemView: Bad save item content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Item");
        }
        else
        {
            trace("ItemEditorItemView: Save item content was successful, now update the object palette.");

            var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
            AppDynamicEventManager.getInstance().dispatchEvent(uop);
        }
        trace("ItemEditorItemView: Finished with handleSaveContent().");
    }

	public function handleDupedObject(obj:Object):void
	{
		trace("In handleDupedObject() Result called with obj = " + obj + "; Result = " + obj.result);
		if (obj.result.returnCode != 0)
		{
			trace("Bad dub object attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Getting Content For Editor");
		}
		else
		{
			trace("refresh the sideBar");
			var de:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
			AppDynamicEventManager.getInstance().dispatchEvent(de);	
		}
	}
	
    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Saving Item");
    }
}
}