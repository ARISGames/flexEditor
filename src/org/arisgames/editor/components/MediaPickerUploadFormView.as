package org.arisgames.editor.components
{
  import flash.events.DataEvent;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.MouseEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.FileFilter;
  import flash.net.FileReference;
  import flash.net.FileReferenceList;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLVariables;

  import mx.collections.ArrayCollection;
  import mx.containers.Form;
  import mx.containers.FormItem;
  import mx.containers.Panel;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.ComboBox;
  import mx.controls.ProgressBar;
  import mx.controls.Spacer;
  import mx.controls.TextInput;
  import mx.events.DynamicEvent;
  import mx.events.FlexEvent;
  import mx.events.ListEvent;
  import mx.managers.PopUpManager;
  import mx.rpc.Responder;

  import org.arisgames.editor.data.arisserver.Media;
  import org.arisgames.editor.models.GameModel;
  import org.arisgames.editor.services.AppServices;
  import org.arisgames.editor.util.AppConstants;
  import org.arisgames.editor.util.AppDynamicEventManager;

  public class MediaPickerUploadFormView extends Panel
  {
    public var delegate:Object;

	private  var validVideoExtensions:Array;
    private var validAudioExtensions:Array;
	private var validImageAndIconExtensions:Array;
    private var allFilter:FileFilter;
	private var imageAndIconFilter:FileFilter;
	private var videoFilter:FileFilter;
	private var audioFilter:FileFilter;

    [Bindable] public  var uploadForm:Form;
    [Bindable] public var mediaName:TextInput;
    [Bindable] public var fileName:TextInput;
    [Bindable] public var findFileButton:Button;
    [Bindable] public var clearFileButton:Button;
    [Bindable] public var cancelButton:Button;
    [Bindable] public var uploadButton:Button;
    [Bindable] public var formSpacer:Spacer;
    [Bindable] public var progressBar:ProgressBar;

    private var fileChooser:FileReferenceList;
    private var fileChosen:FileReference;

    public function MediaPickerUploadFormView()
    {
      super();
      this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
      AppServices.getInstance().getValidAudioExtensions(new Responder(handleLoadValidAudioExtensions, handleFault));
      AppServices.getInstance().getValidImageAndIconExtensions(new Responder(handleLoadValidImageAndIconExtensions, handleFault));
      AppServices.getInstance().getValidVideoExtensions(new Responder(handleLoadValidVideoExtensions, handleFault));

      findFileButton.addEventListener(MouseEvent.CLICK, handleFindFileButton);
      clearFileButton.addEventListener(MouseEvent.CLICK, handleClearFileButton);
      cancelButton.addEventListener(MouseEvent.CLICK, handleCancelButton);
      uploadButton.addEventListener(MouseEvent.CLICK, handleUploadButton);
    }

    private function generateFileFilters():void
    {
      if(!validImageAndIconExtensions) validImageAndIconExtensions = new Array();
      if(!validVideoExtensions)        validVideoExtensions        = new Array();
      if(!validAudioExtensions)        validAudioExtensions        = new Array();

      var all:String = "";
      var img:String = "";
      var vid:String = "";
      var aud:String = "";

      for(var i:Number = 0; i < validImageAndIconExtensions.length; i++)
      {
        all = all + ";*." + validImageAndIconExtensions[i];
        if(i != 0) img = img + ";*." + validImageAndIconExtensions[i];
        else       img =        "*." + validImageAndIconExtensions[i]
      }
      for(i = 0; i < validVideoExtensions.length; i++)
      {
        all = all + ";*." + validVideoExtensions[i];
        if(i != 0) vid = vid + ";*." + validVideoExtensions[i];
        else       vid =        "*." + validVideoExtensions[i];
      }
      for (i = 0; i < validAudioExtensions.length; i++)
      {
        all = all + ";*." + validAudioExtensions[i];
        if(i != 0) aud = aud + ";*." + validAudioExtensions[i];
        else       aud =        "*." + validAudioExtensions[i];
      }
      imageAndIconFilter = new FileFilter("Image / Icon", img);
      videoFilter        = new FileFilter("Video", vid);
      audioFilter        = new FileFilter("Audio", aud);

      all = all.substring(1, all.length);
      allFilter = new FileFilter("Media", all);
    }

    private function handleFindFileButton(evt:MouseEvent):void
    {
      if(!allFilter) generateFileFilters();

      fileChooser = new FileReferenceList();
      fileChooser.addEventListener(Event.SELECT, onSelectFile);
      fileChooser.browse([allFilter, imageAndIconFilter, videoFilter, audioFilter]);
    }

    private function handleClearFileButton(evt:MouseEvent):void
    {
      fileName.text = "";
      clearFileButton.setVisible(false);
      clearFileButton.includeInLayout = false;
      formSpacer.setVisible(true);
      formSpacer.includeInLayout = false;
      uploadButton.enabled = false;
      this.validateNow();
    }

    private function onSelectFile(event:Event):void
    {
      if(fileChooser.fileList.length < 1) return;
      fileChosen = fileChooser.fileList[0];

      var fileOK:Boolean = false;

      if(fileChosen.name.slice(-3, fileChosen.name.length) == "mov"
          || fileChosen.name.slice(-3, fileChosen.name.length) == "m4v"
          || fileChosen.name.slice(-3, fileChosen.name.length) == "3gp"
          || fileChosen.name.slice(-3, fileChosen.name.length) == "mp4")
      {
        if(fileChosen.size <= AppConstants.MAX_VIDEO_UPLOAD_SIZE)
        {
          fileName.text = fileChosen.name;
          if(mediaName.text == "") mediaName.text = fileName.text;
          fileOK = true;
        }
        else
        {
          Alert.show("Sorry! The file you chose is too large...\n\n"+
              fileChosen.name+": "+Math.round(((fileChosen.size)/1024)/1024)+" MB\n"+
              "Max Filesize: "+Math.round(((AppConstants.MAX_VIDEO_UPLOAD_SIZE)/1024)/1024)+" MB", "File Size Too Large");
        }
      }
      else
      {
        if(fileChosen.size <= AppConstants.MAX_IMAGE_UPLOAD_SIZE)
        {
          fileName.text = fileChosen.name;
          if(mediaName.text == "") mediaName.text = fileName.text;
          fileOK = true;
        }
        else
        {
          Alert.show("Sorry! The file you chose is too large...\n\n"+
              fileChosen.name+": "+Math.round(((fileChosen.size)/1024)/1024)+" MB\n"+
              "Max Filesize: "+Math.round(((AppConstants.MAX_IMAGE_UPLOAD_SIZE)/1024)/1024)+" MB", "File Size Too Large");
        }
      }

      if(fileOK)
      {
        clearFileButton.setVisible(true);
        clearFileButton.includeInLayout = true;
        formSpacer.setVisible(true);
        formSpacer.includeInLayout = true;
        uploadButton.enabled = true;
        this.validateNow();
      }
    }

    private function handleUploadButton(evt:MouseEvent):void
    {
      this.changeViewModeToUploadView(true);

      var sendVars:URLVariables = new URLVariables();
      sendVars.gameID = GameModel.getInstance().game.gameId;
      sendVars.action = "upload";

      var request:URLRequest = new URLRequest();
      request.data = sendVars;
      request.url = AppConstants.APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL;
      request.method = URLRequestMethod.POST;
      fileChosen.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
      fileChosen.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
      fileChosen.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
      fileChosen.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadComplete);
      fileChosen.upload(request, "file", false);
    }

    private function uploadComplete(event:DataEvent):void
    {
      var response:XML = XML(event.data);
      AppServices.getInstance().createMediaForGame(GameModel.getInstance().game.gameId, mediaName.text, response.toString(), 0, new Responder(handleUploadAndSaveFileSuccess, handleFault));
    }

    private function onUploadProgress(event:ProgressEvent):void
    {
      var numPerc:Number = Math.round((Number(event.bytesLoaded) / Number(event.bytesTotal)) * 100);
      progressBar.setProgress(numPerc, 100);
      progressBar.label = numPerc + "% Uploaded";
      progressBar.validateNow();
    }

    private function handleUploadAndSaveFileSuccess(obj:Object):void
    {
      if(obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Saving Uploaded Media"); return; }

      var m:Media = new Media();

      m.mediaId = obj.result.data.media_id;
      m.name = obj.result.data.name;
      m.type = obj.result.data.type;
      m.urlPath = obj.result.data.url_path;
      m.fileName = obj.result.data.file_name;
      m.isDefault = obj.result.data.is_default;

      if(delegate.hasOwnProperty("didUploadMedia"))
        delegate.didUploadMedia(this, m);

      PopUpManager.removePopUp(this);
    }

    private function changeViewModeToUploadView(toUpload:Boolean):void
    {
      uploadForm.enabled = !toUpload;
      uploadButton.enabled = !toUpload;
      cancelButton.enabled = !toUpload;
      progressBar.setVisible(toUpload);
      progressBar.includeInLayout = toUpload;
      this.validateNow();
    }

    private function handleCancelButton(evt:MouseEvent):void
    {		
      PopUpManager.removePopUp(this);		
    }

    private function handleLoadValidVideoExtensions(obj:Object):void
    {
      if (obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Valid Video Types"); return; }
      validVideoExtensions = obj.result.data as Array;
    }

    private function handleLoadValidAudioExtensions(obj:Object):void
    {
      if (obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Valid Audio Types"); return; }
      validAudioExtensions = obj.result.data as Array;
    }

    private function handleLoadValidImageAndIconExtensions(obj:Object):void
    {
      if(obj.result.returnCode != 0) { Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Valid Image And Icon Types"); return; }
      validImageAndIconExtensions = obj.result.data as Array;
    }

    private function onUploadIoError(event:IOErrorEvent):void
    {
      Alert.show("IO Error in uploading file.  Error = " + event.toString(), "Error");
      this.changeViewModeToUploadView(false);
    }

    private function onUploadSecurityError(event:SecurityErrorEvent):void
    {
      Alert.show("Security Error in uploading file.  Error = " + event.toString(), "Error");
      this.changeViewModeToUploadView(false);
    }

    public function handleFault(obj:Object):void
    {
      Alert.show("Error occurred: " + obj.message, "Problems Uploading Media");
    }
  }
}

