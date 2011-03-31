package org.arisgames.editor.view
{
import flash.events.MouseEvent;
import flash.utils.Dictionary;
import flash.net.navigateToURL;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.DataGrid;
import mx.controls.LinkButton;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.CloseEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
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


public class GameDetailsEditorView extends Panel{
    [Bindable] public var gameName:TextInput;
    [Bindable] public var description:TextArea;
	[Bindable] public var introNodeCbo:mx.controls.ComboBox;
	[Bindable] public var completeNodeCbo:mx.controls.ComboBox;
	[Bindable] public var allowPlayerLocationsCb:mx.controls.CheckBox;
	[Bindable] public var deletePlayerLocationsCb:mx.controls.CheckBox;
	
	[Bindable] public var saveAndCloseButton:Button;
	[Bindable] public var deleteButton:LinkButton;
	
	public var game:Game;
	[Bindable] public var nodes:ArrayCollection;

    /**
     * Constructor
     */
    public function GameDetailsEditorView()
    {
        super();
		this.nodes = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
		saveAndCloseButton.addEventListener(MouseEvent.CLICK, handleSaveAndCloseButton);
		deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonOnClickHandler);
		
		
		//Load up the data from the current Game
		gameName.text = GameModel.getInstance().game.name;
		description.text = GameModel.getInstance().game.description;
		allowPlayerLocationsCb.selected = GameModel.getInstance().game.allowsPlayerCreatedLocations;
		deletePlayerLocationsCb.selected = GameModel.getInstance().game.resetDeletesPlayerCreatedLocations;
		//ComboBoxes will load after their data loads
		
		//Fetch the nodes
		AppServices.getInstance().getPagesByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNodes, handleFault));

    }

	private function handleLoadNodes(obj:Object):void
	{
		trace("GameDetailsEditorView: handleLoadNodes");
		nodes.removeAll();
		
		//Insert a bugus Node
		var nullNode:Node = new Node();
		nullNode.title = "None";
		nodes.addItem(nullNode);
		
		if (obj.result.returnCode != 0)
		{
			var msg:String = obj.result.returnCodeDescription;
			trace("GameDetailsEditorView: handleLoadNodes error :" + msg);
			Alert.show(msg, "Error While Loading Possible Nodes");
		}
		else
		{
			//Get em in the array
			for (var j:Number = 0; j < obj.result.data.length; j++)
			{
				var newNode:Node = AppUtils.parseResultDataIntoNode(obj.result.data[j]) as Node;
				nodes.addItem(newNode);
			}
			nodes.refresh();
			trace("GameDetailsEditorView: handleLoadNodes loaded " + nodes.length + " Node Object(s).");
			
			//Select the current nodes
			this.updateComboBoxSelectedNodeFromId(introNodeCbo, GameModel.getInstance().game.introNodeId);
			this.updateComboBoxSelectedNodeFromId(completeNodeCbo, GameModel.getInstance().game.completeNodeId);

		}
	}
	
	private function updateComboBoxSelectedNodeFromId(cbo:mx.controls.ComboBox, nodeId:int):void
	{
		for (var j:Number = 0; j < nodes.length; j++){
			var n:Node = nodes.getItemAt(j) as Node;
			if (n.nodeId == nodeId) cbo.selectedItem = n;
		}
	}
	

	private function deleteButtonOnClickHandler(evt:Event):void {
		Alert.show("Are you sure? This cannot be undone!", "Delete Game", Alert.YES|Alert.NO, this, alertClickHandler);
	}
	
	private function alertClickHandler(evt:CloseEvent):void {
		if (evt.detail == Alert.YES) {
			GameModel.getInstance().game.deleteOnServer();
			StateModel.getInstance().currentState = StateModel.VIEWCREATEOROPENGAMEWINDOW;
			PopUpManager.removePopUp(this);
		} else {
			//Do nothing
		}
	}	

	
	protected function handlePcmMapButton(event:MouseEvent):void
	{
		var loc:String = AppConstants.APPLICATION_ENVIRONMENT_SERVICES_URL + 
			"REST_CollectedItems.php?gameId=" + GameModel.getInstance().game.gameId + "&type=map";
		navigateToURL(new URLRequest(loc),"_blank");
	}
	
	protected function handlePcmKMLButton(event:MouseEvent):void
	{
		var loc:String = AppConstants.APPLICATION_ENVIRONMENT_SERVICES_URL + 
			"REST_CollectedItems.php?gameId=" + GameModel.getInstance().game.gameId + "&type=kml";
		navigateToURL(new URLRequest(loc),"_blank");
	}
	
	
	protected function handleGameLocsKMLButton(event:MouseEvent):void
	{
		var loc:String = AppConstants.APPLICATION_ENVIRONMENT_SERVICES_URL + 
			"REST_Locations.php?gameId=" + GameModel.getInstance().game.gameId + "&type=kml";
		navigateToURL(new URLRequest(loc),"_blank");
	}
	
	
	
	private function handleSaveAndCloseButton(evt:MouseEvent):void
	{
		trace("GameDetailsEditorView: handleSaveAndCloseButton");
		GameModel.getInstance().game.name = gameName.text;
		GameModel.getInstance().game.description = description.text;
		GameModel.getInstance().game.allowsPlayerCreatedLocations = allowPlayerLocationsCb.selected;
		GameModel.getInstance().game.resetDeletesPlayerCreatedLocations = deletePlayerLocationsCb.selected;
		var introNode:Node = introNodeCbo.selectedItem as Node;
		GameModel.getInstance().game.introNodeId = introNode.nodeId;
		var selectedNode:Node = completeNodeCbo.selectedItem as Node;
		GameModel.getInstance().game.completeNodeId = selectedNode.nodeId;
		
		GameModel.getInstance().game.saveOnServer();
		PopUpManager.removePopUp(this);
	}
	
    public function handleFault(obj:Object):void
    {
        trace("Fault called.  The error is: " + obj.fault.faultString);
        Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
	}
}
}