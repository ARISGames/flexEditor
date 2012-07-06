package org.arisgames.editor.view
{
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Canvas;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.DataGrid;
import mx.controls.HorizontalList;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.LinkButton;
import mx.controls.NumericStepper;
import mx.controls.TextArea;
import mx.controls.TextInput;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;

import org.arisgames.editor.components.GameEditorMediaPickerMX;
import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.PlaceMark;
import org.arisgames.editor.data.TabBarItem;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.arisserver.WebPage;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.models.SecurityModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;


public class GameDetailsEditorView extends Panel{
	[Bindable] public var gameName:TextInput;
	[Bindable] public var inventoryCap:NumericStepper;
    [Bindable] public var description:TextArea;
	[Bindable] public var introNodeCbo:mx.controls.ComboBox;
	[Bindable] public var completeNodeCbo:mx.controls.ComboBox;
	
	[Bindable] public var noteShareToMapCb:mx.controls.CheckBox;
	[Bindable] public var noteShareToBookCb:mx.controls.CheckBox;
	[Bindable] public var playerCreateTagsCb:mx.controls.CheckBox;
	[Bindable] public var isLocationalCb:mx.controls.CheckBox;
	[Bindable] public var readyForPublicCb:mx.controls.CheckBox;
	[Bindable] public var playerCreateCommentsCb:mx.controls.CheckBox;
	[Bindable] public var playerLikesNotesCb:mx.controls.CheckBox;
	
	[Bindable] public var saveAndCloseButton:Button;
	[Bindable] public var deleteButton:LinkButton;
	[Bindable] public var duplicateButton:LinkButton;

	
	//Media Stuff
	[Bindable] public var iconImageCanvas:Canvas;
	[Bindable] public var iconPreviewImage:Image;
	[Bindable] public var iconAVLinkButton:LinkButton;
	[Bindable] public var iconRemoveButton:Button;
	[Bindable] public var iconNoMediaLabel:Label;
	[Bindable] public var iconPopupMediaPickerButton:Button;
	
	[Bindable] public var mediaImageCanvas:Canvas;
	[Bindable] public var mediaPreviewImage:Image;
	[Bindable] public var mediaAVLinkButton:LinkButton;
	[Bindable] public var mediaRemoveButton:Button;
	[Bindable] public var mediaNoMediaLabel:Label;
	[Bindable] public var mediaPopupMediaPickerButton:Button;
	
	private var mediaPicker:GameEditorMediaPickerMX;
	
	[Bindable] public var addEditor:Button;
	[Bindable] public var removeEditor:Button;
	[Bindable] public var addEditorEmail:TextInput;
	[Bindable] public var removeEditorDG:DataGrid;
	//[Bindable] public var removeEditorEmail:TextInput;


	//
		
	public var game:Game;
	[Bindable] public var nodes:ArrayCollection;
	[Bindable] public var editors:ArrayCollection;
	[Bindable] public var tabList:ArrayCollection;
	[Bindable] public var tabView:HorizontalList;

    /**
     * Constructor
     */
    public function GameDetailsEditorView()
    {
        super();
		this.nodes = new ArrayCollection();
		this.tabList = new ArrayCollection();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
		trace("IconMediaId:" + GameModel.getInstance().game.iconMediaId + " MediaId:" + GameModel.getInstance().game.mediaId);
		
		loadGameMedia();
		
		saveAndCloseButton.addEventListener(MouseEvent.CLICK, handleSaveAndCloseButton);
		deleteButton.addEventListener(MouseEvent.CLICK, deleteButtonOnClickHandler);
		duplicateButton.addEventListener(MouseEvent.CLICK, duplicateButtonOnClickHandler);
		
		//Load up the data from the current Game
		gameName.text = GameModel.getInstance().game.name;
		inventoryCap.value = GameModel.getInstance().game.inventoryCap;
		description.text = GameModel.getInstance().game.description;
		
		noteShareToMapCb.selected = GameModel.getInstance().game.noteShareToMap;
		noteShareToBookCb.selected = GameModel.getInstance().game.noteShareToBook;
		playerCreateTagsCb.selected = GameModel.getInstance().game.playerCreateTags;
		isLocationalCb.selected = GameModel.getInstance().game.isLocational;
		readyForPublicCb.selected = GameModel.getInstance().game.readyForPublic;
		playerCreateCommentsCb.selected = GameModel.getInstance().game.playerCreateComments;
		playerLikesNotesCb.selected = GameModel.getInstance().game.playerLikesNotes;
		
		populateEditors();
		
		//ComboBoxes will load after their data loads
		
		//Fetch the nodes
		AppServices.getInstance().getPagesByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadNodes, handleFault));
		//Fetch tab bar data
		AppServices.getInstance().getTabBarItemsForGame(GameModel.getInstance().game.gameId, new Responder(handleLoadTabBarItems, handleFault));
    
		//MediaStuff
		iconAVLinkButton.addEventListener(MouseEvent.CLICK, handleIconAVButtonClick);
		mediaAVLinkButton.addEventListener(MouseEvent.CLICK, handleMediaAVButtonClick);
		iconRemoveButton.addEventListener(MouseEvent.CLICK, handleIconRemoveButtonClick);
		mediaRemoveButton.addEventListener(MouseEvent.CLICK, handleMediaRemoveButtonClick);
		iconPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleIconPickerButton);
		mediaPopupMediaPickerButton.addEventListener(MouseEvent.CLICK, handleMediaPickerButton);
	
		pushDataIntoGUI();
	}
	
	public function handleIconClick(evt:Event):void {
		trace("THIS-> "+tabView.selectedIndex);
		if(!tabList[tabView.selectedIndex].enabled)
		{
			tabList[tabView.selectedIndex].enabled = true;
			tabList[tabView.selectedIndex].append = "";
		}
		else if(tabList[tabView.selectedIndex].enabled)
		{
			tabList[tabView.selectedIndex].enabled = false;
			tabList[tabView.selectedIndex].append = "_DIM";
		}
		tabList.refresh();
	}
	
	private function loadGameMedia():void {
		if(GameModel.getInstance().game.iconMediaId != 0 && GameModel.getInstance().game.media == null)
			AppServices.getInstance().getMediaByGameIdAndMediaId(GameModel.getInstance().game.gameId, GameModel.getInstance().game.iconMediaId, new Responder(handleSetIconMedia, handleFault));
		if(GameModel.getInstance().game.mediaId != 0 && GameModel.getInstance().game.media == null)
			AppServices.getInstance().getMediaByGameIdAndMediaId(GameModel.getInstance().game.gameId, GameModel.getInstance().game.mediaId, new Responder(handleSetMedia, handleFault));
	}
	
	private function handleSetMedia(obj:Object):void{
		GameModel.getInstance().game.media = new Media();
		if(obj.result.data != null){
			GameModel.getInstance().game.media.mediaId = obj.result.data.media_id;
			GameModel.getInstance().game.media.name = obj.result.data.name;
			GameModel.getInstance().game.media.type = obj.result.data.type;
			GameModel.getInstance().game.media.urlPath = obj.result.data.url_path;
			GameModel.getInstance().game.media.fileName = obj.result.data.file_name;
			GameModel.getInstance().game.media.isDefault = obj.result.data.is_default;
		}
		this.pushDataIntoGUI();
	}
	
	private function handleSetIconMedia(obj:Object):void{
		GameModel.getInstance().game.iconMedia = new Media();
		if(obj.result.data != null){
			GameModel.getInstance().game.iconMedia.mediaId = obj.result.data.media_id;
			GameModel.getInstance().game.iconMedia.name = obj.result.data.name;
			GameModel.getInstance().game.iconMedia.type = obj.result.data.type;
			GameModel.getInstance().game.iconMedia.urlPath = obj.result.data.url_path;
			GameModel.getInstance().game.iconMedia.fileName = obj.result.data.file_name;
			GameModel.getInstance().game.iconMedia.isDefault = obj.result.data.is_default;
		}
		this.pushDataIntoGUI();
	}
	
	private function handleIconPickerButton(evt:MouseEvent):void
	{
		trace("GameDetailsEditorView: handleIconPickerButton() called...");
		this.openMediaPicker(true);
	}
	
	private function handleMediaPickerButton(evt:MouseEvent):void
	{
		trace("GameDetailsEditorView: handleMediaPickerButton() called...");
		this.openMediaPicker(false);
	}
	
	private function openMediaPicker(isIconMode:Boolean):void
	{
		mediaPicker = new GameEditorMediaPickerMX();
		mediaPicker.setIsIconPicker(isIconMode);
		mediaPicker.delegate = this;
		
		PopUpManager.addPopUp(mediaPicker, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(mediaPicker);
	}
	
	private function handleMediaRemoveButtonClick(evt:MouseEvent):void
	{
		trace("handleMediaRemoveButtonClick() called.");
		GameModel.getInstance().game.mediaId = 0;
		GameModel.getInstance().game.media = null;
		
		AppServices.getInstance().saveGame(GameModel.getInstance().game, new Responder(handleSaveGameAfterRemove, handleFault));
	}
	
	public function didSelectMediaItem(picker:GameEditorMediaPickerMX, m:Media):void
	{
		trace("GameDetailsEditorView: didSelectMediaItem()");
				
		if (picker.isInIconPickerMode())
		{
			GameModel.getInstance().game.iconMediaId = m.mediaId;
			GameModel.getInstance().game.iconMedia = m;
			trace("Just set Game Icon Media Id = '" + GameModel.getInstance().game.iconMediaId + "'");
		}
		else
		{
			GameModel.getInstance().game.mediaId = m.mediaId;
			GameModel.getInstance().game.media = m;
			trace("Just set Game Media Id = '" + GameModel.getInstance().game.mediaId + "'");
		}
		AppServices.getInstance().saveGame(GameModel.getInstance().game, new Responder(handleSaveGame, handleFault));		
		this.pushDataIntoGUI();
		
	}
	
	
	private function handleIconAVButtonClick(evt:MouseEvent):void
	{
		trace("IconAVButtonClick clicked!");
		var url:String = GameModel.getInstance().game.iconMedia.urlPath + GameModel.getInstance().game.iconMedia.fileName;
		trace("URL to launch = '" + url + "'");
		var req:URLRequest = new URLRequest(url);
		navigateToURL(req,"to_blank");
	}
	
	private function handleMediaAVButtonClick(evt:MouseEvent):void
	{
		trace("MediaAVButtonClick clicked!");
		var url:String = GameModel.getInstance().game.media.urlPath + GameModel.getInstance().game.media.fileName;
		trace("URL to launch = '" + url + "'");
		var req:URLRequest = new URLRequest(url);
		navigateToURL(req,"to_blank");
	}
	
	private function handleIconRemoveButtonClick(evt:MouseEvent):void
	{
		trace("handleIconRemoveButtonClick() called.");
		GameModel.getInstance().game.iconMediaId = 0;
		GameModel.getInstance().game.iconMedia = null;
		
		AppServices.getInstance().saveGame(GameModel.getInstance().game, new Responder(handleSaveGameAfterRemove, handleFault));
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
		Alert.show("Are you sure? This cannot be undone!", "Delete Game", Alert.YES|Alert.NO, this, delAlertClickHandler);
	}
	
	private function duplicateButtonOnClickHandler(evt:Event):void {
		Alert.show("Duplicate Game? The new name will be \""+GameModel.getInstance().game.name+"_copy\".", "Duplicate Game", Alert.YES|Alert.NO, this, dupAlertClickHandler);
	}
	
	private function delAlertClickHandler(evt:CloseEvent):void {
		if (evt.detail == Alert.YES) {
			GameModel.getInstance().game.deleteOnServer();
			StateModel.getInstance().currentState = StateModel.VIEWCREATEOROPENGAMEWINDOW;
			PopUpManager.removePopUp(this);
		} else {
			//Do nothing
		}
	}	
	
	private function dupAlertClickHandler(evt:CloseEvent):void {
		if (evt.detail == Alert.YES) {
			AppServices.getInstance().duplicateGame(GameModel.getInstance().game.gameId, new Responder(handleDuplicateGame, handleFault));
			PopUpManager.removePopUp(this);
		} else {
			//Do nothing
		}
	}	

	protected function handleDuplicateGame(obj:Object):void{
		trace("handleDuplicateGame called...");
		if (obj.result.returnCode != 0)
		{
			trace("Bad duplicate attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Duplicating Game");
		}
		else
		{
			trace("Successfully Duplicated Game! :)");
			Alert.show("Game successfully duplicated!", "Success");
		}
	}
	
	protected function handleWbpButton(event:MouseEvent):void
	{
		var loc:String = AppConstants.APPLICATION_ENVIRONMENT_SERVICES_URL + 
			"samples/jsWebBackPack/index.html?gameId=" + GameModel.getInstance().game.gameId;
		navigateToURL(new URLRequest(loc),"_blank");
	}
	
	protected function handlePcmMapButton(event:MouseEvent):void
	{
		var loc:String = AppConstants.APPLICATION_ENVIRONMENT_SERVICES_URL + 
			"samples/viewPlayerCreatedNotes.html?gameId=" + GameModel.getInstance().game.gameId;
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
	
	protected function handleRtmButton(event:MouseEvent):void
	{
		var loc:String = "https://docs.google.com/document/d/1BYluK42uO_CxuqW4T6wJoA4eb7lOtmIL78a14cOiAsk/edit?hl=en_US";
		navigateToURL(new URLRequest(loc),"_blank");
	}
	
	protected function handleJtcButton(event:MouseEvent):void
	{
		var loc:String = "https://groups.google.com/forum/?fromgroups#!forum/arisgames";
		navigateToURL(new URLRequest(loc),"_blank");
	}
	
	
	private function handleSaveAndCloseButton(evt:MouseEvent):void
	{
		trace("GameDetailsEditorView: handleSaveAndCloseButton");
		GameModel.getInstance().game.name = gameName.text;
		GameModel.getInstance().game.inventoryCap = inventoryCap.value;
		GameModel.getInstance().game.description = description.text;
		
		GameModel.getInstance().game.noteShareToMap = noteShareToMapCb.selected;
		GameModel.getInstance().game.noteShareToBook = noteShareToBookCb.selected;
		GameModel.getInstance().game.playerCreateTags = playerCreateTagsCb.selected;
		GameModel.getInstance().game.isLocational = isLocationalCb.selected;
		GameModel.getInstance().game.readyForPublic = readyForPublicCb.selected;
		GameModel.getInstance().game.playerCreateComments = playerCreateCommentsCb.selected;
		GameModel.getInstance().game.playerLikesNotes = playerLikesNotesCb.selected;

		var introNode:Node = introNodeCbo.selectedItem as Node;
		GameModel.getInstance().game.introNodeId = introNode.nodeId;
		var selectedNode:Node = completeNodeCbo.selectedItem as Node;
		GameModel.getInstance().game.completeNodeId = selectedNode.nodeId;
		
		GameModel.getInstance().game.saveOnServer();
		this.saveTabs();
		PopUpManager.removePopUp(this);
	}
	
	public function saveTabs():void{
		for(var x:Number = 0; x < this.tabList.length; x++)
		{
			tabList.getItemAt(x).index = x+1;
			AppServices.getInstance().saveTab(GameModel.getInstance().game.gameId, tabList.getItemAt(x) as TabBarItem, new Responder(handleSaveTab, handleFault));
		}
	}
	
	private function handleSaveGameAfterRemove(obj:Object):void
	{
		trace("handleSaveObjectAfterRemove called...");
		if (obj.result.returnCode != 0)
		{
			trace("Bad removal of icon / media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Removing Media Item");
		}
		else
		{
			trace("Successfully removed Icon / Media from the data model and database.  Now update the GUI.");
			this.pushDataIntoGUI();
		}
	}
	
	
	private function pushDataIntoGUI():void
	{
		trace("GameDetailsEditorView: Media Id = '" + GameModel.getInstance().game.mediaId + "'; Icon Media Object = '" + GameModel.getInstance().game.iconMedia + "'; Media Object = '" + GameModel.getInstance().game.media + "'");
		
		// Load The Icon Media
		if (GameModel.getInstance().game.iconMedia != null && (GameModel.getInstance().game.iconMedia.type == AppConstants.MEDIATYPE_AUDIO || GameModel.getInstance().game.iconMedia.type == AppConstants.MEDIATYPE_VIDEO))
		{
			iconImageCanvas.setVisible(false);
			iconImageCanvas.includeInLayout = false;
			iconPreviewImage.setVisible(true);
			iconPreviewImage.includeInLayout = true;
			iconAVLinkButton.setVisible(true);
			iconAVLinkButton.includeInLayout = true;
			iconNoMediaLabel.setVisible(false);
			iconNoMediaLabel.includeInLayout = false;
			iconRemoveButton.setVisible(true);
			iconRemoveButton.includeInLayout = true;
			
			if (GameModel.getInstance().game.iconMedia.type == AppConstants.MEDIATYPE_AUDIO)
			{
				iconAVLinkButton.label = "Listen To Audio";
			}
			else
			{
				iconAVLinkButton.label = "View Video";
			}
		}
		else if (GameModel.getInstance().game.iconMedia != null && (GameModel.getInstance().game.iconMedia.type == AppConstants.MEDIATYPE_IMAGE || GameModel.getInstance().game.iconMedia.type == AppConstants.MEDIATYPE_ICON))
		{
			iconImageCanvas.setVisible(true);
			iconImageCanvas.includeInLayout = true;
			iconPreviewImage.setVisible(true);
			iconPreviewImage.includeInLayout = true;
			iconAVLinkButton.setVisible(false);
			iconAVLinkButton.includeInLayout = false;
			iconNoMediaLabel.setVisible(false);
			iconNoMediaLabel.includeInLayout = false;
			iconRemoveButton.setVisible(true);
			iconRemoveButton.includeInLayout = true;
			
			var iconurl:String = GameModel.getInstance().game.iconMedia.urlPath + GameModel.getInstance().game.iconMedia.fileName;
			iconPreviewImage.source = iconurl;
			trace("GameDetailsEditorView: Just set icon image url = '" + iconurl + "'");
		}
		else
		{
			/*
			//BLANK SQUARE
			iconImageCanvas.setVisible(true);
			iconImageCanvas.includeInLayout = true;
			iconPreviewImage.setVisible(false);
			iconPreviewImage.includeInLayout = false;
			iconAVLinkButton.setVisible(false);
			iconAVLinkButton.includeInLayout = false;
			iconNoMediaLabel.setVisible(true);
			iconNoMediaLabel.includeInLayout = true;
			iconRemoveButton.setVisible(false);
			iconRemoveButton.includeInLayout = false;
			*/
			
			iconImageCanvas.setVisible(true);
			iconImageCanvas.includeInLayout = true;
			iconPreviewImage.setVisible(true);
			iconPreviewImage.includeInLayout = true;
			iconAVLinkButton.setVisible(false);
			iconAVLinkButton.includeInLayout = false;
			iconNoMediaLabel.setVisible(true);
			iconNoMediaLabel.includeInLayout = true;
			iconRemoveButton.setVisible(false);
			iconRemoveButton.includeInLayout = false;
			
			iconurl = AppConstants.IMG_DEFAULT_ICON_SIZE_REFERENCE_URL;
			iconPreviewImage.source = iconurl;
			trace("GameDetailsEditorView: Just set icon image url = '" + iconurl + "'");
		}
		
		// Load The Media GUI
		if (GameModel.getInstance().game.media != null && (GameModel.getInstance().game.media.type == AppConstants.MEDIATYPE_AUDIO || GameModel.getInstance().game.media.type == AppConstants.MEDIATYPE_VIDEO))
		{
			mediaImageCanvas.setVisible(false);
			mediaImageCanvas.includeInLayout = false;
			mediaPreviewImage.setVisible(false);
			mediaPreviewImage.includeInLayout = false;
			mediaAVLinkButton.setVisible(true);
			mediaAVLinkButton.includeInLayout = true;
			mediaNoMediaLabel.setVisible(false);
			mediaNoMediaLabel.includeInLayout = false;
			mediaRemoveButton.setVisible(true);
			mediaRemoveButton.includeInLayout = true;
			
			if (GameModel.getInstance().game.media.type == AppConstants.MEDIATYPE_AUDIO)
			{
				mediaAVLinkButton.label = "Listen To Audio";
			}
			else
			{
				mediaAVLinkButton.label = "View Video";
			}
		}
		else if (GameModel.getInstance().game.media != null && (GameModel.getInstance().game.media.type == AppConstants.MEDIATYPE_IMAGE || GameModel.getInstance().game.media.type == AppConstants.MEDIATYPE_ICON))
		{
			mediaImageCanvas.setVisible(true);
			mediaImageCanvas.includeInLayout = true;
			mediaPreviewImage.setVisible(true);
			mediaPreviewImage.includeInLayout = true;
			mediaAVLinkButton.setVisible(false);
			mediaAVLinkButton.includeInLayout = false;
			mediaNoMediaLabel.setVisible(false);
			mediaNoMediaLabel.includeInLayout = false;
			mediaRemoveButton.setVisible(true);
			mediaRemoveButton.includeInLayout = true;
			
			var mediaurl:String = GameModel.getInstance().game.media.urlPath + GameModel.getInstance().game.media.fileName;
			mediaPreviewImage.source = mediaurl;
			trace("Just set media image url = '" + mediaurl + "'");
		}
		else
		{
			
			/*
			// BLANK SQUARE
			mediaImageCanvas.setVisible(true);
			mediaImageCanvas.includeInLayout = true;
			mediaPreviewImage.setVisible(false);//?
			mediaPreviewImage.includeInLayout = false;//?
			mediaAVLinkButton.setVisible(false);
			mediaAVLinkButton.includeInLayout = false;
			mediaNoMediaLabel.setVisible(true);
			mediaNoMediaLabel.includeInLayout = true;
			mediaRemoveButton.setVisible(false);
			mediaRemoveButton.includeInLayout = false;
			*/
			
			mediaImageCanvas.setVisible(true);
			mediaImageCanvas.includeInLayout = true;
			mediaPreviewImage.setVisible(true);
			mediaPreviewImage.includeInLayout = true;
			mediaAVLinkButton.setVisible(false);
			mediaAVLinkButton.includeInLayout = false;
			mediaNoMediaLabel.setVisible(true);
			mediaNoMediaLabel.includeInLayout = true;
			mediaRemoveButton.setVisible(false);
			mediaRemoveButton.includeInLayout = false;
			
			mediaurl = AppConstants.IMG_DEFAULT_SPLASH_SIZE_REFERENCE_URL;
			mediaPreviewImage.source = mediaurl;
			trace("Just set media image url = '" + mediaurl + "'");
		}
	}

	private function handleSaveGame(obj:Object):void
	{
		trace("GameDetailsEditorView: handleSaveGame()");
		if (obj.result.returnCode != 0)
		{
			trace("Bad save of Game... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
			var msg:String = obj.result.returnCodeDescription;
			Alert.show("Error Was: " + msg, "Error While Selecting Media for Game");
		}
	}
	
	public function populateEditors():void{
		AppServices.getInstance().getGameEditors(GameModel.getInstance().game.gameId, new Responder(handlePopulateEditors, handleFault));
	}
	
	public function handlePopulateEditors(obj:Object):void{
		editors = new ArrayCollection();
		
		for(var x:Number = 0; x < obj.result.data.length; x++){
			editors.addItem(obj.result.data[x].email);
		}
	}
	
	public function handleAddEditor(evt:Event):void {
		if(addEditorEmail.text != ""){
			findUserIdFromEmail(addEditorEmail.text, true);
		}
	}
	
	public function handleRemoveEditor(evt:Event):void {
		if(removeEditorDG.selectedIndex != -1 && editors.getItemAt(removeEditorDG.selectedIndex) != null){
			findUserIdFromEmail(editors.getItemAt(removeEditorDG.selectedIndex) as String, false);
		}
	}
	
	private function handleAddedEditor(obj:Object):void{
		if(obj.result.returnCode != 0)
			Alert.show("User was not successfully added. Something went wrong.", "Error Adding Editor");
		else{
			editors.addItem(addEditorEmail.text);
			Alert.show("User was successfully added as an editor.", "Success!");
		}
	}
	private function handleRemovedEditor(obj:Object):void{
		if(obj.result.returnCode != 0)
			Alert.show("User was not successfully removed. Something went wrong.", "Error Removing Editor");
		else{
			editors.removeItemAt(removeEditorDG.selectedIndex);
			Alert.show("User was successfully removed as an editor.", "Success!");
		}
	}
	private function findUserIdFromEmail(email:String, add:Boolean):void{
		if(add){
			AppServices.getInstance().getEditors(new Responder(handleFindIdToAdd, handleFault));
		}
		else{
			AppServices.getInstance().getEditors(new Responder(handleFindIdToRemove, handleFault));
		}
	}
	private function handleFindIdToAdd(obj:Object):void
	{
		var editorId:Number = 0;
		var found:Boolean = false;
		
		for(var x:Number = 0; x < obj.result.data.length && !found; x++){
			if(obj.result.data[x].email.toLowerCase() == addEditorEmail.text.toLowerCase()){
				found = true;
				editorId = obj.result.data[x].editor_id;
			}
		}
		
		if(found){
			trace("Found ID for " + addEditorEmail.text + "; Id=" + editorId);
			AppServices.getInstance().addEditor(GameModel.getInstance().game.gameId, editorId, new Responder(handleAddedEditor, handleFault));
		}
		else
			Alert.show("User was not found in database", "404");
	}
	private function handleFindIdToRemove(obj:Object):void
	{
		var editorId:Number = 0;
		var found:Boolean = false;

		for(var x:Number = 0; x < obj.result.data.length && !found; x++){
			if(obj.result.data[x].email == editors.getItemAt(removeEditorDG.selectedIndex) as String){
				found = true;
				editorId = obj.result.data[x].editor_id;
				trace(obj.result.data[x].email);
			}
		}
		if(found){
			trace("Found ID for " + (editors.getItemAt(removeEditorDG.selectedIndex) as String) + "; Id=" + editorId);
			AppServices.getInstance().removeEditor(GameModel.getInstance().game.gameId, editorId, new Responder(handleRemovedEditor, handleFault));
		}
		else
			Alert.show("User was not found in database", "404");
	}
	
	public function handleLoadTabBarItems(obj:Object):void
	{
		if(obj.result.returnCode != 0)
			Alert.show("Error Loading Tab Bar Items");
		else{
			trace("Loaded tab bar items");
			for(var x:Number = 0; x < obj.result.data.length; x++)
			{
				var tab:TabBarItem = new TabBarItem(obj.result.data[x].tab, obj.result.data[x].tab_index, true, "");
				if(tab.index == 0){ tab.append = "_DIM"; tab.enabled = false;}
				if(tab.type != "PICKGAME" && tab.type != "STARTOVER") this.tabList.addItem(tab); //Don't allow changing of gamepicker
			}
			this.tabList.refresh();
		}
		
	}
	
	public function handleSaveTab(obj:Object):void
	{
		
	}
	
	public function handleTabReorder(evt:DragEvent):void
	{
		trace("Tab Re-ordered");
	}
	
    public function handleFault(obj:Object):void
    {
        trace("Fault called.  The error is: " + obj.fault.faultString);
        Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
	}
}
}