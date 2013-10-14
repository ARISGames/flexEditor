package org.arisgames.editor.components
{
  import flash.events.MouseEvent;
  import flash.net.URLRequest;
  import flash.net.navigateToURL;

  import mx.containers.Canvas;
  import mx.containers.VBox;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.Image;
  import mx.controls.Label;
  import mx.controls.TextInput;
  import mx.events.DynamicEvent;
  import mx.events.FlexEvent;
  import mx.rpc.Responder;

  import org.arisgames.editor.data.arisserver.Media;
  import org.arisgames.editor.models.GameModel;
  import org.arisgames.editor.services.AppServices;
  import org.arisgames.editor.util.AppConstants;
  import org.arisgames.editor.util.AppDynamicEventManager;

  public class MediaPickerRendererView extends VBox
  {
    [Bindable] public var imageCanvas:Canvas;
    [Bindable] public var image:Image;
    [Bindable] public var avButton:Button;
    [Bindable] public var mediaName:TextInput;

    [Bindable] public var secretText:Label;
    [Bindable] public var moreSecretText:TextInput;

    [Bindable] public var saveButton:Button;
    [Bindable] public var deleteButton:Button;

    public function MediaPickerRendererView()
    {
      super();
      this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
      avButton.addEventListener(MouseEvent.CLICK, handleAVButtonClick);
      saveButton.addEventListener(MouseEvent.CLICK, handleSaveButtonClick);
      deleteButton.addEventListener(MouseEvent.CLICK, handleDeleteButtonClick);
    }

    override public function set data(value:Object):void
    {
      super.data = value;
      invalidateProperties();
    }

    private function renderData():void
    {
      secretText.text = data.@mediaId+"";
      moreSecretText.text = data.@urlPath.toString() + data.@fileName.toString()+"";

      if(data.@type && (data.@type.toString() == AppConstants.MEDIATYPE_IMAGE || data.@type.toString() == AppConstants.MEDIATYPE_ICON))
      {
        if(data.@urlPath && data.@urlPath.toString() != "" && data.@fileName && data.@fileName.toString() != "")
        {
          var url:String = data.@urlPath.toString() + data.@fileName.toString()+"";
          image.source = url;
          imageCanvas.visible = true;
          imageCanvas.includeInLayout = true;
          image.visible = true;
          image.includeInLayout = true;
          avButton.visible = false;
          avButton.includeInLayout = false;
        }
      }
      else
      {
        imageCanvas.visible = false;
        imageCanvas.includeInLayout = false;
        image.visible = false;
        image.includeInLayout = false;
        if(data.@type && data.@type.toString() == AppConstants.MEDIATYPE_AUDIO)
        {
          avButton.label = "Listen To Audio";
          avButton.visible = true;
          avButton.includeInLayout = true;
        }
        else if(data.@type && data.@type.toString() == AppConstants.MEDIATYPE_VIDEO)
        {
          avButton.label = "View Video";
          avButton.visible = true;
          avButton.includeInLayout = true;
        }
      }

      mediaName.text = data.@label;
      if(data.@isDefault && data.@isDefault.toString() == "true")
      {
        mediaName.editable = false;
        saveButton.visible = false;
        saveButton.includeInLayout = false;
        deleteButton.visible = false;
        deleteButton.includeInLayout = false;
      }
      else
      {
        mediaName.editable = true;
        saveButton.visible = true;
        saveButton.includeInLayout = true;
        deleteButton.visible = true;
        deleteButton.includeInLayout = true;
      }
    }

    override protected function commitProperties():void
    {
      super.commitProperties();
      renderData();
    }

    private function handleAVButtonClick(evt:MouseEvent):void
    {
      var url:String = data.@urlPath.toString() + data.@fileName.toString();
      var req:URLRequest = new URLRequest(url);
      navigateToURL(req,"to_blank");
    }

    private function handleSaveButtonClick(evt:MouseEvent):void
    {
      data.@label = mediaName.text;
      AppServices.getInstance().renameMediaForGame(GameModel.getInstance().game.gameId, data.@mediaId, mediaName.text, new Responder(handleSaveMedia, handleFault));
    }

    private function handleDeleteButtonClick(evt:MouseEvent):void
    {
      AppServices.getInstance().deleteMediaForGame(GameModel.getInstance().game.gameId, data.@mediaId, new Responder(handleDeleteMedia, handleFault));
    }

    public function handleSaveMedia(obj:Object):void
    {
      if(obj.result.returnCode != 0) Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Renaming Media");
    }

    public function handleDeleteMedia(obj:Object):void
    {
      if(obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Deleting Media"); return; }

      Alert.show("Just deleted Media named '" + data.@label + "'.", "Successfully Deleted Media");
      AppDynamicEventManager.getInstance().dispatchEvent(new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEMEDIAPICKER));
    }

    public function handleFault(obj:Object):void
    {
      Alert.show("Error occurred: " + obj.message, "Problems With Media Item");
    }
  }
}
