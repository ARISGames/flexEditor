package org.arisgames.editor.services
{

import mx.rpc.IResponder;

import org.arisgames.editor.dao.AppDAO;
import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.TabBarItem;
import org.arisgames.editor.data.arisserver.AugBubble;
import org.arisgames.editor.data.arisserver.Conversation;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.PlayerNote;
import org.arisgames.editor.data.arisserver.NoteTag;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.arisserver.PlayerStateChange;
import org.arisgames.editor.data.arisserver.Quest;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.data.arisserver.WebHook;
import org.arisgames.editor.data.arisserver.WebPage;
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
			game.isLocational = true;
			game.noteShareToMap = true;
			game.noteShareToBook = true;
			game.playerCreateTags = true;
			game.playerCreateComments = true;
			r = AppDAO.getInstance().getGameServer().createGame(SecurityModel.getInstance().getUserId(),
																game.name, game.description,
																game.pcMediaId, game.iconMediaId, game.mediaId,
																game.isLocational, game.readyForPublic,
																game.noteShareToMap, game.noteShareToBook, game.playerCreateTags, game.playerCreateComments,
																game.introNodeId, game.completeNodeId, game.inventoryCap);
		}
		else
		{
			trace("Appservices: saveGame: This game has an Id (" + game.gameId + "), so call update Game.");
			r = AppDAO.getInstance().getGameServer().updateGame(game.gameId,
																game.name, game.description,
																game.pcMediaId, game.iconMediaId, game.mediaId,
																game.isLocational, game.readyForPublic,
																game.noteShareToMap, game.noteShareToBook, game.playerCreateTags, game.playerCreateComments,
																game.introNodeId, game.completeNodeId, game.inventoryCap);
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

	public function duplicateObject(game:Game, obId:int, resp:IResponder):void
	{
		trace("Appservices: duplicateItem");
		var r:Object;
		r = AppDAO.getInstance().getContentServer().duplicateObject(game.gameId, obId);
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
	
	public function getWebPagesByGameId(gid:Number, resp:IResponder):void
	{
		var r:Object;
		r = AppDAO.getInstance().getWebPageServer().getWebPages(gid);
		r.addResponder(resp);
	}
	
	public function getAugBubblesByGameId(gid:Number, resp:IResponder):void
	{
		var r:Object;
		r = AppDAO.getInstance().getAugBubbleServer().getAugBubbles(gid);
		r.addResponder(resp);
	}
	
	public function getPlayerNoteById(gid:Number, pnid:Number, resp:IResponder):void
	{
		var r:Object;
		r = AppDAO.getInstance().getPlayerNoteServer().getNoteById(pnid);
		r.addResponder(resp);
	}

	public function getWebHookById(gid:Number, wid:Number, resp:IResponder):void
	{
		var r:Object;
		r = AppDAO.getInstance().getWebHookServer().getWebHook(gid, wid);
		r.addResponder(resp);
	}

	public function savePlayerNote(gid:Number, playerNote:PlayerNote, resp:IResponder):void
	{
		var r:Object;
		if (isNaN(playerNote.playerNoteId) || playerNote.playerNoteId == 0)
		{
			trace("This item doesn't have a player note Id, so call create Player Note");
			r = AppDAO.getInstance().getPlayerNoteServer().createNewNote(gid, 0);
		}
		else
		{
			trace("This item has a playerNoteId (" + playerNote.playerNoteId + "), so call update PlayerNote.");
			r = AppDAO.getInstance().getPlayerNoteServer().updateNote(playerNote.playerNoteId, playerNote.title, playerNote.sharedToMap, playerNote.sharedToNotebook);
		}
		r.addResponder(resp);
	}
	
    public function saveItem(gid:Number, item:Item, resp:IResponder):void
    {
        var r:Object;
        if (isNaN(item.itemId) || item.itemId == 0)
        {
            trace("This item doesn't have an itemId, so call create Item.");
            r = AppDAO.getInstance().getItemServer().createItem(gid, item.name, item.description, item.iconMediaId, item.mediaId, item.dropable, item.destroyable, item.isAttribute, item.maxQty, item.weight, item.url, item.type);
        }
        else
        {
            trace("This item has an itemId (" + item.itemId + "), so call update Item.");
            r = AppDAO.getInstance().getItemServer().updateItem(gid, item.itemId, item.name, item.description, item.iconMediaId, item.mediaId, item.dropable, item.destroyable, item.isAttribute, item.maxQty, item.weight, item.url, item.type);
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
	
	public function saveWebPage(gid:Number, webPage:WebPage, resp:IResponder):void
	{
		var r:Object;
		if (isNaN(webPage.webPageId) || webPage.webPageId == 0)
		{
			trace("This Web Page doesn't have an Id, so call create WebPage.");
			r = AppDAO.getInstance().getWebPageServer().createWebPage(gid, webPage.name, webPage.url, webPage.iconMediaId);
		}
		else
		{
			trace("This Web Page has an Id (" + webPage.webPageId + "), so call update webPage. gameid:" + gid + " name:" + webPage.name);
			r = AppDAO.getInstance().getWebPageServer().updateWebPage(gid, webPage.webPageId, webPage.name, webPage.url, webPage.iconMediaId);
		}
		r.addResponder(resp);
	}
	
	public function saveAugBubble(gid:Number, augBubble:AugBubble, resp:IResponder):void
	{
		var r:Object;
		if (isNaN(augBubble.augBubbleId) || augBubble.augBubbleId == 0)
		{
			trace("This Aug Bubble doesn't have an Id, so call create AugBubble.");
			r = AppDAO.getInstance().getAugBubbleServer().createAugBubble(gid, augBubble.name, augBubble.desc, augBubble.iconMediaId);
		}
		else
		{
			trace("This Aug Bubble has an Id (" + augBubble.augBubbleId + "), so call update augBubble. gameid:" + gid + " name:" + augBubble.name);
			r = AppDAO.getInstance().getAugBubbleServer().updateAugBubble(gid, augBubble.augBubbleId, augBubble.name, augBubble.desc, augBubble.iconMediaId);
		}
		r.addResponder(resp);
	}
	

    public function savePage(gid:Number, n:Node, resp:IResponder):void
    {
        var r:Object;
        if (isNaN(n.nodeId) || n.nodeId == 0)
        {
            trace("This page doesn't have an Id, so call create page.");
            r = AppDAO.getInstance().getNodeServer().createNode(gid, n.title, n.text, n.mediaId, n.iconMediaId, n.opt1Text, n.opt1NodeId, n.opt2Text, n.opt2NodeId, n.opt3Text, n.opt3NodeId, n.qaCorrectAnswer, n.qaIncorrectNodeId, n.qaCorrectNodeId);
        }
        else
        {
            trace("This page has an Id (" + n.nodeId + "), so call update page.");
            r = AppDAO.getInstance().getNodeServer().updateNode(gid, n.nodeId, n.title, n.text, n.mediaId, n.iconMediaId, n.opt1Text, n.opt1NodeId, n.opt2Text, n.opt2NodeId, n.opt3Text, n.opt3NodeId, n.qaCorrectAnswer, n.qaIncorrectNodeId, n.qaCorrectNodeId);
        }
        r.addResponder(resp);
    }
	
	public function saveWebHook(gid:Number, w:WebHook, resp:IResponder):void
	{
		var r:Object;
		if (isNaN(w.webHookId) || w.webHookId == 0)
		{
			trace("This web hook doesn't have an Id, so call create web hook.");
			r = AppDAO.getInstance().getWebHookServer().createWebHook(gid, w.name, w.url, w.incoming);
		}
		else
		{
			trace("This web hook has an Id (" + w.webHookId + "), so call update webhook.");

			if(w.incoming) r = AppDAO.getInstance().getWebHookServer().updateWebHook(gid, w.webHookId, w.name, ""); //save url as "" (causes problems with duplicating games... it gets generated non-server side anyways)
			else r = AppDAO.getInstance().getWebHookServer().updateWebHook(gid, w.webHookId, w.name, w.url);

		}
		r.addResponder(resp);
	}
	

    public function saveLocation(gid:Number, loc:Location, imageMatchMediaId:Number, resp:IResponder):void
    {
        var l:Object;
        if (isNaN(loc.locationId))
        {
            trace("AppServices.as: This Location doesn't have an Id, so call create Location. Qr Code = " + loc.qrCode + " QuickTravel = " + loc.quickTravel);

            l = AppDAO.getInstance().getLocationServer().createLocationWithQrCode(gid, loc.name, loc.iconMediaId, loc.latitude, loc.longitude, loc.error, loc.type, loc.typeId, loc.quantity, loc.hidden, loc.forceView, loc.quickTravel , loc.qrCode, imageMatchMediaId, loc.errorText);
        }
        else
        {
            trace("AppServices.as: This Location has an Id (" + loc.locationId + "), so call locations.updateLocationWithQrCode. GameId = " + gid + " LocName: " + loc.name + " iconMediaId: " + loc.iconMediaId + " Qr Code = " + loc.qrCode  + "QuickTravel = " + loc.quickTravel);
            l = AppDAO.getInstance().getLocationServer().updateLocationWithQrCode(gid, loc.locationId, loc.name, loc.iconMediaId, loc.latitude, loc.longitude, loc.error, loc.type, loc.typeId, loc.quantity, loc.hidden, loc.forceView, loc.quickTravel, loc.qrCode, imageMatchMediaId, loc.errorText);
        }
        l.addResponder(resp);
    }
	
	public function getAllImageMatchMedia(gid:Number, loc:PlaceMark, resp:IResponder):void
	{
		var l:Object;
		if (isNaN(loc.id))
		{
			trace("AppServices.as: This Location doesn't have an Id- the Location should have been saved to the database previously. :(");
			l = null;
		}
		else
		{
			trace("AppServices.as: Going to get image match media for location ID:"+ loc.id);
			l = AppDAO.getInstance().getLocationServer().getAllImageMatchEntriesForLocation(gid, loc.id);
		}
		l.addResponder(resp);
	}
	
	public function addImageMatchMediaIdToLocation(gid:Number, loc:PlaceMark, id:Number, resp:IResponder):void
	{
		var l:Object;
		if (isNaN(loc.id))
		{
			trace("AppServices.as: This Location doesn't have an Id- the Location should have been saved to the database previously. :(");
			l = null;
		}
		else
		{
			trace("AppServices.as: Going to add image match media to location ID:"+ loc.id);
			l = AppDAO.getInstance().getLocationServer().addImageMatchEntryForLocation(gid, loc.id, id);
		}
		l.addResponder(resp);
	}
	
	public function removeImageMatchMediaIdFromLocation(gid:Number, loc:PlaceMark, id:Number, resp:IResponder):void
	{
		var l:Object;
		if (isNaN(loc.id))
		{
			trace("AppServices.as: This Location doesn't have an Id- the Location should have been saved to the database previously. :(");
			l = null;
		}
		else
		{
			trace("AppServices.as: Going to add image match media to location ID:"+ loc.id);
			l = AppDAO.getInstance().getLocationServer().removeImageMatchEntryForLocation(gid, loc.id, id);
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
        trace("SaveFolder: Game Id = " + gid + "; Folder Id = " + opi.id + "; Name = " + opi.name + "; Parent Id = " + opi.parentFolderId + "; Previous Folder Id = " + opi.previousFolderId + "; Is it open? = " + opi.isOpen);
        l = AppDAO.getInstance().getContentServer().saveFolder(gid, opi.id, opi.name, opi.parentFolderId, opi.previousFolderId, opi.isOpen);
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
        trace("SaveContent: GameId = " + gid + "; Object Content Id = " + opi.id + "; Folder Id = " + opi.parentContentFolderId + "; Object type = " + opi.objectType + ", Content Id = " + opi.objectId + "; Previous Content Object Id = " + opi.previousContentId);
        l = AppDAO.getInstance().getContentServer().saveContent(gid, opi.id, opi.parentContentFolderId, opi.objectType, opi.objectId, opi.previousContentId);
        l.addResponder(resp);
    }

    public function deleteContent(gid:Number, opi:ObjectPaletteItemBO, resp:IResponder):void
    {
        var l:Object;
        l = AppDAO.getInstance().getContentServer().deleteContent(gid, opi.id);
        l.addResponder(resp);
    }
	
	public function getTabBarItemsForGame(gid:Number, resp:IResponder):void
	{
		var l:Object;
		trace("GetTabBarItemsForGame: GameId = " + gid);
		l = AppDAO.getInstance().getGameServer().getTabBarItemsForGame(gid);
		l.addResponder(resp);
	}
	
	public function saveTab(gid:Number, tab:TabBarItem, resp:IResponder):void
	{
		var l:Object;
		trace("Saving tab...");
		if(!tab.enabled) tab.index = 0;
		l =  AppDAO.getInstance().getGameServer().saveTab(gid, tab.type, tab.index);
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
	
	public function getWebHooksByGameId(gid:Number, resp:IResponder):void
	{
		var l:Object;
		l = AppDAO.getInstance().getWebHookServer().getWebHooks(gid);
		l.addResponder(resp);
	}
	
	public function getNoteTagsByGameId(gid:Number, resp:IResponder):void
	{
		var l:Object;
		l = AppDAO.getInstance().getPlayerNoteServer().getAllTagsInGame(gid);
		l.addResponder(resp);
	}
	
	public function getNoteTagById(tid:Number, resp:IResponder):void
	{
		var r:Object;
		r = AppDAO.getInstance().getPlayerNoteServer().getGameTag(tid);
		r.addResponder(resp);
	}

	public function addNoteTag(gid:Number, tag:NoteTag, resp:IResponder):void
	{
		var l:Object;
		l = AppDAO.getInstance().getPlayerNoteServer().addTagToGame(gid, tag.tag);
		l.addResponder(resp);
	}
	
	public function deleteNoteTag(gid:Number, tag:NoteTag, resp:IResponder):void
	{
		var l:Object;
		l = AppDAO.getInstance().getPlayerNoteServer().deleteTagFromGame(gid, tag.tag_id);
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
	
	public function getWebPageById(gid:Number, id:Number, resp:IResponder):void
	{
		var l:Object;
		//trace("getWebPageById called with GID = '" + gid + "', and ID = '" + id + "'");
		l = AppDAO.getInstance().getWebPageServer().getWebPage(gid, id);
		l.addResponder(resp);
	}
	
	public function getAugBubbleById(gid:Number, id:Number, resp:IResponder):void
	{
		var l:Object;
		//trace("getAugBubbleById called with GID = '" + gid + "', and ID = '" + id + "'");
		l = AppDAO.getInstance().getAugBubbleServer().getAugBubble(gid, id);
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
	
	public function deleteWebHook(gid:Number, wid:Number, resp:IResponder):void
	{
		var l:Object;
		trace("deleteMediaForGame called with GID = '" + gid + "'; WID = '" + wid + "'");
		l = AppDAO.getInstance().getWebHookServer().deleteWebHook(gid, wid);
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
	
	public function updateAugBubbleMediaIndex(augId:Number, mediaId:Number, name:String, game:Game, index:Number, resp:IResponder):void{
		var l:Object;
		l = AppDAO.getInstance().getAugBubbleServer().updateAugBubbleMediaIndex(augId, mediaId, name, game.gameId, index);
		l.addResponder(resp);
	}
	
	public function removeAugBubbleMediaIndex(augId:Number, mediaId:Number, index:Number, resp:IResponder):void{
		var l:Object;
		l = AppDAO.getInstance().getAugBubbleServer().removeAugBubbleMediaIndex(augId, mediaId, index);
		l.addResponder(resp);
	}
	
	public function getAugBubbleMedia(gid:Number, augId:Number, resp:IResponder):void{
		var l:Object;
		l = AppDAO.getInstance().getAugBubbleServer().getAugBubbleMedia(gid, augId);
		l.addResponder(resp);
	}
	
	public function updatePlayerNoteMediaIndex(pnId:Number, mediaId:Number, game:Game, resp:IResponder):void{
		var l:Object;
		l = AppDAO.getInstance().getPlayerNoteServer().addContentToNote(pnId, game.gameId, 0, mediaId, "MEDIA", "");
		l.addResponder(resp);
	}
	
	public function removePlayerNoteMediaIndex(contentId:Number, resp:IResponder):void{
		var l:Object;
		l = AppDAO.getInstance().getPlayerNoteServer().deleteNoteContent(contentId);
		l.addResponder(resp);
	}
	
	public function getPlayerNoteMedia(gid:Number, augId:Number, resp:IResponder):void{
		var l:Object;
		l = AppDAO.getInstance().getPlayerNoteServer().getPlayerNoteMedia(gid, augId);
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
		if(req.notOpHuman == "Player Has") req.notOp = "DO";
		else if(req.notOpHuman == "Player Has Not") req.notOp = "NOT";
        if (isNaN(req.requirementId))
        {
            trace("This Requirement doesn't have an Id, so call Create Requirement function On Remote Server..");
			trace("Requirement ID:" + req.requirementId + " Requirement:" + req.requirement + " Detail1:" + req.requirementDetail1 + " Detail2:" + req.requirementDetail2 );
			l = AppDAO.getInstance().getRequirementsServer().createRequirement(gid, req.contentType, req.contentId, req.requirement, req.requirementDetail1, req.requirementDetail2, req.requirementDetail3, req.requirementDetail4, req.boolean, req.notOp);
        }
        else
        {
            trace("This Requirement has an Id (" + req.requirementId + "), so call Update Requirement function on Remote Server.");
			trace("Requirement ID:" + req.requirementId + " Requirement:" + req.requirement + " Detail1:" + req.requirementDetail1 + " Detail2:" + req.requirementDetail2 );

			l = AppDAO.getInstance().getRequirementsServer().updateRequirement(gid, req.requirementId, req.contentType, req.contentId, req.requirement, req.requirementDetail1, req.requirementDetail2, req.requirementDetail3, req.requirementDetail4, req.boolean, req.notOp);
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
		
	public function getQuestById(gid:Number, id:Number, resp:IResponder):void
	{
		trace("AppServices: getQuest called with id=" + id);
		var l:Object;
		//trace("getPageById called with GID = '" + gid + "', and ID = '" + id + "'");
		l = AppDAO.getInstance().getQuestsServer().getQuest(gid, id);
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
			l = AppDAO.getInstance().getQuestsServer().createQuest(gid, quest.title, quest.activeText, quest.completeText, quest.iconMediaId, quest.index);
		}
		else
		{
			trace("This Quest has an Id (" + quest.questId + "), so call Update Quest function on Remote Server.");
			trace("Updating quest id: " + quest.questId + " title: " + quest.title + " activeText: " + quest.activeText + " completeText: " + quest.completeText + " iconMediaId: " + quest.iconMediaId);
			l = AppDAO.getInstance().getQuestsServer().updateQuest(gid, quest.questId, quest.title, quest.activeText, quest.completeText, quest.iconMediaId, quest.index);
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
	
	public function switchConversationOrder(gid:Number, npcId:Number, convoAId:Number, convoBId:Number, resp:IResponder):void {
		trace("AppServices: switchConversationOrder called with GameId:" + gid + " NpcId: " + npcId + " convoA: " + convoAId + " convoB: " + convoBId);
		var l:Object;
		l = AppDAO.getInstance().getConversationServer().swapSortIndex(gid, npcId, convoAId, convoBId);
		l.addResponder(resp);
	}
	
	public function switchQuestOrder(gid:Number, questAId:Number, questBId:Number, resp:IResponder):void {
		trace("AppServices: switchConversationOrder called with GameId:" + gid + " QuestAId:" + questAId + " QuestBId: " + questBId);
		var l:Object;
		l = AppDAO.getInstance().getQuestsServer().swapSortIndex(gid, questAId, questBId);
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
			l = AppDAO.getInstance().getConversationServer().createConversationWithNode(gid, c.npcId, c.linkText, c.scriptText, c.index);
		}
		else
		{
			trace("This Conversation has an Id:" + c.conversationId + " so call updateConversationWithNode function on Remote Server.");
			l = AppDAO.getInstance().getConversationServer().updateConversationWithNode(gid, c.conversationId, c.linkText, c.scriptText, c.index );
		}
		l.addResponder(resp);
	}
	
	public function addEditor(gid:Number, editorId:Number, resp:IResponder):void
	{
		trace("addEditor called for game Id=" + gid + " with editorId '" + editorId + "'");
		var r:Object;
		r = AppDAO.getInstance().getGameServer().addEditorToGame(editorId ,gid);
		r.addResponder(resp);
	}
	
	public function removeEditor(gid:Number, editorId:Number, resp:IResponder):void
	{
		trace("removeEditor called for game Id=" + gid + " with editorId '" + editorId + "'");
		var r:Object;
		r = AppDAO.getInstance().getGameServer().removeEditorFromGame(editorId ,gid);
		r.addResponder(resp);
	}
	
	public function getEditors(resp:IResponder):void
	{
		trace("Retreiving all Editors");
		var r:Object;
		r = AppDAO.getInstance().getGameServer().getEditors();
		r.addResponder(resp);
	}
	
	public function getGameEditors(gid:Number, resp:IResponder):void
	{
		trace("Retreiving all Editors");
		var r:Object;
		r = AppDAO.getInstance().getGameServer().getGameEditors(gid);
		r.addResponder(resp);
	}
	
	public function duplicateGame(gid:Number, resp:IResponder):void {
		trace("Duplicating Game");
		var r:Object;
		r = AppDAO.getInstance().getGameServer().duplicateGame(gid);
		r.addResponder(resp);
	}
	
}
}