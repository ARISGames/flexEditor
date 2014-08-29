package org.arisgames.editor.view
{

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.containers.ApplicationControlBar;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.DataGrid;
import mx.controls.TextInput;
import mx.core.IUIComponent;
import mx.events.DataGridEvent;
import mx.events.DragEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.DragManager;
import mx.rpc.Responder;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

import mx.managers.PopUpManager;
import mx.rpc.Responder;

import org.arisgames.editor.components.MediaPickerMX;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.arisserver.Quest;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class GameEditorMapView extends VBox
{

  [Bindable] public var locations:ArrayCollection;
  [Bindable] public var locs:DataGrid;
  [Bindable] public var addLocationButton:Button;
  [Bindable] public var mapControlBar:ApplicationControlBar;
  [Bindable] public var refreshButton:Button;

  public function GameEditorMapView()
  {
    super();
    locations = new ArrayCollection();
    this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
  }

  private function handleInit(event:FlexEvent):void
  {
	this.loadLocations(null);
  }

  private function loadLocations(obj:Object):void
  {
    AppServices.getInstance().getLocationsByGameId(GameModel.getInstance().game.gameId, new Responder(handleLoadLocations, handleFault));
  }

  private function handleLoadLocations(obj:Object):void
  {
    locations.removeAll();
    for(var i:Number = 0; i < obj.result.data.list.length; i++)
    {
      var l:Location = new Location();
      l.locationId        = obj.result.data.list.getItemAt(i).location_id;
      l.latitude          = obj.result.data.list.getItemAt(i).latitude;
      l.longitude         = obj.result.data.list.getItemAt(i).longitude;
      l.name              = obj.result.data.list.getItemAt(i).name;
      l.errorText         = obj.result.data.list.getItemAt(i).fail_text;
      l.type              = obj.result.data.list.getItemAt(i).type;
      l.typeId            = obj.result.data.list.getItemAt(i).type_id;
      l.iconMediaId       = obj.result.data.list.getItemAt(i).icon_media_id;
      l.error             = obj.result.data.list.getItemAt(i).error;
      l.quantity          = obj.result.data.list.getItemAt(i).item_qty;
      l.hidden            = obj.result.data.list.getItemAt(i).hidden;
      l.forceView         = obj.result.data.list.getItemAt(i).force_view;
      l.quickTravel       = obj.result.data.list.getItemAt(i).allow_quick_travel;
      l.wiggle            = obj.result.data.list.getItemAt(i).wiggle;
      l.displayAnnotation = obj.result.data.list.getItemAt(i).show_title;
      l.qrId              = obj.result.data.list.getItemAt(i).qrcode_id;
      l.qrCode            = obj.result.data.list.getItemAt(i).code;

	  if(l.type != "PlayerNote") locations.addItem(l);
    }
	locations.refresh();
  }
  public function handleFault(obj:Object):void { Alert.show("Error occurred: " + obj.message, "Problems In Requirements Editor"); }

  public function handleRefreshButtonClick(evt:DynamicEvent):void
  {
    this.loadLocations(null);
  }
 
  public function handleLocationButtonClick(evt:MouseEvent):void
  {
	  var l:Location = (locations.getItemAt(locs.selectedIndex) as Location);
	  var loc:String = AppConstants.APPLICATION_ENVIRONMENT_SERVICES_URL + 
		  "location-edit.html?locationId=" + l.locationId;
	  navigateToURL(new URLRequest(loc),"_blank");
  }

  public function handleRequirementsButtonClick(evt:MouseEvent):void
  {
	var l:Location = (locations.getItemAt(locs.selectedIndex) as Location);
	var requirementsEditor:RequirementsEditorMX = new RequirementsEditorMX();
	requirementsEditor.validateNow();	  
	PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
	PopUpManager.centerPopUp(requirementsEditor);
	requirementsEditor.setVisible(true);
	requirementsEditor.includeInLayout = true;
	requirementsEditor.setRequirementTypeAndId("Location", l.locationId);
  }
  public function handleSaveButtonClick(evt:MouseEvent):void
  {
	  AppServices.getInstance().saveLocation(GameModel.getInstance().game.gameId,(locations.getItemAt(locs.selectedIndex) as Location),0,new Responder(loadLocations, handleFault));
  }
  public function handleDeleteButtonClick(evt:MouseEvent):void
  {
	  AppServices.getInstance().deleteLocation(GameModel.getInstance().game.gameId, (locations.getItemAt(locs.selectedIndex) as Location).locationId, new Responder(loadLocations, handleFault));
  }
  
  public function dragEnter(evt:DragEvent):void
  {
	  var dropTarget:IUIComponent = evt.currentTarget as IUIComponent;
	  DragManager.acceptDragDrop(dropTarget);
  }
  public function dragDrop(evt:DragEvent):void
  {
	  var it:ObjectPaletteItemBO = (evt.dragSource.dataForFormat('treeItems') as Array)[0];
	  var l:Location = new Location();
	  l.name = it.name;
	  l.type = it.objectType;
	  l.typeId = it.objectId;
	 
	  AppServices.getInstance().saveLocation(GameModel.getInstance().game.gameId,l,0,new Responder(loadLocations, handleFault));
  }
}
}
