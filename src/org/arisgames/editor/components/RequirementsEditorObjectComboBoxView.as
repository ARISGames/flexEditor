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

public class RequirementsEditorObjectComboBoxView extends VBox implements IDropInListItemRenderer
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
    public function RequirementsEditorObjectComboBoxView()
    {
        super();
        possibleObjects = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in RequirementsEditorObjectComboBoxView's handleInit");
    }

    override public function get data():Object
    {
        trace("RequirementsEditorObjectComboBoxView.getData() called.  Returning = '" + super.data + "'");
        return super.data;
    }

    override public function set data(value:Object):void
    {
        trace("RequirementsEditorObjectComboBoxView.setData() called with value = '" + value + "'");
        super.data = value;
        var req:Requirement = value as Requirement;
//        trace("What will be assigned = '" + value[_listData.dataField] + "'; The Requirement Id = '" + req.requirementId + "'; The Requirement = '" + req.requirement + "'");
        trace("What will be assigned (new) = '" + req.requirementDetail1 + "'; The Requirement Id = '" + req.requirementId + "'; The Requirement = '" + req.requirement + "'");

        // Reload PossibleObjects
//        cbo.data = value[_listData.dataField];
        cbo.data = req.requirementDetail1;
        this.loadPossibleObjectsBasedOnRequirement(req.requirement);
    }

    public function get listData():BaseListData
    {
        trace("RequirementsEditorObjectComboBoxView.getListData called.  Returning = '" + _listData + "'");
        return _listData;
    }

    public function set listData(value:BaseListData):void
    {
        trace("RequirementsEditorObjectComboBoxView.setListData() called with value = '" + value + "'");
        //        _listData = (value as DataGridListData);
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

    public function loadPossibleObjectsBasedOnRequirement(req:String):void
    {
        trace("loadPossibleObjectsBasedOnRquirement() called with req = '" + req + "'");

        if (req == null)
        {
            trace("req passed in is null, can't load any objects based off of it.");
            return;
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE)
        {
            trace("going to load items - 1");
            AppServices.getInstance().getItemsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadItems, handleFault));
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE)
        {
            trace("going to load items - 2");
            AppServices.getInstance().getItemsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadItems, handleFault));
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_DATABASE)
        {
            trace("going to load nodes - 3");
            AppServices.getInstance().getPagesByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNodes, handleFault));
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_DATABASE)
        {
            trace("going to load npc - 4");
            AppServices.getInstance().getCharactersByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNPCs, handleFault));
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE)
        {
            trace("Upload Media option selected... editor will need to be reconfigured here to support different data model.");
        }
        else
        {
            trace("Should never have gotten this far, but if it does there's not going to be any objects loaded.");
        }
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

    private function handleLoadNodes(obj:Object):void
    {
        trace("handling load Nodes...");
        possibleObjects.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading possible nodes attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Possible Nodes");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.length; j++)
            {
                var to:Object = new Object();
                to.label = obj.result.data[j].title;
                to.data = obj.result.data[j].node_id;
                possibleObjects.addItem(to);
            }
            possibleObjects.refresh();
            this.updateComboBoxSelectedItem();
            trace("Loaded '" + possibleObjects.length + "' Possible Nodes Object(s).");
        }
    }

    private function handleLoadNPCs(obj:Object):void
    {
        trace("handling load NPCs...");
        possibleObjects.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading possible NPCs attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Possible NPCs");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.length; j++)
            {
                var to:Object = new Object();
                to.label = obj.result.data[j].name;
                to.data = obj.result.data[j].npc_id;
                possibleObjects.addItem(to);
            }
            possibleObjects.refresh();
            this.updateComboBoxSelectedItem();
            trace("Loaded '" + possibleObjects.length + "' Possible NPC Object(s).");
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