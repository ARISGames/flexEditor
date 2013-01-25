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
	
	import org.arisgames.editor.data.arisserver.Item;
	import org.arisgames.editor.data.arisserver.ItemTag;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	public class ItemTagsEditorView extends Panel
	{
		public var gameItemTagsData:ArrayCollection;
		public var itemTagsData:ArrayCollection;
		
		// Data For GUI
		[Bindable] public var gameItemTags:ArrayCollection;
		
		// GUI
		[Bindable] public var dg:DataGrid;
		[Bindable] public var header:Text;
		[Bindable] public var addItemTagText:TextInput;
		[Bindable] public var addItemTagButton:Button;
		[Bindable] public var closeButton:Button;

		private var reloadBatchRecievedCount:int;
		public var item:Item;
		
		/**
		 * Constructor
		 */
		public function ItemTagsEditorView()
		{
			super();
			gameItemTags = new ArrayCollection();
			gameItemTagsData = new ArrayCollection();
			itemTagsData = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			header.htmlText = "Item Tags";
			
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			addItemTagButton.addEventListener(MouseEvent.CLICK, handleAddItemTagButtonClick);
			
			this.reloadTheItemTags();
		}
		
		public function handleRefreshItemTagData(evt:DynamicEvent):void
		{
			trace("ItemTagsEditorView: Starting handleRefreshItemTagData()....");
			gameItemTags.refresh();
		}
		
		private function reloadTheItemTags():void
		{
			trace("ItemTagsEditorView: Starting reloadTheItemTags()....");
			reloadBatchRecievedCount = 0;
			AppServices.getInstance().getTagsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadGameItemTagsData, handleFault));
			AppServices.getInstance().getTagsByItemId(this.item.itemId, new Responder(handleLoadItemItemTagsData, handleFault));
		}
		
		public function handleDeleteButtonClick(evt:MouseEvent):void
		{
			trace("ItemTagsEditorView: handleDeleteButtonClick() called with Selected Index = '" + dg.selectedIndex + "'");
			AppServices.getInstance().deleteTagById(GameModel.getInstance().game.gameId, (gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tag_id, new Responder(handleDeleteItemTag, handleFault));
		}
		
		public function handleTagClick(evt:MouseEvent):void
		{
			trace("ItemTagsEditorView: handleTagClick() called with Selected Index = '" + dg.selectedIndex + "'");
			if(dg.selectedIndex < 0 || dg.selectedIndex > gameItemTags.length-1) return;
			if((gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tagged == "x")
				AppServices.getInstance().untagItem(GameModel.getInstance().game.gameId, item.itemId, (gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tag_id, new Responder(handleTagItemTag, handleFault));
			else
				AppServices.getInstance().tagItem(GameModel.getInstance().game.gameId, item.itemId, (gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tag_id, new Responder(handleTagItemTag, handleFault));
		}
		
		private function handleTagItemTag(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad tag Item tag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Item Tag");
			}
			else
			{
				trace("tagging of ItemTag went well in the database, so now update it from UI datamodel and UI.");
				if(dg.selectedIndex < 0 || dg.selectedIndex > gameItemTags.length-1) return;
/*
				if((gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tagged == "x")
					(gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tagged = "";
				else
					(gameItemTags.getItemAt(dg.selectedIndex) as ItemTag).tagged = "x";
*/
				this.reloadTheItemTags();
			}
		}
		
		private function handleDeleteItemTag(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad delete Item tag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Deleting Item Tag");
			}
			else
			{
				trace("Deletion of ItemTag went well in the database, so now removing it from UI datamodel and UI.");
				gameItemTagsData.removeItemAt(dg.selectedIndex);
				gameItemTagsData.refresh();
				compileItemTagsForList();
				this.reloadTheItemTags();
			}
		}
		
		private function handleAddItemTagButtonClick(evt:MouseEvent):void
		{
			trace("Add ItemTag Button clicked...");
			if(addItemTagText.text != "")
			var n:ItemTag = new ItemTag(0, addItemTagText.text);
			n.tagged = "x"
			gameItemTags.addItem(n);
			AppServices.getInstance().addItemTag(GameModel.getInstance().game.gameId, n, new Responder(handleAddItemTagSave, handleFault));
			gameItemTags.refresh();
		}

		private function handleUpdateItemTagSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad update ItemTag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Updating ItemTag");
			}
			else trace("Update ItemTag was successful.");
		}
		
		
		private function handleAddItemTagSave(obj:Object):void
		{
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle add / save Item tag attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Adding / Save ItemTag");
			}
			else
			{
				trace("Add / Save ItemTag was successful.");
				AppServices.getInstance().tagItem(GameModel.getInstance().game.gameId, item.itemId, obj.result.data, new Responder(handleTagItemTag, handleFault));
			}
		}
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("Close button clicked...");
			
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEITEMTAGSEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function handleLoadGameItemTagsData(obj:Object):void
		{
			trace("handling load ItemTags...");
			gameItemTagsData.removeAll();
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle loading ItemTags attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Quests");
			}
			else
			{
				for (var j:Number = 0; j < obj.result.data.length; j++)
				{
					var n:ItemTag = new ItemTag(obj.result.data[j].tag_id, obj.result.data[j].name);
					gameItemTagsData.addItem(n);
				}
			}

			gameItemTagsData.refresh();
			
			reloadBatchRecievedCount++;
			if(reloadBatchRecievedCount >= 2)
				compileItemTagsForList();
		}
		
		private function handleLoadItemItemTagsData(obj:Object):void
		{
			reloadBatchRecievedCount++;
			trace("handling load ItemTags...");
			itemTagsData.removeAll();
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle loading ItemTags attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Quests");
			}
			else
			{
				for (var j:Number = 0; j < obj.result.data.length; j++)
				{
					var n:ItemTag = new ItemTag(obj.result.data[j].tag_id, obj.result.data[j].name);
					itemTagsData.addItem(n);
				}
			}
			
			itemTagsData.refresh();
			
			reloadBatchRecievedCount++;
			if(reloadBatchRecievedCount >= 2)
				compileItemTagsForList();
		}
		
		private function compileItemTagsForList():void
		{
			gameItemTags.removeAll();
			for (var i:Number = 0; i < gameItemTagsData.length; i++)
				gameItemTags.addItem(gameItemTagsData.getItemAt(i));
			for (i = 0; i < gameItemTagsData.length; i++)
			{
				for (var j:Number = 0; j < itemTagsData.length; j++)
				{
					if((gameItemTagsData.getItemAt(i) as ItemTag).tag_id == (itemTagsData.getItemAt(j) as ItemTag).tag_id)
						(gameItemTags.getItemAt(i) as ItemTag).tagged = "x";
				}
			}
			
			gameItemTags.refresh();
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems In ItemTag Editor");
		}
	}
}