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
	public var boolean:String;
	public var notOp:String;
	public var notOpHuman:String;
    public var _requirementDetail1:String;
    public var requirementDetail1Human:String;
    public var requirementDetail2:String;
	public var requirementDetail3:String;
	public var requirementDetail4:String;
    public var contentId:Number;
    public var contentType:String;
	
    /**
     * Constructor
     */
    public function Requirement()
    {
        super();
		boolean = AppConstants.REQUIREMENT_BOOLEAN_AND_DATABASE;
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
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE)
        {
            trace("going to load an item for item id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE)
        {
            trace("going 2 load an item for item id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_WEBPAGE_DATABASE)
		{
			trace("going to load a web page for web page id = '" + new Number(requirementDetail1) + "'");
			AppServices.getInstance().getWebPageById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
		}
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_DATABASE)
		{
			trace("going to load an aug bubble for aug bubble id = '" + new Number(requirementDetail1) + "'");
			AppServices.getInstance().getAugBubbleById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
		}
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE)
        {
            trace("going to load a node for node id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getPageById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE)
        {
            trace("going to load a npc for npc id = '" + new Number(requirementDetail1) + "'");
            AppServices.getInstance().getCharacterById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
        }
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_DATABASE)
		{
			trace("going to load a quest for quest id = '" + new Number(requirementDetail1) + "'");
			AppServices.getInstance().getQuestById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
		}
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_DATABASE)
		{
			trace("going to load incoming web hook for web hook id = '" + new Number(requirementDetail1) + "'");
			AppServices.getInstance().getWebHookById(GameModel.getInstance().game.gameId, new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
		}
        else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_DATABASE)
        {
            trace("setRequirementDetail1(): Upload Media option selected... nothing needs to be done.");
        }
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_DATABASE)
		{
			trace("going to load incoming game tags = '" + new Number(requirementDetail1) + "'");
			AppServices.getInstance().getNoteTagById(new Number(requirementDetail1), new Responder(handleRequirementDetail1DataLoad, handleFault));
		}
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_DATABASE || AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_DATABASE)
		{
			trace("setRequirementDetail1(): Note With (x) selected... nothing needs to be done.");
		}
		
		else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_PLAYER_NOTE_DATABASE)
		{
			trace("requirement about player notes");
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

            if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE)
            {
                trace("going to load item name - 1");
                name = obj.result.data.name;
				if(obj.result.data.description != "")
					name += ": " + obj.result.data.description;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE)
            {
                trace("going to load item name - 2");
                name = obj.result.data.name;
				if(obj.result.data.description != "")
					name += ": " + obj.result.data.description;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE)
            {
                trace("going to load node name - 3");
                name = obj.result.data.title;
				if(obj.result.data.text != "")
					name += ": " + obj.result.data.text;
            }
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE)
            {
                trace("going to load np name - 4");
                name = obj.result.data.name;
				if(obj.result.data.description != "")
					name += ": " + obj.result.data.description;
            }
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_DATABASE)
			{
				trace("going to load quest name - 5");
				name = obj.result.data.name;
				if(obj.result.data.description != "")
					name += ": " + obj.result.data.description;
			}
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_DATABASE)
			{
				trace("going to load incoming web hook name - 5");
				name = obj.result.data.name;
				if(obj.result.data.url != "")
					name += ": " + obj.result.data.url;
			}
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_WEBPAGE_DATABASE)
			{
				trace("going to load web page name - 6");
				name = obj.result.data.name;
				if(obj.result.data.url != "")
					name += ": " + obj.result.data.url;
			}
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_DATABASE)
			{
				trace("going to load aug bubble name - 7");
				name = obj.result.data.name;
				if(obj.result.data.description != "")
					name += ": " + obj.result.data.description;
			}
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_DATABASE )
			{
				trace("going to load note tag");
				name = obj.result.data.tag;
			}
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_DATABASE || AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_DATABASE)
			{
				trace("Player note requriement picked. Do nothin'");
			}
			
			else if (requirement == AppConstants.REQUIREMENT_PLAYER_VIEWED_PLAYER_NOTE_DATABASE)
			{
				trace("Player note requriement picked. Do nothin'");
			}
            else if (requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_DATABASE || requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_DATABASE)
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