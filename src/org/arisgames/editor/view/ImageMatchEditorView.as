package org.arisgames.editor.view
{
	import flash.events.Event;
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
	import mx.events.DataGridEventReason;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.components.PlaceMarker;
	import org.arisgames.editor.components.PlaceMarkerEditorMediaPickerMX;
	import org.arisgames.editor.data.PlaceMark;
	import org.arisgames.editor.data.arisserver.Media;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;

	
	public class ImageMatchEditorView extends Panel
	{
		
		public var placeMark:PlaceMark;
		public var placeMarker:PlaceMarker;
		
		public var selectedIndex:Number;
		
		// GUI
		[Bindable] public var closeButton:Button;
		
		[Bindable] public var mediaImageCanvas:Canvas;
		[Bindable] public var mediaPreviewImage:Image;
		[Bindable] public var mediaRemoveButton:Button;
		[Bindable] public var mediaNoMediaLabel:Label;
		[Bindable] public var mediaPopupMediaPickerButton:Button;
		[Bindable] public var addMediaButton:Button;
		
		[Bindable] public var images:ArrayCollection;
		
		[Bindable] public var mediaList:DataGrid;
		
		private var mediaPicker:PlaceMarkerEditorMediaPickerMX;

				
		/**
		 * Constructor
		 */
		public function ImageMatchEditorView()
		{
			super();
			images = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{			
			selectedIndex = 0;
			mediaRemoveButton.addEventListener(MouseEvent.CLICK, handleMediaRemoveButtonClick);
			mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleMediaPickerButton);
			addMediaButton.addEventListener(MouseEvent.CLICK, handleAddMediaButtonClick);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			mediaList.addEventListener(MouseEvent.CLICK, handleItemFocusIn);
		}
		
		public function handleItemFocusIn(evt:Event):void {
			trace("ImageMatchEditorView: Focus on datagrid");
			setSelectedIndex(mediaList.selectedIndex);
		}
		
		private function handleAddMediaButtonClick(evt:MouseEvent):void {
			if(this.placeMarker.imageMatchMediaIdList.length > 0 && this.placeMarker.imageMatchMediaIdList[this.placeMarker.imageMatchMediaIdList.length - 1] == 0){
				setSelectedIndex(this.placeMarker.imageMatchMediaIdList.length - 1);
				handleMediaPickerButton(null);
				return;
			}
			
			this.placeMarker.imageMatchMediaList.addItem(null);
			this.placeMarker.imageMatchMediaIdList.addItem(0);
			var obj:Object = new Object();
			obj.name = "New Image Match Media";
			this.images.addItem(obj);
			this.placeMarker.imageMatchMedia = null;
			this.placeMarker.imageMatchMediaId = 0;
			setSelectedIndex(images.length - 1);
			pushDataIntoGUI();
			handleMediaPickerButton(null);
		}
		
		private function setSelectedIndex(to:Number):void {
			selectedIndex = to;
			mediaList.selectedIndex = selectedIndex;
			if(placeMarker.imageMatchMediaIdList.length > 0){
				placeMarker.imageMatchMedia = placeMarker.imageMatchMediaList[to];
				placeMarker.imageMatchMediaId = placeMarker.imageMatchMediaIdList[to];
			}
			else {
				placeMarker.imageMatchMedia = null;
				placeMarker.imageMatchMediaId = 0;
			}
			
			pushDataIntoGUI();
		}
		
		private function handleMediaRemoveButtonClick(evt:MouseEvent):void
		{
			trace("handleMediaRemoveButtonClick() called.");
			if(this.placeMarker.imageMatchMediaIdList[selectedIndex] != null){
				AppServices.getInstance().removeImageMatchMediaIdFromLocation(GameModel.getInstance().game.gameId, placeMarker.placemark, placeMarker.imageMatchMediaIdList[selectedIndex], new Responder(handleRemoveMedia, handleFault));
				this.placeMarker.imageMatchMediaIdList.removeItemAt(selectedIndex);
				this.placeMarker.imageMatchMediaList.removeItemAt(selectedIndex);
				this.images.removeItemAt(selectedIndex);
				this.placeMarker.imageMatchMediaIdList.refresh();
				this.placeMarker.imageMatchMediaList.refresh();
				setSelectedIndex(0);
				this.images.refresh();
			}
			if(this.placeMarker.imageMatchMediaIdList.length > 0 && this.placeMarker.imageMatchMediaIdList[0] != null){
				this.placeMarker.imageMatchMediaId = placeMarker.imageMatchMediaIdList[0];
				this.placeMarker.imageMatchMedia = placeMarker.imageMatchMediaList[0];
			}
			else{
				setSelectedIndex(0);
				this.placeMarker.imageMatchMediaId = 0;
				this.placeMarker.imageMatchMedia = null;
			}
			
			pushDataIntoGUI();
			//AppServices.getInstance().removeImageMatchMediaIdFromLocation(GameModel.getInstance().game.gameId,
		}
		
		private function handleRemoveMedia(obj:Object):void {
			trace("ImageMatchEditorView: In handleRemoveMedia()");
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
			if(selectedIndex == 0 && placeMarker.imageMatchMediaIdList.length == 0){
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(false);
				mediaPreviewImage.includeInLayout = false;
				mediaNoMediaLabel.setVisible(false);
				mediaNoMediaLabel.includeInLayout = false;
				mediaRemoveButton.setVisible(false);
				mediaRemoveButton.includeInLayout = false;
				mediaPopupMediaPickerButton.setVisible(false);
				mediaPopupMediaPickerButton.includeInLayout = false;
				return;
			}
			
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
				
				/*
				//BLANK SQUARE
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(false);
				mediaPreviewImage.includeInLayout = false;
				mediaNoMediaLabel.setVisible(true);
				mediaNoMediaLabel.includeInLayout = true;
				mediaRemoveButton.setVisible(false);
				mediaRemoveButton.includeInLayout = false;
				*/
				
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(true);
				mediaPreviewImage.includeInLayout = true;
				mediaNoMediaLabel.setVisible(true);
				mediaNoMediaLabel.includeInLayout = true;
				mediaRemoveButton.setVisible(false);
				mediaRemoveButton.includeInLayout = false;
				
				mediaurl = AppConstants.IMG_DEFAULT_IMAGE_SIZE_REFERENCE_URL;
				mediaPreviewImage.source = mediaurl;
				trace("Just set media image url = '" + mediaurl + "'");
			}
		}
		
		public function setPlaceMarks(placeMark:PlaceMark, placeMarker:PlaceMarker):void{
			this.placeMark = placeMark;
			this.placeMarker = placeMarker;
			
			if(this.placeMarker.imageMatchMediaList == null) this.placeMarker.imageMatchMediaList = new ArrayCollection();
			if(this.placeMarker.imageMatchMediaIdList == null) this.placeMarker.imageMatchMediaIdList = new ArrayCollection();
			
			AppServices.getInstance().getAllImageMatchMedia(GameModel.getInstance().game.gameId, placeMarker.placemark, new Responder(handleLoadImageMatchMedia, handleFault));
		}
		
		
		public function didSelectMediaItem(picker:PlaceMarkerEditorMediaPickerMX, m:Media):void
		{
			trace("PlaceMarkerEditorMediaDisplayView: didSelectMediaItem()");
			placeMarker.imageMatchMediaId = m.mediaId;
			placeMarker.imageMatchMedia = m;
			images[selectedIndex].name = m.name;
			placeMarker.imageMatchMediaIdList[selectedIndex] = m.mediaId;
			placeMarker.imageMatchMediaList[selectedIndex] = m;
			AppServices.getInstance().addImageMatchMediaIdToLocation(GameModel.getInstance().game.gameId, placeMarker.placemark, m.mediaId, new Responder(handleAddMedia, handleFault));
			images.refresh();
			placeMarker.imageMatchMediaList.refresh();
			placeMarker.imageMatchMediaIdList.refresh();
			this.pushDataIntoGUI();
		}
		
		public function handleAddMedia(obj:Object):void {
			trace("ImageMatchEditorView: in handleAddMedia()");
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
			placeMarker.imageMatchMedia = null;
			placeMarker.imageMatchMediaId = 0;
			placeMarker.imageMatchMediaList.removeAll();
			placeMarker.imageMatchMediaIdList.removeAll();
			images.removeAll();
			for(var x:Number = 0; x < obj.result.data.length && obj.result.data[x].data != null; x++){
				placeMarker.imageMatchMediaList.addItem(new Media());
		
				placeMarker.imageMatchMediaList[x].fileName = obj.result.data[x].data.file_name;
				placeMarker.imageMatchMediaList[x].isDefault = obj.result.data[x].data.is_default;
				placeMarker.imageMatchMediaList[x].mediaId = obj.result.data[x].data.media_id;
				placeMarker.imageMatchMediaIdList.addItem(obj.result.data[x].data.media_id);
				placeMarker.imageMatchMediaList[x].name = obj.result.data[x].data.name;
				var image:Object = new Object();
				image.name = obj.result.data[x].data.name;
				images.addItem(image);
				placeMarker.imageMatchMediaList[x].type = obj.result.data[x].data.type;
				placeMarker.imageMatchMediaList[x].urlPath = obj.result.data[x].data.url_path;
				
				if(x == 0){
					placeMarker.imageMatchMedia = placeMarker.imageMatchMediaList[x];
					placeMarker.imageMatchMediaId = placeMarker.imageMatchMediaIdList[x];
				}
			}
			placeMarker.imageMatchMediaList.refresh();
			placeMarker.imageMatchMediaIdList.refresh();
			images.refresh();			
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