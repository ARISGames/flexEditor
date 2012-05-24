package org.arisgames.editor.view
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.events.DataGridEvent;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.data.arisserver.NoteTag;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	public class NoteTagsEditorView extends Panel
	{
		// Data For GUI
		[Bindable] public var gtNoteTags:ArrayCollection;
		[Bindable] public var ptNoteTags:ArrayCollection;
		
		// GUI
		[Bindable] public var gtdg:DataGrid;
		[Bindable] public var ptdg:DataGrid;
		[Bindable] public var gtheader:Text;
		[Bindable] public var ptheader:Text;
		[Bindable] public var addNoteTagText:TextInput;
		[Bindable] public var addNoteTagButton:Button;
		[Bindable] public var closeButton:Button;

		/**
		 * Constructor
		 */
		public function NoteTagsEditorView()
		{
			super();
			gtNoteTags = new ArrayCollection();
			ptNoteTags = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			gtheader.htmlText = "Note Tags";
			ptheader.htmlText = "Player Created Tags";
			
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			addNoteTagButton.addEventListener(MouseEvent.CLICK, handleAddNoteTagButtonClick);
			
			this.reloadTheNoteTags();
		}
		
		public function handleRefreshNoteTagData(evt:DynamicEvent):void
		{
			trace("NoteTagsEditorView: Starting handleRefreshNoteTagData()....");
			gtNoteTags.refresh();
			ptNoteTags.refresh();
		}
		
		private function reloadTheNoteTags():void
		{
			trace("NoteTagsEditorView: Starting reloadTheNoteTags()....");
			AppServices.getInstance().getNoteTagsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNoteTags, handleFault));
		}
		
		public function handlegtDeleteButtonClick(evt:MouseEvent):void
		{
			trace("NoteTagsEditorView: handleDeleteButtonClick() called with Selected Index = '" + gtdg.selectedIndex + "'");
			AppServices.getInstance().deleteNoteTag(GameModel.getInstance().game.gameId, (gtNoteTags.getItemAt(gtdg.selectedIndex) as NoteTag), new Responder(handlegtDeleteNoteTag, handleFault));
		}
		
		public function handleptDeleteButtonClick(evt:MouseEvent):void
		{
			trace("NoteTagsEditorView: handleDeleteButtonClick() called with Selected Index = '" + ptdg.selectedIndex + "'");
			AppServices.getInstance().deleteNoteTag(GameModel.getInstance().game.gameId, (ptNoteTags.getItemAt(ptdg.selectedIndex) as NoteTag), new Responder(handleptDeleteNoteTag, handleFault));
		}
		
		private function handlegtDeleteNoteTag(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete note tag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Note Tag");
			}
			else
			{
				trace("Deletion of NoteTag went well in the database, so now removing it from UI datamodel and UI.");
				gtNoteTags.removeItemAt(gtdg.selectedIndex);
				gtNoteTags.refresh();
				this.reloadTheNoteTags();
			}
		}
		
		private function handleptDeleteNoteTag(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete note tag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Note Tag");
			}
			else
			{
				trace("Deletion of NoteTag went well in the database, so now removing it from UI datamodel and UI.");
				ptNoteTags.removeItemAt(ptdg.selectedIndex);
				ptNoteTags.refresh();
				this.reloadTheNoteTags();
			}
		}
		
		private function handleAddNoteTagButtonClick(evt:MouseEvent):void
		{
			trace("Add NoteTag Button clicked...");
			if(addNoteTagText.text != "")
			var n:NoteTag = new NoteTag(0, addNoteTagText.text, 0);
			gtNoteTags.addItem(n);
			AppServices.getInstance().addNoteTag(GameModel.getInstance().game.gameId, n, new Responder(handleAddNoteTagSave, handleFault));
			gtNoteTags.refresh();
		}

		private function handleUpdateNoteTagSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad update NoteTag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Updating NoteTag");
			}
			else trace("Update NoteTag was successful.");
		}
		
		
		private function handleAddNoteTagSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle add / save note tag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Adding / Save NoteTag");
			}
			else
			{
				trace("Add / Save NoteTag was successful.");
				this.reloadTheNoteTags();
			}
		}
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("Close button clicked...");
			
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSENOTETAGSEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleLoadNoteTags(obj:Object):void
		{
			trace("handling load noteTags...");
			gtNoteTags.removeAll();
			ptNoteTags.removeAll();
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle loading noteTags attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Quests");
			}
			else
			{
				for (var j:Number = 0; j < obj.result.data.length; j++)
				{
					var n:NoteTag = new NoteTag(obj.result.data[j].tag_id, obj.result.data[j].tag, obj.result.data[j].player_created);
					if(n.player_created)
						ptNoteTags.addItem(n);
					else
						gtNoteTags.addItem(n);
				}
				trace("Loaded '" + gtNoteTags.length + "' NoteTag(s), and '" + ptNoteTags.length + "' player tags.");
			}

			gtNoteTags.refresh();
			ptNoteTags.refresh();
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems In NoteTag Editor");
		}
		
	}
}