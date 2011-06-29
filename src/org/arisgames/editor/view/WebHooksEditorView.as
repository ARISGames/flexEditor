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
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.data.arisserver.WebHook;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	public class WebHooksEditorView extends Panel
	{
		// Data For GUI
		[Bindable] public var incomingWebHooks:ArrayCollection;
		[Bindable] public var outgoingWebHooks:ArrayCollection;
		
		// GUI
		[Bindable] public var inDg:DataGrid;
		[Bindable] public var outDg:DataGrid;

		[Bindable] public var addInWebHookButton:Button;
		[Bindable] public var addOutWebHookButton:Button;
		
		[Bindable] public var inHead:Text;
		[Bindable] public var outHead:Text;

		[Bindable] public var inDesc:Text;
		[Bindable] public var outDesc:Text;

		[Bindable] public var closeButton:Button;
		
		public var persistUrl:String;
		public var persistIndex:Number;
		
		private var requirementsEditor:RequirementsEditorMX;
		
		/**
		 * Constructor
		 */
		public function WebHooksEditorView()
		{
			super();
			incomingWebHooks = new ArrayCollection();
			outgoingWebHooks = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			outHead.htmlText = "Outgoing Web Hooks";
			inHead.htmlText = "Incoming Web Hooks";
			
			inDesc.htmlText = "<font color=\"#FF0000\">*</font>The outside world can communicate with ARIS via 'Incoming Web Hooks'. A URL is provided for a machine of your chosing to 'ping' when you want <br />a requirement to be set. An example of this could be setting up a physical button that can be pressed to finish a Quest.<font color=\"#FF0000\"></font>";
			outDesc.htmlText = "<font color=\"#FF0000\">*</font>ARIS communicates with the outside world via 'Outgoing Web Hooks'. Set the url to an address that will be 'ping'ed when the requirements set <br />for it are first fulfilled. An example of this could be setting a monitor to display a video when a user finishes a Quest.<font color=\"#FF0000\"></font>";

			
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			
			addInWebHookButton.addEventListener(MouseEvent.CLICK, handleAddInWebHookButtonClick);
			addOutWebHookButton.addEventListener(MouseEvent.CLICK, handleAddOutWebHookButtonClick);

			inDg.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, handleBeginEdit);
			inDg.addEventListener(DataGridEvent.ITEM_FOCUS_OUT, handleEndEdit);
			
			outDg.addEventListener(DataGridEvent.ITEM_FOCUS_OUT, handleOutEndEdit);
			
			AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR, closeRequirementsEditor);

			this.reloadTheWebHooks();
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
			var w:WebHook = (outgoingWebHooks.getItemAt(outDg.selectedIndex) as WebHook);
			requirementsEditor.setRequirementTypeAndId(requirementType, w.webHookId);//TODO: Make this depend on the col
			
			this.parent.addChild(requirementsEditor);
			
			// Need to validate the display so that entire component is rendered
			requirementsEditor.validateNow();
			
			PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(requirementsEditor);
			requirementsEditor.setVisible(true);
			requirementsEditor.includeInLayout = true;
		}
		
		public function handleBeginEdit(evt:DataGridEvent):void {
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
		}
		
		
		
		public function handleRefreshWebHookData(evt:DynamicEvent):void
		{
			trace("WebHooksEditorView: Starting handleRefreshWebHookData()....");
			incomingWebHooks.refresh();
			outgoingWebHooks.refresh();
		}
		
		private function reloadTheWebHooks():void
		{
			trace("WebHooksEditorView: Starting reloadTheWebHooks()....");
			AppServices.getInstance().getWebHooksByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadWebHooks, handleFault));
		}
		
		public function handleInDeleteButtonClick(evt:MouseEvent):void
		{
			trace("WebHooksEditorView: handleDeleteButtonClick() called with Selected Index = '" + inDg.selectedIndex + "'");
			AppServices.getInstance().deleteWebHook(GameModel.getInstance().game.gameId, ((incomingWebHooks.getItemAt(inDg.selectedIndex) as WebHook).webHookId), new Responder(handleInDeleteWebHook, handleFault));
		}
		
		public function handleOutDeleteButtonClick(evt:MouseEvent):void
		{
			trace("WebHooksEditorView: handleDeleteButtonClick() called with Selected Index = '" + outDg.selectedIndex + "'");
			AppServices.getInstance().deleteWebHook(GameModel.getInstance().game.gameId, ((outgoingWebHooks.getItemAt(outDg.selectedIndex) as WebHook).webHookId), new Responder(handleOutDeleteWebHook, handleFault));
		}
		
		public function handleRequirementsButtonClick(evt:MouseEvent):void
		{
			trace("WebHooksEditorView: handleRequirementsButtonClick() called with Selected Index = '" + outDg.selectedIndex + "'");
			this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_WEBHOOK);
		}
		
		private function handleInDeleteWebHook(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete web hook attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Web Hook");
			}
			else
			{
				trace("Deletion of WebHook went well in the database, so now removing it from UI datamodel and UI.");
				incomingWebHooks.removeItemAt(inDg.selectedIndex);
				incomingWebHooks.refresh();
			}
		}
		
		
		private function handleOutDeleteWebHook(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete web hook attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Web Hook");
			}
			else
			{
				trace("Deletion of WebHook went well in the database, so now removing it from UI datamodel and UI.");
				outgoingWebHooks.removeItemAt(outDg.selectedIndex);
				outgoingWebHooks.refresh();
			}
		}
		
		private function handleAddInWebHookButtonClick(evt:MouseEvent):void
		{
			trace("Add WebHook Button clicked...");
			var w:WebHook;
			w = new WebHook("Incoming WebHook", 0, AppConstants.APPLICATION_ENVIRONMENT_JSON_SERVICES_URL + "webhooks.setWebHookReq/" + GameModel.getInstance().game.gameId + "/" + "/" + 0 + "/{player id}", true);
			incomingWebHooks.addItem(w);
			AppServices.getInstance().saveWebHook(GameModel.getInstance().game.gameId, w, new Responder(handleAddInWebHookSave, handleFault));
		}
		
		private function handleAddOutWebHookButtonClick(evt:MouseEvent):void
		{
			trace("Add WebHook Button clicked...");
			var w:WebHook;
			w = new WebHook("Outgoing WebHook", 0, "(insert URL to ping here)", false);
			var noSpaceName:String = w.name.split(" ").join("");
			w.appendage = "?hook=" + noSpaceName + "&wid=" + w.webHookId + "&gameid=" + GameModel.getInstance().game.gameId + "&playerid=" + "{player id}";			outgoingWebHooks.addItem(w);
			AppServices.getInstance().saveWebHook(GameModel.getInstance().game.gameId, w, new Responder(handleAddOutWebHookSave, handleFault));
		}
		

		private function handleUpdateWebHookSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad update WebHook attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Updating WebHook");
			}
			else trace("Update WebHook was successful.");
		}
		
		
		private function handleAddInWebHookSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle add / save web hook attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Adding / Save WebHook");
			}
			else
			{
				var wid:Number = obj.result.data;
				trace("Add / Save WebHook was successful.  The WebHook Id returned = '" + wid + "'");
				
				if (wid != 0)
				{
					trace("Returned Id was not zero, so going to look through " + incomingWebHooks.length + " requirements looking for the one with a missing id.");
					for (var j:Number = 0; j < incomingWebHooks.length; j++)
					{
						var w:WebHook = incomingWebHooks.getItemAt(j) as WebHook;
						trace("&&&&& Checking j = '" + j + "'; WebHook Id = '" + w.webHookId + "'");
						if (isNaN(w.webHookId) || w.webHookId == 0)
						{
							trace("Found previously added / saved WebHook.  Add ID to it and exiting method.");
							w.webHookId = wid;
							w.url = AppConstants.APPLICATION_ENVIRONMENT_JSON_SERVICES_URL + "webhooks.setWebHookReq/" + GameModel.getInstance().game.gameId + "/" + w.webHookId + "/" + 0 + "/{player id}";
							AppServices.getInstance().saveWebHook(GameModel.getInstance().game.gameId, w, new Responder(handleUpdateWebHookSave, handleFault));
							incomingWebHooks.refresh();
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
		
		
		
		
		private function handleAddOutWebHookSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle add / save web hook attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Adding / Save WebHook");
			}
			else
			{
				var wid:Number = obj.result.data;
				trace("Add / Save WebHook was successful.  The WebHook Id returned = '" + wid + "'");
				
				if (wid != 0)
				{
					trace("Returned Id was not zero, so going to look through " + outgoingWebHooks.length + " requirements looking for the one with a missing id.");
					for (var j:Number = 0; j < outgoingWebHooks.length; j++)
					{
						var w:WebHook = outgoingWebHooks.getItemAt(j) as WebHook;
						trace("&&&&& Checking j = '" + j + "'; WebHook Id = '" + w.webHookId + "'");
						if (isNaN(w.webHookId) || w.webHookId == 0)
						{
							trace("Found previously added / saved WebHook.  Add ID to it and exiting method.");
							w.webHookId = wid;
							AppServices.getInstance().saveWebHook(GameModel.getInstance().game.gameId, w, new Responder(handleUpdateWebHookSave, handleFault));
							outgoingWebHooks.refresh();
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
			for each(var hook:WebHook in outgoingWebHooks){
				trace("Saving outgoing web hook: " + hook.name);
				AppServices.getInstance().saveWebHook(GameModel.getInstance().game.gameId, hook, new Responder(handleUpdateWebHookSave, handleFault));
			}
			for each(hook in incomingWebHooks){
				trace("Saving incoming web hook: " + hook.name);
				AppServices.getInstance().saveWebHook(GameModel.getInstance().game.gameId, hook, new Responder(handleUpdateWebHookSave, handleFault));
			}
			
			
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEWEBHOOKSEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleLoadWebHooks(obj:Object):void
		{
			trace("handling load webHooks...");
			incomingWebHooks.removeAll();
			outgoingWebHooks.removeAll();
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle loading webHooks attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Quests");
			}
			else
			{
				incomingWebHooks = new ArrayCollection();
				outgoingWebHooks = new ArrayCollection();
				for (var j:Number = 0; j < obj.result.data.list.length; j++)
				{
					var w:WebHook = new WebHook("", 0, "", true);
					w.name = obj.result.data.list.getItemAt(j).name;
					w.webHookId = obj.result.data.list.getItemAt(j).web_hook_id;
					w.url = obj.result.data.list.getItemAt(j).url;
					w.incoming = obj.result.data.list.getItemAt(j).incoming;
					if(w.incoming){
						w.url = AppConstants.APPLICATION_ENVIRONMENT_JSON_SERVICES_URL + "webhooks.setWebHookReq/" + GameModel.getInstance().game.gameId + "/" + w.webHookId +  "/" + 0 + "/{player id}";
						incomingWebHooks.addItem(w);
					}
					else{
						var noSpaceName:String = w.name.split(" ").join("");
						w.appendage = "?hook=" + noSpaceName + "&wid=" + w.webHookId + "&gameid=" + GameModel.getInstance().game.gameId + "&playerid=" + "{player id}";
						outgoingWebHooks.addItem(w);
					}
				}
				trace("Loaded '" + incomingWebHooks.length + "' incomingWebHook(s) + " + outgoingWebHooks.length + " outgoingWebHooks(s).");
			}

			incomingWebHooks.refresh();
			outgoingWebHooks.refresh();
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			
			Alert.show("Error occurred: " + obj.message, "Problems In Web Hook Editor");
		}
		
	}
}