package org.arisgames.editor.view
{
import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;
import mx.validators.Validator;

import org.arisgames.editor.MainView;
import org.arisgames.editor.components.ItemEditorMediaDisplayMX;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.view.PlayerStateChangesEditorMX;

public class ItemEditorPlaqueView extends Panel
{
    // Data Object
    private var objectPaletteItem:ObjectPaletteItemBO;

    // GUI
    [Bindable] public var theName:TextInput;
    [Bindable] public var description:TextArea;
    [Bindable] public var cancelButton:Button;
    [Bindable] public var saveButton:Button;
	[Bindable] public var changePlayerStateButton:Button;
    [Bindable] public var hbox:HBox;
    [Bindable] public var mediaDisplay:ItemEditorMediaDisplayMX;

    [Bindable] public var v1:Validator;
    [Bindable] public var v2:Validator;
    
		
    /**
     * Constructor
     */
    public function ItemEditorPlaqueView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)

    }

    private function handleInit(event:FlexEvent):void
    {
        trace("ItemEditorItemView: handleInit");
        //cancelButton.addEventListener(MouseEvent.CLICK, handleCancelButton);
        saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		changePlayerStateButton.addEventListener(MouseEvent.CLICK, handlePlayerInventoryChangeButtonClick);
		

		// WB Bugfix for MediaPickers losing saved information
		mediaDisplay.iconPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		mediaDisplay.mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("ItemEditorItemView: setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorPlaqueView");
        objectPaletteItem = opi;
        mediaDisplay.setObjectPaletteItem(opi);
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
        theName.text = objectPaletteItem.page.title;
        description.text = objectPaletteItem.page.text;
    }

    private function isFormValid():Boolean
    {
        return (Validator.validateAll([v1, v2]).length == 0)
    }


    private function handleCancelButton(evt:MouseEvent):void
    {
        trace("Cancel button clicked...");
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
        objectPaletteItem.page.title = theName.text;
        objectPaletteItem.page.text = description.text;
        AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, objectPaletteItem.page, new Responder(handleSavePage, handleFault));

        // Save ObjectPaletteItem
        objectPaletteItem.name = objectPaletteItem.page.title;
        AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault))
    
		// Close down the panel
		var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
		AppDynamicEventManager.getInstance().dispatchEvent(de);
	}

    private function handleSavePage(obj:Object):void
    {
        trace("ItemEditorItemView: In handleSavePage() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorItemView: Bad save page attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Page");
        }
        else
        {
            trace("ItemEditorItemView: Save page was successful, wait on saveContent now to close the editor and update the object palette.");
        }
        trace("ItemEditorItemView: Finished with handleSaveCharacter().");
    }

    private function handleSaveContent(obj:Object):void
    {
        trace("ItemEditorItemView: In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorItemView: Bad save page content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Page");
        }
        else
        {
            trace("ItemEditorItemView: Save page content was successful, now update the object palette.");

            var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
            AppDynamicEventManager.getInstance().dispatchEvent(uop);
        }
        trace("ItemEditorItemView: Finished with handleSaveContent().");
    }

	private function handlePlayerInventoryChangeButtonClick(evt:MouseEvent):void
	{
		trace("ItemEditorItemView: Starting handle Open Requirements Button click.");
		this.openPlayerStateChangesEditor();
	}
	
	private function openPlayerStateChangesEditor():void
	{
		var pscEditor:PlayerStateChangesEditorMX = new PlayerStateChangesEditorMX();
		pscEditor.setEventTypeAndId(AppConstants.PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE, objectPaletteItem.objectId);

		this.parent.addChild(pscEditor);
		// Need to validate the display so that entire component is rendered
		pscEditor.validateNow();
		
		PopUpManager.addPopUp(pscEditor, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(pscEditor);
		pscEditor.setVisible(true);
		pscEditor.includeInLayout = true;
	}

	
    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Saving Page");
    }
}
}