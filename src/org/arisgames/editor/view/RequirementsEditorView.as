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
    private var theData:Object;

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
        reqs.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSave);
        addRequirementButton.addEventListener(MouseEvent.CLICK, handleAddRequirementButton);
        closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);

        // Load Requirement Types
//        AppServices.getInstance().getRequirementTypeOptions(GameModel.getInstance().game.gameId, new Responder(handleLoadRequirementTypes, handleFault));
    }

    public function handleRefreshRequirementsData(evt:DynamicEvent):void
    {
        trace("Starting refreshRequirementsData()....");
        requirements.refresh();
    }

    public function getTheData():Object
    {
        return theData;
    }

    public function setTheData(value:Object):void
    {
        this.theData = value;
        this.reloadTheRequirements();
    }

    private function reloadTheRequirements():void
    {
        var contentType:String;
        var contentId:Number;
        if (theData instanceof PlaceMark)
        {
            contentType = AppConstants.REQUIREMENTTYPE_LOCATION;
            contentId = (theData as PlaceMark).id;
        }
        else
        {
            contentType = "";
            contentId = 0;
        }

        AppServices.getInstance().getRequirementsForObject(GameModel.getInstance().game.gameId, contentType, contentId, new Responder(handleLoadRequirements, handleFault));
    }

    public function isPlaceMarkDataLoaded():Boolean
    {
        if (theData != null && theData instanceof PlaceMark)
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
        if (this.isPlaceMarkDataLoaded())
        {
            r.contentType = AppConstants.REQUIREMENTTYPE_LOCATION;
            r.contentId = (theData as PlaceMark).id;
        }
        requirements.addItem(r);
        AppServices.getInstance().saveRequirement(GameModel.getInstance().game.gameId, r, new Responder(handleAddRequirementSave, handleFault));
    }

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

        if (DataGrid(evt.target).itemEditorInstance instanceof RequirementsEditorRequirementComboBoxMX)
        {
            trace("It's a Requirement ComboBox, so process accordingly.");
            // Disable copying data back to the control.
            evt.preventDefault();

            // Get new requirement from editor.
            var st:String = RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            trace("Height Of Row = '" + reqs.rowHeight + "'; Req Editor Height = '" + RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).height + "'");
            trace("Width Of Column = '" + reqs.columnWidth + "'; Req Editor Width = '" + RequirementsEditorRequirementComboBoxMX(DataGrid(evt.target).itemEditorInstance).width + "'");

            var r:Requirement = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            var origR:String = r.requirement;
            var newR:String = AppUtils.convertRequirementHumanLabelToDatabaseLabel(st);
            trace("New Value Chosen For Requirement Id = '" + r.requirementId + "' In Editor; Original Requirement = '" + origR + "'; New Requirement (Database) = '" + newR + "'; New Requirement (Editor) = '" + st + "'");

            // Close the cell editor.
            reqs.destroyItemEditor();

            // Update the new data choice
            r.requirement = newR;

            // Notify the list control to update its display.
            var res:Boolean = requirements.refresh();
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
        else if (DataGrid(evt.target).itemEditorInstance instanceof RequirementsEditorObjectComboBoxMX)
        {
            trace("It's an Object ComboBox, so process accordingly.");
            evt.preventDefault();

            // Get new requirement from editor for renderer to display
            var st:String = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
            reqs.editedItemRenderer.data = st;

            var r:Requirement = (requirements.getItemAt(reqs.selectedIndex) as Requirement);
            var origR:String = r.requirementDetail1;
            var newR:String = RequirementsEditorObjectComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.data;
            trace("New Object Value Chosen For Requirement Id = '" + r.requirementId + "' In Editor; Original Object = '" + origR + "'; New Object (Value) = '" + newR + "'; New Requirement (Editor) = '" + st + "'");

            // Close the cell editor.
            reqs.destroyItemEditor();

            // Update the new data choice
            r.requirementDetail1 = newR;
            r.requirementDetail1Human = st;

            // Notify the list control to update its display.
            var res:Boolean = requirements.refresh();
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
                r.requirementDetail1 = obj.result.data.list.getItemAt(j).requirement_detail_1;
                r.requirementDetail2 = obj.result.data.list.getItemAt(j).requirement_detail_2;
                r.requirementDetail3 = obj.result.data.list.getItemAt(j).requirement_detail_3;
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
/*
        if (evt.requirement != null)
        {
            this.openRequirementsEditorMapView(evt.requirement);
        }
        else
        {
            trace("No Requirement object was passed in with the DynamicEvent, so not going to open the Requirements Editor Map.");
        }
*/
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
        var pm:PlaceMark = theData as PlaceMark;
        if (r.requirementDetail1 != null && r.requirementDetail2 != null)
        {
            requirementsEditorMap.setPlacemarkLocation(parseFloat(r.requirementDetail1), parseFloat(r.requirementDetail2));
        }
        else
        {
            requirementsEditorMap.setPlacemarkLocation(pm.latitude, pm.longitude);
        }

/*
        mediaPicker.setObjectPaletteItem(objectPaletteItem);
        mediaPicker.setIsIconPicker(isIconMode);
*/
        this.parent.addChild(requirementsEditorMap);
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