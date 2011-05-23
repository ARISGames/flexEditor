/**
 * Tree logic based on http://www.adobe.com/devnet/flex/quickstart/working_with_tree/src/TreeKeepOpen/index.html
 */

package org.arisgames.editor.view
{

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Panel;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Image;
import mx.controls.Menu;
import mx.controls.TextInput;
import mx.effects.Glow;
import mx.events.DragEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.managers.DragManager;
import mx.managers.PopUpManager;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;

import org.arisgames.editor.components.PaletteTree;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class GameEditorObjectPaletteView extends VBox
{
    [Bindable] public var objectPalette:Panel;
    [Bindable] public var addObjectButton:Button;
    [Bindable] public var addFolderButton:Button;
	[Bindable] public var editQuestsButton:Button;
	[Bindable] public var editGameButton:Button;
	[Bindable] public var returnToGameListButton:Button;

	//[Bindable] public var editDialogButton:Button;
	//[Bindable] public var editGoogleMapButton:Button;
    [Bindable] public var trashIcon:Image;
    [Bindable] public var glowImage:Glow;

    // Object Palette Tree Objects
    [Bindable] public var paletteTree:PaletteTree;
    [Bindable] public var open:Object = new Object();
    [Bindable] public var refreshData:Boolean = false;
    [Bindable] public var treeModel:ArrayCollection;
    [Bindable] public var provider:String = "treeModel";

    /**
     * Constructor
     */
    public function GameEditorObjectPaletteView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);

        // Setup Tree Data
        trace("This is the treeModel being glued to the GameModel.  The size is currently: '" + GameModel.getInstance().game.gameObjects.length + "'");
        treeModel = GameModel.getInstance().game.gameObjects;
    }

    private function onComplete(event:FlexEvent): void
    {
        addObjectButton.addEventListener(MouseEvent.CLICK, addObjectButtonOnClick);
        addFolderButton.addEventListener(MouseEvent.CLICK, addFolderButtonOnClick);
		editQuestsButton.addEventListener(MouseEvent.CLICK, editQuestsButtonOnClick);
		editGameButton.addEventListener(MouseEvent.CLICK, editGameButtonOnClick);
		returnToGameListButton.addEventListener(MouseEvent.CLICK, returnToGameListButtonOnClick);

        paletteTree.addEventListener(ListEvent.ITEM_EDIT_END, handlePaletteObjectDataEditFinished);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.APPLICATIONDYNAMICEVENT_CURRENTSTATECHANGED, handleCurrentStateChangedEvent);
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE, handleRedrawTreeEvent);
		
		AppServices.getInstance().getFoldersAndContentByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadFoldersAndContentForObjectPalette, handleFault));

    }

	private function handleCurrentStateChangedEvent(obj:Object):void
	{
		trace("GameEditorObjectPalletView: handleCurrentStateChangedEvent");
		
		if (StateModel.getInstance().currentState == StateModel.VIEWGAMEEDITOR){
			trace("GameEditorObjectPalletView: handleCurrentStateChangedEvent: Refreshing");
			this.refreshData = true;
			AppServices.getInstance().getFoldersAndContentByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadFoldersAndContentForObjectPalette, handleFault));
		}
	}
	
	private function handleLoadFoldersAndContentForObjectPalette(obj:Object):void
	{
		trace("GameEditorObjectPaletteView: Starting handleLoadFoldersAndContentForObjectPalette()...");
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
			op.isOpen = obj.result.data.folders.list.getItemAt(j).is_open;
			trace("Folder Loaded: Id-"+op.id+" Name-"+op.name+" parentFolderId-"+op.previousFolderId+" previousFolderId-"+op.previousFolderId+" isOpen-"+op.isOpen);
			ops.addItem(op);
		}
		trace("Folders loaded, number of object palette BOs = '" + ops.length + "'");
		
		/*
		// Sort By Previous Folder Id From 0 to N
		var opsTemp:ArrayCollection = ops;
		ops = new ArrayCollection();
		
		
		//Iterates #folders times (the max depth can only be the max num folders)
		for(var l:Number = 0; l < 20; l++){
			//Iterates each folder searching for ones at depth l
			for(var n:Number = 0; n < opsTemp.length; n++){
				if(opsTemp.getItemAt(n).parentFolderId == l){
					ops.addItem(opsTemp.getItemAt(n));
				}
			}
		}
		*/
		
		//This doesn't work correctly, and Phil doesn't understand
		//this, so he's going to do it the old fashioned way ^^
		var dataSortField:SortField = new SortField();
		dataSortField.name = "previousFolderId";
		dataSortField.numeric = true;
		
		var numericDataSort:Sort = new Sort();
		numericDataSort.fields = [dataSortField];
		//*
		ops.sort = numericDataSort;
		ops.refresh();
		//*/

		
		trace("Folders sorted by Previous Folder Id");
		
		var dict:Dictionary = new Dictionary();
		
		for (j = 0; j < ops.length; j++)
		{
			op = ops.getItemAt(j) as ObjectPaletteItemBO;
			trace("j = " + j + "; Folder Id = '" + op.id +"'; Folder Name = '" + op.name + "'; Parent Id = '" + op.parentFolderId + "'; Previous Folder Id = '" + op.previousFolderId);
			trace("THESE ARE THE FOLDER'S CHILDREN :" + op.children + " ? ");
			if(op.children == null) trace("NULL?!?!?!");
			if (op.parentFolderId == 0)
			{
				// It's at the root level
				dict[op.id] = op;
			}
			else
			{
				// It's a child of a previously added object
				var o:ObjectPaletteItemBO = dict[op.previousFolderId] as ObjectPaletteItemBO;
				if(o == null){
					//if this is reached, the folder has a "previous folder Id" of a folder that does not exist
					op.parentFolderId = 0;
					dict[op.id] = op;
				}
				else{
					o.children.addItem(op);
				}

			}
		}
		trace("Folders loaded into dictionary.");
		trace("Loaded Folder heirarchy: (Only shows root+1 depth)");
		var continues:Boolean = true;
		var i:Number = 0;
		for (var key:Object in dict){
			trace(dict[key].name);
			for(var k:Number = 0; k < dict[key].children.length; k++){
				trace("    "+dict[i].children.getItemAt(k).name);
			}
		}
		
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
			trace("j = " + j + "; Object Id = '" + op.id +"'; Object Name = '" + op.name + "'; Parent Id = '" + op.parentFolderId + "'; Previous Folder Id = '" + op.previousFolderId);
			
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
		
		GameModel.getInstance().game.gameObjects.removeAll();
		GameModel.getInstance().game.gameObjects.addAll(rfc);
		this.loadSpecificDataIntoGameObjects();
		trace("Done attaching underlying data to game objects.  Should be ready for GUI now.");
		
		treeModel = GameModel.getInstance().game.gameObjects;
		treeModel.refresh();
		paletteTree.openFolders();
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

	
    private function handlePaletteObjectDataEditFinished(evt:ListEvent):void
    {
        trace("handlePaletteObjectDataEditFinished called...");

        // Ben's Crazy Idea To Capture Newly Edited Data Starts Here
        var ti:TextInput = paletteTree.itemEditorInstance as TextInput;
        trace("Hopefully new value = '" + ti.text + "'");
        // Ben's Crazy Idea To Capture Newly Edited Data Ends Here

        var index:Number = evt.rowIndex;
        var obj:ObjectPaletteItemBO = treeModel.getItemAt(index) as ObjectPaletteItemBO;
        trace("index = '" + index + "'; game id = '" + GameModel.getInstance().game.gameId + "'; object type = '" + obj.objectType + "'");

        if (obj.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
        {
                trace("It's a character...");
                var npc:NPC = new NPC();
                npc.npcId = obj.objectId;
                npc.name = ti.text;
                AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, npc, new Responder(handleSaveItem, handleFault));
        }
        else if (obj.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
                trace("It's an item...");
                var it:Item = new Item();
                it.itemId = obj.objectId;
                it.name = ti.text;
                AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, it, new Responder(handleSaveItem, handleFault));
        }
        else if (obj.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
        {
                trace("It's a page...");
                var node:Node = new Node();
                node.nodeId = obj.objectId;
                node.title = ti.text;
                AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, node, new Responder(handleSavePage, handleFault));
        }
        else if (obj.isFolder())
        {
            trace("It's a folder, with ID = '" + obj.id + "'");
            obj.name = ti.text;
            AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, obj, new Responder(handleSaveFolder, handleFault));
        }
        else
        {
            trace("No germane Content Type found, so this palette object was NOT saved!!!!!");
        }

        trace("handlePaletteObjectDataEditFinished finished.");
    }
	
	
	private function returnToGameListButtonOnClick(evt:MouseEvent):void
	{
		StateModel.getInstance().currentState = StateModel.VIEWCREATEOROPENGAMEWINDOW;
	}
	
	
	private function editGameButtonOnClick(evt:MouseEvent):void
	{
		var gameEditor:GameDetailsEditorMX = new GameDetailsEditorMX();
		
		this.parent.addChild(gameEditor);
		// Need to validate the display so that entire component is rendered
		gameEditor.validateNow();
		
		PopUpManager.addPopUp(gameEditor, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(gameEditor);
		gameEditor.setVisible(true);
		gameEditor.includeInLayout = true;
	}

    private function addObjectButtonOnClick(evt:MouseEvent):void
    {
        var pt:Point = new Point();
        var myMenu:Menu;

        var myMenuData:Array = [{label: AppConstants.CONTENTTYPE_CHARACTER, type: "normal"}, {label: AppConstants.CONTENTTYPE_ITEM, type: "normal"}, {label: AppConstants.CONTENTTYPE_PAGE, type: "normal"}];

        myMenu = Menu.createMenu(objectPalette, myMenuData, false);
        myMenu.addEventListener("itemClick", menuHandler);

        // Calculate position of Menu in Application's coordinates.
        pt.x = addObjectButton.x;
        pt.y = addObjectButton.y;
        pt = addObjectButton.localToGlobal(pt);

        myMenu.show(pt.x + 0, pt.y - 66); // WB Magic number values here, play around with them as needed
    }

    private function addFolderButtonOnClick(evt:MouseEvent):void
    {
        trace("addFolderButtonOnClick() started...");
        var o:ObjectPaletteItemBO = new ObjectPaletteItemBO(true);
        o.id = 0;
        o.name = "New Folder " + new Date();
		paletteTree.expandItem(o, true, false, false, null);
		o.isOpen = true;
        this.addObjectPaletteItem(o);
    }
	
	private function editQuestsButtonOnClick(evt:MouseEvent):void 
	{
		trace("editQuestsButtonOnClick() started... ");
		var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_OPENQUESTSEDITOR);
		AppDynamicEventManager.getInstance().dispatchEvent(de);
	}
	
	private function editDialogButtonOnClick(evt:MouseEvent):void
	{
		trace("editDialogButtonOnClick() started... ");
	}

    private function menuHandler(event:MenuEvent):void
    {
        trace("menu handler is called; label = '" + event.label + "'");
        var stuff:String = event.label;
        if (AppConstants.CONTENTTYPE_CHARACTER == stuff)
        {
            trace("add a character to the object palette...");
            var o:ObjectPaletteItemBO = new ObjectPaletteItemBO(false);
            o.name = "Unnamed Character";
            o.objectType = AppConstants.CONTENTTYPE_CHARACTER_DATABASE;
            o.iconMediaId = AppConstants.DEFAULT_ICON_MEDIA_ID_NPC;
            this.addObjectPaletteItem(o);
        }
        else if (AppConstants.CONTENTTYPE_ITEM == stuff)
        {
            trace("add an item to the object palette...");
            var i:ObjectPaletteItemBO = new ObjectPaletteItemBO(false);
            i.name = "Unnamed Item";
            i.objectType = AppConstants.CONTENTTYPE_ITEM_DATABASE;
            i.iconMediaId = AppConstants.DEFAULT_ICON_MEDIA_ID_ITEM;
            this.addObjectPaletteItem(i);
        }
        else if (AppConstants.CONTENTTYPE_PAGE == stuff)
        {
            trace("add a page to the object palette...");
            var p:ObjectPaletteItemBO = new ObjectPaletteItemBO(false);
            p.name = "Unnamed Plaque";
            p.objectType = AppConstants.CONTENTTYPE_PAGE_DATABASE;
            p.iconMediaId = AppConstants.DEFAULT_ICON_MEDIA_ID_PLAQUE;
            this.addObjectPaletteItem(p);
        }
        trace("Done with menuHandler.");
    }

    public function addObjectPaletteItem(item:ObjectPaletteItemBO):void
    {
        trace("Started addObjectPaletteItem() with item's object type = '" + item.objectType + "'");
        AppUtils.printPaletteObjectDataModel();

        // Save To Database
        if (item.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE)
        {
            var npc:NPC = new NPC();
            npc.npcId = 0;
            npc.name = item.name;
            npc.iconMediaId = item.iconMediaId;
            AppServices.getInstance().saveCharacter(GameModel.getInstance().game.gameId, npc, new Responder(handleCreateCharacter, handleFault));
            trace("Just finished calling saveCharacter() for name = '" + item.name + "'.");
        }
        else if (item.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE)
        {
            var it:Item = new Item();
            it.itemId = 0;
            it.name = item.name;
            it.iconMediaId = item.iconMediaId;
            AppServices.getInstance().saveItem(GameModel.getInstance().game.gameId, it, new Responder(handleCreateItem, handleFault));
            trace("Just finished calling saveItem() for name = '" + item.name + "'.");
        }
        else if (item.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE)
        {
            var node:Node = new Node();
            node.nodeId = 0;
            node.title = item.name;
            node.iconMediaId = item.iconMediaId;
            AppServices.getInstance().savePage(GameModel.getInstance().game.gameId, node, new Responder(handleCreatePage, handleFault));
            trace("Just finished calling savePage() for name = '" + item.name + "'.");
        }
        else if (item.isFolder())
        {
            trace("Item is a folder, so do initial save of it here.")
            AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, item, new Responder(handleSaveFolder, handleFault));
        }
        else
        {
            trace("***** addObjectPaletteItem DID NOT SAVE core data! *****");
        }
        trace("Done with save to database.  Item ID = '" + item.objectId + "'");

        if (item.isFolder())
        {
            treeModel.addItemAt(item, 0);
        }
        else
        {
            treeModel.addItem(item);
        }
        trace("tree data model updated....");
        AppUtils.printPaletteObjectDataModel();

        open = paletteTree.openItems;
        refreshData = true;
        trace("End of addObjectPaletteItem()");

    }

    private function handleRedrawTreeEvent(evt:DynamicEvent):void
    {
        trace("In handleRefreshTreeEvent...");
        refreshData = true;
        this.renderTree();
		paletteTree.openFolders();
        trace("Done in handleRefreshTreeEvent.");
    }

    public function renderTree():void
    {
        if (refreshData)
        {
            trace("refreshData is true, so going to refresh the data on the tree.");
            AppUtils.printPaletteObjectDataModel();
            // Refresh Tree on update.
            paletteTree.invalidateList();
            refreshData = false;
            paletteTree.openItems = open;
            // Validate and update properties
            // of the Tree and redraw it if necessary.
            paletteTree.validateNow();
        }
    }

    public function trashDragEnterHandler(evt:DragEvent):void
    {
        // Get the drop target component from the event object.
        var dropTarget:Image = evt.currentTarget as Image;

        trace("Drag Source = '" + evt.dragSource + "'");

        var itemsArray:Array = evt.dragSource.dataForFormat('treeItems') as Array;
        trace("itemsArray created with size = '" + itemsArray.length + "'");

        var it:ObjectPaletteItemBO = itemsArray[0];
        trace("Object: Id = '" + it.id +"'; is Folder? = '" + it.isFolder() + "'; Name = '" + it.name + "'");

        // If folder check all items in data model to see if any point to it before allowing deletion.
        var okDrop:Boolean = true;
        if (it.isFolder())
        {
            trace("Dragged Object is a folder, so check to see if it's got any children before allowing deletion.")
            if (it.children.length > 0)
            {
                trace("This folder has children, so can't allow it to be deleted.");
                okDrop = false;
            }
        }

        if (okDrop)
        {
            // Trick to make effect happen
            trashIcon.visible = false;
            trashIcon.visible = true;

            // Accept the drop.
            DragManager.acceptDragDrop(dropTarget);
        }
        else
        {
            Alert.show("This folder has items in it and can't be deleted until they are first removed.  Please do so and then try deleting the folder again.", "Can't Delete Folder Yet");
        }
    }

    public function trashDragExitHandler(evt:DragEvent):void
    {
        // Stop Effect And Reset Trash Bin To Original State
        glowImage.end();
    }

    public function trashDragDropHandler(evt:DragEvent):void
    {
        trace("trashDragDropHandler called!  New data tree looks like...");
        AppUtils.printPaletteObjectDataModel();

        // Remove From Server Side Palette Object Model
        var itemsArray:Array = evt.dragSource.dataForFormat('treeItems') as Array;
        trace("itemsArray created with size = '" + itemsArray.length + "'");

        var it:ObjectPaletteItemBO = itemsArray[0];
        trace("Object: Id = '" + it.id +"'; is Folder? = '" + it.isFolder() + "'; Name = '" + it.name + "'");

        if (it.isFolder())
        {
            AppServices.getInstance().deleteFolder(GameModel.getInstance().game.gameId, it, new Responder(handleDeleteFolder, handleFault));
        }
        else
        {
            AppServices.getInstance().deleteContent(GameModel.getInstance().game.gameId, it, new Responder(handleDeleteContent, handleFault));
        }

        // Remove From Client Data Model
        var index:Number;
        for (var lc:Number = 0; lc < treeModel.length; lc++)
        {
            var t:ObjectPaletteItemBO = treeModel[lc] as ObjectPaletteItemBO;
            if (t.id == it.id)
            {
                index = lc;
                break;
            }
        }
        trace("Found index to remove...");
        treeModel.removeItemAt(index);
        refreshData = true;
        this.renderTree();

        // Stop Effect And Reset Trash Bin To Original State
        glowImage.end();
    }

    public function handleSaveItem(obj:Object):void
    {
        trace("GameEditorObjectPalletView: In handleSaveItem() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("GameEditorObjectPalletView: Bad save item attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Item");
        }
        else
        {
            trace("GameEditorObjectPalletView: Save item was successful.");
        }
        trace("GameEditorObjectPalletView: Finished with handleSaveItem().");
    }

    public function handleSaveCharacter(obj:Object):void
    {
        trace("GameEditorObjectPalletView: handleSaveCharacter() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("GameEditorObjectPalletView: Bad save character attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Character");
        }
        else
        {
            trace("GameEditorObjectPalletView: Save character was successful.");
        }
        trace("GameEditorObjectPalletView: Finished with handleSaveCharacter().");
    }

    public function handleSavePage(obj:Object):void
    {
        trace("GameEditorObjectPalletView: In handleSavePage() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("GameEditorObjectPalletView: Bad save page attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("GameEditorObjectPalletView: Error Was: " + msg, "Error While Saving Page");
        }
        else
        {
            trace("GameEditorObjectPalletView: Save page was successful.");
        }
        trace("GameEditorObjectPalletView: Finished with handleSavePage().");
    }

    public function handleCreateItem(obj:Object):void
    {
        trace("In handleCreateItem() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create item attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Item");
        }
        else
        {
            trace("Create item was successful.");
            for (var lc:Number = 0; lc < treeModel.length; lc++)
            {
                var it:ObjectPaletteItemBO = treeModel.getItemAt(lc) as ObjectPaletteItemBO;
                trace("LC = " + lc + "; it.id = '" + it.id + "; Object Type = '" + it.objectType + "'; objectId = '" + it.objectId + "'; Return Object Id = '" + obj.result.data + "'");
                if (it.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE && isNaN(it.objectId))
                {
                    it.id = 0;
                    it.objectId = obj.result.data;
                    trace("Found a Item with a NULL object Id, so setting it to the data's result: " + obj.result.data);
                    AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, it, new Responder(handleSaveContent, handleFault));
                    break;
                }
            }
        }
        trace("Finished with handleCreateItem().");
    }

    public function handleCreateCharacter(obj:Object):void
    {
        trace("In handleCreateCharacter() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create character attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Character");
        }
        else
        {
            trace("Create character was successful.");
            for (var lc:Number = 0; lc < treeModel.length; lc++)
            {
                var it:ObjectPaletteItemBO = treeModel.getItemAt(lc) as ObjectPaletteItemBO;
                trace("LC = " + lc + "; it.id = '" + it.id + "; Object Type = '" + it.objectType + "'; objectId = '" + it.objectId + "'; Return Object Id = '" + obj.result.data + "'");
                if (it.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE && isNaN(it.objectId))
                {
                    it.id = 0;
                    it.objectId = obj.result.data;
                    trace("Found a Character with a NULL object Id, so setting it to the data's result: " + obj.result.data);
                    AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, it, new Responder(handleSaveContent, handleFault));
                    break;
                }
            }
        }
        trace("Finished with handleCreateCharacter().");
    }

    public function handleCreatePage(obj:Object):void
    {
        trace("In handleCreatePage() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create page attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Character");
        }
        else
        {
            trace("Create page was successful.");
            for (var lc:Number = 0; lc < treeModel.length; lc++)
            {
                var it:ObjectPaletteItemBO = treeModel.getItemAt(lc) as ObjectPaletteItemBO;
                trace("LC = " + lc + "; it.id = '" + it.id + "; Object Type = '" + it.objectType + "'; objectId = '" + it.objectId + "'; Return Object Id = '" + obj.result.data + "'");
                if (it.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE && isNaN(it.objectId))
                {
                    it.id = 0;
                    it.objectId = obj.result.data;
                    trace("Found a Page with a NULL object Id, so setting it to the data's result: " + obj.result.data);
                    AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, it, new Responder(handleSaveContent, handleFault));
                    break;
                }
            }
        }
        trace("Finished with handleCreatePage().");
    }

    private function handleLoadingOfIconMedia(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Bad reloading of content for purposes of loading icon media data... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Character");
        }
        else
        {
            // loop through tree model and match object palette id with object_content_id in returned data... then load icon media data
            trace("Made it successfully into handleLoadingOfIconMedia(): ObjectPaletteItem ID = '" + obj.result.data.object_content_id + "'; icon media id = '" + obj.result.data.icon_media_id + "'");

            for (var lc:Number = 0; lc < treeModel.length; lc++)
            {
                var it:ObjectPaletteItemBO = treeModel.getItemAt(lc) as ObjectPaletteItemBO;
                if (!it.isFolder() && it.id == obj.result.data.object_content_id)
                {
                    var m:Media = new Media();
                    m.mediaId = obj.result.data.icon_media.media_id;
                    m.name = obj.result.data.icon_media.name;
                    m.type = obj.result.data.icon_media.type;
                    m.urlPath = obj.result.data.icon_media.url_path;
                    m.fileName = obj.result.data.icon_media.file_name;
                    m.isDefault = obj.result.data.icon_media.is_default;
                    trace("Icon Media Data Loaded: mediaId = '" + m.mediaId + "'; name = '" + m.name + "'; type = '" + m.type + "'; urlPath = '" + m.urlPath + "'; fileName = '" + m.fileName + "'; isDefault = '" + m.isDefault + "'");

                    it.iconMediaId = obj.result.data.icon_media_id;
                    it.iconMedia = m;
                    trace("Found the germane ObjectPaletteItem and attached the Icon Media data to it for use by the GUI.");

                    // Reload Icon In Object Palette
                    var uop:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE);
                    AppDynamicEventManager.getInstance().dispatchEvent(uop);
                    return;
                }
            }
        }
    }

    public function handleSaveFolder(obj:Object):void
    {
        trace("In handleSaveFolder() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create folder attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Folder");
        }
        else
        {
            trace("Create folder was successful.");
            for (var lc:Number = 0; lc < treeModel.length; lc++)
            {
                var it:ObjectPaletteItemBO = treeModel.getItemAt(lc) as ObjectPaletteItemBO;
                trace("LC = " + lc + "; Item Id = " + it.id + "; Item Object Id = " + it.objectId + "; Item Object Type = " + it.objectType + "; Item Name = " + it.name);
                if (it.isFolder() && it.id == 0)
                {
                    it.id = obj.result.data;
                    trace("Found a Folder with a NULL object Id, so setting it to the data's result: " + obj.result.data);
                    this.sortAndSavePaletteObjects();
                    break;
                }
            }
        }
        trace("Finished with handleSaveFolder().");
    }

    public function handleSaveContent(obj:Object):void
    {
        trace("In handleSaveContent() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad create content attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Creating Content");
        }
        else
        {
            trace("Create Content was successful.");
            for (var lc:Number = 0; lc < treeModel.length; lc++)
            {
                var it:ObjectPaletteItemBO = treeModel.getItemAt(lc) as ObjectPaletteItemBO;
                if (!it.isFolder() && it.id == 0)
                {
                    it.id = obj.result.data;
                    trace("Found a Content Object with a NULL object Id, so setting it to the data's result: " + obj.result.data);
                    trace("Data Model In Editor Now Equals = ");
                    AppUtils.printPaletteObjectDataModel();
                    trace("Done Displaying New Data Model In Editor.");
                    this.sortAndSavePaletteObjects();

                    // Make sure default icon media is loaded
                    AppServices.getInstance().getContent(GameModel.getInstance().game.gameId, it.id, new Responder(handleLoadingOfIconMedia, handleFault));

                    // Make sure that underlying data is attached (for create object use case)
                    if (it.objectType == AppConstants.CONTENTTYPE_CHARACTER_DATABASE && it.character == null)
                    {
                        trace("Object With Id = " + it.id + " is missing it's Character data (ID = " + it.objectId + "), so need to load it.");
                        AppServices.getInstance().getCharacterById(GameModel.getInstance().game.gameId, it.objectId, new Responder(handlePairingOfCharacterData, handleFault))
                    }
                    else if (it.objectType == AppConstants.CONTENTTYPE_ITEM_DATABASE && it.item == null)
                    {
                        trace("Object With Id = " + it.id + " is missing it's Item data (ID = " + it.objectId + "), so need to load it.");
                        AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, it.objectId, new Responder(handlePairingOfItemData, handleFault))
                    }
                    else if (it.objectType == AppConstants.CONTENTTYPE_PAGE_DATABASE && it.page == null)
                    {
                        trace("Object With Id = " + it.id + " is missing it's Page data (ID = " + it.objectId + "), so need to load it.");
                        AppServices.getInstance().getPageById(GameModel.getInstance().game.gameId, it.objectId, new Responder(handlePairingOfPlaqueData, handleFault))
                    }
                    break;
                }
            }
        }
        trace("Finished with handleSaveContent().");
    }

    private function handlePairingOfCharacterData(obj:Object):void
    {
        trace("In handlePairingOfCharacterData() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad handlePairingOfCharacterData... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Adding Character");
        }
        else
        {
            var data:Object = obj.result.data;
            var npc:NPC = AppUtils.parseResultDataIntoNPC(data);

            for (var lc:Number = 0; lc < GameModel.getInstance().game.gameObjects.length; lc++)
            {
                var opi:ObjectPaletteItemBO = GameModel.getInstance().game.gameObjects.getItemAt(lc) as ObjectPaletteItemBO;
                AppUtils.matchDataWithGameObject(opi, AppConstants.CONTENTTYPE_CHARACTER_DATABASE, npc, null, null);
            }
        }
    }

    private function handlePairingOfItemData(obj:Object):void
    {
        trace("In handlePairingOfItemData() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad handlePairingOfItemData... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Adding Item");
        }
        else
        {
            var data:Object = obj.result.data;
            var item:Item = AppUtils.parseResultDataIntoItem(data);

            for (var lc:Number = 0; lc < GameModel.getInstance().game.gameObjects.length; lc++)
            {
                var opi:ObjectPaletteItemBO = GameModel.getInstance().game.gameObjects.getItemAt(lc) as ObjectPaletteItemBO;
                AppUtils.matchDataWithGameObject(opi, AppConstants.CONTENTTYPE_ITEM_DATABASE, null, item, null);
            }
        }
    }

    private function handlePairingOfPlaqueData(obj:Object):void
    {
        trace("In handlePairingOfPlaqueData() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad handlePairingOfPlaqueData... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Adding Plaque");
        }
        else
        {
            var data:Object = obj.result.data;
            var node:Node = AppUtils.parseResultDataIntoNode(data);

            for (var lc:Number = 0; lc < GameModel.getInstance().game.gameObjects.length; lc++)
            {
                var opi:ObjectPaletteItemBO = GameModel.getInstance().game.gameObjects.getItemAt(lc) as ObjectPaletteItemBO;
                AppUtils.matchDataWithGameObject(opi, AppConstants.CONTENTTYPE_PAGE_DATABASE, null, null, node);
            }
        }
    }

    public function handleDeleteFolder(obj:Object):void
    {
        trace("In handleDeleteFolder() Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad delete folder attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Deleting Folder");
        }
        else
        {
            trace("Delete folder was successful.");
            this.sortAndSavePaletteObjects();
        }
        trace("Finished with handleDeleteFolder().");
    }

    public function handleDeleteContent(obj:Object):void
    {
        trace("GameEditorObjectPalletView: handleDeleteContent() Result called with obj = " + obj + "; Result = " + obj.result);
		
		//close open placemark editors...
		GameModel.getInstance().removeOpenPlaceMarkEditors();		
		
        if (obj.result.returnCode != 0)
        {
            trace("GameEditorObjectPalletView: Bad delete content attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Deleting Content");
        }
        else
        {
            trace("GameEditorObjectPalletView: Delete content was successful. Refresh Object Pallet and Locations");
            this.sortAndSavePaletteObjects();
			GameModel.getInstance().loadLocations();

        }
		
        trace("Finished with handleDeleteContent().");
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "More problems");
    }

    private function sortAndSavePaletteObjects():void
    {
        trace("Starting sortAndSavePaletteObjects()...");
        // Update the data objects associations and save to database
        var go:ArrayCollection = AppUtils.repairPaletteObjectAssociations();
        for (var lc:Number = 0; lc < go.length; lc++)
        {
            var obj:ObjectPaletteItemBO = go.getItemAt(lc) as ObjectPaletteItemBO;
            if (obj.isFolder())
            {
                AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, obj, new Responder(handleSortAndSaveCallback, handleFault));
            }
            else
            {
                AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, obj, new Responder(handleSortAndSaveCallback, handleFault));
            }
        }
		paletteTree.openFolders();
        trace("Finished with sortAndSavePaletteObjects().");
    }

    private function handleSortAndSaveCallback(obj:Object):void
    {
        trace("handleSortAndSaveCallback() called...");
    }
}
}