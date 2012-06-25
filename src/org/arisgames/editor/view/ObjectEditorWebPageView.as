package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.Label;
	import mx.controls.NumericStepper;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.rpc.Responder;
	import mx.validators.Validator;
	import mx.managers.PopUpManager;

	
	import org.arisgames.editor.components.ItemEditorMediaDisplayMX;
	import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppUtils;
	import org.arisgames.editor.util.AppDynamicEventManager;
	
	public class ObjectEditorWebPageView extends Panel
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
		[Bindable] public var spawnablePopupButton:Button;

		
		[Bindable] public var appendage:Label;
		
		[Bindable] public var v1:Validator;
		[Bindable] public var v2:Validator;
		
		private var spawnablePopup:SpawnableEditorMX;

		
		/**
		 * Constructor
		 */
		public function ObjectEditorWebPageView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("ObjectEditorWebPageView: handleInit");
			saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
			appendage.text = "?gameId=" + GameModel.getInstance().game.gameId + "&webPageId=playerId={the player's id}";
			spawnablePopupButton.addEventListener(MouseEvent.CLICK, handleSpawnableButton);
		}
		
		private function handleSpawnableButton(evt:MouseEvent):void
		{
			trace("ObjectEditorItemView: handleSpawnableButton() called...");
			spawnablePopup = new SpawnableEditorMX();
			spawnablePopup.setObjectPaletteItem(objectPaletteItem);
			spawnablePopup.delegate = this;
			this.spawnablePopupButton.label = "Edit Spawn Settings";
			PopUpManager.addPopUp(spawnablePopup, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(spawnablePopup);
		}
		
		public function duplicateObject(evt:Event):void {
			AppServices.getInstance().duplicateObject(GameModel.getInstance().game, objectPaletteItem.id, new Responder(handleDupedObject, handleFault));
		}
		
		public function getObjectPaletteItem():ObjectPaletteItemBO
		{
			return objectPaletteItem;
		}
		
		public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
		{
			trace("ObjectEditorWebPageView: Setting objectPaletteItem with name = '" + opi.name);
			objectPaletteItem = opi;
			appendage.text = "?gameId=" + GameModel.getInstance().game.gameId + "&webPageId="+this.objectPaletteItem.objectId+"playerId={the player's id}";
			if(opi.isSpawnable) this.spawnablePopupButton.label = "Edit Spawn Settings";
			mediaDisplay.setObjectPaletteItem(opi);
			this.pushDataIntoGUI();
		}
		
		private function pushDataIntoGUI():void
		{
			var obj:Object = objectPaletteItem;
			theName.text = objectPaletteItem.webPage.name;
			description.text = objectPaletteItem.webPage.url;
		}
		
		private function isFormValid():Boolean
		{
			return (Validator.validateAll([v1, v2]).length == 0)
		}
		
		private function handleCancelButton(evt:MouseEvent):void
		{
			trace("ObjectEditorWebPageView: Cancel button clicked...");
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleSaveButton(evt:MouseEvent):void
		{
			trace("ObjectEditorWebPageView: Save button clicked...");
			
			if (!isFormValid())
			{
				trace("ItemEditorItemView: Form is not valid, stop save processing.");
				return;
			}
			
			// Save Item Data
			objectPaletteItem.webPage.name = theName.text;
			objectPaletteItem.webPage.url = description.text;
			
			AppServices.getInstance().saveWebPage(GameModel.getInstance().game.gameId, objectPaletteItem.webPage, new Responder(handleSaveWebPage, handleFault));
			
			// Save ObjectPaletteItem
			objectPaletteItem.name = objectPaletteItem.webPage.name;
			AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault))
			
			// Close down the panel
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
			
		}
		
		private function handleSaveWebPage(obj:Object):void
		{
			trace("ObjectEditorWebPageView: In handleSaveWebPage() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorWebPageView: Bad save web page attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Saving Web Page");
			}
			else
			{
				trace("ObjectEditorWebPageView:  Save web page was successful, wait on saveContent now to close the editor and update the object palette.");
			}
			trace("ObjectEditorWebPageView: Finished with handleSaveWebPage().");
		}
		
		private function handleSaveContent(obj:Object):void
		{
			trace("ObjectEditorWebPageView: In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("ObjectEditorWebPageView: Bad save item content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Saving Item");
			}
			else
			{
				trace("ObjectEditorWebPageView: Save item content was successful, now update the object palette.");
				
				var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
				AppDynamicEventManager.getInstance().dispatchEvent(uop);
			}
			trace("ItemEditorItemView: Finished with handleSaveContent().");
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
			Alert.show("Error occurred: " + obj.message, "Problems Saving WebPage");
		}
	}
}