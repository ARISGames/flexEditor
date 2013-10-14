package org.arisgames.editor.components
{
  import com.ninem.controls.TreeBrowser;
  import com.ninem.events.TreeBrowserEvent;

  import flash.events.MouseEvent;

  import mx.containers.Panel;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.DataGrid;
  import mx.core.ClassFactory;
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

  public class MediaPickerFileListView extends Panel
  {
    public var delegate:Object;

    [Bindable] public var rootXML:XML;

    [Bindable] public var treeBrowser:TreeBrowser;
    [Bindable] public var closeButton:Button;
    [Bindable] public var selectButton:Button;

    [Bindable] [Embed(source="assets/img/separator.png")] public var separatorIcon:Class;
    [Bindable] [Embed(source="assets/img/upload.png")]    public var uploadIcon:Class;

    public function MediaPickerFileListView()
    {
      super();
      this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
      var cf:ClassFactory = new ClassFactory(MediaPickerRendererMX);
      treeBrowser.detailRenderer = cf;
      treeBrowser.addEventListener(TreeBrowserEvent.NODE_SELECTED, onNodeSelected);
      closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
      selectButton.addEventListener(MouseEvent.CLICK, handleSelectButton);

      AppServices.getInstance().getMediaForGame(GameModel.getInstance().game.gameId, new Responder(handleLoadingOfMediaIntoXML, handleFault));
    }

    private function handleSelectButton(evt:MouseEvent):void
    {
      var m:Media = new Media();
      m.mediaId   = treeBrowser.selectedItem.@mediaId;
      m.name      = treeBrowser.selectedItem.@name;
      m.type      = treeBrowser.selectedItem.@type;
      m.urlPath   = treeBrowser.selectedItem.@urlPath;
      m.fileName  = treeBrowser.selectedItem.@fileName;
      m.isDefault = treeBrowser.selectedItem.@isDefault;

      if(delegate.hasOwnProperty("didSelectMediaItem"))
        delegate.didSelectMediaItem(this, m);

      PopUpManager.removePopUp(this);
    }

    public function didUploadMedia(uploader:ItemEditorMediaPickerUploadFormMX, m:Media):void
    {
      if(delegate.hasOwnProperty("didSelectMediaItem"))
        delegate.didSelectMediaItem(this, m);

      PopUpManager.removePopUp(uploader);
    }

    private function handleLoadingOfMediaIntoXML(obj:Object):void
    {
      if(obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Media"); return; }

      var imageXML:XML = new XML('<node label="Image"/>');
      var audioXML:XML = new XML('<node label="Audio"/>');
      var videoXML:XML = new XML('<node label="Video"/>');
      var iconXML:XML  = new XML('<node label="Icon"/>');

      imageXML.appendChild('<node type="uploadButton" label="" icon="uploadIcon"/>');
      audioXML.appendChild('<node type="uploadButton" label="" icon="uploadIcon"/>');
      videoXML.appendChild('<node type="uploadButton" label="" icon="uploadIcon"/>');
      iconXML.appendChild( '<node type="uploadButton" label="" icon="uploadIcon"/>');

      var media:Array = obj.result.data as Array;

      for(var defaultM:Number = 0; defaultM < 2; defaultM++) //iterate through list twice- once for non-defaults, again for defaults
      {
        for(var i:Number = 0; i < media.length; i++)
        {
          var o:Object = media[i];
          if(o.is_default == defaultM) //non-defaults first
          {
            var node:String = "<node label='"+AppUtils.filterStringToXMLEscapeCharacters(o.name)+"' mediaId='"+o.media_id+"' type='"+o.type+"' urlPath='"+o.url_path+"' fileName='"+o.file_name+"' isDefault='"+o.is_default+"'/>";

            switch(o.type)
            {
              case AppConstants.MEDIATYPE_IMAGE: imageXML.appendChild(node); break;
              case AppConstants.MEDIATYPE_AUDIO: audioXML.appendChild(node); break;
              case AppConstants.MEDIATYPE_VIDEO: videoXML.appendChild(node); break;
              case AppConstants.MEDIATYPE_ICON:  iconXML.appendChild(node);  break;
            }
          }
        }
        if(!defaultM) //add separators in between non-defaults and defaults
        {
          imageXML.appendChild('<node type="separator" label="" icon="separatorIcon"/>');
          audioXML.appendChild('<node type="separator" label="" icon="separatorIcon"/>');
          videoXML.appendChild('<node type="separator" label="" icon="separatorIcon"/>');
          iconXML.appendChild( '<node type="separator" label="" icon="separatorIcon"/>');
        }
      }

      rootXML = new XML('<nodes></nodes>');
      rootXML.appendChild(imageXML);
      rootXML.appendChild(audioXML);
      rootXML.appendChild(videoXML);
      rootXML.appendChild(iconXML);
	}

    private function onNodeSelected(event:TreeBrowserEvent):void
	{		
      if(event.isBranch) selectButton.enabled = false;	
      else if(event.item.@type == "separator") selectButton.enabled = false;
      else if(event.item.@type == "uploadButton")
      {
        selectButton.enabled = false;
        this.displayMediaUploader();
        PopUpManager.removePopUp(this);
      }
      else selectButton.enabled = true;
    }

    private function displayMediaUploader():void
    {
      var mediaUploader:MediaPickerUploadFormMX = new MediaPickerUploadFormMX();
      mediaUploader.delegate = this;
      PopUpManager.addPopUp(mediaUploader, AppUtils.getInstance().getMainView(), true);
      PopUpManager.centerPopUp(mediaUploader);
    }

    private function handleCloseButton(evt:MouseEvent):void
    {
      PopUpManager.removePopUp(this);
    }

    public function handleFault(obj:Object):void
    {
      Alert.show("Error occurred: " + obj.message, "Problems Loading Media");
    }

  }

}
