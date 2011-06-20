package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.LinkButton;
	import mx.events.DataGridEvent;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.data.arisserver.Media;
	import org.arisgames.editor.components.PlaceMarker;
	import org.arisgames.editor.components.PlaceMarkerEditorMediaPickerMX;
	import org.arisgames.editor.data.PlaceMark;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;

	
	public class ImageMatchEditorView extends Panel
	{
		
		public var placeMark:PlaceMark;
		public var placeMarker:PlaceMarker;
		
		
		// GUI
		[Bindable] public var closeButton:Button;
		
		[Bindable] public var mediaImageCanvas:Canvas;
		[Bindable] public var mediaPreviewImage:Image;
		[Bindable] public var mediaRemoveButton:Button;
		[Bindable] public var mediaNoMediaLabel:Label;
		[Bindable] public var mediaPopupMediaPickerButton:Button;
		
		private var mediaPicker:PlaceMarkerEditorMediaPickerMX;

				
		/**
		 * Constructor
		 */
		public function ImageMatchEditorView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{			
			mediaRemoveButton.addEventListener(MouseEvent.CLICK, handleMediaRemoveButtonClick);
			mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleMediaPickerButton);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
		}
		
		private function handleMediaRemoveButtonClick(evt:MouseEvent):void
		{
			trace("handleMediaRemoveButtonClick() called.");
			this.placeMarker.imageMatchMediaId = 0;
			this.placeMarker.imageMatchMedia = null;
			pushDataIntoGUI();
		}
		
		private function handleMediaPickerButton(evt:MouseEvent):void
		{
			trace("ImageMatchEditorView: handleMediaPickerButton() called...");
			this.openMediaPicker();
		}
		
		private function openMediaPicker():void
		{
			mediaPicker = new PlaceMarkerEditorMediaPickerMX();
			mediaPicker.setPlaceMarker(placeMarker);
			mediaPicker.delegate = this;
			
			PopUpManager.addPopUp(mediaPicker, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(mediaPicker);
		}
		
		
		private function pushDataIntoGUI():void
		{
			trace("ImageMatchEditorView: pushDataIntoGUI called with imageMatchMedia Id = '" + placeMarker.imageMatchMediaId);
				
				// Load The Media GUI
			mediaPopupMediaPickerButton.setVisible(true);
			mediaPopupMediaPickerButton.includeInLayout = true;
			if (placeMarker.imageMatchMedia != null && (placeMarker.imageMatchMedia.type == AppConstants.MEDIATYPE_IMAGE || placeMarker.imageMatchMedia.type == AppConstants.MEDIATYPE_ICON))
			{
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(true);
				mediaPreviewImage.includeInLayout = true;
				mediaNoMediaLabel.setVisible(false);
				mediaNoMediaLabel.includeInLayout = false;
				mediaRemoveButton.setVisible(true);
				mediaRemoveButton.includeInLayout = true;
			
				var mediaurl:String = placeMarker.imageMatchMedia.urlPath + placeMarker.imageMatchMedia.fileName;
				mediaPreviewImage.source = mediaurl;
				trace("Just set media image url = '" + mediaurl + "'");
			}
			else
			{
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(false);
				mediaPreviewImage.includeInLayout = false;
				mediaNoMediaLabel.setVisible(true);
				mediaNoMediaLabel.includeInLayout = true;
				mediaRemoveButton.setVisible(false);
				mediaRemoveButton.includeInLayout = false;
			}
		}
		
		public function setPlaceMarks(placeMark:PlaceMark, placeMarker:PlaceMarker):void{
			this.placeMark = placeMark;
			this.placeMarker = placeMarker;
			
			if(placeMarker.imageMatchMediaId != 0){
				if(placeMarker.imageMatchMedia != null){
					AppServices.getInstance().getMediaByGameIdAndMediaId(GameModel.getInstance().game.gameId, placeMarker.imageMatchMediaId, new Responder(handleLoadImageMatchMedia, handleFault));
					return;
				}
			}
			pushDataIntoGUI();
		}
		
		
		public function didSelectMediaItem(picker:PlaceMarkerEditorMediaPickerMX, m:Media):void
		{
			trace("PlaceMarkerEditorMediaDisplayView: didSelectMediaItem()");
			placeMarker.imageMatchMediaId = m.mediaId;
			placeMarker.imageMatchMedia = m;
			
			this.pushDataIntoGUI();
			
		}
		
		
		
		
		public function handleLoadImageMatchMedia(obj:Object):void{
			trace("In handleLoadImageMatchMedia() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("Bad loading of media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Media");
				return;
			}
			
			placeMarker.imageMatchMedia = new Media();
			placeMarker.imageMatchMedia.fileName = obj.result.data.file_name;
			placeMarker.imageMatchMedia.isDefault = obj.result.data.is_default;
			placeMarker.imageMatchMedia.mediaId = obj.result.data.media_id;
			placeMarker.imageMatchMedia.name = obj.result.data.name;
			placeMarker.imageMatchMedia.type = obj.result.data.type;
			placeMarker.imageMatchMedia.urlPath = obj.result.data.url_path;
			
			pushDataIntoGUI();
		}
		
		public function isPlaceMarkDataLoaded():Boolean
		{
			if (this.placeMark != null)
			{
				return true;
			}
			return false;
		}
		
		public function handleCloseButton(evt:MouseEvent):void
		{
			trace("Close button clicked...");
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEIMAGEMATCHEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems In ImageMatch Editor");
		}
	
	}
}