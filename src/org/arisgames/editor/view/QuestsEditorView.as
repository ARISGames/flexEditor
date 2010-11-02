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
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_REFRESHDATAINQUESTSEDITOR, handleRefreshQuestData);
        addQuestButton.addEventListener(MouseEvent.CLICK, handleAddQuestButton);
        closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
		this.reloadTheQuests();
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
            quests.removeItemAt(dg.selectedIndex);
            quests.refresh();
        }
    }

    private function handleAddQuestButton(evt:MouseEvent):void
    {
        trace("Add Quest Button clicked...");
        var q:Quest = new Quest();
        q.title = "New Quest";
        quests.addItem(q);
        AppServices.getInstance().saveQuest(GameModel.getInstance().game.gameId, q, new Responder(handleAddQuestSave, handleFault));
    }

	/*
    public function handleDataEditBeginning(evt:DataGridEvent):void
    {
        trace("RequirementsEditor.handleDataEditBeginning()....");
        var r:Requirement = reqs.selectedItem as Requirement;

        if (AppUtils.isUploadMediaItemRequirementType(r))
        {
            trace("This requirement is an Uploaded Media Item, so stop the itemEditor from being setup.");
            evt.preventDefault();
        }
        else
        {
            trace("This requirement is not Uploaded Media Item, so let the event continue to be processed.");
        }
    }

    public function handleDataLineSave(evt:DataGridEvent):void
    {
        trace("handleDataLineSave() called with DataGridEvent type = '" + evt.type + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "'");

		var st:String;
		var r:Requirement;
		var origR:String;
		var newR:String;
		var res:Boolean;
		
        if (DataGrid(evt.target).itemEditorInstance is RequirementsEditorRequirementComboBoxMX)
        {
            trace("It's a Requirement ComboBox, so process accordingly.");
            // Disable copying data back to the control.
            evt.preventDefault();

            // Get new requirement from editor.
            st = RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            trace("Height Of Row = '" + reqs.rowHeight + "'; Req Editor Height = '" + RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).height + "'");
            trace("Width Of Column = '" + reqs.columnWidth + "'; Req Editor Width = '" + RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).width + "'");

            r = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            origR = r.requirement;
            newR = AppUtils.convertRequirementHumanLabelToDatabaseLabel(st);
            trace("New Value Chosen For Requirement Id = '" + r.requirementId + "' In Editor; Original Requirement = '" + origR + "'; New Requirement (Database) = '" + newR + "'; New Requirement (Editor) = '" + st + "'");

            // Close the cell editor.
            reqs.destroyItemEditor();

            // Update the new data choice
            r.requirement = newR;

            // Notify the list control to update its display.
            res = requirements.refresh();
            trace("Successful refresh? '" + res + "'");
//        reqs.dataProvider.itemUpdated(evt.itemRenderer.data);


            if (origR == newR)
            {
                trace("The 'new' requirement is the same as the 'old' one, so no need to update the data nor save it to the database.... just return.");
                return;
            }

            trace("A new requirement was selected, so save it to the database and clear all old details that may have been in the database record.");
            r.requirementDetail1 = null;
            r.requirementDetail2 = null;
            r.requirementDetail3 = null;
            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));

            // Renderer The Germane Editor So That The Event Will Be Received
            if (r.requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE)
            {
                trace("The requirement was just changed to Upload Media Item, so popup the Requirements Editor Map.");
                this.openRequirementsEditorMapView(r);
            }
            else
            {
                trace("The requirement is not Upload Media Item, so just highlight the regular Object column.");
                reqs.editedItemPosition = {columnIndex: evt.columnIndex + 1, rowIndex: evt.rowIndex};
            }
        }
        else if (DataGrid(evt.target).itemEditorInstance is RequirementsEditorObjectComboBoxMX)
        {
            trace("It's an Object ComboBox, so process accordingly.");
            evt.preventDefault();

            // Get new requirement from editor for renderer to display
            st = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            r = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            origR = r.requirementDetail1;
            newR = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.data;
            trace("New Object Value Chosen For Requirement Id = '" + r.requirementId + "' In Editor; Original Object = '" + origR + "'; New Object (Value) = '" + newR + "'; New Requirement (Editor) = '" + st + "'");

            // Close the cell editor.
            reqs.destroyItemEditor();

            // Update the new data choice
            r.requirementDetail1 = newR;
            r.requirementDetail1Human = st;

            // Notify the list control to update its display.
           	res = requirements.refresh();
            trace("Successful refresh? '" + res + "'");
//        reqs.dataProvider.itemUpdated(evt.itemRenderer.data);

            if (origR == newR)
            {
                trace("The 'new' chosen object is the same as the 'old' one, so no need to update the data nor save it to the database.... just return.");
                return;
            }

            trace("A new object was selected, so save it to the database.");
            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));
        }
        else
        {
            trace("It's not a Requirement nor an Object Combo Box Editor, so ignore.");            
        }
    }

    private function handleUpdateRequirementSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad update requirement attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating Requirement");
        }
        else
        {
            var rid:Number = obj.result.data;
            if (rid == 1)
            {
                trace("Update Requirement was successful.  The Requirement Id returned = '" + rid + "'");
            }
            else
            {
                Alert.show("The database had a problem while updating this record.  Please try again.", "Database Error While Updating Requirement");
            }
        }
    }
*/
	
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
                        trace("Found previusly added / saved quest.  Add Id to it and exiting method.");
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
                q.iconMediaId = obj.result.data.list.getItemAt(j).icon_media_id;
                quests.addItem(q);
            }
            trace("Loaded '" + quests.length + "' Quest(s).");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems In Quests Editor");
    }

}
}