package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.NumericStepper;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.rpc.Responder;
	import mx.validators.Validator;
	
	import org.arisgames.editor.components.ItemEditorMediaDisplayMX;
	import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	
	//			delegate.imageListWasUpdated(this.selectedIndex, images[selectedIndex], this.images);
	//			delegate.mediaWasRemoved(selectedIndex, images[selectedIndex]);

	public class ObjectEditorAugBubbleView extends Panel
	{
		// Data Object
		public var objectPaletteItem:ObjectPaletteItemBO;
		
		// GUI
		[Bindable] public var theName:TextInput;
		[Bindable] public var description:TextArea;
		[Bindable] public var cancelButton:Button;
		[Bindable] public var saveButton:Button;
		[Bindable] public var hbox:HBox;
		[Bindable] public var mediaDisplay:ItemEditorMediaDisplayMX;
		[Bindable] public var multiMedia:MultiMediaPickerMX;
		
		[Bindable] public var v1:Validator;
		[Bindable] public var v2:Validator;
		
		/**
		 * Constructor
		 */
		public function ObjectEditorAugBubbleView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("ObjectEditorAugBubbleView: handleInit");
			multiMedia.setDelegate(this);
			saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		}
		
		public function imageListWasUpdated(index:Number, obj:Object, uList:ArrayCollection):void{
			AppServices.getInstance().updateAugBubbleMediaIndex(objectPaletteItem.augBubble.augBubbleId, obj.id, GameModel.getInstance().game, index, new Responder(handleUpdatedImageList, handleFault));
		}
		
		public function mediaWasRemoved(index:Number, obj:Object):void {
			AppServices.getInstance().removeAugBubbleMediaIndex(objectPaletteItem.augBubble.augBubbleId, obj.id, index, new Responder(handleRemovedImageList, handleFault));
		}
		
		public function getObjectPaletteItem():ObjectPaletteItemBO
		{
			return objectPaletteItem;
		}
		
		public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
		{
			trace("ObjectEditorAugBubbleView: Setting objectPaletteItem with name = '" + opi.name);
			objectPaletteItem = opi;
			mediaDisplay.setObjectPaletteItem(opi);
			multiMedia.images = new ArrayCollection();
			multiMedia.namez = new ArrayCollection();
			for(var x:Number = 0; x < objectPaletteItem.augBubble.media.length; x++){
				multiMedia.images.addItem(objectPaletteItem.augBubble.media[x]);
				multiMedia.namez.addItem(objectPaletteItem.augBubble.media[x].name);
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
			var obj:Object = objectPaletteItem;
			theName.text = objectPaletteItem.augBubble.name;
			description.text = objectPaletteItem.augBubble.desc;
		}
		
		private function isFormValid():Boolean
		{
			return (Validator.validateAll([v1, v2]).length == 0)
		}
		
		private function handleCancelButton(evt:MouseEvent):void
		{
			trace("ObjectEditorAugBubbleView: Cancel button clicked...");
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleSaveButton(evt:MouseEvent):void
		{
			trace("ObjectEditorAugBubbleView: Save button clicked...");
			
			if (!isFormValid())
			{
				trace("ItemEditorItemView: Form is not valid, stop save processing.");
				return;
			}
			
			// Save Item Data
			objectPaletteItem.augBubble.name = theName.text;
			objectPaletteItem.augBubble.desc = description.text;
			
			AppServices.getInstance().saveAugBubble(GameModel.getInstance().game.gameId, objectPaletteItem.augBubble, new Responder(handleSaveAugBubble, handleFault));
			
			// Save ObjectPaletteItem
			objectPaletteItem.name = objectPaletteItem.augBubble.name;
			AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault))
			
			// Close down the panel
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
			
		}
		
		private function handleSaveAugBubble(obj:Object):void
		{
			trace("ObjectEditorAugBubbleView: In handleSaveAugBubble() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorAugBubbleView: Bad save web page attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Saving Web Page");
			}
			else
			{
				trace("ObjectEditorAugBubbleView:  Save web page was successful, wait on saveContent now to close the editor and update the object palette.");
			}
			trace("ObjectEditorAugBubbleView: Finished with handleSaveAugBubble().");
		}
		
		private function handleSaveContent(obj:Object):void
		{
			trace("ObjectEditorAugBubbleView: In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorAugBubbleView: Bad save item content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Saving Item");
			}
			else
			{
				trace("ObjectEditorAugBubbleView: Save item content was successful, now update the object palette.");
				
				var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
				AppDynamicEventManager.getInstance().dispatchEvent(uop);
			}
			trace("ItemEditorItemView: Finished with handleSaveContent().");
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
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems Saving AugBubble");
		}
	}
}