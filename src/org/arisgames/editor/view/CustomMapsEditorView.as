package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.events.DataGridEvent;
	import mx.events.DynamicEvent;
	import flash.events.DataEvent;
	import flash.events.Event;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.data.arisserver.CustomMap;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	public class CustomMapsEditorView extends Panel
	{
		// Data For GUI
		[Bindable] public var customMaps:ArrayCollection;
		//[Bindable] public var outgoingWebHooks:ArrayCollection;
		
		// GUI
		[Bindable] public var customMapsDg:DataGrid;
		//[Bindable] public var outDg:DataGrid;

		[Bindable] public var addCustomMapButton:Button;
		//[Bindable] public var addOutWebHookButton:Button;
		
		[Bindable] public var uploadZipButton:Button;
		
		[Bindable] public var customMapsHead:Text;
		//[Bindable] public var outHead:Text;

		[Bindable] public var customMapsDesc:Text;
		//[Bindable] public var outDesc:Text;

		[Bindable] public var closeButton:Button;
		
		public var persistUrl:String;
		public var persistIndex:Number;
		
		private var fileChooser:FileReferenceList;
		private var fileChosen:FileReference;

		
		private var requirementsEditor:RequirementsEditorMX;
		
		/**
		 * Constructor
		 */
		public function CustomMapsEditorView()
		{
			super();
			customMaps = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			customMapsHead.htmlText = "Custom Maps";
			
			//customMaps.htmlText = "<font color=\"#FF0000\">*</font>You can create custom maps for your ARIS game. Your map will either completely replace or be layered on top of the normal map for a specific location. Click the 'instructions' link below for details on how to create custom maps. <font color=\"#FF0000\"></font>";
			
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			
			addCustomMapButton.addEventListener(MouseEvent.CLICK, handleAddCustomMapButtonClick);

		
			//customMapsDg.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, handleBeginEdit);
				
			//customMapsDg.addEventListener(DataGridEvent.ITEM_FOCUS_OUT, handleEndEdit);
			
			AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR, closeRequirementsEditor);

			this.reloadTheCustomMaps();
		}
		
		private function closeRequirementsEditor(evt:DynamicEvent):void
		{
			trace("closeRequirementsEditor called...");
			PopUpManager.removePopUp(requirementsEditor);
			requirementsEditor = null;
		}
		
		private function openRequirementsEditor(requirementType:String):void
		{
			requirementsEditor = new RequirementsEditorMX();
			var cm:CustomMap = (customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap);
			requirementsEditor.setRequirementTypeAndId(requirementType, cm.customMapId);
			
			this.parent.addChild(requirementsEditor);
			
			// Need to validate the display so that entire component is rendered
			requirementsEditor.validateNow();
			
			PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(requirementsEditor);
			requirementsEditor.setVisible(true);
			requirementsEditor.includeInLayout = true;
		}
		
		/*public function handleBeginEdit(evt:DataGridEvent):void {
			trace("Edit Beginning");
			persistUrl = (incomingWebHooks.getItemAt(inDg.selectedIndex) as WebHook).url;
			persistIndex = inDg.selectedIndex;
		}
		
		public function handleEndEdit(evt:DataGridEvent):void {
			trace("Edit Ending- " + persistUrl);
			(incomingWebHooks.getItemAt(inDg.selectedIndex) as WebHook).url = persistUrl;
			incomingWebHooks.refresh();
		}
		
		public function handleOutEndEdit(evt:DataGridEvent):void {
			(outgoingWebHooks.getItemAt(outDg.selectedIndex) as WebHook).appendage = "?hook=" + ((outgoingWebHooks.getItemAt(outDg.selectedIndex) as WebHook).name.split(" ").join("")) + "&wid=" + (outgoingWebHooks.getItemAt(outDg.selectedIndex) as WebHook).webHookId + "&gameid=" + GameModel.getInstance().game.gameId + "&playerid=" + "{player id}";
			outgoingWebHooks.refresh();
		}*/
		
		
		public function handleUpPressed(evt:Event):void{
			if(customMapsDg.selectedIndex > 0 && customMapsDg.selectedIndex < customMaps.length){
				AppServices.getInstance().switchCustomMapOrder(GameModel.getInstance().game.gameId, (customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap).customMapId, (customMaps.getItemAt(customMapsDg.selectedIndex-1) as CustomMap).customMapId, new Responder(handleSwitchedSortPosUp, handleFault));
				trace("up");
			}
		}
		
		public function handleDownPressed(evt:Event):void{
			if(customMapsDg.selectedIndex >= 0 && customMapsDg.selectedIndex < customMaps.length-1){
				AppServices.getInstance().switchCustomMapOrder(GameModel.getInstance().game.gameId, (customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap).customMapId, (customMaps.getItemAt(customMapsDg.selectedIndex+1) as CustomMap).customMapId, new Responder(handleSwitchedSortPosDown, handleFault));
				trace("down");
			}
		}
		
		private function handleSwitchedSortPosUp(obj:Object):void {
			trace("CustomMapsEditorView: In handleSwitchedSortPosUp() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("CustomMapsEditorView: Bad save custom map attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("CustomMapsEditorView: Error Was: " + msg, "Error While Saving Custom Map");
			}
			else
			{
				var sel:Number = customMapsDg.selectedIndex;
				customMaps.getItemAt(sel).index = sel-1;
				customMaps.getItemAt(sel-1).index = sel;
				customMaps.addItemAt(customMaps.removeItemAt(sel), sel-1);
				customMaps.refresh();
				//dg.selectedIndex = sel-1;
			}
		}
		
		private function handleSwitchedSortPosDown(obj:Object):void {
			trace("CustomMapsEditorView: In handleSwitchedSortPosDown() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("CustomMapsEditorView: Bad save character content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("CustomMapsEditorView: Error Was: " + msg, "Error While Saving Custom Map");
			}
			else
			{
				var sel:Number = customMapsDg.selectedIndex;
				customMaps.getItemAt(sel).index = sel+1;
				customMaps.getItemAt(sel+1).index = sel;
				customMaps.addItemAt(customMaps.removeItemAt(sel), sel+1);
				customMaps.refresh();
				//dg.selectedIndex = sel+1;
			}
		}
		
		
		public function handleRefreshCustomMapData(evt:DynamicEvent):void
		{
			trace("CustomMapsEditorView: Starting handleRefreshCustomMapData()....");
			customMaps.refresh();
		}
		
		private function reloadTheCustomMaps():void
		{
			trace("CustomMapsEditorView: Starting reloadTheCustomMaps()....");
			AppServices.getInstance().getCustomMapsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadCustomMaps, handleFault));
		}
		
		public function handleDeleteButtonClick(evt:MouseEvent):void
		{
			trace("CustomMapsEditorView: handleDeleteButtonClick() called with Selected Index = '" + customMapsDg.selectedIndex + "'");
			AppServices.getInstance().deleteCustomMap(GameModel.getInstance().game.gameId, ((customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap).customMapId), new Responder(handleDeleteCustomMap, handleFault));
		}
		
		
		public function handleRequirementsButtonClick(evt:MouseEvent):void
		{
			trace("CustomMapsEditorView: handleRequirementsButtonClick() called with Selected Index = '" + customMapsDg.selectedIndex + "'");
			this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_CUSTOMMAP);
		}
		
		public function handleZipFileButtonClick(evt:MouseEvent):void
		{
			trace("handleZipFileButton=clicked...");
			// Build File Filters
			var all:String = "";
			var img:String = "";
			
			var zipFilter:FileFilter = new FileFilter("Zip File", "*.zip");
			
			fileChooser = new FileReferenceList();
			fileChooser.addEventListener(Event.SELECT, onSelectZipFile);
			fileChooser.browse([zipFilter]);
		}
		
		private function handleDeleteCustomMap(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete custom map attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Custom Map");
			}
			else
			{
				trace("Deletion of CustomMap went well in the database, so now removing it from UI datamodel and UI.");
				customMaps.removeItemAt(customMapsDg.selectedIndex);
				customMaps.refresh();
			}
		}
		
		
		private function onSelectZipFile(event:Event):void
		{
			var fileOK:Boolean = false;
			if (fileChooser.fileList.length >= 1)
			{
				for (var k:Number = 0; k < fileChooser.fileList.length; k++)
				{
					trace("File to Upload: Name = '" + fileChooser.fileList[k].name + "' and type is " + fileChooser.fileList[k].type);
					fileChosen = fileChooser.fileList[k];
					trace("File to Upload: Name = '" + fileChooser.fileList[k].name + "' and type is " + fileChosen.type);
				}
				//this.displayIsIconFormQuestionIfConditionsAreMet();
				//clearFileButton.setVisible(true);
				//clearFileButton.includeInLayout = true;
				//formSpacer.setVisible(true);
				//formSpacer.includeInLayout = true;
				//uploadButton.enabled = true;
				
				
				
				// put zip file in the correct location on server
				
					// Variables to send along with upload
				var sendVars:URLVariables = new URLVariables();
				sendVars.gameID = GameModel.getInstance().game.gameId;
				sendVars.action = "upload";
				var cm:CustomMap = (customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap);
				sendVars.gameOverlayId = cm.customMapId;
				
				var request:URLRequest = new URLRequest();
				request.data = sendVars;
				request.url = AppConstants.APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL;
				request.method = URLRequestMethod.POST;
				//fileChosen.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				//fileChosen.addEventListener(Event.COMPLETE, onUploadComplete);
				//fileChosen.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
				//fileChosen.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
				fileChosen.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteResponseHandler);
				fileChosen.upload(request, "file", false);

				
				this.validateNow();
			}
			
			
			
		}
		
		private function uploadCompleteResponseHandler(event:DataEvent):void
		{
			var response:XML = XML( event.data );
			trace("HTTP Response = '" + response.toString() + "'");
			trace("=============================================================");
			trace("HTTP Respone (XML Format) = '" + response.toXMLString() + "'");
			
			// remove old zip file, if one exists
			
			
			// get new zip file name, put into overlays.folder_name
			// unzip file
			var cm:CustomMap = customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap;
			var tileZipFile:String = response.toString();
			cm.tileFolder = tileZipFile.substr(0, tileZipFile.length - 4);
			cm.zipUploaded = true;
			customMaps.refresh();
			AppServices.getInstance().unzipCustomMapTiles(GameModel.getInstance().game.gameId, cm.customMapId, response.toString(), new Responder(handleUnzipCustomMapTiles, handleFault));
			
			
		}
		
		private function handleUnzipCustomMapTiles(obj:Object):void
		{
	

			if (obj.result.returnCode != 0)
			{
				trace("Bad unzip custom map attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Custom Map");
			}
			else
			{
				trace("Unzip custom map compete.");
				// write info from zip file into database
				AppServices.getInstance().unzipCustomMapTiles(GameModel.getInstance().game.gameId, ((customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap).customMapId), ((customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap).tileFolder + ".zip"), new Responder(handleWriteCustomMapTilestoDatabase, handleFault));
				
				
			}
				
		}
		
		private function handleWriteCustomMapTilestoDatabase(obj:Object):void 
		{
			trace("ItemEditorMediaPickerUploadFormView: handleUploadAndSaveFileSuccess()");
			if (obj.result.returnCode != 0)
			{
				
			}
			else
			{
				trace("CustomMapsEditorView: Upload was legit, call the delegate with the to unzip the file");
				
				var cm:CustomMap = customMaps.getItemAt(customMapsDg.selectedIndex) as CustomMap;
				AppServices.getInstance().writeCustomMapTilesToDatabase(GameModel.getInstance().game.gameId, cm.customMapId, cm.tileFolder, new Responder(handleWriteCustomMapTilesSuccess, handleFault));
				
			}
		}
		
		
		
		private function handleWriteCustomMapTilesSuccess(obj:Object):void 
		{
			trace("CustomMapsEditorView: handleWriteCustomMapTilesSuccess()");
			if (obj.result.returnCode != 0)
			{
				
			}
			else
			{
				trace("CustomMapsEditorView: Success!");
				
			}
		}
		
		private function handleAddCustomMapButtonClick(evt:MouseEvent):void
		{
			trace("Add Custom Map Button clicked...");
			var cm:CustomMap;
			cm = new CustomMap("Custom Map", 0, customMaps.length); 
			var noSpaceName:String = cm.name.split(" ").join("");
			//w.appendage = "?hook=" + noSpaceName + "&wid=" + w.webHookId + "&gameid=" + GameModel.getInstance().game.gameId + "&playerid=" + "{player id}";			outgoingWebHooks.addItem(w);
			customMaps.addItem(cm);
			AppServices.getInstance().saveCustomMap(GameModel.getInstance().game.gameId, cm, new Responder(handleAddCustomMapSave, handleFault));
		}
		

		private function handleUpdateCustomMapSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad update CustomMap attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Updating CustomMap");
			}
			else trace("Update CustomMap was successful.");
		}
		
		
		private function handleAddCustomMapSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle add / save custom map attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Adding / Save WebHook");
			}
			else
			{
				var cid:Number = obj.result.data;  // MAKE SURE THIS IS PASSING CUSTOM MAP ID
				trace("Add / Save CustomMap was successful.  The CustomMap Id returned = '" + cid + "'");
				
				if (cid != 0)
				{
					trace("Returned Id was not zero, so going to look through " + customMaps.length + " requirements looking for the one with a missing id.");
					for (var j:Number = 0; j < customMaps.length; j++)
					{
						var cm:CustomMap = customMaps.getItemAt(j) as CustomMap;
						trace("&&&&& Checking j = '" + j + "'; CustomMap Id = '" + cm.customMapId + "'");
						if (isNaN(cm.customMapId) || cm.customMapId == 0)
						{
							trace("Found previously added / saved CustomMap.  Add ID to it and exiting method.");
							cm.customMapId = cid;
							AppServices.getInstance().saveCustomMap(GameModel.getInstance().game.gameId, cm, new Responder(handleUpdateCustomMapSave, handleFault));
							customMaps.refresh();
							return;
						}
						
						
					}
				}
				else
				{
					trace("Returned Id was zero, so this method is done.");
				}
			}
		}
		
		
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("Close button clicked...");
			for each(var cm:CustomMap in customMaps){
				trace("Saving custom map: " + cm.name);
				AppServices.getInstance().saveCustomMap(GameModel.getInstance().game.gameId, cm, new Responder(handleUpdateCustomMapSave, handleFault));
			}
			
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSECUSTOMMAPSEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		protected function handleInstructionsButton(event:MouseEvent):void
		{
			var loc:String = "https://docs.google.com/document/d/1A4QvrjyTlzstbWmUDrvI-CpYGYo9zMinIyX1z7EJfhE/edit"; 
			navigateToURL(new URLRequest(loc),"_blank");
		}
		
		private function handleLoadCustomMaps(obj:Object):void
		{
			trace("handling load customMaps...");
			customMaps.removeAll();
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle loading customMaps attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Custom Maps");
			}
			else
			{
				customMaps = new ArrayCollection();
				for (var j:Number = 0; j < obj.result.data.list.length; j++)
				{
					var cm:CustomMap = new CustomMap("", 0,0);  
					cm.name = obj.result.data.list.getItemAt(j).name;
					cm.customMapId = obj.result.data.list.getItemAt(j).overlay_id;
					cm.index = j;
					if (obj.result.data.list.getItemAt(j).file_uploaded)
						cm.zipUploaded = true;
					else
						cm.zipUploaded = false;
					
					
					
					if(cm.index != obj.result.data.list.getItemAt(j).sort_index) AppServices.getInstance().saveCustomMap(GameModel.getInstance().game.gameId, cm, new Responder(handleUpdateCustomMapSave, handleFault));
					customMaps.addItem(cm);
					
				}
				trace("Loaded '" + customMaps.length + "' custom maps(s).");
			}

			customMaps.refresh();
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			
			Alert.show("Error occurred: " + obj.message, "Problems In Custom Map Editor");
		}
		
	}
}