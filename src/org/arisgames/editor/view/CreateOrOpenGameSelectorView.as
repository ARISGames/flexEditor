package org.arisgames.editor.view
{
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
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
import org.arisgames.editor.data.arisserver.WebPage;
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
		doubleClickEnabled = true;
        createGameButton.addEventListener(MouseEvent.CLICK, onCreateButtonClick);
        loadGameButton.addEventListener(MouseEvent.CLICK, onLoadButtonClick);
		gamesDataGrid.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
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
			g.iconMediaId = obj.result.data.list.getItemAt(j).icon_media_id;
			g.mediaId = obj.result.data.list.getItemAt(j).media_id;
			g.pcMediaId = obj.result.data.list.getItemAt(j).pc_media_id;
			g.introNodeId = obj.result.data.list.getItemAt(j).on_launch_node_id;
			g.completeNodeId = obj.result.data.list.getItemAt(j).game_complete_node_id;
			g.noteShareToMap = obj.result.data.list.getItemAt(j).allow_share_note_to_map;
			g.noteShareToBook = obj.result.data.list.getItemAt(j).allow_share_note_to_book;
			g.playerCreateComments = obj.result.data.list.getItemAt(j).allow_note_comments;
			g.playerLikesNotes = obj.result.data.list.getItemAt(j).allow_note_likes;
			g.playerCreateTags = obj.result.data.list.getItemAt(j).allow_player_tags;
			g.isLocational = obj.result.data.list.getItemAt(j).is_locational;
			g.readyForPublic = obj.result.data.list.getItemAt(j).ready_for_public;
			g.inventoryCap = obj.result.data.list.getItemAt(j).inventory_weight_cap;
			g.allowtrading = obj.result.data.list.getItemAt(j).allow_trading;
			g.showPlayerOnMap = obj.result.data.list.getItemAt(j).show_player_location;
			
			usersGames.addItem(g);
        }
        trace("done loading UsersGames.");
    }

    private function onCreateButtonClick(evt:MouseEvent):void
    {
		trace("create button clicked!");
		var g:Game = new Game();
		GameModel.getInstance().game = g;
		g.name = nameOfGame.text;
		g.description = gameDescription.text;

        AppServices.getInstance().saveGame(g, new Responder(handleCreateGame, handleFault));
    }
	
    private function onLoadButtonClick(evt:MouseEvent):void
    {
		trace("load button clicked!");
		//make sure something is happening
		if(gamesDataGrid.selectedItem != null){
	        var g:Game = gamesDataGrid.selectedItem as Game;
	        trace("Selected game to load data for has Id = " + g.gameId);
	
	        // Load the game into the app's models
	        GameModel.getInstance().game = g;
	        GameModel.getInstance().game.placeMarks.removeAll();
	        GameModel.getInstance().game.gameObjects.removeAll();
			GameModel.getInstance().shouldCenterOnLoad = true;
			GameModel.getInstance().loadLocations();
	
	        StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITOR;
			
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
    }

	private function onDoubleClick(evt:MouseEvent):void
	{
		trace("Double Click");
		//make sure something is happening
		if(gamesDataGrid.selectedItem != null){
			var g:Game = gamesDataGrid.selectedItem as Game;
			trace("Selected game to load data for has Id = " + g.gameId);
			
			// Load the game into the app's models
			GameModel.getInstance().game = g;
			GameModel.getInstance().game.placeMarks.removeAll();
			GameModel.getInstance().game.gameObjects.removeAll();
			GameModel.getInstance().shouldCenterOnLoad = true;
			GameModel.getInstance().loadLocations();
			
			StateModel.getInstance().currentState = StateModel.VIEWGAMEEDITOR;
			
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
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
            
			//Clear everything from previous loads of other games
			GameModel.getInstance().game.placeMarks.removeAll();
			GameModel.getInstance().game.gameObjects.removeAll();
			GameModel.getInstance().shouldCenterOnLoad = true;
			GameModel.getInstance().loadLocations();

			
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