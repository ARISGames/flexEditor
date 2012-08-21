package org.arisgames.editor.components
{

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.Tree;
import mx.events.DragEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.events.TreeEvent;
import mx.rpc.Responder;
import mx.utils.ObjectUtil;

import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;


public class PaletteTree extends Tree
{
    private var currentObjectBeingDragged:ObjectPaletteItemBO = null;
	private var playerContentFolderOpen:Boolean = false;

    /**
     * Constructor
     */
    public function PaletteTree()
    {
        super();
		editorXOffset = 50;
		editorWidthOffset = -50;
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR, handleCloseBOEditor);
		this.addEventListener(MouseEvent.CLICK, listenForMouseSingleClicks)
        this.addEventListener(MouseEvent.DOUBLE_CLICK, listenForMouseDoubleClicks)
		this.addEventListener(TreeEvent.ITEM_OPEN, saveFolderOpen)
		this.addEventListener(TreeEvent.ITEM_CLOSE, saveFolderClose)
    }
	
	private function saveFolderOpen(event:TreeEvent):void {
		trace("Folder Opening...");
		var thisFolder:ObjectPaletteItemBO = event.item as ObjectPaletteItemBO;
		thisFolder.isOpen = true;
		if(thisFolder.isClientContentFolder){
			trace("Opened PlayerGenContent Folder");
			this.playerContentFolderOpen = true;
		}
		AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, thisFolder, new Responder(handleSavePaletteObject, handleFault));
	}
	
	private function saveFolderClose(event:TreeEvent):void {
		trace("Folder Closing...");
		var thisFolder:ObjectPaletteItemBO = event.item as ObjectPaletteItemBO;
		thisFolder.isOpen = false;
		if(thisFolder.isClientContentFolder){
			trace("ClosePlayerGenContent Folder");
			this.playerContentFolderOpen = false;
		}
		//
		AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, thisFolder, new Responder(handleSavePaletteObject, handleFault));
	}
	
	private function handleCloseBOEditor(evt:Event):void {
		trace("Closing editor...");
		trace("Opening folders after handleCloseBOEditor");
		openFolders();
	}
	
	public function openFolders():void {
		trace("PaleteTree: Opening Folders... (openFolders())");
		var go:ArrayCollection = AppUtils.repairPaletteObjectAssociations();
		for (var lc:Number = 0; lc < go.length; lc++)
		{
			var obj:ObjectPaletteItemBO = go.getItemAt(lc) as ObjectPaletteItemBO;
			if (obj.isFolder())
			{
				if(obj.isClientContentFolder){
					if(this.playerContentFolderOpen){
						trace("PlayerCreatedObjects folder IS open");
						expandItem(obj, true, false, false, null);
					}
				}
				if(obj.isOpen){
					trace("This folder is open: "+ obj.name);
					expandItem(obj, true, false, false, null);
				}
			}
		}
		trace("PaleteTree: Done Opening Folders... (openFolders())");
	}

	private function listenForMouseSingleClicks(evt:MouseEvent):void
	{
		var obj:ObjectPaletteItemBO = this.selectedItem as ObjectPaletteItemBO;
		if(obj == null){
			trace("click detected- not on item. returning");
			return;
		}
		trace("Just got a single click for '" + evt.currentTarget + "'; Selected Item = '" + this.selectedItem + "'; Selected Data = '" + this.selectedData + "'; Object Name = '" + obj.name + "'");
		
		var de:DynamicEvent;
		//Find Level of folder heirarchy
		var level:int = 0;
		var ob:ObjectPaletteItemBO = this.selectedItem as ObjectPaletteItemBO;
		while(ob.parentContentFolderId != 0)
		{
			level++;
			ob = AppUtils.findParentObjectPaletteItem(ob);
		}
		if(evt.stageX > ((level*16)+36) && evt.stageX < ((level*16)+58)) //Reeally awful code to detect whether the icon was clicked or not.
		{
			de = new DynamicEvent(AppConstants.DYNAMICEVENT_HIDEOBJECTPALETTEITEM);
			this.selectedItem.isHidden = !this.selectedItem.isHidden;
			de.objectPaletteItem = this.selectedItem;
			AppDynamicEventManager.getInstance().dispatchEvent(de);	
			
		}
		else
		{
			de = new DynamicEvent(AppConstants.DYNAMICEVENT_HIGHLIGHTOBJECTPALETTEITEM);
			de.objectPaletteItem = this.selectedItem;
			AppDynamicEventManager.getInstance().dispatchEvent(de);	
			
			//Also, unhide when selected
			if(this.selectedItem.isHidden)
			{
				de = new DynamicEvent(AppConstants.DYNAMICEVENT_HIDEOBJECTPALETTEITEM);
				this.selectedItem.isHidden = !this.selectedItem.isHidden;
				de.objectPaletteItem = this.selectedItem;
				AppDynamicEventManager.getInstance().dispatchEvent(de);
			}
			
			
		}
		this.invalidateList();
		// Validate and update properties
		// of the Tree and redraw it if necessary.
		this.validateNow();
		de = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_GAMEPLACEMARKSLOADED);
		AppDynamicEventManager.getInstance().dispatchEvent(de);
		
		//Remove placemark editors...
		GameModel.getInstance().removeOpenPlaceMarkEditors();	
	}
	
    private function listenForMouseDoubleClicks(evt:MouseEvent):void
    {
        var obj:ObjectPaletteItemBO = this.selectedItem as ObjectPaletteItemBO;
		if(obj == null){
			trace("double click detected- not on item. returning");
			return;
		}
        trace("Just got a double click for '" + evt.currentTarget + "'; Selected Item = '" + this.selectedItem + "'; Selected Data = '" + this.selectedData + "'; Object Name = '" + obj.name + "'");
		if(this.selectedItem.isClientContentFolder) {
			trace("Don't do anything though, because it is the ios content folder");
			return;	
		}
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_EDITOBJECTPALETTEITEM);
        de.objectPaletteItem = this.selectedItem;
        AppDynamicEventManager.getInstance().dispatchEvent(de);
		
		//Remove placemark editors...
		GameModel.getInstance().removeOpenPlaceMarkEditors();		
    }

    /**
     * Overriden to stop the Tree from removing item that's been drug out of Tree from Tree data model, in effect
     * keeping it a "copy" operation and not a "move" operation.
     * @param event DragEvent
     * @return void
     */
    protected override function dragCompleteHandler(event:DragEvent):void
    {
        trace("In overridden dragCompleteHandler!");
        // No ObjectPaletteItemBO appears in DragSource
        trace("Done in overridden dragCompleteHandler!");
    }

	
    protected override function dragDropHandler(event:DragEvent):void
    {
        super.dragDropHandler(event);
        trace("In overriden dragDropHandler with DragEvent's dragged source = " + event.dragSource + "; Has TreeItems Format: " + event.dragSource.hasFormat('treeItems') + "; Dragged Item = '" + event.draggedItem + "'");
        // NOTE: No ObjectPaletteItemBO appears in DragSource
        trace("The Dragged Object Id = " + currentObjectBeingDragged.id + "'; Name = '" + currentObjectBeingDragged.name + "'; is Folder = '" + currentObjectBeingDragged.isFolder() + "'");

        // Update the data objects associations and save to database
        var go:ArrayCollection = AppUtils.repairPaletteObjectAssociations();
        for (var lc:Number = 0; lc < go.length; lc++)
        {
            var obj:ObjectPaletteItemBO = go.getItemAt(lc) as ObjectPaletteItemBO;
            if (obj.isFolder())
            {
                AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, obj, new Responder(handleSavePaletteObject, handleFault));
            }
            else
            {
                AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, obj, new Responder(handleSavePaletteObject, handleFault));
            }
        }
		
		


