package org.arisgames.editor.components
{
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.containers.Canvas;
import mx.containers.HBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.LinkButton;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;

import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class ItemEditorMediaDisplayView extends HBox
{
    // Data Object
    private var objectPaletteItem:ObjectPaletteItemBO;

    // GUI
    [Bindable] public var iconImageCanvas:Canvas;
    [Bindable] public var iconPreviewImage:Image;
    [Bindable] public var iconAVLinkButton:LinkButton;
    [Bindable] public var iconRemoveButton:Button;
    [Bindable] public var iconNoMediaLabel:Label;
    [Bindable] public var iconPopupMediaPickerButton:Button;

    [Bindable] public var mediaImageCanvas:Canvas;
    [Bindable] public var mediaPreviewImage:Image;
    [Bindable] public var mediaAVLinkButton:LinkButton;
    [Bindable] public var mediaRemoveButton:Button;
    [Bindable] public var mediaNoMediaLabel:Label;
    [Bindable] public var mediaPopupMediaPickerButton:Button;

    private var mediaPicker:ItemEditorMediaPickerMX;

    /**
     * Constructor
     */
    public function ItemEditorMediaDisplayView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("ItemEditorMediaDisplayView: handleInit");
		iconAVLinkButton.addEventListener(MouseEvent.CLICK, handleIconAVButtonClick);
        mediaAVLinkButton.addEventListener(MouseEvent.CLICK, handleMediaAVButtonClick);
        iconRemoveButton.addEventListener(MouseEvent.CLICK, handleIconRemoveButtonClick);
        mediaRemoveButton.addEventListener(MouseEvent.CLICK, handleMediaRemoveButtonClick);
        iconPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleIconPickerButton);
        mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleMediaPickerButton);
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("ItemEditorMediaDisplayView: setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorPlaqueView");
        objectPaletteItem = opi;
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
        trace("ItemEditorMediaDisplayView: pushDataIntoGUI called with Icon Media Id = '" + objectPaletteItem.iconMediaId + "'; Media Id = '" + objectPaletteItem.mediaId + "'; Icon Media Object = '" + objectPaletteItem.iconMedia + "'; Media Object = '" + objectPaletteItem.media + "'");

        // Load The Icon Media
        if (objectPaletteItem.iconMedia != null && (objectPaletteItem.iconMedia.type == AppConstants.MEDIATYPE_AUDIO || objectPaletteItem.iconMedia.type == AppConstants.MEDIATYPE_VIDEO))
        {
            iconImageCanvas.setVisible(false);
            iconImageCanvas.includeInLayout = false;
            iconPreviewImage.setVisible(true);
            iconPreviewImage.includeInLayout = true;
            iconAVLinkButton.setVisible(true);
            iconAVLinkButton.includeInLayout = true;
            iconNoMediaLabel.setVisible(false);
            iconNoMediaLabel.includeInLayout = false;
            iconRemoveButton.setVisible(true);
            iconRemoveButton.includeInLayout = true;

            if (objectPaletteItem.iconMedia.type == AppConstants.MEDIATYPE_AUDIO)
            {
                iconAVLinkButton.label = "Listen To Audio";
            }
            else
            {
                iconAVLinkButton.label = "View Video";
            }
        }
        else if (objectPaletteItem.iconMedia != null && (objectPaletteItem.iconMedia.type == AppConstants.MEDIATYPE_IMAGE || objectPaletteItem.iconMedia.type == AppConstants.MEDIATYPE_ICON))
        {
            iconImageCanvas.setVisible(true);
            iconImageCanvas.includeInLayout = true;
            iconPreviewImage.setVisible(true);
            iconPreviewImage.includeInLayout = true;
            iconAVLinkButton.setVisible(false);
            iconAVLinkButton.includeInLayout = false;
            iconNoMediaLabel.setVisible(false);
            iconNoMediaLabel.includeInLayout = false;
            iconRemoveButton.setVisible(true);
            iconRemoveButton.includeInLayout = true;

            var iconurl:String = objectPaletteItem.iconMedia.urlPath + objectPaletteItem.iconMedia.fileName;
            iconPreviewImage.source = iconurl;
            trace("ItemEditorMediaDisplayView: Just set icon image url = '" + iconurl + "'");
        }
        else
        {
            iconImageCanvas.setVisible(true);
            iconImageCanvas.includeInLayout = true;
            iconPreviewImage.setVisible(false);
            iconPreviewImage.includeInLayout = false;
            iconAVLinkButton.setVisible(false);
            iconAVLinkButton.includeInLayout = false;
            iconNoMediaLabel.setVisible(true);
            iconNoMediaLabel.includeInLayout = true;
            iconRemoveButton.setVisible(false);
            iconRemoveButton.includeInLayout = false;
        }

        // Load The Media GUI
        if (objectPaletteItem.media != null && (objectPaletteItem.media.type == AppConstants.MEDIATYPE_AUDIO || objectPaletteItem.media.type == AppConstants.MEDIATYPE_VIDEO))
        {
            mediaImageCanvas.setVisible(false);
            mediaImageCanvas.includeInLayout = false;
            mediaPreviewImage.setVisible(false);
            mediaPreviewImage.includeInLayout = false;
            mediaAVLinkButton.setVisible(true);
            mediaAVLinkButton.includeInLayout = true;
            mediaNoMediaLabel.setVisible(false);
            mediaNoMediaLabel.includeInLayout = false;
            mediaRemoveButton.setVisible(true);
            mediaRemoveButton.includeInLayout = true;

            if (objectPaletteItem.media.type == AppConstants.MEDIATYPE_AUDIO)
            {
                mediaAVLinkButton.label = "Listen To Audio";
            }
            else
            {
                mediaAVLinkButton.label = "View Video";
            }
        }
        else if (objectPaletteItem.media != null && (objectPaletteItem.media.type == AppConstants.MEDIATYPE_IMAGE || objectPaletteItem.media.type == AppConstants.MEDIATYPE_ICON))
        {
            mediaImageCanvas.setVisible(true);
            mediaImageCanvas.includeInLayout = true;
            mediaPreviewImage.setVisible(true);
            mediaPreviewImage.includeInLayout = true;
            mediaAVLinkButton.setVisible(false);
            mediaAVLinkButton.includeInLayout = false;
            mediaNoMediaLabel.setVisible(false);
            mediaNoMediaLabel.includeInLayout = false;
            mediaRemoveButton.setVisible(true);
            mediaRemoveButton.includeInLayout = true;

            var mediaurl:String = objectPaletteItem.media.urlPath + objectPaletteItem.media.fileName;
            mediaPreviewImage.source = mediaurl;
            trace("Just set media image url = '" + mediaurl + "'");
        }
        else
        {
            mediaImageCanvas.setVisible(true);
            mediaImageCanvas.includeInLayout = true;
            mediaPreviewImage.setVisible(false);
            mediaPreviewImage.includeInLayout = false;
            mediaAVLinkButton.setVisible(false);
            mediaAVLinkButton.includeInLayout = false;
            mediaNoMediaLabel.setVisible(true);
            mediaNoMediaLabel.includeInLayout = true;
            mediaRemoveButton.setVisible(false);
            mediaRemoveButton.includeInLayout = false;
        }
    }

    private function handleIconPickerButton(evt:MouseEvent):void
    {
        trace("ItemEditorMediaDisplayView: handleIconPickerButton() called...");
        this.openMediaPicker(true);
    }

    private function handleMediaPickerButton(evt:MouseEvent):void
    {
        trace("ItemEditorMediaDisplayView: handleMediaPickerButton() called...");
        this.openMediaPicker(false);
    }

    private function openMediaPicker(isIconMode:Boolean):void
    {
        mediaPicker = new ItemEditorMediaPickerMX();
        mediaPicker.setObjectPaletteItem(objectPaletteItem);
        mediaPicker.setIsIconPicker(isIconMode);
		mediaPicker.delegate = this;

        PopUpManager.addPopUp(mediaPicker, AppUtils.getInstance().getMainView(), true);
        PopUpManager.centerPopUp(mediaPicker);
    }
	
	public function didSelectMediaItem(picker:ItemEditorMediaPickerMX, m:Media):void
	{
		trace("ItemEditorMediaDisplayView: didSelectMediaItem()");
		
		if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
		{
			if (picker.isInIconPickerMode())
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
			//AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, objectPaletteItem.character, new Responder(handleSaveObject, handleFault));
		}
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
		{
			if (picker.isInIconPickerMode())
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
			//AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveObject, handleFault));
		}
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
		{
			if (picker.isInIconPickerMode())
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
			//AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, objectPaletteItem.page, new Responder(handleSaveObject, handleFault));
		}
		
		this.pushDataIntoGUI();
		
	}
	
	private function handleSaveObject(obj:Object):void
	{
		trace("ItemEditorMediaDisplayView: handleSaveObject()");
		if (obj.result.returnCode != 0)
		{
			trace("Bad save of selected media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Selecting Media");
		}
	}
	
    private function handleIconAVButtonClick(evt:MouseEvent):void
    {
        trace("IconAVButtonClick clicked!");
        var url:String = objectPaletteItem.iconMedia.urlPath + objectPaletteItem.iconMedia.fileName;
        trace("URL to launch = '" + url + "'");
        var req:URLRequest = new URLRequest(url);
        navigateToURL(req,"to_blank");
    }

    private function handleMediaAVButtonClick(evt:MouseEvent):void
    {
        trace("MediaAVButtonClick clicked!");
        var url:String = objectPaletteItem.media.urlPath + objectPaletteItem.media.fileName;
        trace("URL to launch = '" + url + "'");
        var req:URLRequest = new URLRequest(url);
        navigateToURL(req,"to_blank");
    }

    private function handleIconRemoveButtonClick(evt:MouseEvent):void
    {
        trace("handleIconRemoveButtonClick() called.");
        this.objectPaletteItem.iconMediaId = 0;
        this.objectPaletteItem.iconMedia = null;

        if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
        {
            objectPaletteItem.character.iconMediaId = 0;
            AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, objectPaletteItem.character, new Responder(handleSaveObjectAfterRemove, handleFault));
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            objectPaletteItem.item.iconMediaId = 0;
            AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveObjectAfterRemove, handleFault));
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
        {
            objectPaletteItem.page.iconMediaId = 0;            
            AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, objectPaletteItem.page, new Responder(handleSaveObjectAfterRemove, handleFault));
        }
        // Reload Icon In Object Palette
        var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
        AppDynamicEventManager.getInstance().dispatchEvent(uop);
    }

    private function handleMediaRemoveButtonClick(evt:MouseEvent):void
    {
        trace("handleMediaRemoveButtonClick() called.");
        this.objectPaletteItem.mediaId = 0;
        this.objectPaletteItem.media = null;

        if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
        {
            objectPaletteItem.character.mediaId = 0;
            AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, objectPaletteItem.character, new Responder(handleSaveObjectAfterRemove, handleFault));
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            objectPaletteItem.item.mediaId = 0;
            AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveObjectAfterRemove, handleFault));
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
        {
            objectPaletteItem.page.mediaId = 0;            
            AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, objectPaletteItem.page, new Responder(handleSaveObjectAfterRemove, handleFault));
        }
    }

    private function handleSaveObjectAfterRemove(obj:Object):void
    {
        trace("handleSaveObjectAfterRemove called...");
        if (obj.result.returnCode != 0)
        {
            trace("Bad removal of icon / media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Removing Media Item");
        }
        else
        {
            trace("Successfully removed Icon / Media from the data model and database.  Now update the GUI.");
            this.pushDataIntoGUI();
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Removing Media Item");
    }
}
}