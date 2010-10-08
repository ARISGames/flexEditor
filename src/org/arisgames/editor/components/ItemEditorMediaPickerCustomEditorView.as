package org.arisgames.editor.components
{
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import mx.containers.Canvas;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.LinkButton;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.view.ItemEditorMediaPickerMX;

public class ItemEditorMediaPickerCustomEditorView extends VBox
{
    // Data Object
    public var objectPaletteItem:ObjectPaletteItemBO;

    private var dataChanged:Boolean;

    // GUI
    [Bindable] public var imageCanvas:Canvas;
    [Bindable] public var previewImage:Image;
    [Bindable] public var avLinkButton:LinkButton;
    [Bindable] public var mediaName:TextInput;

    [Bindable] public var saveButton:Button;
    [Bindable] public var selectButton:Button;
    [Bindable] public var deleteButton:Button;

    /**
     * Constructor
     */
    public function ItemEditorMediaPickerCustomEditorView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("In ItemEditorMediaPickerCustomEditorView's handleInit");
        avLinkButton.addEventListener(MouseEvent.CLICK, handleAVButtonClick);
        saveButton.addEventListener(MouseEvent.CLICK, handleSaveButtonClick);
        selectButton.addEventListener(MouseEvent.CLICK, handleSelectButtonClick);
        deleteButton.addEventListener(MouseEvent.CLICK, handleDeleteButtonClick);
    }

    override public function set data(value:Object):void
    {
        super.data = value;
        dataChanged = true;
        invalidateProperties();
    }

    private function renderData():void
    {
        if (data.@type && (data.@type.toString() == AppConstants.MEDIATYPE_IMAGE || data.@type.toString() == AppConstants.MEDIATYPE_ICON))
        {
            trace("It's either an Image or an Icon, so let's try to display it in the preview editor.");

            if (data.@urlPath && data.@urlPath.toString() != "" && data.@fileName && data.@fileName.toString() != "")
            {
                var url:String = data.@urlPath.toString() + data.@fileName.toString();
                previewImage.source = url;
                trace("Just set image url = '" + url + "'");
                imageCanvas.visible = true;
                imageCanvas.includeInLayout = true;
                previewImage.visible = true;
                previewImage.includeInLayout = true;
                avLinkButton.visible = false;
                avLinkButton.includeInLayout = false;
            }
        }
        else
        {
            trace("It's not an image or icon, so hide image viewer.");
            imageCanvas.visible = false;
            imageCanvas.includeInLayout = false;
            previewImage.visible = false;
            previewImage.includeInLayout = false;
            if (data.@type && data.@type.toString() == AppConstants.MEDIATYPE_AUDIO)
            {
                avLinkButton.label = "Listen To Audio";
            }
            else
            {
                avLinkButton.label = "View Video";
            }
            avLinkButton.visible = true;
            avLinkButton.includeInLayout = true;
        }

        mediaName.text = data.@label;

        if (data.@isDefault && data.@isDefault == false)
        {
            trace("Data is not default so show Save & Delete Button.");
            mediaName.editable = true;
            saveButton.visible = true;
            saveButton.includeInLayout = true;
            deleteButton.visible = true;
            deleteButton.includeInLayout = true;
        }
    }

    override protected function commitProperties():void
    {
        super.commitProperties();
        if (dataChanged)
        {
            renderData();
            dataChanged = false;
        }
    }

    private function handleAVButtonClick(evt:MouseEvent):void
    {
        trace("AVButtonClick clicked!");
        var url:String = data.@urlPath.toString() + data.@fileName.toString();
        trace("URL to launch = '" + url + "'");
        var req:URLRequest = new URLRequest(url);
        navigateToURL(req,"to_blank");
    }

    private function handleSaveButtonClick(evt:MouseEvent):void
    {
        trace("Save Button clicked...");
        data.@label = mediaName.text;
        AppServices.getInstance().renameMediaForGame(GameModel.getInstance().game.gameId, data.@mediaId, mediaName.text, new Responder(handleSaveMedia, handleFault));
    }

    private function handleSelectButtonClick(evt:MouseEvent):void
    {
        trace("Select Button clicked...");
        var iconMode:Boolean = (this.parent.parent as ItemEditorMediaPickerMX).isInIconPickerMode();
        trace("Is In Icon Picker Mode (According to parent.parent): " + iconMode);

        trace("data object = '" + data + "'");
        var m:Media = new Media();
        m.mediaId = data.@mediaId;
        m.name = data.@name;
        m.type = data.@type;
        m.urlPath = data.@urlPath;
        m.fileName = data.@fileName;
        m.isDefault = data.@isDefault;

        trace("processed data object: media id = '" + m.mediaId + "'; name = '" + m.name + "'; type = '" + m.type + "'; urlPath = '" + m.urlPath + "'; fileName = '" + m.fileName + "'; isDefault = '" + m.isDefault + "'");

        if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
        {
            if (iconMode)
            {
                objectPaletteItem.character.iconMediaId = m.mediaId;
                objectPaletteItem.iconMediaId = m.mediaId;
                objectPaletteItem.iconMedia = m;
                trace("Just set Character with ID = '" + objectPaletteItem.character.npcId + "' Icon Media Id = '" + objectPaletteItem.character.iconMediaId + "'");
            }
            else
            {
                objectPaletteItem.character.mediaId = m.mediaId;
                objectPaletteItem.mediaId = m.mediaId;
                objectPaletteItem.media = m;
                trace("Just set Character with ID = '" + objectPaletteItem.character.npcId + "' Media Id = '" + objectPaletteItem.character.mediaId + "'");
            }
            AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, objectPaletteItem.character, new Responder(handleSaveObjectFromSelectClick, handleFault));
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            if (iconMode)
            {
                objectPaletteItem.item.iconMediaId = m.mediaId;
                objectPaletteItem.iconMediaId = m.mediaId;
                objectPaletteItem.iconMedia = m;
                trace("Just set Item with ID = '" + objectPaletteItem.item.itemId + "' Icon Media Id = '" + objectPaletteItem.item.iconMediaId + "'");
            }
            else
            {
                objectPaletteItem.item.mediaId = m.mediaId;
                objectPaletteItem.mediaId = m.mediaId;
                objectPaletteItem.media = m;
                trace("Just set Item with ID = '" + objectPaletteItem.item.itemId + "' Media Id = '" + objectPaletteItem.item.mediaId + "'");
            }
            AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveObjectFromSelectClick, handleFault));
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
        {
            if (iconMode)
            {
                objectPaletteItem.page.iconMediaId = m.mediaId;
                objectPaletteItem.iconMediaId = m.mediaId;
                objectPaletteItem.iconMedia = m;
                trace("Just set Page with ID = '" + objectPaletteItem.page.nodeId + "' Icon Media Id = '" + objectPaletteItem.page.iconMediaId + "'");
            }
            else
            {
                objectPaletteItem.page.mediaId = m.mediaId;
                objectPaletteItem.mediaId = m.mediaId;
                objectPaletteItem.media = m;
                trace("Just set Page with ID = '" + objectPaletteItem.page.nodeId + "' Media Id = '" + objectPaletteItem.page.mediaId + "'");
            }
            AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, objectPaletteItem.page, new Responder(handleSaveObjectFromSelectClick, handleFault));
        }

        // Close Media Picker
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleSaveObjectFromSelectClick(obj:Object):void
    {
        trace("handleSaveObjectFromSelectClick() called...");
        if (obj.result.returnCode != 0)
        {
            trace("Bad save of selected media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Selecting Media");
        }
        else
        {
            trace("The Save From The Select Clicked worked fine, refresh the editor.  The updated IDs are: Object ID = '" + objectPaletteItem.id + "'; Icon Media ID = '" + objectPaletteItem.iconMediaId + "'; Media ID = '" + objectPaletteItem.mediaId + "'");
            // Close and reopen item editor (only safe to do here because icon and media data has been saved in object)
            var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
            AppDynamicEventManager.getInstance().dispatchEvent(de);

            de = new DynamicEvent(AppConstants.DYNAMICEVENT_EDITOBJECTPALETTEITEM);
            de.objectPaletteItem = objectPaletteItem;
            AppDynamicEventManager.getInstance().dispatchEvent(de);
        }
    }

    private function handleDeleteButtonClick(evt:MouseEvent):void
    {
        trace("Delete Button clicked...");
        AppServices.getInstance().deleteMediaForGame(GameModel.getInstance().game.gameId, data.@mediaId, new Responder(handleDeleteMedia, handleFault));
    }

    public function handleSaveMedia(obj:Object):void
    {
        trace("handleSaveMedia called... value of label = '" + data.@label + "'");
        if (obj.result.returnCode != 0)
        {
            trace("Bad save of media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Renaming Media");
        }
    }

    public function handleDeleteMedia(obj:Object):void
    {
        trace("handleDeleteMedia called... value of label = '" + data.@label + "'");
        if (obj.result.returnCode != 0)
        {
            trace("Bad delete of media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Deleting Media");
            var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
            AppDynamicEventManager.getInstance().dispatchEvent(de);
            return;
        }

        Alert.show("Just deleted Media named '" + data.@label + "'.", "Successfully Deleted Media");
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems With Media Item");
    }
}
}