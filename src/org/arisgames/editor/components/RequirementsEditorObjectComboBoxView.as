package org.arisgames.editor.components
{
import mx.collections.ArrayCollection;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.collections.Sort; 
import mx.collections.SortField; 

import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppUtils;

public class RequirementsEditorObjectComboBoxView extends VBox implements IDropInListItemRenderer
{
    // GUI
    [Bindable] public var cbo:ComboBox;
    [Bindable] public var possibleObjects:ArrayCollection;

    private var _listData:DataGridListData;
    // Define a property for returning the new value to the cell.
    [Bindable] public var value:Object;

    /**
     * Constructor
     */
    public function RequirementsEditorObjectComboBoxView()
    {
        super();
        possibleObjects = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in RequirementsEditorObjectComboBoxView's handleInit");
    }

    override public function get data():Object
    {
        trace("RequirementsEditorObjectComboBoxView.getData() called.  Returning = '" + super.data + "'");
        return super.data;
    }

    override public function set data(value:Object):void
    {
        trace("RequirementsEditorObjectComboBoxView.setData() called with value = '" + value + "'");
        super.data = value;
        var req:Requirement = value as Requirement;
		if(!AppUtils.isObjectsHavingRequirementType(req))
			return;
//        trace("What will be assigned = '" + value[_listData.dataField] + "'; The Requirement Id = '" + req.requirementId + "'; The Requirement = '" + req.requirement + "'");
        trace("What will be assigned (new) = '" + req.requirementDetail1 + "'; The Requirement Id = '" + req.requirementId + "'; The Requirement = '" + req.requirement + "'");

        // Reload PossibleObjects
//        cbo.data = value[_listData.dataField];
        cbo.data = req.requirementDetail1;
        this.loadPossibleObjectsBasedOnRequirement(req.requirement);
    }

    public function get listData():BaseListData
    {
        trace("RequirementsEditorObjectComboBoxView.getListData called.  Returning = '" + _listData + "'");
        return _listData;
    }

    public function set listData(value:BaseListData):void
    {
        trace("RequirementsEditorObjectComboBoxView.setListData() called with value = '" + value + "'");
        //        _listData = (value as DataGridListData);
        _listData = DataGridListData(value);
    }

    public function get text():String
    {
        if (value != null)
        {
            trace("Value doesn't equal null, so return a value.  value = '" + value.toString() + "'");
            return value.toString();
        }
        trace("No Text To Return");
        return "No Text To Return";
    }

    public function set text(value:String):void
    {
        trace("set text() called with value = '" + value + "'");
    }

    public function loadPossibleObjectsBasedOnRequirement(req:String):void
    {
        trace("loadPossibleObjectsBasedOnRequirement() called with req = '" + req + "'");

        if (req == null)
        {
            trace("req passed in is null, can't load any objects based off of it.");
            return;
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_ITEM_DATABASE)
        {
            trace("going to load items - 1");
            AppServices.getInstance().getItemsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadItems, handleFault));
        }
		else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_TAGGED_ITEM_DATABASE)
		{
			trace("going to load items - 1");
			AppServices.getInstance().getTagsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadTags, handleFault));
		}
        else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE)
        {
            trace("going to load items - 2");
            AppServices.getInstance().getItemsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadItems, handleFault));
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE)
        {
            trace("going to load nodes - 3");
            AppServices.getInstance().getPagesByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNodes, handleFault));
        }
        else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE)
        {
            trace("going to load npc - 4");
            AppServices.getInstance().getCharactersByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNPCs, handleFault));
        }
		else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_DATABASE)
		{
			trace("going to load quests - 5");
			AppServices.getInstance().getQuestsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadQuests, handleFault));
		}
		else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_WEBPAGE_DATABASE)
		{
			trace("going to load webPages - 6");
			AppServices.getInstance().getWebPagesByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadWebPages, handleFault));
		}
		else if (req == AppConstants.REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_DATABASE)
		{
			trace("going to load augBubbles - 7");
			AppServices.getInstance().getAugBubblesByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadAugBubbles, handleFault));
		}
		else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_DATABASE){
			trace("going to load incoming web hooks - 8");
			AppServices.getInstance().getWebHooksByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadWebHooks, handleFault));
		}
        else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_DATABASE)
        {
            trace("Upload Media option selected... editor will need to be reconfigured here to support different data model.");
        }
		else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_DATABASE){
			trace("going to load game tags");
			AppServices.getInstance().getNoteTagsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadGameTags, handleFault));
		}
		else if (req == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_DATABASE || req == AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_DATABASE || AppConstants.REQUIREMENT_PLAYER_HAS_NOTE_DATABASE || AppConstants.REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_DATABASE)
		{
			trace("Upload Media option selected... editor will need to be reconfigured here to support different data model.");
		}
        else
        {
            trace("Should never have gotten this far, but if it does there's not going to be any objects loaded.");
        }
    }

	private function handleLoadQuests(obj:Object):void
	{

		trace("handling load quests...");
		possibleObjects.removeAll();
		if(obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible quests attempt... let's see what happened. Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible Items");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].name;
				if(obj.result.data[j].description != "")
					to.label += ": " + obj.result.data[j].description;
				to.data = obj.result.data[j].quest_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("RequirementsEditorObjectComboBoxView: Loaded '" + possibleObjects.length + "' Possible Quest Object(s).");
		}
		
	}
	
	private function handleLoadWebHooks(obj:Object):void
	{
		
		trace("handling load web hooks...");
		possibleObjects.removeAll();
		if(obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible web hooks attempt... let's see what happened. Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible web hooks");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				if(obj.result.data[j].incoming){
					var to:Object = new Object();
					to.label = obj.result.data[j].name;
					if(obj.result.data[j].url != "")
						to.label += ": " + obj.result.data[j].url;
					to.data = obj.result.data[j].web_hook_id;
					possibleObjects.addItem(to);
				}
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("RequirementsEditorObjectComboBoxView: Loaded '" + possibleObjects.length + "' Possible web hook(s).");
		}
		
	}
	
	private function handleLoadGameTags(obj:Object):void
	{
		
		trace("handling load game note tags...");
		possibleObjects.removeAll();
		if(obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible game tags attempt... let's see what happened. Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible game tags");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].tag;
				to.data = obj.result.data[j].tag_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("RequirementsEditorObjectComboBoxView: Loaded '" + possibleObjects.length + "' Possible game tag(s).");
		}
		
	}
	
	private function handleLoadItems(obj:Object):void
	{
		trace("handling load items...");
		possibleObjects.removeAll();
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible items attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible Items");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].name;
				if(obj.result.data[j].description != "")
					to.label += ": " + obj.result.data[j].description;
				to.data = obj.result.data[j].item_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("Loaded '" + possibleObjects.length + "' Possible Item Object(s).");
		}
	}
	
	private function handleLoadTags(obj:Object):void
	{
		trace("handling load tags...");
		possibleObjects.removeAll();
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible tags attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible tagss");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].name;
				to.data = obj.result.data[j].tag_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("Loaded '" + possibleObjects.length + "' Possible Item Object(s).");
		}
	}
	
	private function handleLoadWebPages(obj:Object):void
	{
		trace("handling load web Pages...");
		possibleObjects.removeAll();
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible webPages attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible web Pages");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].name;
				if(obj.result.data[j].url != "")
					to.label += ": " + obj.result.data[j].url;
				to.data = obj.result.data[j].web_page_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("Loaded '" + possibleObjects.length + "' Possible Web Page Object(s).");
		}
	}
	
	private function handleLoadAugBubbles(obj:Object):void
	{
		trace("handling load aug Bubbles...");
		possibleObjects.removeAll();
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible augBubbles attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible aug bubbles");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].name;
				if(obj.result.data[j].description != "")
					to.label += ": " + obj.result.data[j].description;
				to.data = obj.result.data[j].aug_bubble_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("Loaded '" + possibleObjects.length + "' Possible Aug Bubble Object(s).");
		}
	}
	
	private function handleLoadCustomMaps(obj:Object):void
	{
		trace("handling load custom maps...");
		possibleObjects.removeAll();
		if (obj.result.returnCode != 0)
		{
			trace("Bad handle loading possible customMaps attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Loading Possible aug bubbles");
		}
		else
		{
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var to:Object = new Object();
				to.label = obj.result.data[j].name;
				if(obj.result.data[j].description != "")
					to.label += ": " + obj.result.data[j].description;
				to.data = obj.result.data[j].aug_bubble_id;
				possibleObjects.addItem(to);
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
			trace("Loaded '" + possibleObjects.length + "' Possible Custom Map Object(s).");
		}
	}
	
    private function handleLoadNodes(obj:Object):void
    {
        trace("handling load Nodes...");
        possibleObjects.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading possible nodes attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Possible Nodes");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.length; j++)
            {
                var to:Object = new Object();
                to.label = obj.result.data[j].title;
				if(obj.result.data[j].title != "")
					if(obj.result.data[j].npc_id != "0") to.label = obj.result.data[j].name + "::" + to.label + ": " + obj.result.data[j].text;
					else to.label += ": " + obj.result.data[j].text;
                to.data = obj.result.data[j].node_id;
                possibleObjects.addItem(to);
            }
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
            possibleObjects.refresh();
            this.updateComboBoxSelectedItem();
            trace("Loaded '" + possibleObjects.length + "' Possible Nodes Object(s).");
        }
    }

    private function handleLoadNPCs(obj:Object):void
    {
        trace("handling load NPCs...");
        possibleObjects.removeAll();
        if (obj.result.returnCode != 0)
        {
            trace("Bad handle loading possible NPCs attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Possible NPCs");
        }
        else
        {
            for (var j:Number = 0; j < obj.result.data.length; j++)
            {
                var to:Object = new Object();
                to.label = obj.result.data[j].name;
				if(obj.result.data[j].description != "")
					to.label += ": " + obj.result.data[j].description;
                to.data = obj.result.data[j].npc_id;
                possibleObjects.addItem(to);
            }
			var dataSortField:SortField = new SortField();
			dataSortField.name = "label";
			dataSortField.numeric = false;
			dataSortField.caseInsensitive = true;
			var alphabeticSort:Sort = new Sort();
			alphabeticSort.fields = [dataSortField];
			possibleObjects.sort = alphabeticSort;
            possibleObjects.refresh();
            this.updateComboBoxSelectedItem();
            trace("Loaded '" + possibleObjects.length + "' Possible NPC Object(s).");
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems In Requirements Editor");
    }

    private function updateComboBoxSelectedItem():void
    {
        trace("in updateComboBoxSelectedItem(), looking for Object to match = '" + cbo.data + "'");
        for (var j:Number = 0; j < possibleObjects.length; j++)
        {
            var o:Object = possibleObjects.getItemAt(j);
            trace("j = '" + j + "'; cbo.data = '" + cbo.data + "'; Object Id (o.data) = '" + o.data + "'; Object's Human Label (o.label) = '" + o.label + "'");
            if (cbo.data == o.label || cbo.data == o.data)
            {
                trace("Found the Object that matched, now setting ComboBox's selectedItem to it.");
                cbo.selectedItem = o;
                return;
            }
        }
    }
}
}