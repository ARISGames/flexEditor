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
	import org.arisgames.editor.components.PlaceMarker;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	
	public class ImageMatchEditorMediaPickerCustomEditorView extends VBox
	{
		// Data Object
		public var placeMarker:PlaceMarker;
		
		private var dataChanged:Boolean;
		
		// GUI
		[Bindable] public var imageCanvas:Canvas;
		[Bindable] public var previewImage:Image;
		[Bindable] public var mediaName:TextInput;
		
		[Bindable] public var saveButton:Button;
		[Bindable] public var deleteButton:Button;
		
		/**
		 * Constructor
		 */
		public function ImageMatchEditorMediaPickerCustomEditorView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("In ImageMatchEditorMediaPickerCustomEditorView's handleInit");
			saveButton.addEventListener(MouseEvent.CLICK, handleSaveButtonClick);
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
				}
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
			else if(data.@isDefault){
				trace("Data is default, so disable Save & Delete Button.");
				mediaName.editable = mediaName.editable = true;
				saveButton.visible = false;
				saveButton.includeInLayout = false;
				deleteButton.visible = false;
				deleteButton.includeInLayout = false;
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
		
		
		private function handleSaveButtonClick(evt:MouseEvent):void
		{
			trace("Save Button clicked...");
			data.@label = mediaName.text;
			AppServices.getInstance().renameMediaForGame(GameModel.getInstance().game.gameId, data.@mediaId, mediaName.text, new Responder(handleSaveMedia, handleFault));
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
			var de:DynamicEvent;    
			
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete of media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Media");
				de = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
				AppDynamicEventManager.getInstance().dispatchEvent(de);
				return;
			}
			
			Alert.show("Just deleted Media named '" + data.@label + "'.", "Successfully Deleted Media");
			de = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems With Media Item");
		}
	}
}