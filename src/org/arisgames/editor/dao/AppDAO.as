package org.arisgames.editor.dao
{
import mx.rpc.remoting.RemoteObject;

import org.arisgames.editor.util.AppConstants;

public class AppDAO
{
    // Singleton Instance
    public static var instance:AppDAO;

    // Data Servers
    private static var loginServer:RemoteObject;
    private static var gameServer:RemoteObject;
	private static var webHookServer:RemoteObject;
    private static var nodeServer:RemoteObject;
    private static var npcServer:RemoteObject;
	private static var webPageServer:RemoteObject;
	private static var augBubbleServer:RemoteObject;
	private static var conversationServer:RemoteObject;
	private static var itemServer:RemoteObject;
	private static var playerNoteServer:RemoteObject;
    private static var locationServer:RemoteObject;
    private static var contentServer:RemoteObject;
    private static var mediaServer:RemoteObject;
    private static var requirementsServer:RemoteObject;
	private static var questsServer:RemoteObject;
	private static var playerStateChangeServer:RemoteObject;
	private static var spawnablesServer:RemoteObject;
	private static var fountainsServer:RemoteObject;

    /**
     * Singleton constructor
     */
    public function AppDAO()
    {
        if (instance != null)
        {
            throw new Error("This is a Singleton class.  To access, please use AppDAO.getInstance().");
        }
        instance = this;
    }

    public static function getInstance():AppDAO
    {
        if (instance == null)
        {
            instance = new AppDAO;
        }
        return instance;
    }

    public function getLoginServer():RemoteObject
    {
        if (loginServer == null)
        {
            loginServer = new RemoteObject();
            loginServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".editors";
            loginServer.destination = "amfphp";
            loginServer.showBusyCursor = true;
        }
        return loginServer;
    }

	public function getGameServer():RemoteObject
	{
		if (gameServer == null)
		{
			gameServer = new RemoteObject();
			gameServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".games";
			gameServer.destination = "amfphp";
			gameServer.showBusyCursor = true;
		}
		return gameServer;
	}
	
	public function getWebHookServer():RemoteObject
	{
		if (webHookServer == null)
		{
			webHookServer = new RemoteObject();
			webHookServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".webhooks";
			webHookServer.destination = "amfphp";
			webHookServer.showBusyCursor = true;
		}
		return webHookServer;
	}

    public function getNodeServer():RemoteObject
    {
        if (nodeServer == null)
        {
            nodeServer = new RemoteObject();
            nodeServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".nodes";
            nodeServer.destination = "amfphp";
            nodeServer.showBusyCursor = true;
        }
        return nodeServer;
    }
	
	public function getPlayerNoteServer():RemoteObject
	{
		if(playerNoteServer == null)
		{
			playerNoteServer = new RemoteObject();
			playerNoteServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".notes";
			playerNoteServer.destination = "amfphp";
			playerNoteServer.showBusyCursor = true;
		}
		return playerNoteServer;
	}
	
	public function getConversationServer():RemoteObject
	{
		if (conversationServer == null)
		{
			conversationServer = new RemoteObject();
			conversationServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".conversations";
			conversationServer.destination = "amfphp";
			conversationServer.showBusyCursor = true;
		}
		return conversationServer;
	}	

    public function getNPCServer():RemoteObject
    {
        if (npcServer == null)
        {
            npcServer = new RemoteObject();
            npcServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".npcs";
            npcServer.destination = "amfphp";
            npcServer.showBusyCursor = true;
        }
        return npcServer;
    }
	
	public function getWebPageServer():RemoteObject
	{
		if (webPageServer == null)
		{
			webPageServer = new RemoteObject();
			webPageServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".webpages";
			webPageServer.destination = "amfphp";
			webPageServer.showBusyCursor = true;
		}
		return webPageServer;
	}
	
	public function getAugBubbleServer():RemoteObject
	{
		if (augBubbleServer == null)
		{
			augBubbleServer = new RemoteObject();
			augBubbleServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".augbubbles";
			augBubbleServer.destination = "amfphp";
			augBubbleServer.showBusyCursor = true;
		}
		return augBubbleServer;
	}

    public function getItemServer():RemoteObject
    {
        if (itemServer == null)
        {
            itemServer = new RemoteObject();
            itemServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".items";
            itemServer.destination = "amfphp";
            itemServer.showBusyCursor = true;
        }
        return itemServer;
    }

    public function getLocationServer():RemoteObject
    {
        if (locationServer == null)
        {
            locationServer = new RemoteObject();
            locationServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".locations";
            locationServer.destination = "amfphp";
            locationServer.showBusyCursor = true;
        }
        return locationServer;
    }

    public function getContentServer():RemoteObject
    {
        if (contentServer == null)
        {
            contentServer = new RemoteObject();
            contentServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".editorFoldersAndContent";
            contentServer.destination = "amfphp";
            contentServer.showBusyCursor = true;
        }
        return contentServer;
    }

    public function getMediaServer():RemoteObject
    {
        if (mediaServer == null)
        {
            mediaServer = new RemoteObject();
            mediaServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".media";
            mediaServer.destination = "amfphp";
            mediaServer.showBusyCursor = true;
        }
        return mediaServer;
    }

    public function getRequirementsServer():RemoteObject
    {
        if (requirementsServer == null)
        {
            requirementsServer = new RemoteObject();
            requirementsServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".requirements";
            requirementsServer.destination = "amfphp";
            requirementsServer.showBusyCursor = true;
        }
        return requirementsServer;
    }

	public function getQuestsServer():RemoteObject 
	{
		if (questsServer == null)
		{
			questsServer = new RemoteObject();
			questsServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".quests";
			questsServer.destination = "amfphp";
			questsServer.showBusyCursor = true;
		}
		return questsServer;
	}
	public function getPlayerStateChangeServer():RemoteObject 
	{
		if (playerStateChangeServer == null)
		{
			playerStateChangeServer = new RemoteObject();
			playerStateChangeServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".playerStateChanges";
			playerStateChangeServer.destination = "amfphp";
			playerStateChangeServer.showBusyCursor = true;
		}
		return playerStateChangeServer;
	}	
	
	public function getSpawnablesServer():RemoteObject 
	{
		if (spawnablesServer == null)
		{
			spawnablesServer = new RemoteObject();
			spawnablesServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".spawnables";
			spawnablesServer.destination = "amfphp";
			spawnablesServer.showBusyCursor = true;
		}
		return spawnablesServer;
	}	
	
	public function getFountainsServer():RemoteObject 
	{
		if (fountainsServer == null)
		{
			fountainsServer = new RemoteObject();
			fountainsServer.source = AppConstants.APPLICATION_ENVIRONMENT_SERVER_VERSION + ".fountains";
			fountainsServer.destination = "amfphp";
			fountainsServer.showBusyCursor = true;
		}
		return fountainsServer;
	}
}
}