package org.arisgames.editor.data.arisserver
{
import mx.controls.Alert;
import mx.events.DynamicEvent;
import mx.rpc.Responder;

import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class Requirement
{
    public var requirementId:Number;
    public var requirement:String;
    public var _requirementDetail1:String;
    public var requirementDetail1Human:String;
    public var requirementDetail2:String;
    public var requirementDetail3:String;
    public var contentId:Number;
    public var contentType:String;
	
    /**
     * Constructor
     */
    public function Requirement()
    {
        super();
    }

    public function get requirementHuman():String
    {
        if (requirement != null)
        {
            return AppUtils.convertRequirementDatabaseLabelToHumanLabel(requirement);
        }
        else
        {
            return "";
        }
    }

    public function set requirementHuman(str:String):void
    {
        requirement = AppUtils.convertRequirementHumanLabelToDatabaseLabel(str);
    }

	

    public function get requirementDetail1():String
    {
        return _requirementDetail1;
    }

    public function set requirementDetail1(value:String):void
    {
        trace("Requirement.setRequirementDetail1() called with value = '" + value + "'");
        _requirementDetail1 = value;

        // Update RequirementDetail1Human
        if (value == null || value == "")
        {
            trace("value passed in is null (or empty string), can't load any objects based off of it.");
            return;
        }
        else if (requirement == null)
        {
            trace("requirement is currently null, so can't load any objects either");
            return;
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE)
        {
            trace("going to load an item for item id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE)
        {
            trace("going 2 load an item for item id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_DATABASE)
        {
            trace("going to load a node for node id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getPageById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_DATABASE)
        {
            trace("going to load a npc for npc id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getCharacterById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE)
        {
            trace("setRequirementDetail1(): Upload Media option selected... nothing needs to be done.");
        }
        else
        {
            trace("setRequirementDetail1(): Should never have gotten this far, but if it does there's not going to be any objects loaded.");
        }
        trace("========= done with Requirement.setRequirementDetail1() =========");
    }

    private function handleRequirementDetail1DataLoad(obj:Object):void
    {
        trace("handleRequirementDetail1DataLoad()...");
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading requirementDetail1 attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading RequirementDetail1");
        }
        else
        {
            var name:String;

            if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE)
            {
                trace("going to load item name - 1");
                name = obj.result.data.name;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE)
            {
                trace("going to load item name - 2");
                name = obj.result.data.name;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_DATABASE)
            {
                trace("going to load node name - 3");
                name = obj.result.data.title;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_DATABASE)
            {
                trace("going to load np name - 4");
                name = obj.result.data.name;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE)
            {
                trace("Upload Media option selected... editor will need to be reconfigured here to support different data model.");
            }

            trace("Setting requirementDetail1Human = '" + name + "' for Requirement Id = '" + requirementId + "'");
            requirementDetail1Human = name;

            var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_REFRESHDATAINREQUIREMENTSEDITOR);
            AppDynamicEventManager.getInstance().dispatchEvent(de);
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems With Requirement Data");
    }
}
}