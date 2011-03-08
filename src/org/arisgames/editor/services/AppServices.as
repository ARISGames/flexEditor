package org.arisgames.editor.services
{

import mx.rpc.IResponder;

import org.arisgames.editor.dao.AppDAO;
import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.arisserver.Conversation;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.arisserver.PlayerStateChange;
import org.arisgames.editor.data.arisserver.Quest;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.SecurityModel;
import org.arisgames.editor.util.AppConstants;

public class AppServices
{
    private static var instance:AppServices;

    /**
     * Singleton constructor.  Do not call externally.
     */
    public function AppServices()
    {
        if (instance != null)
        {
            throw new Error("AppServices is singleton class.  Please use AppServices.getInstance() to make use of it.");
        }
        instance = this;
    }

    public static function getInstance():AppServices
    {
        if (instance == null)
        {
            instance = new AppServices();
        }
        return instance;
    }

    public function login(user:String, pwd:String, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getLoginServer().login(user, pwd);
        r.addResponder(resp);
    }

    public function remindOfUsername(email:String, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getLoginServer().emailUserName(email);
        r.addResponder(resp);
    }

    public function resetPassword(email:String, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getLoginServer().resetAndEmailNewPassword(email);
        r.addResponder(resp);
    }

    public function registerAccount(user:String, pwd:String, email:String, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getLoginServer().createEditor(user, pwd, email, null);
        r.addResponder(resp);
    }

	public function saveGame(game:Game, resp:IResponder):void
	{
		var r:Object;
		if (isNaN(game.gameId) || game.gameId == 0)
		{
			trace("Appservices: saveGame: This game doesn't have a gameId, so call create Game.");
			r = AppDAO.getInstance().getGameServer().createGame(SecurityModel.getInstance().getUserId(),
																game.name, game.description,
																game.pcMediaId, game.iconMediaId, 
																game.allowsPlayerCreatedLocations, game.resetDeletesPlayerCreatedLocations, 
																game.introNodeId, game.completeNodeId);
		}
		else
		{
			trace("Appservices: saveGame: This game has an Id (" + game.gameId + "), so call update Item.");
			r = AppDAO.getInstance().getGameServer().updateGame(game.gameId,
																game.name, game.description,
																game.pcMediaId, game.iconMediaId, 
																game.allowsPlayerCreatedLocations, game.resetDeletesPlayerCreatedLocations, 
																game.introNodeId, game.completeNodeId);
		}
		r.addResponder(resp);
	}

	public function deleteGame(game:Game, resp:IResponder):void
	{
		trace("Appservices: deleteGame: This game has an Id (" + game.gameId + ")");
		var r:Object;
		r = AppDAO.getInstance().getGameServer().deleteGame(game.gameId);
		r.addResponder(resp);

	}


    public function loadGamesByUserId(userId:Number, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getGameServer().getGamesForEditor(userId);
        r.addResponder(resp);
    }

    public function getLocationsByGameId(gid:Number, resp:IResponder):void
    {
        var l:Object;
        trace("AppServices:Loading locations for game ID:" + gid);
        l = AppDAO.getInstance().getLocationServer().getLocationsWithQrCode(gid);
        l.addResponder(resp);
    }

    public function getPagesByGameId(gid:Number, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getNodeServer().getNodes(gid);
        r.addResponder(resp);
    }

    public function getCharactersByGameId(gid:Number, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getNPCServer().getNpcs(gid);
        r.addResponder(resp);
    }

    public function getItemsByGameId(gid:Number, resp:IResponder):void
    {
        var r:Object;
        r = AppDAO.getInstance().getItemServer().getItems(gid);
        r.addResponder(resp);
    }

    public function saveItem(gid:Number, item:Item, resp:IResponder):void
    {
        var r:Object;
        if (isNaN(item.itemId) || item.itemId == 0)
        {
            trace("This item doesn't have an itemId, so call create Item.");
            r = AppDAO.getInstance().getItemServer().createItem(gid, item.name, item.description, item.iconMediaId, item.mediaId, item.dropable, item.destroyable, item.maxQty);
        }
        else
        {
            trace("This item has an itemId (" + item.itemId + "), so call update Item.");
            r = AppDAO.getInstance().getItemServer().updateItem(gid, item.itemId, item.name, item.description, item.iconMediaId, item.mediaId, item.dropable, item.destroyable, item.maxQty);
        }
        r.addResponder(resp);
    }

    public function saveCharacter(gid:Number, npc:NPC, resp:IResponder):void
    {
        var r:Object;
        if (isNaN(npc.npcId) || npc.npcId == 0)
        {
            trace("This NPC doesn't have an Id, so call create NPC.");
            r = AppDAO.getInstance().getNPCServer().createNpc(gid, npc.name, npc.description, npc.greeting, npc.closing, npc.mediaId, npc.iconMediaId);
        }
        else
        {
            trace("This NPC has an Id (" + npc.npcId + "), so call update NPC. gameid:" + gid + " name:" + npc.name + "greeting:" + npc.greeting);
            r = AppDAO.getInstance().getNPCServer().updateNpc(gid, npc.npcId, npc.name, npc.description, npc.greeting, npc.closing, npc.mediaId, npc.iconMediaId);
        }
        r.addResponder(resp);
    }

    public function savePage(gid:Number, n:Node, resp:IResponder):void
    {
        var r:Object;
        if (isNaN(n.nodeId) || n.nodeId == 0)
        {
            trace("This NPC doesn't have an Id, so call create NPC.");
            r = AppDAO.getInstance().getNodeServer().createNode(gid, n.title, n.text, n.mediaId, n.iconMediaId, n.opt1Text, n.opt1NodeId, n.opt2Text, n.opt2NodeId, n.opt3Text, n.opt3NodeId, n.qaCorrectAnswer, n.qaIncorrectNodeId, n.qaCorrectNodeId);
        }
        else
        {
            trace("This NPC has an Id (" + n.nodeId + "), so call update NPC.");
            r = AppDAO.getInstance().getNodeServer().updateNode(gid, n.nodeId, n.title, n.text, n.mediaId, n.iconMediaId, n.opt1Text, n.opt1NodeId, n.opt2Text, n.opt2NodeId, n.opt3Text, n.opt3NodeId, n.qaCorrectAnswer, n.qaIncorrectNodeId, n.qaCorrectNodeId);
        }
        r.addResponder(resp);
    }

    public function saveLocation(gid:Number, loc:Location, resp:IResponder):void
    {
        var l:Object;
        if (isNaN(loc.locationId))
        {
            trace("AppServices.as: This Location doesn't have an Id, so call create Location. Qr Code = " + loc.qrCode + "QuickTravel = " + loc.quickTravel);

            l = AppDAO.getInstance().getLocationServer().createLocationWithQrCode(gid, loc.name, loc.iconMediaId, loc.latitude, loc.longitude, loc.error, loc.type, loc.typeId, loc.quantity, loc.hidden, loc.forceView, loc.quickTravel , loc.qrCode);
        }
        else
        {
            trace("AppServices.as: This Location has an Id (" + loc.locationId + "), so call locations.updateLocationWithQrCode. GameId = " + gid + " LocName: " + loc.name + " iconMediaId: " + loc.iconMediaId + " Qr Code = " + loc.qrCode  + "QuickTravel = " + loc.quickTravel);
            l = AppDAO.getInstance().getLocationServer().updateLocationWithQrCode(gid, loc.locationId, loc.name, loc.iconMediaId, loc.latitude, loc.longitude, loc.error, loc.type, loc.typeId, loc.quantity, loc.hidden, loc.forceView, loc.quickTravel, loc.qrCode);
        }
        l.addResponder(resp);
    }

    public function deleteLocation(gid:Number, locId:Number, resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getLocationServer().deleteLocation(gid, locId);
        l.addResponder(resp);
    }

    public function saveFolder(gid:Number, opi:ObjectPaletteItemBO, resp:IResponder):void
    {
        var l:Object;
        trace("SaveFolder: Game Id = " + gid + "; Folder Id = " + opi.id + "; Name = " + opi.name + "; Parent Id = " + opi.parentFolderId + "; Previous Folder Id = " + opi.previousFolderId);
        l = AppDAO.getInstance().getContentServer().saveFolder(gid, opi.id, opi.name, opi.parentFolderId, opi.previousFolderId);
        l.addResponder(resp);
    }

    public function deleteFolder(gid:Number, opi:ObjectPaletteItemBO, resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getContentServer().deleteFolder(gid, opi.id);
        l.addResponder(resp);
    }

    public function getContent(gid:Number, ocid:Number, resp:IResponder):void
    {
        var l:Object;
        trace("GetContent: GameId = " + gid + "; Object Content Id = " + ocid + "'");
        l = AppDAO.getInstance().getContentServer().getContent(gid, ocid);
        l.addResponder(resp);
    }

    public function saveContent(gid:Number, opi:ObjectPaletteItemBO, resp:IResponder):void
    {
        var l:Object;
        trace("SaveContent: GameId = " + gid + "; Object Content Id = " + opi.id + "; Folder Id = " + opi.parentContentFolderId + "; Content Id = " + opi.objectId + "; Previous Content Object Id = " + opi.previousContentId);
        l = AppDAO.getInstance().getContentServer().saveContent(gid, opi.id, opi.parentContentFolderId, opi.objectType, opi.objectId, opi.previousContentId);
        l.addResponder(resp);
    }

    public function deleteContent(gid:Number, opi:ObjectPaletteItemBO, resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getContentServer().deleteContent(gid, opi.id);
        l.addResponder(resp);
    }

    public function getFoldersAndContentByGameId(gid:Number, resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getContentServer().getFoldersAndContent(gid);
        l.addResponder(resp);
    }

    public function getItemById(gid:Number, id:Number, resp:IResponder):void
    {
        var l:Object;
        //trace("getItemById called with GID = '" + gid + "', and ID = '" + id + "'");
        l = AppDAO.getInstance().getItemServer().getItem(gid, id);
        l.addResponder(resp);
    }

    public function getPageById(gid:Number, id:Number, resp:IResponder):void
    {
        var l:Object;
        //trace("getPageById called with GID = '" + gid + "', and ID = '" + id + "'");
        l = AppDAO.getInstance().getNodeServer().getNode(gid, id);
        l.addResponder(resp);
    }

    public function getCharacterById(gid:Number, id:Number, resp:IResponder):void
    {
        var l:Object;
        //trace("getCharacterById called with GID = '" + gid + "', and ID = '" + id + "'");
        l = AppDAO.getInstance().getNPCServer().getNpc(gid, id);
        l.addResponder(resp);
    }

    public function getMediaForGame(gid:Number, resp:IResponder):void
    {
        var l:Object;
        trace("$$$$$$$$$$$ getMediaForGame called with GID = '" + gid + "'. $$$$$$$$$$$$");
        l = AppDAO.getInstance().getMediaServer().getMedia(gid);
        l.addResponder(resp);
    }

    public function getMediaByGameIdAndMediaId(gid:Number, mid:Number, resp:IResponder):void
    {
        var l:Object;
        trace("getMediaByGameIdAndMediaId called with Game Id = '" + gid + "' and Media Id = '" + mid + "'");
        l = AppDAO.getInstance().getMediaServer().getMediaObject(gid, mid);
        l.addResponder(resp);
    }

    public function renameMediaForGame(gid:Number, mid:Number, newName:String, resp:IResponder):void
    {
        var l:Object;
        trace("renameMediaForGame called with GID = '" + gid + "'; MID = '" + mid + "'; New Name = '" + newName + "'");
        l = AppDAO.getInstance().getMediaServer().renameMedia(gid, mid, newName);
        l.addResponder(resp);
    }

    public function deleteMediaForGame(gid:Number, mid:Number, resp:IResponder):void
    {
        var l:Object;
        trace("deleteMediaForGame called with GID = '" + gid + "'; MID = '" + mid + "'");
        l = AppDAO.getInstance().getMediaServer().deleteMedia(gid, mid);
        l.addResponder(resp);
    }

    public function createMediaForGame(gid:Number, mediaName:String, fileName:String, isIcon:Number, resp:IResponder):void
    {
        var l:Object;
        trace("createMediaForGame called with GID = '" + gid + "'.  Media Name = " + mediaName + ";  File Name = '" + fileName + "'; Is Icon = '" + isIcon + "'");
        l = AppDAO.getInstance().getMediaServer().createMedia(gid, mediaName, fileName, isIcon);
        l.addResponder(resp);
    }

    public function getValidVideoExtensions(resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getMediaServer().getValidVideoExtensions();
        l.addResponder(resp);
    }

    public function getValidAudioExtensions(resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getMediaServer().getValidAudioExtensions();
        l.addResponder(resp);
    }

    public function getValidImageAndIconExtensions(resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getMediaServer().getValidImageAndIconExtensions();
        l.addResponder(resp);
    }

    public function getRequirementsForObject(gid:Number, objectType:String, objectId:Number, resp:IResponder):void
    {
        trace("getRequirementsForObject() called with Game Id = '" + gid + "', Object Type = '" + objectType + "', Object Id = '" + objectId + "'");
        var l:Object;
        l = AppDAO.getInstance().getRequirementsServer().getRequirementsForObject(gid, objectType, objectId);
        l.addResponder(resp);
    }

    public function getRequirementTypeOptions(gid:Number, resp:IResponder):void
    {
        trace("getRequirementTypeOptions() called with Game Id = '" + gid + "'");
        var l:Object;
        l = AppDAO.getInstance().getRequirementsServer().requirementTypeOptions(gid);
        l.addResponder(resp);
    }

    public function saveRequirement(gid:Number, req:Requirement, resp:IResponder):void
    {
        var l:Object;
        if (isNaN(req.requirementId))
        {
            trace("This Requirement doesn't have an Id, so call Create Requirement function On Remote Server..");
			trace("Requirement ID:" + req.requirementId + " Requirement:" + req.requirement + " Detail1:" + req.requirementDetail1 + " Detail2:" + req.requirementDetail2 );
			l = AppDAO.getInstance().getRequirementsServer().createRequirement(gid, req.contentType, req.contentId, req.requirement, req.requirementDetail1, req.requirementDetail2, req.requirementDetail3, req.boolean);
        }
        else
        {
            trace("This Requirement has an Id (" + req.requirementId + "), so call Update Requirement function on Remote Server.");
			trace("Requirement ID:" + req.requirementId + " Requirement:" + req.requirement + " Detail1:" + req.requirementDetail1 + " Detail2:" + req.requirementDetail2 );

			l = AppDAO.getInstance().getRequirementsServer().updateRequirement(gid, req.requirementId, req.contentType, req.contentId, req.requirement, req.requirementDetail1, req.requirementDetail2, req.requirementDetail3, req.boolean);
        }
        l.addResponder(resp);
    }

    public function deleteRequirement(gid:Number, req:Requirement, resp:IResponder):void
    {
        trace("deleteRequirement() called with Game Id = '" + gid + "' and Requirement Id = '" + req.requirementId + "'");
        var l:Object;
        l = AppDAO.getInstance().getRequirementsServer().deleteRequirement(gid, req.requirementId);
        l.addResponder(resp);
    }
	
	public function getRequirementsByGameId(gid:Number, resp:IResponder):void
	{
		trace("getRequirements called with GameID = '" + gid + "'");
		var l:Object;
		l = AppDAO.getInstance().getRequirementsServer().getRequirementsForObject(gid, "", 0); // This seems to be the way to select all Requirements for a game
		l.addResponder(resp);
	}
	
	public function getQuestsByGameId(gid:Number, resp:IResponder):void
	{
		trace("AppServices: getQuests called with GameID = '" + gid + "'");
		var l:Object;
		l = AppDAO.getInstance().getQuestsServer().getQuests(gid);
		l.addResponder(resp);
	}
	public function deleteQuest(gid:Number, quest:Quest, resp:IResponder):void
	{
		trace("AppServices: deleteQuest() called with Game Id = '" + gid + "' and Quest Id = '" + quest.questId + "'");
		var l:Object;
		l = AppDAO.getInstance().getQuestsServer().deleteQuest(gid, quest.questId);
		l.addResponder(resp);
	}
	public function saveQuest(gid:Number, quest:Quest, resp:IResponder):void
	{
		var l:Object;
		if (isNaN(quest.questId))
		{
			trace("This Quest doesn't have an Id, so call Create Quest function On Remote Server..");
			l = AppDAO.getInstance().getQuestsServer().createQuest(gid, quest.title, quest.activeText, quest.completeText, quest.iconMediaId );
		}
		else
		{
			trace("This Quest has an Id (" + quest.questId + "), so call Update Quest function on Remote Server.");
			trace("Updating quest id: " + quest.questId + " title: " + quest.title + " activeText: " + quest.activeText + " completeText: " + quest.completeText + " iconMediaId: " + quest.iconMediaId);
			l = AppDAO.getInstance().getQuestsServer().updateQuest(gid, quest.questId, quest.title, quest.activeText, quest.completeText, quest.iconMediaId);
		}
		l.addResponder(resp);
	}
	
	public function getPlayerStateChangesForObject(gid:Number, eventType:String, eventObjectId:Number, resp:IResponder):void
	{
		trace("AppServices: getPlayerStateChangesForObject called with GameID = '" + gid + "'");
		var l:Object;
		l = AppDAO.getInstance().getPlayerStateChangeServer().getPlayerStateChangesForObject(gid,eventType,eventObjectId);
		l.addResponder(resp);
	}
	
	public function deletePlayerStateChange(gid:Number, psc:PlayerStateChange, resp:IResponder):void
	{
		trace("AppServices: deletePlayerStateChange() called with Game Id = '" + gid + "' and PSC Id = '" + psc.playerStateChangeId + "'");
		var l:Object;
		l = AppDAO.getInstance().getPlayerStateChangeServer().deletePlayerStateChange(gid, psc.playerStateChangeId);
		l.addResponder(resp);
	}
	
	public function savePlayerStateChange(gid:Number, psc:PlayerStateChange, resp:IResponder):void
	{
		var l:Object;
		if (isNaN(psc.playerStateChangeId))
		{
			trace("This PlayerStateChange doesn't have an Id, so call Create PlayerStateChange function On Remote Server..");
			l = AppDAO.getInstance().getPlayerStateChangeServer().createPlayerStateChange(gid, psc.eventType, psc.eventDetail, psc.action, psc.actionDetail, psc.actionAmount );
		}
		else
		{
			trace("This PlayerStateChange has an Id (" + psc.playerStateChangeId + "), so call Update PlayerStateChange function on Remote Server.");
			l = AppDAO.getInstance().getPlayerStateChangeServer().updatePlayerStateChange(gid, psc.playerStateChangeId, psc.eventType, psc.eventDetail, psc.action, psc.actionDetail, psc.actionAmount);
		}
		l.addResponder(resp);
	}
	
	public function getConversationsForNpc(gid:Number, npcid:Number, resp:IResponder):void
	{
		trace("AppServices: getConversationsForNpc called with GameId:" + gid + " NpcId:" + npcid);
		var l:Object;
		l = AppDAO.getInstance().getConversationServer().getConversationsWithNodeForNpc(gid,npcid);
		l.addResponder(resp);
	}
	
	public function deleteConversation(gid:Number, c:Conversation, resp:IResponder):void
	{
		trace("AppServices: deleteConversation() called with Game Id:" + gid + " conversation Id:" + c.conversationId);
		var l:Object;
		l = AppDAO.getInstance().getConversationServer().deleteConversationWithNode(gid, c.conversationId);
		l.addResponder(resp);
	}
	
	public function saveConversation(gid:Number, c:Conversation, resp:IResponder):void
	{
		var l:Object;
		if (isNaN(c.conversationId))
		{
			trace("This Conversation doesn't have an Id, so call createConversation function On Remote Server. npcId: " + c.npcId);
			l = AppDAO.getInstance().getConversationServer().createConversationWithNode(gid, c.npcId, c.linkText, c.scriptText);
		}
		else
		{
			trace("This Conversation has an Id:" + c.conversationId + " so call updateConversationWithNode function on Remote Server.");
			l = AppDAO.getInstance().getConversationServer().updateConversationWithNode(gid, c.conversationId, c.linkText, c.scriptText );
		}
		l.addResponder(resp);
	}
	
	
}
}