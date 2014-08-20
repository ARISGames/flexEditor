package org.arisgames.editor.view
{

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.DataGrid;
import mx.containers.ApplicationControlBar;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.TextInput;
import mx.events.DataGridEvent;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;

import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.data.arisserver.Location;
import org.arisgames.editor.services.AppServices;
import mx.rpc.Responder;
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
    locs.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, handleEditStart);
    locs.addEventListener(DataGridEvent.ITEM_EDIT_END,       handleEditEnd);
	this.loadLocations();
  }

  private function loadLocations():void
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

      locations.addItem(l);
    }
	locations.refresh();
  }
  public function handleFault(obj:Object):void { Alert.show("Error occurred: " + obj.message, "Problems In Requirements Editor"); }

  private function handleEditStart(evt:DynamicEvent):void
  {

  }
  private function handleEditEnd(evt:DynamicEvent):void
  {

  }

  private function handleRefreshButtonClick(evt:DynamicEvent):void
  {
    this.loadLocations();
    var de:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE); //Refresh Side Palette
    AppDynamicEventManager.getInstance().dispatchEvent(de);
  }
  private function handleAddButtonClick(evt:DynamicEvent):void
  {

  }
  private function handleDeleteButtonClick(evt:MouseEvent):void
  {

  }
}
}
