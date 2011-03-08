package org.arisgames.editor.view
{
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.DataGrid;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;

import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.models.SecurityModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;


public class CreateOrOpenGameSelectorView extends Panel
{
    [Bindable] public var nameOfGame:TextInput;
    [Bindable] public var gameDescription:TextArea;
    [Bindable] public var createGameButton:Button;
    [Bindable] public var gamesDataGrid:DataGrid;
    [Bindable] public var loadGameButton:Button;
    [Bindable] public var usersGames:ArrayCollection;


    /**
     * Constructor
     */
    public function CreateOrOpenGameSelectorView()
    {
        super();
        usersGames = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);

    }

    private function onComplete(event:FlexEvent): void
    {
        createGameButton.addEventListener(MouseEvent.CLICK, onCreateButtonClick);
        loadGameButton.addEventListener(MouseEvent.CLICK, onLoadButtonClick);
        AppServices.getInstance().loadGamesByUserId(SecurityModel.getInstance().getUserId(), new Responder(handleLoadUsersGames, handleFault)); 
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.APPLICATIONDYNAMICEVENT_CURRENTSTATECHANGED, handleCurrentStateChangedEvent);

    }

	private function handleCurrentStateChangedEvent(obj:Object):void
	{
		trace("CreateOrOpenGameSelectorView: handleCurrentStateChangedEvent");

		if (StateModel.getInstance().currentState == StateModel.VIEWCREATEOROPENGAMEWINDOW){
			trace("CreateOrOpenGameSelectorView: handleCurrentStateChangedEvent: Refreshing");
			nameOfGame.text = "";
			gameDescription.text = "";
			usersGames.removeAll();
			AppServices.getInstance().loadGamesByUserId(SecurityModel.getInstance().getUserId(), new Responder(handleLoadUsersGames, handleFault)); 
		}
	}
	
    private function handleLoadUsersGames(obj:Object):void
    {
		trace("handleLoadUsersGames");

		usersGames.removeAll();
		
        if (obj.result.data == null)
        {
            trace("obj.result.data is NULL");
            return;
        }

        for (var j:Number = 0; j < obj.result.data.list.length; j++)
        {
            var g:Game = new Game();
            g.gameId = obj.result.data.list.getItemAt(j).game_id;
            g.name = obj.result.data.list.getItemAt(j).name;
            g.description = obj.result.data.list.getItemAt(j).description;
			g.iconMediaId = obj.result.data.list.getItemAt(j).game_icon_media_id;
			g.pcMediaId = obj.result.data.list.getItemAt(j).pc_media_id;
			g.introNodeId = obj.result.data.list.getItemAt(j).on_launch_node_id;
			g.completeNodeId = obj.result.data.list.getItemAt(j).game_complete_node_id;
			g.allowsPlayerCreatedLocations = obj.result.data.list.getItemAt(j).allow_player_created_locations;
			g.resetDeletesPlayerCreatedLocations = obj.result.data.list.getItemAt(j).delete_player_locations_on_reset;

			usersGames.addItem(g);
        }
        trace("done loading UsersGames.");
    }

    private function onCreateButtonClick(evt:MouseEvent):void
    {
        trace("create button clicked!");
		var g:Game = new Game();
		g.name = nameOfGame.text;
		g.description = gameDescription.text;
        AppServices.getInstance().saveGame(g, new Responder(handleCreateGame, handleFault));
    }

    private function onLoadButtonClick(evt:MouseEvent):void
    {
        trace("load button clicked!");
        var g:Game = gamesDataGrid.selectedItem as Game;
        trace("Selected game to load data for has Id = " + g.gameId);

        // Load the game into the app's models
        GameModel.getInstance().game = g;
        GameModel.getInstance().game.placeMarks.removeAll();
        GameModel.getInstance().game.gameObjects.removeAll();
		GameModel.getInstance().loadLocations();
        AppServices.getInstance().getFoldersAndContentByGameId(g.gameId, new Responder(handleLoadFoldersAndContentForObjectPalette, handleFault));

        StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITOR;
    }

 

    private function handleLoadFoldersAndContentForObjectPalette(obj:Object):void
    {
        trace("Starting handleLoadFoldersAndContentForObjectPalette()...");
        var ops:ArrayCollection = new ArrayCollection();
        ops.removeAll();
		var op:ObjectPaletteItemBO;

        trace("Starting to load the folders.");
        // Load Folders
        for (var j:Number = 0; j < obj.result.data.folders.list.length; j++)
        {
            op = new ObjectPaletteItemBO(true);
            op.id = obj.result.data.folders.list.getItemAt(j).folder_id;
            op.name = obj.result.data.folders.list.getItemAt(j).name;
            op.parentFolderId = obj.result.data.folders.list.getItemAt(j).parent_id;
            op.previousFolderId = obj.result.data.folders.list.getItemAt(j).previous_id;
            ops.addItem(op);
        }
        trace("Folders loaded, number of object palette BOs = '" + ops.length + "'");

        // Sort By Previous Folder Id From 0 to N
        var dataSortField:SortField = new SortField();
        dataSortField.name = "previousFolderId";
        dataSortField.numeric = true;

        var numericDataSort:Sort = new Sort();
        numericDataSort.fields = [dataSortField];

        ops.sort = numericDataSort;
        ops.refresh();
        trace("Folders sorted by Previous Folder Id");

        var dict:Dictionary = new Dictionary();

        for (j = 0; j < ops.length; j++)
        {
            op = ops.getItemAt(j) as ObjectPaletteItemBO;
            trace("j = " + j + "; Folder Id = '" + op.id +"'; Folder Name = '" + op.name + "'");
            if (op.parentFolderId == 0)
            {
                // It's at the root level
                dict[op.id] = op;
            }
            else
            {
                // It's a child of a previously added object
                var o:ObjectPaletteItemBO = dict[op.parentFolderId] as ObjectPaletteItemBO;
                o.children.addItem(op);
            }
        }
        trace("Folders loaded into dictionary.");

        ops.removeAll();
        // Load Content
        for (j = 0; j < obj.result.data.contents.list.length; j++)
        {
            op = new ObjectPaletteItemBO(false);
            op.id = obj.result.data.contents.list.getItemAt(j).object_content_id;
            op.objectId = obj.result.data.contents.list.getItemAt(j).content_id;
            op.objectType = obj.result.data.contents.list.getItemAt(j).content_type;
            op.name = obj.result.data.contents.list.getItemAt(j).name;
            op.iconMediaId = obj.result.data.contents.list.getItemAt(j).icon_media_id;

            // Load Icon Media Object (if exists)
			var m:Media;
			
            if (obj.result.data.contents.list.getItemAt(j).icon_media != null)
            {
                m = new Media();
                m.mediaId = obj.result.data.contents.list.getItemAt(j).icon_media.media_id;
                m.name = obj.result.data.contents.list.getItemAt(j).icon_media.name;
                m.type = obj.result.data.contents.list.getItemAt(j).icon_media.type;
                m.urlPath = obj.result.data.contents.list.getItemAt(j).icon_media.url_path;
                m.fileName = obj.result.data.contents.list.getItemAt(j).icon_media.file_name;
                m.isDefault = obj.result.data.contents.list.getItemAt(j).icon_media.is_default;

                op.iconMedia = m;
            }

            op.mediaId = obj.result.data.contents.list.getItemAt(j).media_id;
            // Load Media Object (if exists)
            if (obj.result.data.contents.list.getItemAt(j).media != null)
            {
                m = new Media();
                m.mediaId = obj.result.data.contents.list.getItemAt(j).media.media_id;
                m.name = obj.result.data.contents.list.getItemAt(j).media.name;
                m.type = obj.result.data.contents.list.getItemAt(j).media.type;
                m.urlPath = obj.result.data.contents.list.getItemAt(j).media.url_path;
                m.fileName = obj.result.data.contents.list.getItemAt(j).media.file_name;
                m.isDefault = obj.result.data.contents.list.getItemAt(j).media.is_default;

                op.media = m;
            }

            op.parentContentFolderId = obj.result.data.contents.list.getItemAt(j).folder_id;
            op.previousContentId = obj.result.data.contents.list.getItemAt(j).previous_id;
            ops.addItem(op);
        }
        trace("Content loaded, now time to sort; size = '" + ops.length + "'");

        // Sort By Previous Content Id From 0 to N
        var dsf:SortField = new SortField();
        dsf.name = "previousContentId";
        dsf.numeric = true;
        var nds:Sort = new Sort();
        nds.fields = [dsf];
        ops.sort = nds;
        ops.refresh();
        trace("Objects are sorted by Previous Content Id");

        // Create ArrayCollection to be used to generate the tree
        var fc:ArrayCollection = new ArrayCollection();
        for (var key:Object in dict)
        {
            fc.addItem(dict[key]);    
        }
        // Resort to get in proper order, not order of keys.
        fc.sort = numericDataSort;
        fc.refresh();

        // Create A New (Pure) ArrayCollection To Hold the Final data
        var rfc:ArrayCollection = new ArrayCollection();
        rfc.addAll(fc);

        trace("Converted Folder Dictionary Into Final ArrayCollection used for Tree rendering");

        for (j = 0; j < ops.length; j++)
        {
            op = ops.getItemAt(j) as ObjectPaletteItemBO;
            trace("j = " + j + "; Object Id = '" + op.id +"'; Object Name = '" + op.name + "'");

            // if previous folder id == 0, then it's root else it goes on as a child of a folder
            if (op.parentContentFolderId == 0)
            {
                rfc.addItem(op);
            }
            else
            {
                var par:ObjectPaletteItemBO = dict[op.parentContentFolderId] as ObjectPaletteItemBO;
                par.children.addItem(op);
            }
        }
        trace("Finished sorting and arranging content items... should be ready to display Tree now.");        

        GameModel.getInstance().game.gameObjects.addAll(rfc);
        this.loadSpecificDataIntoGameObjects();
        trace("Done attaching underlying data to game objects.  Should be ready for GUI now.");
    }

    /**
     * Function for loading Item, Character, and Plaque data into Game Objects after they've been sorted
     * and loaded into the Game Model.  Has to be done this way to do serial nature of Flex.
     *
     * SHOULD ONLY BE CALLED after handleLoadFoldersAndContentForObjectPalette
     */
    private function loadSpecificDataIntoGameObjects():void
    {
        for (var j:int = 0; j < GameModel.getInstance().game.gameObjects.length; j++)
        {
            var obj:ObjectPaletteItemBO = GameModel.getInstance().game.gameObjects.getItemAt(j) as ObjectPaletteItemBO;
            this.processLoadingSpecificData(obj);
        }
    }

    private function processLoadingSpecificData(obj:ObjectPaletteItemBO):void
    {
        if (!obj.isFolder())
        {
            if (obj.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
            {
                //trace("Load underlying character data...");
                AppServices.getInstance().getCharacterById(GameModel.getInstance().game.gameId, obj.objectId, new Responder(handleLoadSpecificData, handleFault));
            }
            else if (obj.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
            {
                //trace("Load underlying item data...");
                AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, obj.objectId, new Responder(handleLoadSpecificData, handleFault));
            }
            else if (obj.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
            {
                //trace("Load underlying page data...");
                AppServices.getInstance().getPageById(GameModel.getInstance().game.gameId, obj.objectId, new Responder(handleLoadSpecificData, handleFault));
            }
        }
        else
        {
            trace("Check folder for children data to load.");
            for (var lc:int = 0; lc < obj.children.length; lc++)
            {
                // Need recursive function here - no telling how deep the folder structure goes
                var co:ObjectPaletteItemBO = obj.children.getItemAt(lc) as ObjectPaletteItemBO;
                this.processLoadingSpecificData(co);
            }
        }
    }

    private function handleLoadSpecificData(retObj:ResultEvent):void
    {
        var item:Item = null;
        var npc:NPC = null;
        var node:Node = null;

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
        else
        {
            trace("retObj data type couldn't be found, returning.");
            return;
        }

        trace("Time to look for it's matching Game Object.  Number Of Objects To Look Through: " + GameModel.getInstance().game.gameObjects.length);

        // Find the Game Object to attach to
        // Need to use recursion function to get into folders for objects attached there
        for (var j:Number = 0; j < GameModel.getInstance().game.gameObjects.length; j++)
        {
            var obj:ObjectPaletteItemBO = GameModel.getInstance().game.gameObjects.getItemAt(j) as ObjectPaletteItemBO;
            //trace("j = " + j + "; Looking at Game Object Id '" + obj.id + ".  It's Object Type = '" + obj.objectType + "', while it's Content Id = '" + obj.objectId + "'; Is Folder? " + obj.isFolder() + "");
            AppUtils.matchDataWithGameObject(obj, objType, npc, item, node);
        }
    }

    public function handleCreateGame(obj:Object):void
    {
        trace("Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create game attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Game");
        }
        else
        {
            trace("Game Creation was successfull");
            GameModel.getInstance().game.gameId = obj.result.data;
            GameModel.getInstance().game.name = nameOfGame.text;
            GameModel.getInstance().game.description = gameDescription.text;
            Alert.show("Your game was succesfully created.  Please use the editor to start building it.", "Successfully Created Game");
            StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITOR;
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called.  The error is: " + obj.fault.faultString);
        Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
    }
}
}