package org.arisgames.editor.view
{
import flash.events.MouseEvent;

import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.validators.Validator;

import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class ItemEditorFolderView extends Panel
{
    // Data Object
    private var objectPaletteItem:ObjectPaletteItemBO;

    // GUI
    [Bindable] public var folderName:TextInput;
    [Bindable] public var cancelButton:Button;
    [Bindable] public var saveButton:Button;

    [Bindable] public var v1:Validator;

    /**
     * Constructor
     */
    public function ItemEditorFolderView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in ItemEditorFolderView's handleInit");
        cancelButton.addEventListener(MouseEvent.CLICK, handleCancelButton);
        saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
    }

    public function getObjectPaletteItem():ObjectPaletteItemBO
    {
        return objectPaletteItem;
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorFolderView");
        objectPaletteItem = opi;
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
        trace("pushDataIntoGUI called.");
        folderName.text = objectPaletteItem.name;
//        this.validateNow();
    }

    private function isFormValid():Boolean
    {
        trace("isFormValid has been called...");

        return (Validator.validateAll([v1]).length == 0)
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
        trace("Save button clicked...");

        if (!isFormValid())
        {
            trace("Form is not valid, stop save processing.");
            return;
        }
        
        objectPaletteItem.name = folderName.text;
        AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveFolder, handleFault));
    }

    public function handleSaveFolder(obj:Object):void
    {
        trace("In handleSaveFolder() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad save folder attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Folder");
        }
        else
        {
            trace("Save folder was successful, now close the editor and update the object palette.");
            var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
            AppDynamicEventManager.getInstance().dispatchEvent(de);

            var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
            AppDynamicEventManager.getInstance().dispatchEvent(uop);
        }
        trace("Finished with handleSaveFolder().");
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "More problems");
    }
}
}