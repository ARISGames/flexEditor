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
	
	/*
	[Bindable] public var alignImageCanvas:Canvas;
	[Bindable] public var alignPreviewImage:Image;
	[Bindable] public var alignAVLinkButton:LinkButton;
	[Bindable] public var alignRemoveButton:Button;
	[Bindable] public var alignNoMediaLabel:Label;
	[Bindable] public var alignPopupMediaPickerButton:Button;
	*/
	public var mediaPickerHidden:Boolean;
    private var mediaPicker:ItemEditorMediaPickerMX;

    /**
     * Constructor
     */
    public function ItemEditorMediaDisplayView()
    {
        super();
		mediaPickerHidden = false;
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("ItemEditorMediaDisplayView: handleInit");
		iconAVLinkButton.addEventListener(MouseEvent.CLICK, handleIconAVButtonClick);
        mediaAVLinkButton.addEventListener(MouseEvent.CLICK, handleMediaAVButtonClick);
		//alignAVLinkButton.addEventListener(MouseEvent.CLICK, handleAlignAVButtonClick);

        iconRemoveButton.addEventListener(MouseEvent.CLICK, handleIconRemoveButtonClick);
        mediaRemoveButton.addEventListener(MouseEvent.CLICK, handleMediaRemoveButtonClick);
		//alignRemoveButton.addEventListener(MouseEvent.CLICK, handleAlignRemoveButtonClick);

        iconPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleIconPickerButton);
        mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleMediaPickerButton);
		//alignPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleAlignPickerButton);

    }

	public function hideMediaPicker(hide:Boolean):void
	{
		if(hide){
			mediaPickerHidden = true;
			mediaImageCanvas.setVisible(false);
			mediaPreviewImage.setVisible(false);
			mediaAVLinkButton.setVisible(false);
			mediaRemoveButton.setVisible(false);
			mediaNoMediaLabel.setVisible(false);
			mediaPopupMediaPickerButton.setVisible(false);
		}
		else {
			mediaPickerHidden = false;
			pushDataIntoGUI();
		}
	}
	
    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("ItemEditorMediaDisplayView: setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorPlaqueView");
        Alert.show("Icon:"+opi.iconMediaId+" Media:"+opi.mediaId);
		objectPaletteItem = opi;
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
        //trace("ItemEditorMediaDisplayView: pushDataIntoGUI called with Icon Media Id = '" + objectPaletteItem.iconMediaId + "'; Media Id = '" + objectPaletteItem.mediaId + "'; Align Media Id = '" + objectPaletteItem.alignMediaId + "'; Icon Media Object = '" + objectPaletteItem.iconMedia + "'; Media Object = '" + objectPaletteItem.media + "'");
		if(objectPaletteItem == null) return;
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
			/*
			//BLANK SQUARE
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
			*/
			
			iconImageCanvas.setVisible(true);
			iconImageCanvas.includeInLayout = true;
			iconPreviewImage.setVisible(true);
			iconPreviewImage.includeInLayout = true;
			iconAVLinkButton.setVisible(false);
			iconAVLinkButton.includeInLayout = false;
			iconNoMediaLabel.setVisible(true);
			iconNoMediaLabel.includeInLayout = true;
			iconRemoveButton.setVisible(false);
			iconRemoveButton.includeInLayout = false;
			
			iconurl = AppConstants.IMG_DEFAULT_ICON_SIZE_REFERENCE_URL;
			iconPreviewImage.source = iconurl;
			trace("ItemEditorMediaDisplayView: Just set icon image url = '" + iconurl + "'");
        }

		if(mediaPickerHidden){
			mediaImageCanvas.setVisible(true);
			mediaPreviewImage.setVisible(true);
			mediaAVLinkButton.setVisible(true);
			mediaRemoveButton.setVisible(true);
			mediaNoMediaLabel.setVisible(true);
			mediaPopupMediaPickerButton.setVisible(true);
			return;
		}
        // Load The Media GUI
		if(objectPaletteItem.objectType != AppConstants.CONTENTTYPE_WEBPAGE_DATABASE && objectPaletteItem.objectType != AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE){
			mediaPopupMediaPickerButton.setVisible(true);
			mediaPopupMediaPickerButton.includeInLayout = true;
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
				/*
				//BLANK SQUARE
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
				*/
				
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(true);
				mediaPreviewImage.includeInLayout = true;
				mediaAVLinkButton.setVisible(false);
				mediaAVLinkButton.includeInLayout = false;
				mediaNoMediaLabel.setVisible(true);
				mediaNoMediaLabel.includeInLayout = true;
				mediaRemoveButton.setVisible(false);
				mediaRemoveButton.includeInLayout = false;
				
				if(objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE) mediaurl = AppConstants.IMG_DEFAULT_PLAQUE_SIZE_REFERENCE_URL;
				else if(objectPaletteItem.objectType != AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE) mediaurl = AppConstants.IMG_DEFAULT_IMAGE_SIZE_REFERENCE_URL;
				else mediaurl = AppConstants.IMG_DEFAULT_PANO_SIZE_REFERENCE_URL;
				mediaPreviewImage.source = mediaurl;
				trace("Just set media image url = '" + mediaurl + "'");
        	}
		}
		else{
			mediaPopupMediaPickerButton.setVisible(false);
			mediaPopupMediaPickerButton.includeInLayout = false;
		}
		
		
		// Load The alignMedia GUI
		/*
		if(objectPaletteItem.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE){
			
			if (objectPaletteItem.alignMedia != null && objectPaletteItem.alignMedia.type == AppConstants.MEDIATYPE_IMAGE)
			{
				
				alignImageCanvas.setVisible(true);
				alignImageCanvas.includeInLayout = true;
				alignPreviewImage.setVisible(true);
				alignPreviewImage.includeInLayout = true;
				alignAVLinkButton.setVisible(false);
				alignAVLinkButton.includeInLayout = false;
				alignNoMediaLabel.setVisible(false);
				alignNoMediaLabel.includeInLayout = false;
				alignRemoveButton.setVisible(true);
				alignRemoveButton.includeInLayout = true;
				
				var alignmediaurl:String = objectPaletteItem.alignMedia.urlPath + objectPaletteItem.alignMedia.fileName;
				alignPreviewImage.source = alignmediaurl;
				trace("Just set align image url = '" + alignmediaurl + "'");
				
			}
			else
			{
				*/
				/*
				//BLANK SQUARE
				alignImageCanvas.setVisible(true);
				alignImageCanvas.includeInLayout = true;
				alignPreviewImage.setVisible(false);
				alignPreviewImage.includeInLayout = false;
				alignAVLinkButton.setVisible(false);
				alignAVLinkButton.includeInLayout = false;
				alignNoMediaLabel.setVisible(true);
				alignNoMediaLabel.includeInLayout = true;
				alignRemoveButton.setVisible(false);
				alignRemoveButton.includeInLayout = false;
				*/
				
				/*
				alignImageCanvas.setVisible(true);
				alignImageCanvas.includeInLayout = true;
				alignPreviewImage.setVisible(true);
				alignPreviewImage.includeInLayout = true;
				alignAVLinkButton.setVisible(false);
				alignAVLinkButton.includeInLayout = false;
				alignNoMediaLabel.setVisible(true);
				alignNoMediaLabel.includeInLayout = true;
				alignRemoveButton.setVisible(false);
				alignRemoveButton.includeInLayout = false;
				
				alignmediaurl = AppConstants.IMG_DEFAULT_ALIGN_SIZE_REFERENCE_URL;
				alignPreviewImage.source = alignmediaurl;
				trace("Just set align image url = '" + alignmediaurl + "'");
				*/
			/*
			}
		}
		else{
			alignPopupMediaPickerButton.setVisible(false);
			alignPopupMediaPickerButton.includeInLayout = false;
		}
			*/
    }

    private function handleIconPickerButton(evt:MouseEvent):void
    {
        trace("ItemEditorMediaDisplayView: handleIconPickerButton() called...");
        this.openMediaPicker(AppConstants.ICON_PICKER);
    }

    private function handleMediaPickerButton(evt:MouseEvent):void
    {
        trace("ItemEditorMediaDisplayView: handleMediaPickerButton() called...");
        this.openMediaPicker(AppConstants.MEDIA_PICKER);
    }
	
	private function handleAlignPickerButton(evt:MouseEvent):void
	{
		//trace("ItemEditorMediaDisplayView: handleAlignPickerButton() called...");
		//this.openMediaPicker(AppConstants.ALIGNMENT_PICKER);
	}

    private function openMediaPicker(pickerMode:Number):void
    {
        mediaPicker = new ItemEditorMediaPickerMX();
        mediaPicker.setObjectPaletteItem(objectPaletteItem);
		if(pickerMode == AppConstants.ICON_PICKER)
        	mediaPicker.setIsIconPicker(true);
		//else if(pickerMode == AppConstants.ALIGNMENT_PICKER)
		//	mediaPicker.setIsAlignmentPicker(true);
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
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_WEBPAGE_DATABASE)
		{
			if (picker.isInIconPickerMode())
			{
				objectPaletteItem.webPage.iconMediaId = m.mediaId;
				objectPaletteItem.iconMediaId = m.mediaId;
				objectPaletteItem.iconMedia = m;
				trace("Just set WebPage with ID = '" + objectPaletteItem.webPage.webPageId + "' Icon Media Id = '" + objectPaletteItem.webPage.iconMediaId + "'");
			}
			//AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveObject, handleFault));
		}
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE)
		{
			if (picker.isInIconPickerMode())
			{
				objectPaletteItem.augBubble.iconMediaId = m.mediaId;
				objectPaletteItem.iconMediaId = m.mediaId;
				objectPaletteItem.iconMedia = m;
				trace("Just set AugBubble with ID = '" + objectPaletteItem.augBubble.augBubbleId + "' Icon Media Id = '" + objectPaletteItem.augBubble.iconMediaId + "'");
			}
			/*else if (picker.isInAlignmentPickerMode())
			{
				objectPaletteItem.augBubble.alignMediaId = m.mediaId;
				objectPaletteItem.alignMediaId = m.mediaId;
				objectPaletteItem.alignMedia = m;
				trace("Just set AugBubble with ID = '" + objectPaletteItem.augBubble.augBubbleId + "' Icon Media Id = '" + objectPaletteItem.augBubble.alignMediaId + "'");
			}*/
			else
			{
				objectPaletteItem.mediaId = m.mediaId;
				objectPaletteItem.media = m;
				trace("Just set Page with ID = '" + objectPaletteItem.augBubble.augBubbleId );
			}
			//AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, objectPaletteItem.item, new Responder(handleSaveObject, handleFault));
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
	
	/*
	private function handleAlignAVButtonClick(evt:MouseEvent):void
	{
		trace("AlignAVButtonClick clicked!");
		var url:String = objectPaletteItem.alignMedia.urlPath + objectPaletteItem.alignMedia.fileName;
		trace("URL to launch = '" + url + "'");
		var req:URLRequest = new URLRequest(url);
		navigateToURL(req,"to_blank");
	}
	*/

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
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_WEBPAGE_DATABASE)
		{
			objectPaletteItem.webPage.iconMediaId = 0;
			AppServices.getInstance().saveWebPage(GameModel.getInstance().game.gameId, objectPaletteItem.webPage, new Responder(handleSaveObjectAfterRemove, handleFault));
		}
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE)
		{
			objectPaletteItem.augBubble.iconMediaId = 0;
			AppServices.getInstance().saveAugBubble(GameModel.getInstance().game.gameId, objectPaletteItem.augBubble, new Responder(handleSaveObjectAfterRemove, handleFault));
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
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE)
		{
			//objectPaletteItem.augBubble.mediaId = 0;            
			AppServices.getInstance().saveAugBubble(GameModel.getInstance().game.gameId, objectPaletteItem.augBubble, new Responder(handleSaveObjectAfterRemove, handleFault));
		}
    }
	
	/*
	private function handleAlignRemoveButtonClick(evt:MouseEvent):void
	{
		trace("handleMediaRemoveButtonClick() called.");
		this.objectPaletteItem.alignMediaId = 0;
		this.objectPaletteItem.alignMedia = null;
		
		if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE)
		{
			objectPaletteItem.augBubble.alignMediaId = 0;            
			AppServices.getInstance().saveAugBubble(GameModel.getInstance().game.gameId, objectPaletteItem.augBubble, new Responder(handleSaveObjectAfterRemove, handleFault));
		}
	}
	*/

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