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


public class ItemEditorMediaPickerUploadFormView extends Panel
{
    public static const isIconTypes:ArrayCollection = new ArrayCollection(
                    [ {label:"False", data:0},
                      {label:"True", data:1} ]);

	public var delegate:Object;
	
    public var validVideoExtensions:Array;
    public var validAudioExtensions:Array;
    public var validImageAndIconExtensions:Array;
	
	public var isIconPicker:Boolean;

    // GUI
    [Bindable] public var uploadForm:Form;
    [Bindable] public var mediaName:TextInput;
    [Bindable] public var isIconFormItem:FormItem;
    [Bindable] public var isIcon:ComboBox;
    [Bindable] public var fileName:TextInput;
    [Bindable] public var findFileButton:Button;
    [Bindable] public var clearFileButton:Button;
    [Bindable] public var cancelButton:Button;
    [Bindable] public var uploadButton:Button;
    [Bindable] public var formSpacer:Spacer;
    [Bindable] public var progressBar:ProgressBar;

    private var fileChooser:FileReferenceList;
    private var fileChosen:FileReference;

    /**
     * Constructor
     */
    public function ItemEditorMediaPickerUploadFormView()
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
        //isIcon.addEventListener(ListEvent.CHANGE, isIconChanged);
    }

    private function isIconChanged(evt:ListEvent):void
    {
        trace("isIconChanged has been called.");
        trace("New value = '" + (isIcon.selectedItem.data as Number).toString() + "'");
    }

    private function handleCancelButton(evt:MouseEvent):void
    {		
		trace("itemEditorMediaPickerUploader: handleCancelButton called...");
		PopUpManager.removePopUp(this);		
    }

	private function handleFindFileButton(evt:MouseEvent):void
	{
		trace("Find File To Upload button clicked...");
		// Build File Filters
		var all:String = "";
		var img:String = "";
		if (validImageAndIconExtensions != null)
		{
			for (var j:Number = 0; j < validImageAndIconExtensions.length; j++)
			{
				all = all + ";*." + validImageAndIconExtensions[j];
				
				if (j != 0)
				{
					img = img + ";*." + validImageAndIconExtensions[j];
				}
				else
				{
					img = "*." + validImageAndIconExtensions[j]
				}
			}
		}
		var imageAndIconFilter:FileFilter = new FileFilter("Image / Icon", img);
		
		var vid:String = "";
		if (validVideoExtensions != null)
		{
			for (j = 0; j < validVideoExtensions.length; j++)
			{
				all = all + ";*." + validVideoExtensions[j];
				
				if (j != 0)
				{
					vid = vid + ";*." + validVideoExtensions[j];
				}
				else
				{
					vid = "*." + validVideoExtensions[j]
				}
			}
		}
		var videoFilter:FileFilter = new FileFilter("Video", vid);
		
		var aud:String = "";
		if (validAudioExtensions != null)
		{
			for (j = 0; j < validAudioExtensions.length; j++)
			{
				all = all + ";*." + validAudioExtensions[j];
				
				if (j != 0)
				{
					aud = aud + ";*." + validAudioExtensions[j];
				}
				else
				{
					aud = "*." + validAudioExtensions[j]
				}
			}
		}
		var audioFilter:FileFilter = new FileFilter("Audio", aud);
		all = all.substring(1, all.length); //remove the starting ';'
		var allFilter:FileFilter = new FileFilter("Media", all);
		
		fileChooser = new FileReferenceList();
		fileChooser.addEventListener(Event.SELECT, onSelectFile);
		fileChooser.browse([allFilter, imageAndIconFilter, videoFilter, audioFilter]);
	}

    private function handleClearFileButton(evt:MouseEvent):void
    {
        trace("handleClearFileButton clicked...");
        fileName.text = "";
        clearFileButton.setVisible(false);
        clearFileButton.includeInLayout = false;
        formSpacer.setVisible(true);
        formSpacer.includeInLayout = false;
        uploadButton.enabled = false;
        //this.displayIsIconFormQuestionIfConditionsAreMet();
        this.validateNow();
    }

    // Called when a file is selected
    private function onSelectFile(event:Event):void
    {
		var fileOK:Boolean = false;
        if (fileChooser.fileList.length >= 1)
        {
			for (var k:Number = 0; k < fileChooser.fileList.length; k++)
			{
				trace("File to Upload: Name = '" + fileChooser.fileList[k].name + "' and type is " + fileChooser.fileList[k].type);
				fileChosen = fileChooser.fileList[k];
				trace("File to Upload: Name = '" + fileChooser.fileList[k].name + "' and type is " + fileChosen.type);

				if(fileChosen.name.slice(-3, fileChosen.name.length) == "mov" || fileChosen.name.slice(-3, fileChosen.name.length) == "m4v" || fileChosen.name.slice(-3, fileChosen.name.length) == "3gp" || fileChosen.name.slice(-3, fileChosen.name.length) == "mp4"){
					if(fileChosen.size <= AppConstants.MAX_VIDEO_UPLOAD_SIZE){
						fileName.text = fileChosen.name;
						if(mediaName.text == ""){
							mediaName.text = fileName.text;
						}
						fileOK = true;
					}
					else {
						Alert.show("Sorry! The file you chose is too large...\n\n"+
							fileChosen.name+": "+Math.round(((fileChosen.size)/1024)/1024)+" MB\n"+
							"Max Filesize: "+Math.round(((AppConstants.MAX_VIDEO_UPLOAD_SIZE)/1024)/1024)+" MB", "File Size Too Large");
					}
				}
				else {
					if(fileChosen.size <= AppConstants.MAX_IMAGE_UPLOAD_SIZE){
						fileName.text = fileChosen.name;
						if(mediaName.text == ""){
							mediaName.text = fileName.text;
						}
						fileOK = true;
					}
					else {
						Alert.show("Sorry! The file you chose is too large...\n\n"+
							fileChosen.name+": "+Math.round(((fileChosen.size)/1024)/1024)+" MB\n"+
							"Max Filesize: "+Math.round(((AppConstants.MAX_IMAGE_UPLOAD_SIZE)/1024)/1024)+" MB", "File Size Too Large");
					}
				}
				
			}
        }

		if(fileOK){
        //this.displayIsIconFormQuestionIfConditionsAreMet();
        	clearFileButton.setVisible(true);
        	clearFileButton.includeInLayout = true;
        	formSpacer.setVisible(true);
        	formSpacer.includeInLayout = true;
        	uploadButton.enabled = true;
        	this.validateNow();
		}
    }

    private function displayIsIconFormQuestionIfConditionsAreMet():void
    {
        trace("displayIsIconFormQuestionIfConditionsAreMet() started...");
        if (fileName.text == null || fileName.text == "")
        {
            trace("fileName text is null or empty.");
            if (isIconFormItem.visible)
            {
                isIcon.setVisible(false);
                isIcon.includeInLayout = false;
                isIconFormItem.setVisible(false);
                isIconFormItem.includeInLayout = false;
                this.validateNow();
            }
            return;
        }

        if (validImageAndIconExtensions != null && validImageAndIconExtensions.length > 0)
        {
            trace("There are some valid extensions to search, so that's what will be done next.");

            var lc:Number = fileName.text.lastIndexOf(".");
            if (lc < fileName.text.length)
            {
                lc = lc + 1;                
            }

            var fileExtension:String = fileName.text.substring(lc);
            trace("fileExtension = '" + fileExtension + "'");

            for (var j:Number = 0; j < validImageAndIconExtensions.length; j++)
            {
                if (fileExtension.toLocaleUpperCase() == (validImageAndIconExtensions[j] as String).toLocaleUpperCase())
                {
                    trace("Found a matching Image / Icon extension, so will set isIconFormItem visible (if it's not already).");
                    if (!isIconFormItem.visible)
                    {
                        isIcon.setVisible(true);
                        isIcon.includeInLayout = true;
                        isIconFormItem.setVisible(true);
                        isIconFormItem.includeInLayout = true;
                        this.validateNow();
                    }
                    return;
                }
            }

            trace("No matching extension was found for an image or icon, so will hide isIconFormItem if currently visible.");
            if (isIconFormItem.visible)
            {
                isIcon.setVisible(false);
                isIcon.includeInLayout = false;
                isIconFormItem.setVisible(false);
                isIconFormItem.includeInLayout = false;
                this.validateNow();
            }
            return;
        }
        else
        {
            trace("There are no valid image / icon extensions to search, so will hide isIconFormItem if currently visible.")
            if (isIconFormItem.visible)
            {
                isIcon.setVisible(false);
                isIcon.includeInLayout = false;
                isIconFormItem.setVisible(false);
                isIconFormItem.includeInLayout = false;
                this.validateNow();
            }
            return;
        }
    }

    private function handleUploadButton(evt:MouseEvent):void
    {
        trace("handleUploadButton() called...");

        // Setup GUI to upload mode
        this.changeViewModeToUploadView(true);

        // Variables to send along with upload
        var sendVars:URLVariables = new URLVariables();
        sendVars.gameID = GameModel.getInstance().game.gameId;
        sendVars.action = "upload";

        var request:URLRequest = new URLRequest();
        request.data = sendVars;
        request.url = AppConstants.APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL;
        request.method = URLRequestMethod.POST;
        fileChosen.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
        fileChosen.addEventListener(Event.COMPLETE, onUploadComplete);
        fileChosen.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
        fileChosen.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
        fileChosen.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, httpResponseHandler);
        fileChosen.upload(request, "file", false);
    }

    private function httpResponseHandler(event:DataEvent):void
    {
        var response:XML = XML( event.data );
        trace("HTTP Response = '" + response.toString() + "'");
        trace("=============================================================");
        trace("HTTP Respone (XML Format) = '" + response.toXMLString() + "'");

        // Save Media Object In Data Base
        var i:Number = 0;
		/*
        if (isIconFormItem.visible)
        {
            i = isIcon.selectedItem.data as Number;
            trace("IsIconFormItem is visible, so getting form data value for isIcon.  It equals = '" + i + "'");
        }
		*/
		if(this.isIconPicker) i = 1;
        AppServices.getInstance().createMediaForGame(GameModel.getInstance().game.gameId, mediaName.text, response.toString(), i, new Responder(handleUploadAndSaveFileSuccess, handleFault));
    }

    // Get upload progress
    private function onUploadProgress(event:ProgressEvent):void
    {
        var numPerc:Number = Math.round((Number(event.bytesLoaded) / Number(event.bytesTotal)) * 100);
        trace("onUploadProgressCalled.  New numPerc = '" + numPerc.toString() +"'");
        progressBar.setProgress(numPerc, 100);
        progressBar.label = numPerc + "% Uploaded";
        progressBar.validateNow();
    }

    // Called on upload complete
    private function onUploadComplete(event:Event):void
    {
        trace("onUploadComplete() called...");
    }

    // Called on upload io error
    private function onUploadIoError(event:IOErrorEvent):void
    {
        Alert.show("IO Error in uploading file.  Error = " + event.toString(), "Error");
        this.changeViewModeToUploadView(false);
    }

    // Called on upload security error
    private function onUploadSecurityError(event:SecurityErrorEvent):void
    {
        Alert.show("Security Error in uploading file.  Error = " + event.toString(), "Error");
        this.changeViewModeToUploadView(false);
    }

    private function handleUploadAndSaveFileSuccess(obj:Object):void
    {
        trace("ItemEditorMediaPickerUploadFormView: handleUploadAndSaveFileSuccess()");
        if (obj.result.returnCode != 0)
        {
            trace("ItemEditorMediaPickerUploadFormView: Bad saving of uploaded media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Saving Uploaded Media");
        }
        else
        {
			trace("ItemEditorMediaPickerUploadFormView: Upload was legit, call the delegate with the new media");			
			
			var m:Media = new Media();
			
			m.mediaId = obj.result.data.media_id;
			m.name = obj.result.data.name;
			m.type = obj.result.data.type;
			m.urlPath = obj.result.data.url_path;
			m.fileName = obj.result.data.file_name;
			m.isDefault = obj.result.data.is_default;
						
			if (delegate.hasOwnProperty("didUploadMedia")){
				delegate.didUploadMedia(this, m);
			}	
			
			PopUpManager.removePopUp(this);
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called: " + obj.message);
        Alert.show("Error occurred: " + obj.message, "Problems Uploading Media");
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

    private function handleLoadValidVideoExtensions(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Error while loading valid video types... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Valid Video Types");
        }
        else
        {
            validVideoExtensions = obj.result.data as Array;
            if (validVideoExtensions != null)
            {
                trace("validVideoExtensions set with " + validVideoExtensions.length + " extensions.");
            }
            else
            {
                trace("validVideoExtensions is NULL... not set");
            }
        }
    }

    private function handleLoadValidAudioExtensions(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Error while loading valid audio types... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Valid Audio Types");
        }
        else
        {
            validAudioExtensions = obj.result.data as Array;
            if (validAudioExtensions != null)
            {
                trace("validAudioExtensions set with " + validAudioExtensions.length + " extensions.");
            }
            else
            {
                trace("validAudioExtensions is NULL... not set");
            }
        }
    }

    private function handleLoadValidImageAndIconExtensions(obj:Object):void
    {
        if (obj.result.returnCode != 0)
        {
            trace("Error while loading valid image and icon types... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Loading Valid Image And Icon Types");
        }
        else
        {
            validImageAndIconExtensions = obj.result.data as Array;
            if (validImageAndIconExtensions != null)
            {
                trace("validImageAndIconExtensions set with " + validImageAndIconExtensions.length + " extensions.");
            }
            else
            {
                trace("validImageAndIconExtensions is NULL... not set");
            }
        }
    }
}
}