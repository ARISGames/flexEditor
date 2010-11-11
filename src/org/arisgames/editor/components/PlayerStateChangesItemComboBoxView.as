package org.arisgames.editor.components
{
import mx.collections.ArrayCollection;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.data.arisserver.PlayerStateChange;

public class PlayerStateChangesItemComboBoxView extends VBox implements IDropInListItemRenderer
{
    // GUI
    [Bindable] public var cbo:ComboBox;
    [Bindable] public var possibleObjects:ArrayCollection;

    private var _listData:DataGridListData;
    // Define a property for returning the new value to the cell.
    [Bindable] public var value:Object;

    /**
     * Constructor
     */
    public function PlayerStateChangesItemComboBoxView()
    {
        super();
		trace("PSCEditorObjectComboBoxView's constructor");

        possibleObjects = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("PSCEditorObjectComboBoxView's handleInit");
		this.loadPossibleItems();
    }
/*	
	override public function set data(value:Object):void
	{
		trace("set data called with value = '" + value + "'; what will be assigned = '" + value[_listData.dataField] + "'");
		cbo.data = value[_listData.dataField];
		//textLabel.text = value[_listData.dataField];
		this.updateComboBoxSelectedItem();
	}
*/
	
	override public function get data():Object
	{
		return super.data;
	}
	
	override public function set data(value:Object):void
	{
		trace("PlayerStateChangedItemComboBox:setData() called with value = '" + value + "'");
		super.data = value;
		var psc:PlayerStateChange = value as PlayerStateChange;
		trace("PlayerStateChangedItemComboBox: data will be set to:" + psc.actionDetail);
		
		cbo.data = psc.actionDetail;
		this.updateComboBoxSelectedItem();
	}

	
	
	
	
	
    public function get listData():BaseListData
    {
        trace("getListData called.  Returning = '" + _listData + "'");
        return _listData;
    }

    public function set listData(value:BaseListData):void
    {
        trace("setListData() called with value = '" + value + "'");
        _listData = DataGridListData(value);
    }

    public function get text():String
    {
       
		if (value != null)
        {
            trace("Value doesn't equal null, so return a value.  value = '" + value.toString() + "'");            
			return value.toString();
        }
        trace("No Text To Return");
        return "No Text To Return";
    }

    public function set text(value:String):void
    {
        trace("set text() called with value = '" + value + "'");
    }

    public function loadPossibleItems():void
    {
        trace("loadPossibleItems() called");

  		trace("going to load items - 1");
        AppServices.getInstance().getItemsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadItems, handleFault));
    }

    private function handleLoadItems(obj:Object):void
    {
        trace("handling load items...");
        possibleObjects.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading possible items attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Possible Items");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.length; j++)
            {
                var to:Object = new Object();
                to.label = obj.result.data[j].name;
                to.data = obj.result.data[j].item_id;
                possibleObjects.addItem(to);
            }
            possibleObjects.refresh();
            this.updateComboBoxSelectedItem();
            trace("Loaded '" + possibleObjects.length + "' Possible Item Object(s).");
        }
    }


    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems In Requirements Editor");
    }

    private function updateComboBoxSelectedItem():void
    {
        trace("in updateComboBoxSelectedItem(), looking for Object to match = '" + cbo.data + "'");
        for (var j:Number = 0; j < possibleObjects.length; j++)
        {
            var o:Object = possibleObjects.getItemAt(j);
            trace("j = '" + j + "'; cbo.data = '" + cbo.data + "'; Object Id (o.data) = '" + o.data + "'; Object's Human Label (o.label) = '" + o.label + "'");
            if (cbo.data == o.label || cbo.data == o.data)
            {
                trace("Found the Object that matched, now setting ComboBox's selectedItem to it.");
                cbo.selectedItem = o;
                return;
            }
        }
    }
}
}