/*
        // Step 1 - Look For Item That Previously Pointed To Moved Item as it's previous option
        var go:ArrayCollection = AppUtils.flattenGameObjectIntoArrayCollection(null);
        for(var lc:Number = 0; lc < go.length; lc++)
        {
            var o:ObjectPaletteItemBO = go.getItemAt(lc) as ObjectPaletteItemBO;
            if (currentObjectBeingDragged.isFolder())
            {
                // Moved Object Is A Folder
                if (o.isFolder() && o.previousFolderId == currentObjectBeingDragged.id)
                {
                    trace("Found the Folder That was previously after the moved Folder.  It's ID = '" + o.id + "'");
                    o.previousFolderId = currentObjectBeingDragged.previousFolderId;
                    AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, o, new Responder(handleSavePaletteObject, handleFault));
                    break;
                }
            }
            else
            {
                // Moved Object Is A Regular Object
                if (o.previousContentId == currentObjectBeingDragged.id)
                {
                    trace("Found the Object That was previously after the moved object.  It's ID = '" + o.id + "'");
                    o.previousContentId = currentObjectBeingDragged.previousContentId;
                    AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, o, new Responder(handleSavePaletteObject, handleFault));
                    break;
                }
            }
        }

        // Step 2 - Find recently moved object and update it's new previous id spot (as well as parent folder if need be)
        // Look At Root
        go.removeAll();
        go.addAll(AppUtils.flattenGameObjectIntoArrayCollection(null));
        var g:ObjectPaletteItemBO;
        var pg:ObjectPaletteItemBO;
        var foundIt:Boolean = false;

        for (lc = 0; lc < go.length; lc++)
        {
            g = go.getItemAt(lc) as ObjectPaletteItemBO;
            if (currentObjectBeingDragged.id = g.id)
            {
                currentObjectBeingDragged.parentFolderId = 0;

                if (pg != null)
                {
                    if (currentObjectBeingDragged.isFolder())
                }

            }


            if (currentObjectBeingDragged.isFolder() && g.isFolder())
            {

            }


            if (g.isFolder())
            {
                // Looking At A Folder

                // Is this object in there?  If so update parent folder id and previous content id
                var res:int = ArrayUtil.getItemIndex(currentObjectBeingDragged, g.children.toArray());
                if (res != -1)
                {
                    // Found it!
                    currentObjectBeingDragged.parentFolderId = g.id;
                    if ((res != 0) && !((g.children.toArray()[res - 1] as ObjectPaletteItemBO).isFolder()))
                    {
                        currentObjectBeingDragged.previousContentId = (g.children.toArray()[res - 1] as ObjectPaletteItemBO).id;
                    }
                    else
                    {
                        currentObjectBeingDragged.previousContentId = 0;
                    }

                    if (currentObjectBeingDragged.isFolder())
                    {
                        AppServices.getInstance().saveFolder(GameModel.getInstance().game.gameId, currentObjectBeingDragged, new Responder(handleSavePaletteObject, handleFault));
                        foundIt = true;
                        break;
                    }
                    else
                    {
                        AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, currentObjectBeingDragged, new Responder(handleSavePaletteObject, handleFault));
                        foundIt = true;
                        break;
                    }
                }
                else
                {
                    // The folder is at this level
                }
            }
            else
            {
                // Looking At An Item

                // If found then update it's previous content id (and set parent folder id to whatever the previous item's folder id is)
                // If statement automatically excludes folders from comparison (as they will never have same id)
                if (currentObjectBeingDragged.id == g.id)
                {
                    if (pg == null)
                    {
                        currentObjectBeingDragged.previousContentId = 0;
                    }
                    else
                    {
                        currentObjectBeingDragged.previousContentId = pg.id;
                    }

                    trace("Found the object that was moved.  It is still at the root level so updating it's previousContentId and saving.");
                    foundIt = true;
                    AppServices.getInstance().saveContent(GameModel.getInstance().game.gameId, currentObjectBeingDragged, new Responder(handleSavePaletteObject, handleFault));
                    break;
                }
            }

            if (!foundIt)
            {
                if (currentObjectBeingDragged.isFolder())
                {
                    // Set to root level
                }
            }

            pg = go.getItemAt(lc) as ObjectPaletteItemBO;
        }
*/


