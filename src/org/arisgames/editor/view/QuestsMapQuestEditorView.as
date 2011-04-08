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
import mx.rpc.Responder;
import mx.validators.Validator;
import org.arisgames.editor.components.ItemEditorMediaDisplayMX;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

/**
 * Editor Pop-out for updating and saving quest details in the QuestsMap
 * @author Will Buck
 */
public class QuestsMapQuestEditorView extends Panel
{
    // Data Object - this will be a quest data object
    private var objectPaletteItem:ObjectPaletteItemBO;

    // GUI
    [Bindable] public var theName:TextInput;
    [Bindable] public var activeDesc:TextArea;
    [Bindable] public var completedDesc:TextArea;
	[Bindable] public var displayReqs:Button;
	[Bindable] public var completedReqs:Button;
    [Bindable] public var cancelButton:Button;
    [Bindable] public var saveButton:Button;
    [Bindable] public var hbox:HBox;
    [Bindable] public var mediaDisplay:ItemEditorMediaDisplayMX;

    [Bindable] public var v1:Validator;
    [Bindable] public var v2:Validator;
    [Bindable] public var v3:Validator;

    /**
     * Constructor
     */
    public function QuestsMapQuestEditorView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in QuestsMapQuestEditorView's handleInit");
        cancelButton.addEventListener(MouseEvent.CLICK, handleCancelButton);
        saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		// WB Bugfix for MediaPickers losing saved information
		mediaDisplay.iconPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		mediaDisplay.mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("setting objectPaletteItem with name = '" + opi.name + "' in QuestsMapQuestEditorView");
        objectPaletteItem = opi;
        mediaDisplay.setObjectPaletteItem(opi);
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
		// Set data in GUI to values from QuestBO
    }

    private function isFormValid():Boolean
    {
        trace("ItemEditorItemView: isFormValid has been called...");        
        return (Validator.validateAll([v1, v2, v3]).length == 0)
    }

    private function handleCancelButton(evt:MouseEvent):void
    {
        trace("Cancel button clicked...");
        // This will close editor (as the item is the same that is currently being edited)
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
        
        /*// Save Item Data
        objectPaletteItem.character.name = theName.text;
        objectPaletteItem.character.description = description.text;
        objectPaletteItem.character.greeting = greeting.text;
        AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, objectPaletteItem.character, new Responder(handleSaveCharacter, handleFault));

        // Save ObjectPaletteItem
        objectPaletteItem.name = objectPaletteItem.character.name;
        AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault))*/
    }

    /*private function handleSaveCharacter(obj:Object):void
    {
        trace("In handleSaveCharacter() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad save character attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Character");
        }
        else
        {
            trace("Save character was successful, wait on saveContent now to close the editor and update the object palette.");
        }
        trace("Finished with handleSaveCharacter().");
    }*/

    /*private function handleSaveContent(obj:Object):void
    {
        trace("In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad save character content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Character");
        }
        else
        {
            trace("Save character content was successful, now close the editor and update the object palette.");
            var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
            AppDynamicEventManager.getInstance().dispatchEvent(de);

            var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
            AppDynamicEventManager.getInstance().dispatchEvent(uop);
        }
        trace("Finished with handleSaveContent().");
    }*/

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Saving Character");
    }
}
}