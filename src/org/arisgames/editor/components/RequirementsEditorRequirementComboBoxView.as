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

public class RequirementsEditorRequirementComboBoxView extends VBox implements IDropInListItemRenderer
{
    // GUI
    [Bindable] public var cbo:ComboBox;
    [Bindable] public var reqTypes:ArrayCollection;

    private var _listData:DataGridListData;
    // Define a property for returning the new value to the cell.
    [Bindable] public var value:Object;

    /**
     * Constructor
     */
    public function RequirementsEditorRequirementComboBoxView()
    {
        super();
        reqTypes = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
//        cbo.addEventListener(ListEvent.CHANGE, handleComboBoxChange);
        // Load Requirement Types
        AppServices.getInstance().getRequirementTypeOptions(GameModel.getInstance().game.gameId, new Responder(handleLoadRequirementTypes, handleFault));
    }

    override public function get data():Object
    {
        return super.data;
    }

    override public function set data(value:Object):void
    {
        trace("set data called with value = '" + value + "'; what will be assigned = '" + value[_listData.dataField] + "'");
        cbo.data = value[_listData.dataField];
        this.updateComboBoxSelectedItem();
    }

    private function updateComboBoxSelectedItem():void
    {
        trace("in updateComboBoxSelectedItem(), looking for RequirementType object to match = '" + cbo.data + "'");
        for (var j:Number = 0; j < reqTypes.length; j++)
        {
            var rt:RequirementType = reqTypes.getItemAt(j) as RequirementType;
            trace("j = '" + j + "'; RT's Human Label = '" + rt.humanLabel + "'");
            if (cbo.data == rt.humanLabel)
            {
                trace("Found the RequirementType that matched, now setting ComboBox's selectedItem to it.");
                cbo.selectedItem = rt;
                return;
            }
        }
    }

    public function get listData():BaseListData
    {
        return _listData;
    }

    public function set listData(value:BaseListData):void
    {
        trace("setListData() called with value = '" + value + "'");
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
        return "";        
    }

    public function set text(value:String):void
    {
        trace("set text() called with value = '" + value + "'");
    }

/*
    private function handleComboBoxChange(evt:ListEvent):void
    {
        trace("cbo's handleComboBoxChange() called; Column Index = '" + evt.columnIndex + "'; Row Index = '" + evt.rowIndex + "'; Text of cbo = '" + cbo.text + "'; Value Of cbo = '" + cbo.value + "'");
    }
*/

    private function handleLoadRequirementTypes(obj:Object):void
    {
        trace("handling load requirement types...");
        reqTypes.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading requirement types attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Requirement Types");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.length; j++)
            {
                var to:RequirementType = new RequirementType();

                switch (obj.result.data[j] as String)
                {
                    case AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE:
                            to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_HUMAN;
                            break;
                    case AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE:
                            to.humanLabel = AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_HUMAN;
                            break;
                    case AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE:
                            to.humanLabel = AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_HUMAN;
                            break;
                    case AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE:
                            to.humanLabel = AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_HUMAN;
                            break;
                    case AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE:
                            to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_HUMAN;
                            break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_DATABASE:
                            to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_HUMAN;
                            break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_VIEWED_WEBPAGE_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_VIEWED_WEBPAGE_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_HUMAN;
						break;
					case AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_LIKES_DATABASE:
						to.humanLabel = AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_LIKES_HUMAN;
						break;
                    default:
                            trace("1 default in case statement in load requirement types for '" + (obj.result.data[j] as String) + "'");
                            to.humanLabel = obj.result.data[j];
                            break;
                }
                to.databaseLabel = obj.result.data[j];
                reqTypes.addItem(to);
            }
            // Update ComboBox due to Asynchronous loading of data
            this.updateComboBoxSelectedItem();

            trace("Loaded '" + reqTypes.length + "' Requirement Type(s).");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems In Requirements Editor");
    }
}
}