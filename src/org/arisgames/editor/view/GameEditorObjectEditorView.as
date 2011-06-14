package org.arisgames.editor.view
{
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.arisserver.WebPage;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppUtils;

public class GameEditorObjectEditorView extends Canvas
{
    // Data Object
    private var objectPaletteItem:ObjectPaletteItemBO;

    // Editors
    [Bindable] public var folderEditor:ItemEditorFolderView;
    [Bindable] public var itemEditor:ItemEditorItemView;
    [Bindable] public var characterEditor:ItemEditorCharacterView;
    [Bindable] public var plaqueEditor:ItemEditorPlaqueView;
	[Bindable] public var webPageEditor:ItemEditorWebPageView;
	[Bindable] public var augBubbleEditor:ItemEditorAugBubbleView;

    
    /**
     * Constructor
     */
    public function GameEditorObjectEditorView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("GameEditorObjectEditorView: in handleInit");
    }

    public function getObjectPaletteItem():ObjectPaletteItemBO
    {
        return objectPaletteItem;
    }

    public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
    {
        trace("setObjectPaletteItem with name = '" + opi.name + "'; (Object Content) ID = '" + opi.id + "'; Object Id = '" + opi.objectId + "'; Is Folder? ='" + opi.isFolder() + "  called.");
        if (!opi.isFolder())
        {
            trace("It's not a folder, so get a fresh copy of the data.");
//            AppServices.getInstance().getContent(GameModel.getInstance().game.gameId, opi.id, new Responder(handleGetContent, handleFault));
            this.objectPaletteItem = opi;
            this.updateTheEditorUI();
        }
        else
        {
            trace("It's a folder, so just load the data per usual.");
            this.objectPaletteItem = opi;
            this.updateTheEditorUI();
        }
    }

    private function handleGetContent(obj:Object):void
    {
        trace("In handleGetContent() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad get content attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Getting Content For Editor");
        }
        else
        {
            trace("Got content ok, now load the object and then get the actual content data.");

            var op:ObjectPaletteItemBO = new ObjectPaletteItemBO(false);
            op.id = obj.result.data.object_content_id;
            op.objectId = obj.result.data.content_id;
            op.objectType = obj.result.data.content_type;
            op.name = obj.result.data.name;
            op.iconMediaId = obj.result.data.icon_media_id;

            // Load Icon Media Object (if exists)
            if (obj.result.data.icon_media != null)
            {
                var m:Media = new Media();
                m.mediaId = obj.result.data.icon_media.media_id;
                m.name = obj.result.data.icon_media.name;
                m.type = obj.result.data.icon_media.type;
                m.urlPath = obj.result.data.icon_media.url_path;
                m.fileName = obj.result.data.icon_media.file_name;
                m.isDefault = obj.result.data.icon_media.is_default;

                op.iconMedia = m;
            }

            op.mediaId = obj.result.data.media_id;
            // Load Media Object (if exists)
            if (obj.result.data.media != null)
            {
                m = new Media();
                m.mediaId = obj.result.data.media.media_id;
                m.name = obj.result.data.media.name;
                m.type = obj.result.data.media.type;
                m.urlPath = obj.result.data.media.url_path;
                m.fileName = obj.result.data.media.file_name;
                m.isDefault = obj.result.data.media.is_default;

                op.media = m;
            }

            op.parentContentFolderId = obj.result.data.folder_id;
            op.previousContentId = obj.result.data.previous_id;

            // Load the underlying data
            if (op.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
            {
                //trace("Load underlying character data...");
                AppServices.getInstance().getCharacterById(GameModel.getInstance().game.gameId, op.objectId, new Responder(handleLoadSpecificData, handleFault));
            }
            else if (op.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
            {
                //trace("Load underlying item data...");
                AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, op.objectId, new Responder(handleLoadSpecificData, handleFault));
            }
            else if (op.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
            {
                //trace("Load underlying page data...");
                AppServices.getInstance().getPageById(GameModel.getInstance().game.gameId, op.objectId, new Responder(handleLoadSpecificData, handleFault));
            }
			else if (op.objectType == AppConstants.CONTENTTYPE_WEBPAGE_DATABASE)
			{
				//trace("Load underlying WebPage data...");
				AppServices.getInstance().getWebPageById(GameModel.getInstance().game.gameId, op.objectId, new Responder(handleLoadSpecificData, handleFault));
			}
			else if (op.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE)
			{
				//trace("Load underlying AugBubble data...");
				AppServices.getInstance().getAugBubbleById(GameModel.getInstance().game.gameId, op.objectId, new Responder(handleLoadSpecificData, handleFault));
			}

            this.objectPaletteItem = op;
        }
        trace("Finished with handleGetContent().");
    }

    private function handleLoadSpecificData(retObj:ResultEvent):void
    {
        var item:Item = null;
        var npc:NPC = null;
        var node:Node = null;
		var webPage:WebPage = null;
		var augBubble:AugBubble = null;

        var data:Object = retObj.result.data;
        var objType:String = "";

        if (data.hasOwnProperty("item_id"))
        {
            trace("retObj has an item_id!  It's value = '" + data.item_id + "'.");
            item = AppUtils.parseResultDataIntoItem(data);

            objType = AppConstants.CONTENTTYPE_ITEM_DATABASE;
        }
        else if (data.hasOwnProperty("npc_id"))
        {
            trace("retObj has an npc_id!  It's value = '" + data.npc_id + "'.");
            npc = AppUtils.parseResultDataIntoNPC(data);

            objType = AppConstants.CONTENTTYPE_CHARACTER_DATABASE;
        }
        else if (data.hasOwnProperty("node_id"))
        {
            trace("retObj has an node_id!  It's value = '" + data.node_id + "'.");
            node = AppUtils.parseResultDataIntoNode(data);

            objType = AppConstants.CONTENTTYPE_PAGE_DATABASE;
        }
		else if (data.hasOwnProperty("web_page_id"))
		{
			trace("retObj has a web_page_id!  It's value = '" + data.web_page_id + "'.");
			webPage = AppUtils.parseResultDataIntoWebPage(data);
			
			objType = AppConstants.CONTENTTYPE_WEBPAGE_DATABASE;
		}
		else if (data.hasOwnProperty("aug_bubble_id"))
		{
			trace("retObj has an aug_bubble_id!  It's value = '" + data.aug_bubble_id + "'.");
			augBubble = AppUtils.parseResultDataIntoAugBubble(data);
			
			objType = AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE;
		}
        else
        {
            trace("retObj data type couldn't be found, returning.");
            return;
        }

        trace("Time to look for it's matching Game Object.");
        AppUtils.matchDataWithGameObject(this.objectPaletteItem, objType, npc, item, node, webPage, augBubble);

        // Update the Editor
        this.updateTheEditorUI();
        trace("Done getting fresh copy of data.");
    }

    private function updateTheEditorUI():void
    {
        // Reset Display By Hiding All Editors First
        folderEditor.setVisible(false);
        folderEditor.includeInLayout = false;
        itemEditor.setVisible(false);
        itemEditor.includeInLayout = false;
        characterEditor.setVisible(false);
        characterEditor.includeInLayout = false;
        plaqueEditor.setVisible(false);
        plaqueEditor.includeInLayout = false;
		webPageEditor.setVisible(false);
		webPageEditor.includeInLayout = false;
		augBubbleEditor.setVisible(false);
		augBubbleEditor.includeInLayout = false;

        if (objectPaletteItem.isFolder())
        {
            trace("It's a folder, so display the Folder Editor.");
            folderEditor.setObjectPaletteItem(objectPaletteItem);
            folderEditor.setVisible(true);
            folderEditor.includeInLayout = true;
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            trace("It's an Item, so display the Item Editor.")
            itemEditor.setObjectPaletteItem(objectPaletteItem);
            itemEditor.setVisible(true);
            itemEditor.includeInLayout = true;
        }
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_WEBPAGE_DATABASE)
		{
			trace("It's a Web Page, so display the Web Page Editor.")
			webPageEditor.setObjectPaletteItem(objectPaletteItem);
			webPageEditor.setVisible(true);
			webPageEditor.includeInLayout = true;
		}
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
        {
            trace("It's a Character, so display the Character Editor.")
            characterEditor.setObjectPaletteItem(objectPaletteItem);
            characterEditor.setVisible(true);
            characterEditor.includeInLayout = true;
			characterEditor.reloadTheConversations();
        }
        else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
        {
            trace("It's an Page, so display the Page Editor.")
            plaqueEditor.setObjectPaletteItem(objectPaletteItem);
            plaqueEditor.setVisible(true);
            plaqueEditor.includeInLayout = true;
        }
		else if (objectPaletteItem.objectType == AppConstants.CONTENTTYPE_AUGBUBBLE_DATABASE)
		{
			trace("It's an Aug Bubble, so display the Aug Bubble Editor.")
			augBubbleEditor.setObjectPaletteItem(objectPaletteItem);
			augBubbleEditor.setVisible(true);
			augBubbleEditor.includeInLayout = true;
		}
    }

    public function handleFault(obj:Object):void
    {
        trace("Error In Object Editor: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Error In Object Editor");
    }
}
}