//        this.printTreeModel();
		trace("Drop index: " + super.calculateDropIndex(event));
        trace("Done with dragDropHandler()!");
    }

    protected override function dragEnterHandler(event:DragEvent):void
    {
		if(this.selectedItem.isClientContentFolder) {
			trace("Do not allow this to be dragged");
			return;
		}
        super.dragEnterHandler(event);
        trace("In overriden dragEnterHandler with DragEvent's dragged source = " + event.dragSource + "; Has TreeItems Format: " + event.dragSource.hasFormat('treeItems') + "; Dragged Item = '" + event.draggedItem + "'");
        // Get Object That Moved
        var oa:Array = event.dragSource.dataForFormat('treeItems') as Array;
        trace("oa size = " + oa.length);
        for(var i:Number=0; i < oa.length; i++)
        {
            currentObjectBeingDragged = ObjectPaletteItemBO(oa[i]);
            trace("Dragged Object Id = " + currentObjectBeingDragged.id + "'; Name = '" + currentObjectBeingDragged.name + "'");
            break;
        }
        trace("Done with dragEnterHandler()!");
    }

    private function handleSavePaletteObject(obj:Object):void
    {
        trace("handleSavePaletteObject() called...");		
        trace("Finished with handleSavePaletteObject.");
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called...");
        Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
    }
}
}