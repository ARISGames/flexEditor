package org.arisgames.editor.util
{
import mx.collections.ArrayCollection;
import mx.utils.ArrayUtil;
import org.arisgames.editor.MainView;
import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.arisserver.Quest;
import org.arisgames.editor.data.arisserver.PlayerStateChange;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;

/**
 * A singleton object that provides parsers, converters and other general utilities
 */

public class AppUtils
{
    private var mainView:MainView;

    // Singleton Pattern
    public static var instance:AppUtils;

    /**
     * Singleton Constructor
     */
    public function AppUtils()
    {
        if (instance != null)
        {
            throw new Error("AppUtils is a singleton, can only be accessed by calling getInstance() function.");
        }
        instance = this;
    }

    public static function getInstance():AppUtils
    {
        if (instance == null)
        {
            instance = new AppUtils();
        }
        return instance;
    }

    public static function getContentTypeForAppViewAsString(ctId:Number):String
    {
        switch (ctId)
        {
            case AppConstants.CONTENTTYPE_CHARACTER_VAL:
                return AppConstants.CONTENTTYPE_CHARACTER;
            case AppConstants.CONTENTTYPE_ITEM_VAL:
                return AppConstants.CONTENTTYPE_ITEM;
            case AppConstants.CONTENTTYPE_PAGE_VAL:
                return AppConstants.CONTENTTYPE_PAGE;
            /*
             case AppConstants.CONTENTTYPE_QRCODEGROUP_VAL:
             return AppConstants.CONTENTTYPE_QRCODEGROUP;
             */
            default:
                return "";
        }
    }

    public static function getContentTypeForDatabaseAsString(ctId:Number):String
    {
        switch (ctId)
        {
            case AppConstants.CONTENTTYPE_CHARACTER_VAL:
                return AppConstants.CONTENTTYPE_CHARACTER_DATABASE;
            case AppConstants.CONTENTTYPE_ITEM_VAL:
                return AppConstants.CONTENTTYPE_ITEM_DATABASE;
            case AppConstants.CONTENTTYPE_PAGE_VAL:
                return AppConstants.CONTENTTYPE_PAGE_DATABASE;
            /*
             case AppConstants.CONTENTTYPE_QRCODEGROUP_VAL:
             return AppConstants.CONTENTTYPE_QRCODEGROUP;
             */
            default:
                return "";
        }
    }

    public static function getContentTypeValueByName(ct:String):Number
    {
        switch (ct)
        {
            case AppConstants.CONTENTTYPE_CHARACTER:
                return AppConstants.CONTENTTYPE_CHARACTER_VAL;
            case AppConstants.CONTENTTYPE_CHARACTER_DATABASE:
                return AppConstants.CONTENTTYPE_CHARACTER_VAL;
            case AppConstants.CONTENTTYPE_ITEM:
                return AppConstants.CONTENTTYPE_ITEM_VAL;
            case AppConstants.CONTENTTYPE_ITEM_DATABASE:
                return AppConstants.CONTENTTYPE_ITEM_VAL;
            case AppConstants.CONTENTTYPE_PAGE:
                return AppConstants.CONTENTTYPE_PAGE_VAL;
            case AppConstants.CONTENTTYPE_PAGE_DATABASE:
                return AppConstants.CONTENTTYPE_PAGE_VAL;
            /*
             case AppConstants.CONTENTTYPE_QRCODEGROUP:
             return AppConstants.CONTENTTYPE_QRCODEGROUP_VAL;
             */
            default:
                trace("getContentTypeValueByName() returning a -1 for name passed in = '" + ct + "'");
                return -1;
        }
    }

    public static function convertPlaceMarkToLocation(pm:PlaceMark):Location
    {
        var loc:Location = new Location();

        loc.locationId = pm.id;
        loc.latitude = pm.latitude;
        loc.longitude = pm.longitude;
        loc.name = pm.name;
		loc.qrCode = pm.qrCode;
        loc.type = AppUtils.getContentTypeForDatabaseAsString(pm.contentType);
        loc.typeId = pm.contentId;
        loc.iconMediaId = 0;
        loc.error = 0;
        loc.quantity = pm.quantity;
        loc.hidden = pm.hidden;
        loc.forceView = pm.forcedView;
		loc.quickTravel = pm.quickTravel;
        return loc;
    }

    public static function flattenGameObjectIntoArrayCollection(go:ArrayCollection):ArrayCollection
    {
        var res:ArrayCollection = new ArrayCollection();

        var gos:ArrayCollection = new ArrayCollection();
        if (go == null)
        {
            gos.addAll(GameModel.getInstance().game.gameObjects);
        }
        else
        {
            gos.addAll(go);
        }

        for (var lc:Number = 0; lc < gos.length; lc++)
        {
            var fgo:ObjectPaletteItemBO = gos.getItemAt(lc) as ObjectPaletteItemBO;
            res.addItem(fgo);
            if (fgo.isFolder() && fgo.children.length > 0)
            {
                res.addAll(AppUtils.flattenGameObjectIntoArrayCollection(fgo.children));
            }
        }

        return res;
    }

    public static function findGameObjectInFolder(go:ObjectPaletteItemBO, folder:ObjectPaletteItemBO):ObjectPaletteItemBO
    {
        if (ArrayUtil.getItemIndex(go, folder.children.toArray()) != -1)
        {
            // Found it
            return folder;
        }
        else
        {
            var kids:ArrayCollection = folder.children;
            var foundIt:ObjectPaletteItemBO;
            for (var lc:Number = 0; lc < kids.length; lc++)
            {
                var o:ObjectPaletteItemBO = kids.getItemAt(lc) as ObjectPaletteItemBO;
                if (o.isFolder())
                {
                    if (AppUtils.findGameObjectInFolder(go, o) != null)
                    {
                        foundIt = o;
                        break;
                    }
                }
            }
            return foundIt;
        }
    }

    public static function repairPaletteObjectAssociations():ArrayCollection
    {
        var go:ArrayCollection = AppUtils.flattenGameObjectIntoArrayCollection(null);

        for (var lc:Number = go.length - 1; lc >= 0; lc--)
        {
            var o:ObjectPaletteItemBO = go.getItemAt(lc) as ObjectPaletteItemBO;
            if (o.isFolder())
            {
                // Take care of the children
                for (var klc:Number = o.children.length - 1; klc >= 0; klc--)
                {
                    var k:ObjectPaletteItemBO = o.children.getItemAt(klc) as ObjectPaletteItemBO;
                    k.parentContentFolderId = o.id;
                    k.previousContentId = klc;
                }

                o.previousFolderId = lc;
            }
            else
            {
                o.parentContentFolderId = 0;
                o.previousContentId = lc;
            }
        }

        return go;
    }

    public static function printPaletteObjectDataModel():void
    {
        for (var i:Number = 0; i < GameModel.getInstance().game.gameObjects.length; i++)
        {
            var o:ObjectPaletteItemBO = GameModel.getInstance().game.gameObjects.getItemAt(i) as ObjectPaletteItemBO;
            trace("i = " + i + "; Id = '" + o.id + "'; Object Name = '" + o.name + "'; isFolder = '" + o.isFolder() + "'; ObjectId = '" + o.objectId + "'; Object Type = '" + o.objectType + "'");
            if (o.isFolder())
            {
                trace("since it's a folder, let's see how many children is has: '" + o.children.length + "'");
            }
        }
    }

    public static function matchDataWithGameObject(obj:ObjectPaletteItemBO, objType:String, npc:NPC, item:Item, node:Node):void
    {
        //trace("matchDataWithGameObject() called: Looking at Game Object Id '" + obj.id + ".  It's Object Type = '" + obj.objectType + "', while it's Content Id = '" + obj.objectId + "'; Is Folder? " + obj.isFolder() + "");

        if (!obj.isFolder() && obj.objectType == objType)
        {
            // This is a possible match, now check its id
            switch (objType)
            {
                case AppConstants.CONTENTTYPE_CHARACTER_DATABASE:
                    if (obj.objectId == npc.npcId)
                    {
                        //trace("Just matched Game Object Id " + obj.id + " with Character of ID = " + npc.npcId);
                        obj.character = npc;
                    }
                    break;
                case AppConstants.CONTENTTYPE_ITEM_DATABASE:
                    if (obj.objectId == item.itemId)
                    {
                        //trace("Just matched Game Object Id " + obj.id + " with Item of ID = " + item.itemId);
                        obj.item = item;
                    }
                    break;
                case AppConstants.CONTENTTYPE_PAGE_DATABASE:
                    //trace("Testing Node Object: Id = '" + obj.id + "'; ObjectId = '" + obj.objectId + "'; Node Id = '" + node.nodeId + "'");
                    if (obj.objectId == node.nodeId)
                    {
                        //trace("Just matched Game Object Id " + obj.id + " with Node of ID = " + node.nodeId);
                        obj.page = node;
                    }
                    break;
            }
        }
        else if (obj.isFolder())
        {
            //trace("This is a folder so need to check it's children.  Number of children to check = '" + obj.children.length + "'");
            for (var lc:Number = 0; lc < obj.children.length; lc++)
            {
                var childObj:ObjectPaletteItemBO = obj.children.getItemAt(lc) as ObjectPaletteItemBO;
                matchDataWithGameObject(childObj, objType, npc, item, node);
            }
        }
    }

	/**
	 * Parses a resultData package from the server into an item
	 * @param Object data The data from the server
	 * @return item
	 * @returns a populated item object
	 * @see item
	 */
	
    public static function parseResultDataIntoItem(data:Object):Item
    {
        if (data.hasOwnProperty("item_id"))
        {
            trace("data has an item_id!  It's value = '" + data.item_id + "'.");
            var item:Item = new Item();

            item.itemId = data.item_id;
            item.name = data.name;
            item.description = data.description;
            item.iconMediaId = data.icon_media_id;
            item.mediaId = data.media_id;
            item.dropable = data.dropable;
            item.destroyable = data.destroyable;
			item.maxQty = data.max_qty_in_inventory;

            return item;
        }
        else
        {
            //trace("Data passed in was not an Item Result set, returning NULL.");
            return null;
        }
    }

    public static function parseResultDataIntoNPC(data:Object):NPC
    {
        if (data.hasOwnProperty("npc_id"))
        {
            trace("retObj has an npc_id!  It's value = '" + data.npc_id + "'.");
            var npc:NPC = new NPC();

            npc.npcId = data.npc_id;
            npc.name = data.name;
            npc.description = data.description;
            npc.greeting = data.greeting;
            npc.mediaId = data.media_id;

            return npc;
        }
        else
        {
            trace("Data passed in was not a NPC Result set, returning NULL.");
            return null;
        }
    }
	
	public static function parseResultDataIntoNode(data:Object):Node
	{
		if (data.hasOwnProperty("node_id"))
		{
			trace("retObj has an node_id!  It's value = '" + data.node_id + "'.");
			var node:Node = new Node();
			
			node.nodeId = data.node_id;
			node.title = data.title;
			node.text = data.text;
			node.mediaId = data.media_id;
			node.opt1Text = data.opt1_text;
			node.opt1NodeId = data.opt1_node_id;
			node.opt2Text = data.opt2_text;
			node.opt2NodeId = data.opt2_node_id;
			node.opt3Text = data.opt3_text;
			node.opt3NodeId = data.opt3_node_id;
			node.qaCorrectAnswer = data.require_answer_string;
			node.qaIncorrectNodeId = data.require_answer_incorrect_node_id;
			node.qaCorrectNodeId = data.require_answer_correct_node_id;
			
			return node;
		}
		else
		{
			trace("Data passed in was not a Node Result set, returning NULL.");
			return null;
		}
	}
	
	

	public static function parseResultDataIntoQuest(data:Object):Quest
	{
		if (data.hasOwnProperty("quest_id"))
		{
			trace("AppUtils: parseResultDataIntoQuest: retObj has an id = '" + data.quest_id + "'.");
			var quest:Quest = new Quest();
			
			quest.questId = data.quest_id;
			quest.title = data.name;
			quest.activeText = data.description
			quest.completeText = data.text_when_complete;
			quest.iconMediaId = data.icon_media_id;
			return quest;
		}
		else
		{
			trace("AppUtils: parseResultDataIntoQuest: Data passed in was not a Quest Result set, returning NULL.");
			return null;
		}
	}

	
	public static function parseResultDataIntoPlayerStateChange(data:Object):PlayerStateChange
	{
		if (data.hasOwnProperty("id"))
		{
			trace("AppUtils: parseResultDataIntoPlayerStateChange: retObj has an id = '" + data.id + "'.");
			var psc:PlayerStateChange = new PlayerStateChange();
			
			psc.playerStateChangeId = data.id;
			psc.eventType = data.event_type;
			psc.eventDetail = data.event_detail;
			psc.action = data.action;
			psc.actionDetail = data.action_detail;
			psc.actionAmount = data.action_amount;

			return psc;
		}
		else
		{
			trace("AppUtils: parseResultDataIntoPlayerStateChange: Data passed in was not a PlayerStateChange Result set, returning NULL.");
			return null;
		}
	}

	
	
    public function setMainView(mv:MainView):void
    {
        this.mainView = mv;
    }

    public function getMainView():MainView
    {
        return mainView;
    }

    public static function filterStringToXMLEscapeCharacters(str:String):String
    {
        var s:String;

        var myPattern:RegExp = /&/gi;
        s = str.replace(myPattern, "&amp;");

        myPattern = /"/gi;
        s = s.replace(myPattern, "&quot;");

        myPattern = /'/gi;
        s = s.replace(myPattern, "&apos;");

        myPattern = /</gi;
        s = s.replace(myPattern, "&lt;");

        myPattern = />/gi;
        s = s.replace(myPattern, "&gt;");

        return s;
    }

    public static function convertRequirementHumanLabelToDatabaseLabel(str:String):String
    {
        switch (str)
        {
            case AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_DATABASE;
            case AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_HUMAN:
                return AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE;
            default:
                return str;
        }
    }

    public static function convertRequirementDatabaseLabelToHumanLabel(str:String):String
    {
        switch (str)
        {
            case AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_HUMAN;
            case AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE:
                return AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_HUMAN;
            default:
                return str;
        }
    }

    public static function isUploadMediaItemRequirementType(req:Requirement):Boolean
    {
        if (req.requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE)
        {
            return true;
        }
        return false;
    }
}
}