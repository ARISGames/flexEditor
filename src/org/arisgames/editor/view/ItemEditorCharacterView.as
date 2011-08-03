package org.arisgames.editor.view
{
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.containers.HBox;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.DataGrid;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.DataGridEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;
import mx.validators.Validator;

import org.arisgames.editor.components.ItemEditorMediaDisplayMX;
import org.arisgames.editor.data.arisserver.Conversation;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;



public class ItemEditorCharacterView extends Panel
{
    // Data Object
    private var objectPaletteItem:ObjectPaletteItemBO;
	
	// Data For Conversations Table
	[Bindable] public var conversations:ArrayCollection;

    // GUI
    [Bindable] public var theName:TextInput;
    [Bindable] public var description:TextArea;
    [Bindable] public var greeting:TextArea;
	[Bindable] public var closing:TextArea;

    [Bindable] public var cancelButton:Button;
    [Bindable] public var saveButton:Button;
    [Bindable] public var hbox:HBox;
    [Bindable] public var mediaDisplay:ItemEditorMediaDisplayMX;

	//Conversations Area
	[Bindable] public var dg:DataGrid;
	[Bindable] public var addConversationButton:Button;

	//Requirements
	private var requirementsEditor:RequirementsEditorMX;

    [Bindable] public var v1:Validator;
    [Bindable] public var v2:Validator;
    [Bindable] public var v3:Validator;

    /**
     * Constructor
     */
    public function ItemEditorCharacterView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in ItemEditorCharacterView's handleInit");
        //cancelButton.addEventListener(MouseEvent.CLICK, handleCancelButton);
        saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
		
		//Conversations
		conversations = new ArrayCollection();
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_REFRESHDATAINCONVERSATIONS, handleRefreshConversationData);
		dg.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSave, false, -100);  //for an explanation of the -100 see http://www.adobe.com/devnet/flash/articles/detecting_datagrid_edits.html       
		addConversationButton.addEventListener(MouseEvent.CLICK, handleAddConversationButton);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR, closeRequirementsEditor);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_EDITOBJECTPALETTEITEM, handleRefreshConversationData);
    }

	public function handleConversationInventoryButton(evt:MouseEvent):void
	{
	}
	
	
	public function handleRefreshConversationData(evt:DynamicEvent):void
	{
		trace("ItemEditorCharaterView: Starting handleRefreshConversationsData()....");
		conversations.refresh();
	}
	
	public function reloadTheConversations():void
	{
		trace("ItemEditorCharaterView: reloadTheConversations() called");

		if (objectPaletteItem != null) {
			trace("ItemEditorCharaterView: Starting reloadTheConversations() with NpcID:" + objectPaletteItem.objectId);
			AppServices.getInstance().getConversationsForNpc(GameModel.getInstance().game.gameId, objectPaletteItem.objectId, new Responder(handleLoadConversations, handleFault));
		}
	}

	/*
	public function handleRequiementsForActiveButtonClick(evt:MouseEvent):void
	{
		trace("QuestsEditorView: handleRequiementsForActiveButtonClick() called with Selected Index = '" + dg.selectedIndex + "'");
		this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_QUESTDISPLAY);
		
	}
	*/
	
	public function handleConversationRequirementsButton(evt:MouseEvent):void
	{
		trace("QuestsEditorView: handleConversationRequirementsButton() called with Selected Index = '" + dg.selectedIndex + "'");
		this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_NODE);
	}	
	
	private function openRequirementsEditor(requirementType:String):void
	{
		requirementsEditor = new RequirementsEditorMX();
	
		var c:Conversation = (conversations.getItemAt(dg.selectedIndex) as Conversation);

		trace("opening requiements editor with type:" + requirementType + "id:" + c.nodeId);
		requirementsEditor.setRequirementTypeAndId(requirementType, c.nodeId);
		
		this.parent.addChild(requirementsEditor);
		
		// Need to validate the display so that entire component is rendered
		requirementsEditor.validateNow();
		
		PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(requirementsEditor);
		requirementsEditor.setVisible(true);
		requirementsEditor.includeInLayout = true;
		
	}
	
	
	public function handleConversationPlayerStateChangesButton(evt:MouseEvent):void
	{
		trace("CharacterEditorView: handleConversationPlayerStateChangesButton() called with Selected Index = '" + dg.selectedIndex + "'");
		this.openPlayerStateChangesEditor();
	}	
	
	private function openPlayerStateChangesEditor():void
	{
		var playerStateChangesEditor:PlayerStateChangesEditorMX = new PlayerStateChangesEditorMX();
		
		var c:Conversation = (conversations.getItemAt(dg.selectedIndex) as Conversation);
		
		trace("opening psc editor with event type:" + AppConstants.PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE + "id:" + c.nodeId);
		playerStateChangesEditor.setEventTypeAndId(AppConstants.PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE,c.nodeId);
					
		this.parent.addChild(playerStateChangesEditor);
		
		// Need to validate the display so that entire component is rendered
		playerStateChangesEditor.validateNow();
		
		PopUpManager.addPopUp(playerStateChangesEditor, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(playerStateChangesEditor);
		playerStateChangesEditor.setVisible(true);
		playerStateChangesEditor.includeInLayout = true;
		
	}
	
	private function closeRequirementsEditor(evt:DynamicEvent):void
	{
		trace("closeRequirementsEditor called...");
		PopUpManager.removePopUp(requirementsEditor);
		requirementsEditor = null;
	}	
	public function handleDeleteButtonClick(evt:MouseEvent):void
	{
		trace("QuestsEditorView: handleDeleteButtonClick() called with Selected Index = '" + dg.selectedIndex + "'");
		AppServices.getInstance().deleteConversation(GameModel.getInstance().game.gameId, (conversations.getItemAt(dg.selectedIndex) as Conversation), new Responder(handleDeleteConversation, handleFault));
	}
	
	private function handleDeleteConversation(obj:Object):void
	{
		if (obj.result.returnCode != 0)
		{
			trace("Bad delete conversation attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Deleting Conversation");
		}
		else
		{
			trace("Deletion of Conversation went well in the database, so now removing it from UI datamodel and UI.");
			conversations.removeItemAt(dg.selectedIndex);
			conversations.refresh();
		}
	}
	
	private function handleAddConversationButton(evt:MouseEvent):void
	{
		trace("Add Conversation Button clicked...");
		var c:Conversation = new Conversation();
		c.linkText = "New Conversation";
		c.npcId = objectPaletteItem.objectId ; //set the npc id
		conversations.addItem(c);
		AppServices.getInstance().saveConversation(GameModel.getInstance().game.gameId, c, new Responder(handleAddConversationSave, handleFault));
	}
	
	public function handleDataLineSave(evt:DataGridEvent):void
	{
		var c:Conversation = (conversations.getItemAt(dg.selectedIndex) as Conversation);
		
		trace("NpcEditorView: handleDataLineSave() called with DataGridEvent type = '" + evt.type + "'; DataField = '" + evt.dataField + "'; Data = '" + data + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "' Conversation Id is '" + c.conversationId + "'");
		
		AppServices.getInstance().saveConversation(GameModel.getInstance().game.gameId, c, new Responder(handleUpdateConversationSave, handleFault));
		conversations.refresh();
		
		
	}
	
	private function handleUpdateConversationSave(obj:Object):void
	{
		if (obj.result.returnCode != 0)
		{
			trace("Bad update conversation attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Updating Conversation");
		}
		else trace("Update Conversation was successful.");
		
	}
	
	
	private function handleAddConversationSave(obj:Object):void
	{
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle add / save conversation attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Adding / Save Conversation");
		}
		else
		{
			var cid:Number = obj.result.data.conversation_id;
			trace("Add / Save Conversation was successful.  The Conversation Id returned = '" + cid + "'");
			
			if (cid != 0)
			{
				trace("Returnned Id was not zero, so going to look through " + conversations.length + " requirements looking for the one with a missing id.");
				for (var j:Number = 0; j < conversations.length; j++)
				{
					var c:Conversation = conversations.getItemAt(j) as Conversation;
					trace("&&&&& Checking j = '" + j + "'; Conversation Id = '" + c.conversationId + "'");
					if (isNaN(c.conversationId))
					{
						trace("Found previusly added / saved conversation.  Add Id to it and exiting method.");
						c.conversationId = cid;
						c.nodeId = obj.result.data.node_id;
						conversations.refresh();
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
		
	private function handleLoadConversations(obj:Object):void
	{
		trace("handling load conversations...");
		conversations.removeAll();
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle loading conversation attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Convos");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.list.length; j++)
			{
				var c:Conversation = new Conversation();
				c.conversationId = obj.result.data.list.getItemAt(j).conversation_id;
				c.nodeId = obj.result.data.list.getItemAt(j).node_id;
				c.linkText = obj.result.data.list.getItemAt(j).conversation_text;
				c.scriptText = obj.result.data.list.getItemAt(j).text;
				c.index = obj.result.data.list.getItemAt(j).sort_index;
				conversations.addItem(c);
			}
			trace("Loaded '" + conversations.length + "' Conversation(s).");
		}
	}
	
    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorCharacterView");
        objectPaletteItem = opi;
        mediaDisplay.setObjectPaletteItem(opi);
        this.pushDataIntoGUI();
    }

    private function pushDataIntoGUI():void
    {
        trace("pushDataIntoGUI called.");
        theName.text = objectPaletteItem.character.name;
        description.text = objectPaletteItem.character.description;
        greeting.text = objectPaletteItem.character.greeting;
		closing.text = objectPaletteItem.character.closing;
    }

    private function isFormValid():Boolean
    {
        trace("isFormValid has been called...");
        
        return (Validator.validateAll([v1, v2, v3]).length == 0)
    }

    private function handleCancelButton(evt:MouseEvent):void
    {
        trace("ItemEditorCharacterView: Cancel button clicked...");
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleSaveButton(evt:MouseEvent):void
    {
        trace("ItemEditorCharacterView: Save button clicked...");

        if (!isFormValid())
        {
            trace("ItemEditorCharacterView: Form is not valid, stop save processing.");
            return;
        }
        
        // Save Item Data
        objectPaletteItem.character.name = theName.text;
        objectPaletteItem.character.description = description.text;
        objectPaletteItem.character.greeting = greeting.text;
		objectPaletteItem.character.closing = closing.text;
        AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, objectPaletteItem.character, new Responder(handleSaveCharacter, handleFault));

        // Save ObjectPaletteItem
        objectPaletteItem.name = objectPaletteItem.character.name;
        AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, objectPaletteItem, new Responder(handleSaveContent, handleFault));
		
		// Close down the panel
		var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
		AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleSaveCharacter(obj:Object):void
    {
        trace("ItemEditorCharacterView: In handleSaveCharacter() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorCharacterView: Bad save character attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("ItemEditorCharacterView: Error Was: " + msg, "Error While Saving Character");
        }
        else
        {
            trace("ItemEditorCharacterView: Save character was successfull.");
        }
        trace("ItemEditorCharacterView: Finished with handleSaveCharacter().");
    }

    private function handleSaveContent(obj:Object):void
    {
        trace("ItemEditorCharacterView: In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorCharacterView: Bad save character content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("ItemEditorCharacterView: Error Was: " + msg, "Error While Saving Character");
        }
        else
        {
            trace("ItemEditorCharacterView: Save character content was successful.");

            var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
            AppDynamicEventManager.getInstance().dispatchEvent(uop);
        }
        trace("ItemEditorCharacterView: Finished with handleSaveContent().");
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Saving Character");
    }
}
}