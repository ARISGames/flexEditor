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

import org.arisgames.editor.data.arisserver.PlayerStateChange;
import org.arisgames.editor.components.PlayerStateChangesItemComboBoxMX;
import org.arisgames.editor.components.PlayerStateChangesEditorActionRendererMX;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class PlayerStateChangesEditorView extends Panel
{
	// Associated Data
	private var eventObjectId:Number; //The object id to impose requirements
	private var eventType:String; //One of the PLAYERSTATECHANGE_EVENTTYPE_ defined in constants
	
	// Data For GUI
    [Bindable] public var pscs:ArrayCollection;

    // GUI
    [Bindable] public var dg:DataGrid;
    [Bindable] public var addButton:Button;
    [Bindable] public var closeButton:Button;

    /**
     * Constructor
     */
    public function PlayerStateChangesEditorView()
    {
        super();
		pscs = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

	public function setEventTypeAndId(t:String, id:Number):void 
	{
		this.eventType = t;
		this.eventObjectId = id;
	}
	
    private function handleInit(event:FlexEvent):void
    {
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR, handleRefreshData);
		dg.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSave);     
		dg.addEventListener(DataGridEvent.ITEM_EDIT_END, handleDataLineSavePostUpdate, false, -100);  //for an explanation of the -100 see http://www.adobe.com/devnet/flash/articles/detecting_datagrid_edits.html       
		addButton.addEventListener(MouseEvent.CLICK, handleAddButton);
        closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
		this.reload();
    }

    public function handleRefreshData(evt:DynamicEvent):void
    {
        trace("PlayerStateChangesEditorView: Starting handleRefreshData()....");
		pscs.refresh();
    }

    private function reload():void
    {
		trace("PlayerStateChangesEditorView: Starting reload().... event type: " + this.eventType + " id: " + this.eventObjectId);
        AppServices.getInstance().getPlayerStateChangesForObject(GameModel.getInstance().game.gameId, this.eventType, this.eventObjectId, new Responder(handleLoad, handleFault));
    }

    public function handleDeleteButtonClick(evt:MouseEvent):void
    {
        trace("PlayerStateChangesEditorView: handleDeleteButtonClick() called with Selected Index = '" + dg.selectedIndex + "'");
        AppServices.getInstance().deletePlayerStateChange(GameModel.getInstance().game.gameId, (pscs.getItemAt(dg.selectedIndex) as PlayerStateChange), new Responder(handleDelete, handleFault));
    }

    private function handleDelete(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad delete PlayerStateChange attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Deleting PlayerStateChange");
        }
        else
        {
            trace("Deletion of PlayerStateChange went well in the database, so now removing it from UI datamodel and UI.");
            pscs.removeItemAt(dg.selectedIndex);
            pscs.refresh();
        }
    }

    private function handleAddButton(evt:MouseEvent):void
    {
        trace("Add Button clicked...");
        var psc:PlayerStateChange = new PlayerStateChange();
		psc.eventType = this.eventType;
		psc.eventDetail = this.eventObjectId;
		psc.action = AppConstants.PLAYERSTATECHANGE_ACTION_GIVEITEM;
		psc.actionAmount = 1;

		pscs.addItem(psc);
        AppServices.getInstance().savePlayerStateChange(GameModel.getInstance().game.gameId, psc, new Responder(handleAddSave, handleFault));
    }

    public function handleDataLineSave(evt:DataGridEvent):void
    {
		trace("handleDataLineSave() called with DataGridEvent type = '" + evt.type + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "'");
		
		var st:String;
		var origPsc:String;
		var newPsc:String;
		var res:Boolean;
		var psc:PlayerStateChange = (pscs.getItemAt(dg.selectedIndex) as PlayerStateChange);

        trace("PlayerStateChangeEditorView: handleDataLineSave() called with DataGridEvent type = '" + evt.type + "'; DataField = '" + evt.dataField + "'; Data = '" + data + "'; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "' Item Renderer = '" + evt.itemRenderer + "' PSC Id is '" + psc.playerStateChangeId + "'");
		
		if (DataGrid(evt.target).itemEditorInstance is PlayerStateChangesItemComboBoxMX)
		{
			trace("PlayerStateChangeEditorView: Item CBO");

			evt.preventDefault();
			
			// Get new requirement from editor for renderer to display
			st = PlayerStateChangesItemComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
			dg.editedItemRenderer.data = st;	
			var newAd:Number = PlayerStateChangesItemComboBoxMX(DataGrid(evt.target).itemEditorInstance).cbo.selectedItem.data;

			// Close the cell editor.
			dg.destroyItemEditor();
			
			// Update the new data choice
			psc.actionDetail = newAd;
			psc.actionDetailHuman = st;
			
			// Notify the list control to update its display.
			pscs.refresh();
	
		}		

		if (DataGrid(evt.target).itemEditorInstance is PlayerStateChangesEditorActionRendererMX)
		{
			trace("PlayerStateChangeEditorView: Event CBO");
			evt.preventDefault();
						
			// Get new requirement from editor for renderer to display
			st = PlayerStateChangesEditorActionRendererMX(DataGrid(evt.target).itemEditorInstance).cbo.text;
			dg.editedItemRenderer.data = st;
			trace("PlayerStateChangeEditorView: st:" + st);

			// Close the cell editor.
			dg.destroyItemEditor();
			
			// Update the new data choice
			psc.actionHuman = st;

			// Notify the list control to update its display.
			pscs.refresh();
			
			
		}		
		

    }
	
	public function handleDataLineSavePostUpdate(evt:DataGridEvent):void
	{
		var psc:PlayerStateChange = (pscs.getItemAt(dg.selectedIndex) as PlayerStateChange);

		AppServices.getInstance().savePlayerStateChange(GameModel.getInstance().game.gameId, psc, new Responder(handleUpdateSave, handleFault));
		pscs.refresh();
	
	}	
	

	

    private function handleUpdateSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad update PSC attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Updating PSC");
        }
        else trace("Update PSC was successful.");
          
    }

	
    private function handleAddSave(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle add / save PSC attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Adding / Save PSC");
        }
        else
        {
            var pscid:Number = obj.result.data;
            trace("Add / Save PSC was successful.  The PSC Id returned = '" + pscid + "'");

            if (pscid != 0)
            {
                trace("Returnned Id was not zero, so going to look through " + pscs.length + " pscs looking for the one with a missing id.");
                for (var j:Number = 0; j < pscs.length; j++)
                {
                    var psc:PlayerStateChange = pscs.getItemAt(j) as PlayerStateChange;
                    trace("&&&&& Checking j = '" + j + "'; PSC Id = '" + psc.playerStateChangeId + "'");
                    if (isNaN(psc.playerStateChangeId))
                    {
                        trace("Found previusly added / saved PSC.  Add Id to it and exiting method.");
                        psc.playerStateChangeId = pscid;
                        pscs.refresh();
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
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR);
        AppDynamicEventManager.getInstance().dispatchEvent(de);
		
		//Just do the close now
		trace("playerStateChanges: handleCloseButton called...");
		PopUpManager.removePopUp(this);
				
    }

    private function handleLoad(obj:Object):void
    {
        trace("handling load pscs...");
        pscs.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading pscs attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading PSCs");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.list.length; j++)
            {
                var psc:PlayerStateChange = AppUtils.parseResultDataIntoPlayerStateChange(obj.result.data.list.getItemAt(j));
                pscs.addItem(psc);
            }
            trace("Loaded '" + pscs.length + "' Player State Changes(s).");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);

		Alert.show("Error occurred: " + obj.message, "Problems In PlayerStateChanges Editor");
    }

}
}