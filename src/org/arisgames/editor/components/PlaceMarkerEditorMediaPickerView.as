package org.arisgames.editor.components
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
	
	import org.arisgames.editor.components.ImageMatchEditorMediaPickerCustomEditorMX;
	import org.arisgames.editor.components.PlaceMarker;
	import org.arisgames.editor.data.arisserver.Media;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	public class PlaceMarkerEditorMediaPickerView extends Panel
	{
		// Data Object
		public var delegate:Object;
		private var placeMarker:PlaceMarker;
		private var uploadFormVisable:Boolean = false;
		
		// Media Data
		[Bindable] public var xmlData:XML;
		
		// GUI
		[Bindable] public var treeBrowser:TreeBrowser;
		[Bindable] public var closeButton:Button;
		[Bindable] public var selectButton:Button;
		
		// Tree Icons
		[Bindable]
		[Embed(source="assets/img/separator.png")]
		public var separatorIcon:Class; //If these names are changed, make sure it is also changed in AppConstants (MEDIATREEICON_*)
		
		[Bindable]
		[Embed(source="assets/img/upload.png")]
		public var uploadIcon:Class; //If these names are changed, make sure it is also changed in AppConstants (MEDIATREEICON_*)
		
		private var mediaUploader:ItemEditorMediaPickerUploadFormMX;
		
		/**
		 * Constructor
		 */
		public function PlaceMarkerEditorMediaPickerView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			title = "Image Matching Media Picker";
			trace("in PlaceMarkerEditorMediaPickerView's handleInit");
			var cf:ClassFactory = new ClassFactory(ImageMatchEditorMediaPickerCustomEditorMX);
			cf.properties = {placeMarker: this.placeMarker};
			treeBrowser.detailRenderer = cf;
			treeBrowser.addEventListener(TreeBrowserEvent.NODE_SELECTED, onNodeSelected);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			selectButton.addEventListener(MouseEvent.CLICK, handleSelectButton);
			// Load Game's Media Into XML
			AppServices.getInstance().getMediaForGame(GameModel.getInstance().game.gameId, new Responder(handleLoadingOfMediaIntoXML, handleFault));
		}
		
		private function printXMLData():void
		{
			trace("XML Data = '" + xmlData.toXMLString() + "'");
		}
		
		public function setPlaceMarker(pm:PlaceMarker):void
		{
			trace("setting placeMarker with name = '" + pm.placemark.name + "' in ItemEditorPlaqueView");
			placeMarker = pm;
		}
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("PlaceMarkerEditorMediaPickerView: handleCloseButton()");
			PopUpManager.removePopUp(this);
		}
		
		
		private function handleSelectButton(evt:MouseEvent):void
		{
			trace("Select Button clicked...");
			
			var obj:TreeBrowser = treeBrowser;
			var m:Media = new Media();
			m.mediaId = treeBrowser.selectedItem.@mediaId;
			m.name = treeBrowser.selectedItem.@label;
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
						
			this.printXMLData();
			
			var media:Array = obj.result.data as Array;
			trace("Number of Media Objects returned from server = '" + media.length + "'");
			
			//Puts media items in xml readable format
			var numImageDefaults:Number = 0;
			var numAudioDefaults:Number = 0;
			var numVideoDefaults:Number = 0;
			var numIconDefaults:Number = 0;
			for (var k:Number = 0; k <= 1; k++) //Iterates over list twice; once for uploaded items, again for default
			{
				//Add "Upload new" at top
				if(k == 0){
					xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_UPLOADNEW + '" icon="'+ AppConstants.MEDIATREEICON_UPLOAD +'"/>');
				}
				for (var j:Number = 0; j < media.length; j++)
				{
					var o:Object = media[j];
					
					if((k==0 && !o.is_default) || (k==1 && o.is_default)){
						var m:Media = new Media();
						
						m.mediaId = o.media_id;
						m.name = o.name;
						m.type = o.type;
						m.urlPath = o.url_path;
						m.fileName = o.file_name;
						m.isDefault = o.is_default; //for both default files and uploaded files
						
						var node:String = "<node label='" + AppUtils.filterStringToXMLEscapeCharacters(m.name) + "' mediaId='" + m.mediaId + "' type='" + m.type + "' urlPath='" + m.urlPath + "' fileName='" + m.fileName + "' isDefault='" + m.isDefault + "'/>";	
						if(k > numIconDefaults) xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_SEPARATOR + '" icon="'+ AppConstants.MEDIATREEICON_SEPARATOR +'"/>');
						xmlData.appendChild(node);
						numIconDefaults+=k;
					
					}
				}
			}
			trace("PlaceMarkerEditorMediaPickerView: handleLoadingOfMediaIntoXML: Just finished loading Media Objects into XML.  Here's what the new XML looks like:");
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
			if (!event.isBranch)
			{
				if (event.item.@label == AppConstants.MEDIATYPE_UPLOADNEW)
				{
					if (uploadFormVisable == false) {
						trace("PlaceMarkerEditorMediaPickerView: onNodeSelected label == MEDIATYPE_UPLOADNEW, display form");
						selectButton.enabled = false;
						uploadFormVisable = true;
						this.displayMediaUploader();
						PopUpManager.removePopUp(this);
					}
					else trace("PlaceMarkerEditorMediaPickerView: ignored second TreeBrowserEvent == MEDIATYPE_UPLOADNEW");
					
				}
				else if(event.item.@label == AppConstants.MEDIATYPE_SEPARATOR){
					//Do Nothing
					trace("Separator Selected");
					selectButton.enabled = false;
				}
				else
				{
					trace("PlaceMarkerEditorMediaPickerView: onNodeSelected is a media item");
					selectButton.enabled = true;
				}
			}
			else {
				selectButton.enabled = false;	
			}
		}
		
		
		
		private function displayMediaUploader():void
		{
			trace("PlaceMarkerEditorMediaPickerPickerView: displayMediaUploader");
			mediaUploader = new ItemEditorMediaPickerUploadFormMX();
			mediaUploader.isIconPicker = false;
			mediaUploader.delegate = this;
			PopUpManager.addPopUp(mediaUploader, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(mediaUploader);
		}
		
		
		public function didUploadMedia(uploader:ItemEditorMediaPickerUploadFormMX, m:Media):void{
			trace("PlaceMarkerEditorMediaPicker: didUploadMedia");
			
			uploadFormVisable = false;
			
			if (delegate.hasOwnProperty("didSelectMediaItem")){
				delegate.didSelectMediaItem(this, m);
			}		
			
			PopUpManager.removePopUp(uploader);
		}
		
	}
}