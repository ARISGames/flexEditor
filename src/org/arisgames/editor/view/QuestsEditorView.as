package org.arisgames.editor.view
{
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.DataGrid;
import mx.events.DataGridEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;

import org.arisgames.editor.data.arisserver.Quest;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class QuestsEditorView extends Panel
{
    // Data For GUI
    [Bindable] public var quests:ArrayCollection;

    // GUI
    [Bindable] public var dg:DataGrid;
    [Bindable] public var addQuestButton:Button;
    [Bindable] public var closeButton:Button;
	
	[Bindable] public var up:Button;
	[Bindable] public var down:Button;

	private var requirementsEditor:RequirementsEditorMX;

    /**
     * Constructor
     */
    public function QuestsEditorView()
    {
        super();
        quests = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
		closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);

		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_REFRESHDATAINQUESTSEDITOR, handleRefreshQuestData);
		dg.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSave, false, -100);  //for an explanation of the -100 see http://www.adobe.com/devnet/flash/articles/detecting_datagrid_edits.html       
		addQuestButton.addEventListener(MouseEvent.CLICK, handleAddQuestButton);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR, closeRequirementsEditor);
		this.reloadTheQuests();
    }
	
	public function handleUpPressed(evt:Event):void{
		if(dg.selectedIndex > 0 && dg.selectedIndex < quests.length){
			AppServices.getInstance().switchQuestOrder(GameModel.getInstance().game.gameId, (quests.getItemAt(dg.selectedIndex) as Quest).questId, (quests.getItemAt(dg.selectedIndex-1) as Quest).questId, new Responder(handleSwitchedSortPosUp, handleFault));
			trace("up");
		}
	}
	
	public function handleDownPressed(evt:Event):void{
		if(dg.selectedIndex >= 0 && dg.selectedIndex < quests.length-1){
			AppServices.getInstance().switchQuestOrder(GameModel.getInstance().game.gameId, (quests.getItemAt(dg.selectedIndex) as Quest).questId, (quests.getItemAt(dg.selectedIndex+1) as Quest).questId, new Responder(handleSwitchedSortPosDown, handleFault));
			trace("down");
		}
	}

    public function handleRefreshQuestData(evt:DynamicEvent):void
    {
        trace("QuestsEditorView: Starting handleRefreshQuestData()....");
        quests.refresh();
    }

    private function reloadTheQuests():void
    {
		trace("QuestsEditorView: Starting reloadTheQuests()....");
        AppServices.getInstance().getQuestsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadQuests, handleFault));
    }

	public function handleRequiementsForVisableButtonClick(evt:MouseEvent):void
	{
		trace("QuestsEditorView: handleRequirementsForActiveButtonClick() called with Selected Index = '" + dg.selectedIndex + "'");
		this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_QUESTDISPLAY);

	}

	public function handleRequirementsForCompleteButtonClick(evt:MouseEvent):void
	{
		trace("QuestsEditorView: handleRequirementsForCompleteButtonClick() called with Selected Index = '" + dg.selectedIndex + "'");
		this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_QUESTCOMPLETE);
	}	
	
	private function openRequirementsEditor(requirementType:String):void
	{
		requirementsEditor = new RequirementsEditorMX();
		var q:Quest = (quests.getItemAt(dg.selectedIndex) as Quest);
		requirementsEditor.setRequirementTypeAndId(requirementType, q.questId);//TODO: Make this depend on the col

		this.parent.addChild(requirementsEditor);
		
		// Need to validate the display so that entire component is rendered
		requirementsEditor.validateNow();
		
		PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(requirementsEditor);
		requirementsEditor.setVisible(true);
		requirementsEditor.includeInLayout = true;
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
        AppServices.getInstance().deleteQuest(GameModel.getInstance().game.gameId, (quests.getItemAt(dg.selectedIndex) as Quest), new Responder(handleDeleteQuest, handleFault));
    }

    private function handleDeleteQuest(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad delete requirement attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Deleting Quest");
        }
        else
        {
            trace("Deletion of Quest went well in the database, so now removing it from UI datamodel and UI.");
			
			var sel:Number = dg.selectedIndex;
			quests.removeItemAt(sel);
			for(var x:Number = sel; x < quests.length; x++){
				quests.getItemAt(x).index = x;
				AppServices.getInstance().saveQuest(GameModel.getInstance().game.gameId, quests.getItemAt(x) as Quest, new Responder(handleUpdateQuestSave, handleFault));
			}
			quests.refresh();
        }
    }

    private function handleAddQuestButton(evt:MouseEvent):void
    {
        trace("Add Quest Button clicked...");
        var q:Quest = new Quest();
        q.title = "New Quest";
		q.index = quests.length;
        quests.addItem(q);
        AppServices.getInstance().saveQuest(GameModel.getInstance().game.gameId, q, new Responder(handleAddQuestSave, handleFault));
    }

    public function handleDataLineSave(evt:DataGridEvent):void
    {
		var q:Quest = (quests.getItemAt(dg.selectedIndex) as Quest);

        trace("QuestEditorView: handleDataLineSave() called with DataGridEvent type = '" + evt.type + "'; DataField = '" + evt.dataField + "'; Data = '" + data + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "' Quest Id is '" + q.questId + "'");

		AppServices.getInstance().saveQuest(GameModel.getInstance().game.gameId, q, new Responder(handleUpdateQuestSave, handleFault));
		quests.refresh();
			
	
    }

    private function handleUpdateQuestSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad update quest attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating Quest");
        }
        else trace("Update Quest was successful.");
          
    }

	
    private function handleAddQuestSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle add / save quest attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Adding / Save Quest");
        }
        else
        {
            var qid:Number = obj.result.data;
            trace("Add / Save Quest was successful.  The Quest Id returned = '" + qid + "'");

            if (qid != 0)
            {
                trace("Returnned Id was not zero, so going to look through " + quests.length + " requirements looking for the one with a missing id.");
                for (var j:Number = 0; j < quests.length; j++)
                {
                    var q:Quest = quests.getItemAt(j) as Quest;
                    trace("&&&&& Checking j = '" + j + "'; Quest Id = '" + q.questId + "'");
                    if (isNaN(q.questId))
                    {
                        trace("Found previously added / saved quest.  Add ID to it and exiting method.");
                        q.questId = qid;
                        quests.refresh();
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
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEQUESTSEDITOR);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleLoadQuests(obj:Object):void
    {
        trace("handling load quests...");
        quests.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading quest attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Quests");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.list.length; j++)
            {
                var q:Quest = new Quest();
                q.questId = obj.result.data.list.getItemAt(j).quest_id;
                q.title = obj.result.data.list.getItemAt(j).name;
                q.activeText = obj.result.data.list.getItemAt(j).description;
                q.completeText = obj.result.data.list.getItemAt(j).text_when_complete;
				q.activeMediaId = obj.result.data.list.getItemAt(j).active_media_id;
				q.completeMediaId = obj.result.data.list.getItemAt(j).complete_media_id;
				q.activeIconMediaId = obj.result.data.list.getItemAt(j).active_icon_media_id;
				q.completeIconMediaId = obj.result.data.list.getItemAt(j).complete_icon_media_id;
				q.fullScreenNotification = obj.result.data.list.getItemAt(j).full_screen_notify;
				q.index = j;
				if(q.index != obj.result.data.list.getItemAt(j).sort_index) AppServices.getInstance().saveQuest(GameModel.getInstance().game.gameId, q, new Responder(handleUpdateQuestSave, handleFault));
                quests.addItem(q);
            }
            trace("Loaded '" + quests.length + "' Quest(s).");
        }
    }

	private function handleSwitchedSortPosUp(obj:Object):void {
		trace("QuestsEditorView: In handleSwitchedSortPosUp() Result called with obj = " + obj + "; Result = " + obj.result);
		if (obj.result.returnCode != 0)
		{
			trace("QuestsEditorView: Bad switch content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("QuestsEditorView: Error Was: " + msg, "Error While Saving Quest");
		}
		else
		{
			var sel:Number = dg.selectedIndex;
			quests.getItemAt(sel).index = sel-1;
			quests.getItemAt(sel-1).index = sel;
			quests.addItemAt(quests.removeItemAt(sel), sel-1);
			quests.refresh();
			//dg.selectedIndex = sel-1;
		}
	}
	
	private function handleSwitchedSortPosDown(obj:Object):void {
		trace("QuestsEditorView: In handleSwitchedSortPosDown() Result called with obj = " + obj + "; Result = " + obj.result);
		if (obj.result.returnCode != 0)
		{
			trace("QuestsEditorView: Bad switch content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("QuestsEditorView: Error Was: " + msg, "Error While Saving Quest");
		}
		else
		{
			var sel:Number = dg.selectedIndex;
			quests.getItemAt(sel).index = sel+1;
			quests.getItemAt(sel+1).index = sel;
			quests.addItemAt(quests.removeItemAt(sel), sel+1);
			quests.refresh();
			//dg.selectedIndex = sel+1;
		}
	}
	
    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);

		Alert.show("Error occurred: " + obj.message, "Problems In Quests Editor");
    }

}
}