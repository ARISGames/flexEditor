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
import org.arisgames.editor.data.arisserver.RequirementType;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;

public class RequirementsEditorBooleanComboBoxView extends VBox implements IDropInListItemRenderer
{
    // GUI
    [Bindable] public var cbo:ComboBox;

    private var _listData:DataGridListData;
    // Define a property for returning the new value to the cell.
    [Bindable] public var value:Object;

    /**
     * Constructor
     */
    public function RequirementsEditorBooleanComboBoxView()
    {
        super();
    }
	
	// Implement the drawFocus() method for the VBox.
	override public function drawFocus(draw:Boolean):void {
		cbo.setFocus();
	}
	 
	override public function get data():Object {
		return super.data;
	}
	
	override public function set data(value:Object):void {
		cbo.data=value[_listData.dataField];
	}
	
	public function get listData():BaseListData
	{
		return _listData;
	}
	
	public function set listData(value:BaseListData):void
	{
		_listData = DataGridListData(value);
	}

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems In Requirements Boolean Editor");
    }
}
}