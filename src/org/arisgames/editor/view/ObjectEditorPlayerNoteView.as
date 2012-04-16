package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	import mx.validators.Validator;
	
	import org.arisgames.editor.MainView;
	import org.arisgames.editor.view.MultiMediaPickerMX;
	import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	import org.arisgames.editor.view.PlayerStateChangesEditorMX;
	
	public class ObjectEditorPlayerNoteView extends Panel
	{
		// Data Object
		public var objectPaletteItem:ObjectPaletteItemBO;
		
		// GUI
		[Bindable] public var theName:TextInput;
		[Bindable] public var cancelButton:Button;
		[Bindable] public var saveButton:Button;
		[Bindable] public var hbox:HBox;
		[Bindable] public var multiMedia:MultiMediaPickerMX;		
		
		/**
		 * Constructor
		 */
		public function ObjectEditorPlayerNoteView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("ItemEditorItemView: handleInit");
			saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
			multiMedia.allowAllMediaTypesf(true);
			multiMedia.setDelegate(this);
			this.multiMedia.allowAddMediaf(false);
		}
		
		public function duplicateObject(evt:Event):void {
			AppServices.getInstance().duplicateObject(GameModel.getInstance().game, objectPaletteItem.id, new Responder(handleDupedObject, handleFault));
		}
		
		public function imageListWasUpdated(index:Number, obj:Object, uList:ArrayCollection):void{
			AppServices.getInstance().updatePlayerNoteMediaIndex(objectPaletteItem.playerNote.playerNoteId, obj.id, GameModel.getInstance().game, new Responder(handleUpdatedImageList, handleFault));
		}
		
		public function mediaWasRemoved(index:Number, obj:Object):void {
			AppServices.getInstance().removePlayerNoteMediaIndex(obj.contentId, new Responder(handleRemovedImageList, handleFault));
		}
		
		public function getObjectPaletteItem():ObjectPaletteItemBO
		{
			return objectPaletteItem;
		}
		
		public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
		{
			trace("ObjectEditorPlayerNoteView: Setting objectPaletteItem with name = '" + opi.name);
			objectPaletteItem = opi;
			multiMedia.images = new ArrayCollection();
			multiMedia.namez = new ArrayCollection();
			for(var x:Number = 0; x < objectPaletteItem.playerNote.media.length; x++){
				multiMedia.images.addItem(objectPaletteItem.playerNote.media[x]);
				multiMedia.namez.addItem(objectPaletteItem.playerNote.media[x].name);
			}
			multiMedia.images.refresh();
			multiMedia.namez.refresh();
			multiMedia.pushDataIntoGUI();
			multiMedia.currentLoaded = 0;
			multiMedia.loadImages(0);
			this.pushDataIntoGUI();
		}
		
		private function pushDataIntoGUI():void
		{
			theName.text = objectPaletteItem.playerNote.title;
		}
		
		private function handleCancelButton(evt:MouseEvent):void
		{
			trace("Cancel button clicked...");
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleSaveButton(evt:MouseEvent):void
		{
			trace("ItemEditorItemView: Save button clicked...");
			
			// Save Item Data
			objectPaletteItem.playerNote.title = theName.text;
			AppServices.getInstance().savePlayerNote(GameModel.getInstance().game.gameId, objectPaletteItem.playerNote, new Responder(handleSavePlayerNote, handleFault));
			
			// Save ObjectPaletteItem
			objectPaletteItem.name = objectPaletteItem.playerNote.title;
			AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault))
			
			// Close down the panel
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleSavePlayerNote(obj:Object):void
		{
			trace("ItemEditorItemView: In handleSavePlayerNote() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ItemEditorItemView: Bad save playerNote attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Saving PlayerNote");
			}
			else
			{
				trace("ItemEditorItemView: Save playerNote was successful, wait on saveContent now to close the editor and update the object palette.");
			}
			trace("ItemEditorItemView: Finished with handleSaveCharacter().");
		}
		
		private function handleSaveContent(obj:Object):void
		{
			trace("ItemEditorItemView: In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ItemEditorItemView: Bad save playerNote content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Saving PlayerNote");
			}
			else
			{
				trace("ItemEditorItemView: Save playerNote content was successful, now update the object palette.");
				
				var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
				AppDynamicEventManager.getInstance().dispatchEvent(uop);
			}
			trace("ItemEditorItemView: Finished with handleSaveContent().");
		}
		
		private function handlePlayerInventoryChangeButtonClick(evt:MouseEvent):void
		{
			trace("ItemEditorItemView: Starting handle Open Requirements Button click.");
			this.openPlayerStateChangesEditor();
		}
		
		private function openPlayerStateChangesEditor():void
		{
			var pscEditor:PlayerStateChangesEditorMX = new PlayerStateChangesEditorMX();
			pscEditor.setEventTypeAndId(AppConstants.PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE, objectPaletteItem.objectId);
			
			this.parent.addChild(pscEditor);
			// Need to validate the display so that entire component is rendered
			pscEditor.validateNow();
			
			PopUpManager.addPopUp(pscEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(pscEditor);
			pscEditor.setVisible(true);
			pscEditor.includeInLayout = true;
		}
		
		private function handleUpdatedImageList(obj:Object):void
		{
			trace("ObjectEditorAugBubbleView: In handleSaveAugBubble() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorAugBubbleView: bad update image list attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While updating image list");
			}
			else
			{
				trace("ObjectEditorAugBubbleView:  Update List was successful, wait on saveContent now to close the editor and update the object palette.");
			}
			trace("ObjectEditorAugBubbleView: Finished with handleSaveAugBubble().");
		}
		
		private function handleRemovedImageList(obj:Object):void
		{
			trace("ObjectEditorAugBubbleView: In handleSaveAugBubble() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorAugBubbleView: Bad remove image list attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While removing image list");
			}
			else
			{
				trace("ObjectEditorAugBubbleView:  Remove image lists was successful, wait on saveContent now to close the editor and update the object palette.");
			}
			trace("ObjectEditorAugBubbleView: Finished with handleSaveAugBubble().");
		}
		
		private function handleRecievedMediaList(obj:Object):void
		{
			trace("ObjectEditorAugBubbleView: In handleSaveAugBubble() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorAugBubbleView: Bad remove image list attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While removing image list");
			}
			else
			{
				trace("ObjectEditorAugBubbleView:  Remove image lists was successful, wait on saveContent now to close the editor and update the object palette.");
				multiMedia.images = obj.data;
			}
			trace("ObjectEditorAugBubbleView: Finished with handleSaveAugBubble().");
		}
		
		public function handleDupedObject(obj:Object):void
		{
			trace("In handleDupedObject() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("Bad dub object attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Getting Content For Editor");
			}
			else
			{
				trace("refresh the sideBar");
				var de:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
				AppDynamicEventManager.getInstance().dispatchEvent(de);	
			}
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems Saving PlayerNote");
		}
	}
}