package org.arisgames.editor.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.VBox;
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
	
	import org.arisgames.editor.components.MultiMediaPickerPickerMX;
	import org.arisgames.editor.data.arisserver.Media;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	
	public class MultiMediaPickerView extends VBox
	{
		
		public var selectedIndex:Number;
		public var allowAllMediaTypes:Boolean = false;
		public var allowAddMedia:Boolean = true;
		
		// GUI
		
		[Bindable] public var mediaImageCanvas:Canvas;
		[Bindable] public var mediaPreviewImage:Image;
		[Bindable] public var mediaRemoveButton:Button;
		[Bindable] public var mediaNoMediaLabel:Label;
		[Bindable] public var mediaPopupMediaPickerButton:Button;
		[Bindable] public var addMediaButton:Button;
		
		[Bindable] public var images:ArrayCollection;
		[Bindable] public var namez:ArrayCollection;
		//"Images object-"
		//	media
		//  id
		//  name
		//  text
		
		[Bindable] public var mediaList:DataGrid;
		
		private var mediaPicker:MultiMediaPickerPickerMX;
		private var delegate:Object;
		private var media:Media;
		private var mediaId:Number;
		
		public var currentLoaded:Number;
		
		/**
		 * Constructor
		 */
		public function MultiMediaPickerView()
		{
			super();
			images = new ArrayCollection();
			namez = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		public function allowAllMediaTypesf(y:Boolean){
			this.allowAllMediaTypes = y;
		}
		
		public function allowAddMediaf(y:Boolean){
			this.allowAddMedia = y;
			if(y)
				this.addMediaButton.visible = true;
			else
				this.addMediaButton.visible = false;
		}
		
		private function handleInit(event:FlexEvent):void
		{			
			selectedIndex = 0;
			currentLoaded = 0;
			mediaRemoveButton.addEventListener(MouseEvent.CLICK, handleMediaRemoveButtonClick);
			mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleMediaPickerButton);
			addMediaButton.addEventListener(MouseEvent.CLICK, handleAddMediaButtonClick);
			mediaList.addEventListener(MouseEvent.CLICK, handleItemFocusIn);
		}
		
		public function setDelegate(obj:Object):void {
			this.delegate=obj;
		}
		
		public function handleItemFocusIn(evt:Event):void {
			trace("MultiMediaPickerView: Focus on datagrid");
			setSelectedIndex(mediaList.selectedIndex);
		}
		
		private function handleAddMediaButtonClick(evt:MouseEvent):void {
			if(this.images.length > 0 && this.images[this.images.length-1].id == 0){
				setSelectedIndex(images.length - 1);
				pushDataIntoGUI();
				handleMediaPickerButton(null);
			}
			
			var obj:Object = new Object();
			obj.name = "New Media";
			obj.id=0;
			this.images.addItem(obj);
			this.namez.addItem("New Media");
			setSelectedIndex(images.length - 1);
			pushDataIntoGUI();
			handleMediaPickerButton(null);
		}
		
		private function setSelectedIndex(to:Number):void {
			if(to == -1){
				return;
			}
			selectedIndex = to;
			mediaList.selectedIndex = selectedIndex;
			if(images.length > 0){
				if(this.images[to].media == null){
					AppServices.getInstance().getMediaByGameIdAndMediaId(GameModel.getInstance().game.gameId, this.images[to].id, new Responder(handleLoadMedia, handleFault));
				}
				else{
					this.media = this.images[to].media;
					this.mediaId = this.images[to].id;
				}
			}
			else {
				this.media = null;
				this.mediaId = 0;
			}
			pushDataIntoGUI();
		}
		
		public function loadImages(x:Number):void {
			if(x >= images.length){
				currentLoaded = -1;
			}
			if(images != null && x < images.length && images[x] != null){
				selectedIndex = x;
				AppServices.getInstance().getMediaByGameIdAndMediaId(GameModel.getInstance().game.gameId, this.images[x].id, new Responder(handleLoadMedia, handleFault));
			}
		}
		
		
		private function handleMediaRemoveButtonClick(evt:MouseEvent):void
		{
			trace("handleMediaRemoveButtonClick() called.");
			if(this.images[selectedIndex] != null){
				delegate.mediaWasRemoved(selectedIndex, images[selectedIndex]);
				this.images.removeItemAt(selectedIndex);
				this.namez.removeItemAt(selectedIndex);
				this.images.refresh();
				setSelectedIndex(0);
			}
			if(this.images.length > 0 && this.images[0].media != null){
				this.mediaId = images[0].id;
				this.media = images[0].media;
			}
			else{
				setSelectedIndex(0);
				this.mediaId = 0;
				this.media = null;
			}
			pushDataIntoGUI();
		}
		
		private function handleMediaPickerButton(evt:MouseEvent):void
		{
			trace("ImageMatchEditorView: handleMediaPickerButton() called...");
			this.openMediaPicker();
		}
		
		private function openMediaPicker():void
		{
			mediaPicker = new MultiMediaPickerPickerMX();
			mediaPicker.delegate = this;
			mediaPicker.allowAllMediaTypes = this.allowAllMediaTypes;
			
			PopUpManager.addPopUp(mediaPicker, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(mediaPicker);
		}
		
		public function pushDataIntoGUI():void {
			if(selectedIndex == 0 && this.images.length == 0){
				/*
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
				return;*/
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(true);
				mediaPreviewImage.includeInLayout = true;
				mediaNoMediaLabel.setVisible(true);
				mediaNoMediaLabel.includeInLayout = true;
				mediaRemoveButton.setVisible(false);
				mediaRemoveButton.includeInLayout = false;
				mediaPopupMediaPickerButton.setVisible(false);
				mediaPopupMediaPickerButton.includeInLayout = false;
				
				mediaurl = AppConstants.IMG_DEFAULT_PANO_SIZE_REFERENCE_URL;
				mediaPreviewImage.source = mediaurl;
				trace("Just set media image url = '" + mediaurl + "'");
				return;
			}
			
			// Load The Media GUI
			mediaPopupMediaPickerButton.setVisible(false);//true);
			mediaPopupMediaPickerButton.includeInLayout = false;//true;
			if (this.images.length > selectedIndex && this.images[selectedIndex].media != null)
			{
				mediaImageCanvas.setVisible(true);
				mediaImageCanvas.includeInLayout = true;
				mediaPreviewImage.setVisible(true);
				mediaPreviewImage.includeInLayout = true;
				mediaNoMediaLabel.setVisible(false);
				mediaNoMediaLabel.includeInLayout = false;
				mediaRemoveButton.setVisible(true);
				mediaRemoveButton.includeInLayout = true;
				
				var mediaurl:String = this.media.urlPath + this.media.fileName;
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
				
				mediaurl = AppConstants.IMG_DEFAULT_PANO_SIZE_REFERENCE_URL;
				mediaPreviewImage.source = mediaurl;
				trace("Just set media image url = '" + mediaurl + "'");
			}
		}
			
		public function didSelectMediaItem(picker:MultiMediaPickerPickerMX, m:Media):void
		{
			trace("PlaceMarkerEditorMediaDisplayView: didSelectMediaItem()");
			this.mediaId = m.mediaId;
			this.media = m;
			this.images[selectedIndex].name = m.name;
			this.namez[selectedIndex] = m.name;
			this.images[selectedIndex].id = m.mediaId;
			this.images[selectedIndex].media = m;
			delegate.imageListWasUpdated(this.selectedIndex, images[selectedIndex], this.images);
			images.refresh();
			this.pushDataIntoGUI();
		}
		
		public function didCloseWindow(picker:MultiMediaPickerPickerMX):void
		{
			this.handleMediaRemoveButtonClick(null);
		}
		
		private function handleLoadMedia(obj:Object):void{
			if(obj.result.data != null){
				this.images[selectedIndex].media = new Media();
				this.images[selectedIndex].media.mediaId = obj.result.data.media_id;
				this.images[selectedIndex].media.name = obj.result.data.name;
				this.images[selectedIndex].name = obj.result.data.name;
				this.namez[selectedIndex] = obj.result.data.name;
				this.images[selectedIndex].media.type = obj.result.data.type;
				this.images[selectedIndex].media.urlPath = obj.result.data.url_path;
				this.images[selectedIndex].media.fileName = obj.result.data.file_name;
				this.images[selectedIndex].media.isDefault = obj.result.data.is_default;
				
				this.media = this.images[selectedIndex].media;
				this.mediaId = this.images[selectedIndex].id;
			}
			this.pushDataIntoGUI();
			if(currentLoaded != -1){
				loadImages(++currentLoaded);
			}
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems In ImageMatch Editor");
		}
		
	}
}
