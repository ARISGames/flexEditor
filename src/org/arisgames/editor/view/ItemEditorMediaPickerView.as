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
	public var delegate:Object;
	
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
        trace("ItemEditorMediaPickerView: handleCloseButton()");
		PopUpManager.removePopUp(this);
    }

	
	private function handleSelectButton(evt:MouseEvent):void
	{
		trace("Select Button clicked...");
		
		var m:Media = new Media();
		m.mediaId = treeBrowser.selectedItem.@mediaId;
		m.name = treeBrowser.selectedItem.@name;
		m.type = treeBrowser.selectedItem.@type;
		m.urlPath = treeBrowser.selectedItem.@urlPath;
		m.fileName = treeBrowser.selectedItem.@fileName;
		m.isDefault = treeBrowser.selectedItem.@isDefault;
		
		if (delegate.hasOwnProperty("didSelectMediaItem")){
			delegate.didSelectMediaItem(this, m);
		}		

		PopUpManager.removePopUp(this);
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
		
		for (var k:Number = 0; k <= 1; k++)
		{
	        for (var j:Number = 0; j < media.length; j++)
	        {
	            var o:Object = media[j];
	            if((k==0 && !o.isDefault) || (k==1 && o.isDefault)){
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
	        }
		}

        trace("ItemEditorMediaPickerView: handleLoadingOfMediaIntoXML: Just finished loading Media Objects into XML.  Here's what the new XML looks like:");
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
		mediaUploader.delegate = this;
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