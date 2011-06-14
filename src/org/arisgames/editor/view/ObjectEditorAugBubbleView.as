package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
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
	
	public class ObjectEditorAugBubbleView extends Panel
	{
		// Data Object
		private var objectPaletteItem:ObjectPaletteItemBO;
		
		// GUI
		[Bindable] public var theName:TextInput;
		[Bindable] public var description:TextArea;
		[Bindable] public var cancelButton:Button;
		[Bindable] public var saveButton:Button;
		[Bindable] public var hbox:HBox;
		[Bindable] public var mediaDisplay:ItemEditorMediaDisplayMX;
		
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
			saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
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
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems Saving AugBubble");
		}
	}
}