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

import org.arisgames.editor.components.RequirementsEditorMapMX;
import org.arisgames.editor.components.RequirementsEditorObjectComboBoxMX;
import org.arisgames.editor.components.RequirementsEditorRequirementComboBoxMX;
import org.arisgames.editor.data.PlaceMark;
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

    private var requirementsEditorMap:RequirementsEditorMapMX;

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
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_OPENREQUIREMENTSEDITORMAP, handleOpenRequirementEditMapDynamicEvent);
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITORMAP, closeRequirementsEditorMapView);
        reqs.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, handleDataEditBeginning);
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

    public function handleDataEditBeginning(evt:DataGridEvent):void
    {
        trace("RequirementEditorView: handleDataEditBeginning()....");
        var r:Requirement = reqs.selectedItem as Requirement;

        if ((AppUtils.isUploadMediaItemRequirementType(r) || !AppUtils.isObjectsHavingRequirementType(r)) && evt.columnIndex != 4)
        {
            trace("RequirementEditorView: This requirement does not require objects, so stop the itemEditor from being setup.");
            ///evt.preventDefault();
        }
        else
        {
            trace("RequirementEditorView: This requirement is not Uploaded Media Item, so let the event continue to be processed.");
        }
    }

    public function handleDataLineSave(evt:DataGridEvent):void
    {
        trace("RequirementEditorView: handleDataLineSave() called with DataGridEvent type = '" + evt.type + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "'");

		var st:String;
		var r:Requirement;
		var origR:String;
		var newR:String;
		var res:Boolean;
		
        if (DataGrid(evt.target).itemEditorInstance is RequirementsEditorRequirementComboBoxMX)
        {
            trace("RequirementEditorView: It's a Requirement ComboBox, so process accordingly.");
            // Disable copying data back to the control.
            evt.preventDefault();

            // Get new requirement from editor.
            st = RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            trace("RequirementEditorView: Height Of Row = '" + reqs.rowHeight + "'; Req Editor Height = '" + RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).height + "'");
            trace("RequirementEditorView: Width Of Column = '" + reqs.columnWidth + "'; Req Editor Width = '" + RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).width + "'");

            r = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            origR = r.requirement;
            newR = AppUtils.convertRequirementHumanLabelToDatabaseLabel(st);

            // Close the cell editor.
            reqs.destroyItemEditor();

            // Update the new data choice
            r.requirement = newR;

            // Notify the list control to update its display.
            res = requirements.refresh();

            if (origR == newR)
            {
                trace("RequirementEditorView: The 'new' requirement is the same as the 'old' one, so no need to update the data nor save it to the database.... just return.");
                return;
            }
			
			//Check if Qty should be used
			if (AppUtils.isQtyHavingRequirementType(r))
			{
				trace("RequirementEditorView: This requirement uses QTY");
				r.requirementDetail2 = "1";
			}
			else
			{
				trace("RequirementEditorView: This requirement does NOT use QTY");
				r.requirementDetail2 = "N/A";
			}

            trace("RequirementEditorView: A new requirement was selected, so save it to the database");
            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));

            // Renderer The Germane Editor So That The Event Will Be Received
            if (AppUtils.isUploadMediaItemRequirementType(r))
            {
                trace("RequirementEditorView: The requirement was just changed to Upload Media Item, so popup the Requirements Editor Map.");
                this.openRequirementsEditorMapView(r);
            }
			else if (!AppUtils.isObjectsHavingRequirementType(r))
			{
				trace("RequirementEditorView: The requirement is not Upload Media Item, and has no objects, so just return");
				return;
			}
            else
            {
                trace("RequirementEditorView: The requirement is not Upload Media Item, so just highlight the regular Object column.");
                reqs.editedItemPosition = {columnIndex: evt.columnIndex + 1, rowIndex: evt.rowIndex};
            }
        }
        else if (DataGrid(evt.target).itemEditorInstance is RequirementsEditorObjectComboBoxMX)
        {
            trace("RequirementEditorView: It's an Object ComboBox, so process accordingly.");
			if (RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem == null || !RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.hasOwnProperty("data")) {
				trace("RequirementEditorView: It's null. Return");
				return;
			}
			
            evt.preventDefault();

            // Get new requirement from editor for renderer to display
            st = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            r = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            origR = r.requirementDetail1;
            newR = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.data;
            trace("RequirementEditorView: New Object Value Chosen For Requirement Id = '" + r.requirementId + "' In Editor; Original Object = '" + origR + "'; New Object (Value) = '" + newR + "'; New Requirement (Editor) = '" + st + "'");

            // Close the cell editor.
            reqs.destroyItemEditor();

            // Update the new data choice
            r.requirementDetail1 = newR;
            r.requirementDetail1Human = st;

            // Notify the list control to update its display.
           	res = requirements.refresh();

            if (origR == newR)
            {
                trace("RequirementEditorView: The 'new' chosen object is the same as the 'old' one, so no need to update the data nor save it to the database.... just return.");
                return;
            }

            trace("RequirementEditorView: A new object was selected, so save it to the database.");
            AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));
        }
        else
        {
            trace("RequirementEditorView: It's not a Requirement nor an Object Combo Box Editor, so ignore until post update");  
        }
    }

	public function handleDataLineSavePostUpdate(evt:DataGridEvent):void
	{
		trace("RequirementEditorView: handleDataLineSavePostUpdate() called with DataGridEvent type = '" + evt.type + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "'");

		if (!(DataGrid(evt.target).itemEditorInstance is RequirementsEditorRequirementComboBoxMX) ||
			!(DataGrid(evt.target).itemEditorInstance is RequirementsEditorObjectComboBoxMX))
		{
			trace("RequirementEditorView: It's not a Requirement nor an Object Combo Box Editor, so just save it as is.");  
			var r:Requirement = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
			AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleUpdateRequirementSave, handleFault));
			
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
            else
            {
                trace("Returned Id was zero, so this method is done.");
            }
        }
    }

    private function handleCloseButton(evt:MouseEvent):void
    {
        trace("Close button clicked...");
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

    private function handleOpenRequirementEditMapDynamicEvent(evt:DynamicEvent):void
    {
        trace("handleOpenRequirementEditMapDynamicEvent() called...");
        this.openRequirementsEditorMapView(reqs.selectedItem as Requirement);
    }
    
    private function openRequirementsEditorMapView(r:Requirement):void
    {
        if (r == null)
        {
            trace("Null requirement passed into openRequirementsEditorMapView, just going to return without opening Requirements Editor Map.");
            return;
        }

        trace("openRequirementsEditorMapView() called for Requirement with ID = '" + r.requirementId + "'");
        requirementsEditorMap = new RequirementsEditorMapMX();
        requirementsEditorMap.requirement = r;
        if (r.requirementDetail1 != null && r.requirementDetail2 != null)
        {
            requirementsEditorMap.setPlacemarkLocation(parseFloat(r.requirementDetail3), parseFloat(r.requirementDetail4), 0);
		}
        else
        {
			var pm:PlaceMark = new PlaceMark();// = GameModel.getInstance().game.placeMarks.getItemAt(0) as PlaceMark;
			
			//Set zoom to inital placemark
			//requirementsEditorMap.setPlacemarkLocation(pm.latitude, pm.longitude, 0);
			
			//Set zoom to map
			//Sets first datapoint as furthest point in all directions as a base to set boundaries of zoom			
			var furthestNorth:Number = pm.latitude;
			var furthestSouth:Number = pm.latitude;
			var furthestWest:Number = pm.longitude;
			var furthestEast:Number = pm.longitude;
			var avLat:Number = pm.latitude;
			var avLong:Number = pm.longitude;
			
			//Go through all datapoints, finding average lat and long, and furthest distance between points
			for (var j:Number = 1; j < GameModel.getInstance().game.placeMarks.length; j++)
			{
				pm = GameModel.getInstance().game.placeMarks.getItemAt(j) as PlaceMark;
				
				if(pm.latitude > furthestNorth)
					furthestNorth = pm.latitude;
				if(pm.latitude < furthestSouth)
					furthestSouth = pm.latitude;
				if(pm.longitude > furthestEast)
					furthestEast = pm.longitude;
				if(pm.longitude < furthestWest)
					furthestWest = pm.longitude;
				avLat+=pm.latitude;
				avLong+=pm.longitude;
			}
			avLat/=j;
			avLong/=j;
			
			var distance:Number = Math.abs(furthestNorth - furthestSouth);
			distance = Math.max(distance, Math.abs(furthestEast - furthestWest));
			var zoom:Number = 15;
			
			if(distance > 100){
				zoom = 2;
			}
			else if(distance > 50){
				zoom = 3;
			}
			else if(distance > 25){
				zoom = 4;
			}
			else if(distance > 10){
				zoom = 5;
			}
			else if(distance > 5){
				zoom = 6;
			}
			else if(distance > 2){
				zoom = 7;
			}
			else if(distance > 1){
				zoom = 8;
			}
			else if(distance > .5){
				zoom = 9;
			}
			else if(distance > .25){
				zoom = 10;
			}
			else if(distance > .125){
				zoom = 11;
			}
			else if(distance > .075){
				zoom = 12;
			}
			else if(distance > .0375){
				zoom = 13;
			}
			else if(distance > .018525){
				zoom = 14;
			}
			trace("zoom="+zoom+"!");
			
			requirementsEditorMap.setPlacemarkLocation(avLat, avLong, zoom);

			

        }

		if(!edMapOpened){
        	this.parent.addChild(requirementsEditorMap);
			edMapOpened = true;
		}
		
        // Need to validate the display so that entire component is rendered
        requirementsEditorMap.validateNow();

        PopUpManager.addPopUp(requirementsEditorMap, AppUtils.getInstance().getMainView(), true);
        PopUpManager.centerPopUp(requirementsEditorMap);
        requirementsEditorMap.setVisible(true);
        requirementsEditorMap.includeInLayout = true;
    }

    private function closeRequirementsEditorMapView(evt:DynamicEvent):void
    {
        trace("closeRequirementsEditorMapView called...");
        PopUpManager.removePopUp(requirementsEditorMap);
        requirementsEditorMap = null;
    }
}
}