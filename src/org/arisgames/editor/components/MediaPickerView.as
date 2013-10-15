package org.arisgames.editor.components
{
  import flash.events.MouseEvent;
  import flash.net.URLRequest;
  import flash.net.navigateToURL;
  
  import mx.containers.Canvas;
  import mx.containers.HBox;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.Image;
  import mx.controls.Label;
  import mx.controls.LinkButton;
  import mx.events.DynamicEvent;
  import mx.events.FlexEvent;
  import mx.managers.PopUpManager;
  import mx.rpc.Responder;
  
  import org.arisgames.editor.data.arisserver.Media;
  import org.arisgames.editor.models.GameModel;
  import org.arisgames.editor.services.AppServices;
  import org.arisgames.editor.util.AppConstants;
  import org.arisgames.editor.util.AppDynamicEventManager;
  import org.arisgames.editor.util.AppUtils;

  public class MediaPickerView extends HBox
  {
	public var delegate:Object;
    public var media:Media;

    [Bindable] public var imageCanvas:Canvas;
    [Bindable] public var image:Image;
    [Bindable] public var chooseMediaButton:Button;
    [Bindable] public var removeMediaButton:Button;
    [Bindable] public var viewAVButton:Button;

    public function MediaPickerView()
    {
      super();
      this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
      chooseMediaButton.addEventListener(MouseEvent.CLICK, handleChooseMediaButtonClick);
      removeMediaButton.addEventListener(MouseEvent.CLICK, handleRemoveMediaButtonClick);
      viewAVButton.addEventListener(MouseEvent.CLICK, handleViewAVButtonClick);
      updateView();
    }
	
	public function setMedia(m:Media):void
	{
		media = m;
		this.updateView();
	}
	
	public function setMediaId(mid:Number):void
	{
		if(mid = 0) setMedia(null);
		if(media && media.mediaId != mid)
			AppServices.getInstance().getMediaByGameIdAndMediaId(GameModel.getInstance().game.gameId, mid, new Responder(handleLoadingOfMedia, handleFault));
	}
	
    private function updateView():void
    {
      if(media != null && (media.type == AppConstants.MEDIATYPE_AUDIO || media.type == AppConstants.MEDIATYPE_VIDEO))
      {
        imageCanvas.setVisible(false);
        imageCanvas.includeInLayout = false;
        image.setVisible(true);
        image.includeInLayout = true;
        viewAVButton.setVisible(true);
        viewAVButton.includeInLayout = true;
        removeMediaButton.setVisible(true);
        removeMediaButton.includeInLayout = true;

        if(media.type == AppConstants.MEDIATYPE_AUDIO) viewAVButton.label = "Listen To Audio";
        if(media.type == AppConstants.MEDIATYPE_VIDEO) viewAVButton.label = "View Video";
      }
      else if(media != null && (media.type == AppConstants.MEDIATYPE_IMAGE || media.type == AppConstants.MEDIATYPE_ICON))
      {
        imageCanvas.setVisible(true);
        imageCanvas.includeInLayout = true;
        image.setVisible(true);
        image.includeInLayout = true;
        viewAVButton.setVisible(false);
        viewAVButton.includeInLayout = false;
        removeMediaButton.setVisible(true);
        removeMediaButton.includeInLayout = true;

        image.source = media.urlPath + media.fileName;
      }
      else
      {
        imageCanvas.setVisible(true);
        imageCanvas.includeInLayout = true;
        image.setVisible(false);
        image.includeInLayout = false;
        viewAVButton.setVisible(false);
        viewAVButton.includeInLayout = false;
        removeMediaButton.setVisible(false);
        removeMediaButton.includeInLayout = false;

        image.source = "";
      }
    }

    private function handleChooseMediaButtonClick(evt:MouseEvent):void
    {
      var mediaPicker:MediaPickerFileListMX = new MediaPickerFileListMX();
      mediaPicker.delegate = this;

      PopUpManager.addPopUp(mediaPicker, AppUtils.getInstance().getMainView(), true);
      PopUpManager.centerPopUp(mediaPicker);
    }

    public function didSelectMediaItem(picker:MediaPickerFileListMX, m:Media):void
    {
      media = m;
	  if(delegate.hasOwnProperty("didSelectMediaItem"))
		  delegate.didSelectMediaItem(this, m);
      this.updateView();
    }

    private function handleRemoveMediaButtonClick(evt:MouseEvent):void
    {
      media = null;
      this.updateView();
    }

    private function handleViewAVButtonClick(evt:MouseEvent):void
    {
      var req:URLRequest = new URLRequest(media.urlPath + media.fileName);
      navigateToURL(req,"to_blank");
    }
	
	private function handleLoadingOfMedia(obj:Object):void
	{
		if(obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Fetching Media"); return; }
		
		media = new Media();
		if(obj.result.data != null)
		{
			media.mediaId = obj.result.data.media_id;
			media.name = obj.result.data.name;
			media.type = obj.result.data.type;
			media.urlPath = obj.result.data.url_path;
			media.fileName = obj.result.data.file_name;
			media.isDefault = obj.result.data.is_default;
		}
		this.updateView();
	}
	
	public function handleFault(obj:Object):void
	{
		Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
	}
  }
}
