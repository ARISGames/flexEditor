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

import org.arisgames.editor.components.RequirementsEditorObjectComboBoxMX;
import org.arisgames.editor.components.RequirementsEditorRequirementComboBoxMX;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class RequirementsEditorView extends Panel
{
    // Associated Data
    private var requirementObjectId:Number; //The object id to impose requirements
	private var requirementObjectType:String; //One of the REQUIREMENTTYPES defined in constants
	private var edMapOpened:Boolean; 

    // Data For GUI
    [Bindable] public var requirements:ArrayCollection;
    [Bindable] public var reqTypes:ArrayCollection;

    // GUI
    [Bindable] public var reqs:DataGrid;
    [Bindable] public var addRequirementButton:Button;
    [Bindable] public var closeButton:Button;

    /**
     * Constructor
     */
    public function RequirementsEditorView()
    {
        super();
		edMapOpened = false;
        requirements = new ArrayCollection();
        reqTypes = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_REFRESHDATAINREQUIREMENTSEDITOR, handleRefreshRequirementsData);
        reqs.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSavePostUpdate, false, -100);  //for an explanation of the -100 see http://www.adobe.com/devnet/flash/articles/detecting_datagrid_edits.html       
		reqs.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSave);       

        addRequirementButton.addEventListener(MouseEvent.CLICK, handleAddRequirementButton);
        closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
    }

    public function handleRefreshRequirementsData(evt:DynamicEvent):void
    {
        trace("Starting refreshRequirementsData()....");
        requirements.refresh();
    }

	/*
	* Tell this requirements panel what object you want to set requirements for
	*
	*/
    public function setRequirementTypeAndId(t:String, id:Number):void
    {
        this.requirementObjectType = t;
		this.requirementObjectId = id;
        this.reloadTheRequirements();
    }

    private function reloadTheRequirements():void
    {
        AppServices.getInstance().getRequirementsForObject(GameModel.getInstance().game.gameId, this.requirementObjectType , this.requirementObjectId, new Responder(handleLoadRequirements, handleFault));
    }

    public function isPlaceMarkDataLoaded():Boolean
    {
        if (this.requirementObjectType != null && this.requirementObjectType == AppConstants.REQUIREMENTTYPE_LOCATION)
        {
            return true;
        }
        return false;
    }

    public function handleDeleteButtonClick(evt:MouseEvent):void
    {
        trace("handleDeleteButtonClick() called with Selected Index = '" + reqs.selectedIndex + "'");
        AppServices.getInstance().deleteRequirement(GameModel.getInstance().game.gameId, (requirements.getItemAt(reqs.selectedIndex) as Requirement), new Responder(handleDeleteRequirement, handleFault));
    }

    private function handleDeleteRequirement(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad delete requirement attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Deleting Requirement");
        }
        else
        {
            trace("Deletion of Requirement went well in the database, so now removing it from UI datamodel and UI.");
            requirements.removeItemAt(reqs.selectedIndex);
            requirements.refresh();
        }
    }

    private function handleAddRequirementButton(evt:MouseEvent):void
    {
        trace("Add Requirement Button clicked...");
        var r:Requirement = new Requirement();
        r.requirement = AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE;
		r.contentType = this.requirementObjectType;
        r.contentId = this.requirementObjectId;
		r.notOp = "DO";
		r.notOpHuman = "Player Has";
        
        requirements.addItem(r);
        AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleAddRequirementSave, handleFault));
    }

    public function handleDataLineSave(evt:DataGridEvent):void
    {
		var st:String;
		var r:Requirement;
		var origR:String;
		var newR:String;
		var res:Boolean;
		
        if (DataGrid(evt.target).itemEditorInstance is RequirementsEditorRequirementComboBoxMX)
        {
            evt.preventDefault();

            st = RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            r = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            origR = r.requirement;
            newR = AppUtils.convertRequirementHumanLabelToDatabaseLabel(st);

            reqs.destroyItemEditor();

            r.requirement = newR;

            res = requirements.refresh();

            if (origR == newR)
				return;
			
			if (AppUtils.isQtyHavingRequirementType(r))
				r.requirementDetail2 = "1";
			else
				r.requirementDetail2 = "N/A";

            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));

			if(!AppUtils.isObjectsHavingRequirementType(r))
				return;
            else
                reqs.editedItemPosition = {columnIndex: evt.columnIndex + 1, rowIndex: evt.rowIndex};
        }
        else if (DataGrid(evt.target).itemEditorInstance is RequirementsEditorObjectComboBoxMX)
        {
			if (RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem == null || !RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.hasOwnProperty("data"))
				return;
			
            evt.preventDefault();

            st = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            r = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            origR = r.requirementDetail1;
            newR = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.data;

            reqs.destroyItemEditor();

            r.requirementDetail1 = newR;
            r.requirementDetail1Human = st;
           	res = requirements.refresh();

            if(origR == newR) return;

            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));
        }
    }

	public function handleDataLineSavePostUpdate(evt:DataGridEvent):void
	{
		if (!(DataGrid(evt.target).itemEditorInstance is RequirementsEditorRequirementComboBoxMX) ||
			!(DataGrid(evt.target).itemEditorInstance is RequirementsEditorObjectComboBoxMX))
		{
			var r:Requirement = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
			AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));
		}
	}

    private function handleUpdateRequirementSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating Requirement");
        }
    }

    private function handleAddRequirementSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle add / save requirement attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Adding / Save Requirement");
        }
        else
        {
            var rid:Number = obj.result.data;
            trace("Add / Save Requirement was successful.  The Requirement Id returned = '" + rid + "'");

            if (rid != 0)
            {
                trace("Returnned Id was not zero, so going to look through " + requirements.length + " requirements looking for the one with a missing id.");
                for (var j:Number = 0; j < requirements.length; j++)
                {
                    var r:Requirement = requirements.getItemAt(j) as Requirement;
                    trace("&&&&& Checking j = '" + j + "'; Requirement Id = '" + r.requirementId + "'");
                    if (isNaN(r.requirementId))
                    {
                        trace("Found previusly added / saved requirement.  Add Id to it and exiting method.");
                        r.requirementId = rid;
                        requirements.refresh();
                        return;
                    }
                }
            }
        }
    }

    private function handleCloseButton(evt:MouseEvent):void
    {
		PopUpManager.removePopUp(this);

        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    private function handleLoadRequirements(obj:Object):void
    {
        trace("handling load requirements...");
        requirements.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading requirement attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Requirements");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.list.length; j++)
            {
                var r:Requirement = new Requirement();
                r.requirementId = obj.result.data.list.getItemAt(j).requirement_id;
                r.requirement = obj.result.data.list.getItemAt(j).requirement;
				r.boolean = obj.result.data.list.getItemAt(j).boolean_operator;
				r.notOp = obj.result.data.list.getItemAt(j).not_operator;
				if(r.notOp == "DO") r.notOpHuman = "Player Has";
				else if(r.notOp == "NOT") r.notOpHuman = "Player Has Not";
				trace ("loading requirement - boolean was:" + r.boolean);
		
                r.requirementDetail1 = obj.result.data.list.getItemAt(j).requirement_detail_1;
                r.requirementDetail2 = obj.result.data.list.getItemAt(j).requirement_detail_2;
				r.requirementDetail3 = obj.result.data.list.getItemAt(j).requirement_detail_3;
				r.requirementDetail4 = obj.result.data.list.getItemAt(j).requirement_detail_4;
                r.contentId = obj.result.data.list.getItemAt(j).content_id;
                r.contentType = obj.result.data.list.getItemAt(j).content_type;
                requirements.addItem(r);
            }
            trace("Loaded '" + requirements.length + "' Requirement(s).");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems In Requirements Editor");
    }
}
}