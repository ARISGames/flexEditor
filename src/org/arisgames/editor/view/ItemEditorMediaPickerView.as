package org.arisgames.editor.view
{
import com.ninem.controls.TreeBrowser;
import com.ninem.events.TreeBrowserEvent;

import flash.events.MouseEvent;

import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.DataGrid;
import mx.core.ClassFactory;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;

import org.arisgames.editor.components.ItemEditorMediaPickerCustomEditorMX;
import org.arisgames.editor.components.ItemEditorMediaPickerUploadFormMX;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class ItemEditorMediaPickerView extends Panel
{
    // Data Object
    private var objectPaletteItem:ObjectPaletteItemBO;
    private var isIconPicker:Boolean = false;

    // Media Data
    [Bindable] public var xmlData:XML;

    // GUI
    [Bindable] public var treeBrowser:TreeBrowser;
    [Bindable] public var closeButton:Button;
	[Bindable] public var selectButton:Button;

	private var mediaUploader:ItemEditorMediaPickerUploadFormMX;

    /**
     * Constructor
     */
    public function ItemEditorMediaPickerView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in ItemEditorMediaPickerView's handleInit");
        var cf:ClassFactory = new ClassFactory(ItemEditorMediaPickerCustomEditorMX);
        cf.properties = {objectPaletteItem: this.objectPaletteItem};
        treeBrowser.detailRenderer = cf;
        treeBrowser.addEventListener(TreeBrowserEvent.NODE_SELECTED, onNodeSelected);
        closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
		selectButton.addEventListener(MouseEvent.CLICK, handleSelectButton);
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEMEDIAUPLOADER, closeMediaUploader);
        // Load Game's Media Into XML
        AppServices.getInstance().getMediaForGame(GameModel.getInstance().game.gameId, new Responder(handleLoadingOfMediaIntoXML, handleFault));
    }

    private function printXMLData():void
    {
        trace("XML Data = '" + xmlData.toXMLString() + "'");
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorPlaqueView");
        objectPaletteItem = opi;
    }

    public function isInIconPickerMode():Boolean
    {
        return isIconPicker;
    }

    public function setIsIconPicker(isIconPickerMode:Boolean):void
    {
        trace("setting isIconPicker mode to: " + isIconPickerMode);
        this.isIconPicker = isIconPickerMode;
        this.updateTitleBasedOnMode();
    }

    private function updateTitleBasedOnMode():void
    {
        if (isIconPicker)
        {
            title = "Icon Picker";
        }
        else
        {
            title = "Media Picker";
        }
    }

    private function handleCloseButton(evt:MouseEvent):void
    {
        trace("Close button clicked...");
        // This will close editor (as the item is the same that is currently being edited)
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

	
	private function handleSelectButton(evt:MouseEvent):void
	{
		trace("Select Button clicked...");
		var iconMode:Boolean = this.isInIconPickerMode();
		
		var m:Media = new Media();
		m.mediaId = treeBrowser.selectedItem.@mediaId;
		m.name = treeBrowser.selectedItem.@name;
		m.type = treeBrowser.selectedItem.@type;
		m.urlPath = treeBrowser.selectedItem.@urlPath;
		m.fileName = treeBrowser.selectedItem.@fileName;
		m.isDefault = treeBrowser.selectedItem.@isDefault;
		
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
	
	
	
	
	
	
	
	
	
	
    private function handleLoadingOfMediaIntoXML(obj:Object):void
    {
        trace("In handleLoadingOfMediaIntoXML() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad loading of media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Media");
			return;
        }

        //Init the XML Data

		xmlData = new XML('<nodes label="' + AppConstants.MEDIATYPE + '"/>');
		
		if (this.isIconPicker) {
			xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_UPLOADNEW + '"/>');			
		}
		else {
			xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_IMAGE + '"/>');
			xmlData.node.(@label == AppConstants.MEDIATYPE_IMAGE).appendChild('<node label="' + AppConstants.MEDIATYPE_UPLOADNEW + '"/>');
			xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_AUDIO + '"/>');
			xmlData.node.(@label == AppConstants.MEDIATYPE_AUDIO).appendChild('<node label="' + AppConstants.MEDIATYPE_UPLOADNEW + '"/>');
			xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_VIDEO + '"/>');
			xmlData.node.(@label == AppConstants.MEDIATYPE_VIDEO).appendChild('<node label="' + AppConstants.MEDIATYPE_UPLOADNEW + '"/>');
		}
		this.printXMLData();
		
		var media:Array = obj.result.data as Array;
        trace("Number of Media Objects returned from server = '" + media.length + "'");

        for (var j:Number = 0; j < media.length; j++)
        {
            var o:Object = media[j];
            var m:Media = new Media();

            m.mediaId = o.media_id;
            m.name = o.name;
            m.type = o.type;
            m.urlPath = o.url_path;
            m.fileName = o.file_name;
            m.isDefault = o.is_default; //for both default files and uploaded files

            var node:String = "<node label='" + AppUtils.filterStringToXMLEscapeCharacters(m.name) + "' mediaId='" + m.mediaId + "' type='" + m.type + "' urlPath='" + m.urlPath + "' fileName='" + m.fileName + "' isDefault='" + m.isDefault + "'/>";

            switch (m.type)
            {
                case AppConstants.MEDIATYPE_IMAGE:
					if (!this.isIconPicker) xmlData.node.(@label == AppConstants.MEDIATYPE_IMAGE).appendChild(node);
                    break;
                case AppConstants.MEDIATYPE_AUDIO:
					if (!this.isIconPicker) xmlData.node.(@label == AppConstants.MEDIATYPE_AUDIO).appendChild(node);
                    break;
                case AppConstants.MEDIATYPE_VIDEO:
					if (!this.isIconPicker) xmlData.node.(@label == AppConstants.MEDIATYPE_VIDEO).appendChild(node);
                    break;
                case AppConstants.MEDIATYPE_ICON:
					if (this.isIconPicker) xmlData.appendChild(node);
                    break;
                default:
                    trace("Default statement reached in load media.  This SHOULD NOT HAPPEN.  The offending mediaId = '" + m.mediaId + "' and type = '" + m.type + "'");
                    break;
            }

        }
        trace("Just finished loading Media Objects into XML.  Here's what the new XML looks like:");
        this.printXMLData();
   
        trace("Finished with handleLoadingOfMediaIntoXML().");
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Loading Media");
    }

    private function onNodeSelected(event:TreeBrowserEvent):void
    {
        trace("onNodeSelected with event item = '" + event.item.toString() + "'");
        trace("is it a branch? '" + event.isBranch + "'")
        if (!event.isBranch)
        {
            if (event.item.@label == AppConstants.MEDIATYPE_UPLOADNEW)
            {
                trace("It's an Upload Item");
				selectButton.enabled = false;
                var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
                AppDynamicEventManager.getInstance().dispatchEvent(de);
                this.displayMediaUploader();
            }
            else
            {
                trace("It's NOT an Upload Item");
				selectButton.enabled = true;
            }
        }
		else {
			selectButton.enabled = false;	
		}
    }

	
	
    private function displayMediaUploader():void
    {
        trace("handleMediaPicketButton() called...");
        mediaUploader = new ItemEditorMediaPickerUploadFormMX();
        PopUpManager.addPopUp(mediaUploader, AppUtils.getInstance().getMainView(), true);
        PopUpManager.centerPopUp(mediaUploader);
    }

    private function closeMediaUploader(evt:DynamicEvent):void
    {
        trace("ItemEditorMediaPicker: closeMediaUploader called...");
        PopUpManager.removePopUp(mediaUploader);
        mediaUploader = null;
    }
    
}
}