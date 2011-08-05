package org.arisgames.editor.components
{
import flash.events.MouseEvent;

import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.Label;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import org.arisgames.editor.data.arisserver.Requirement;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class RequirementsEditorObjectRendererView extends VBox implements IDropInListItemRenderer
{
    [Bindable] public var textLabel:Label;
    [Bindable] public var mediaItemMapButton:Button;

    private var _listData:DataGridListData;

    /**
     * Constructor
     */
    public function RequirementsEditorObjectRendererView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("in RequirementsEditorObjectRendererView's handleInit");
        mediaItemMapButton.addEventListener(MouseEvent.CLICK, handleMediaItemButtonClick);
    }

    private function setToButtonMode(buttonMode:Boolean):void
    {
        textLabel.includeInLayout = !buttonMode;
        textLabel.visible = !buttonMode;
        mediaItemMapButton.includeInLayout = buttonMode;
        mediaItemMapButton.visible = buttonMode;
    }

    override public function get data():Object
    {
        trace("getData() called.  Returning = '" + super.data + "'");
        return super.data;
    }

    override public function set data(value:Object):void
    {
        var req:Requirement = value as Requirement;
        trace("set data called with value = '" + value + "'; The Requirement Id = '" + req.requirementId + "'; The Requirement = '" + req.requirement + "'");

        if (req.requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE || req.requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_DATABASE || req.requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_DATABASE || req.requirement == AppConstants.REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_DATABASE)
        {
            trace("This is a Uploaded Media Item requirement, so display requirement map button mode.");
            this.setToButtonMode(true);
        }
        else
        {
            trace("This is NOT a Uploaded Media Item requirement, so display regular text label mode.");
            this.setToButtonMode(false);
            textLabel.text = value[_listData.dataField];
        }
    }

    public function get listData():BaseListData
    {
        trace("get listData called.  Returning = '" + _listData + "'");
        return _listData;
    }

    public function set listData(value:BaseListData):void
    {
        trace("setListData() called with value = '" + value + "'");
        //        _listData = (value as DataGridListData);
        _listData = DataGridListData(value);
    }

    private function handleMediaItemButtonClick(evt:MouseEvent):void
    {
        trace("handleMediaItemButtonClick() called...");
        var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_OPENREQUIREMENTSEDITORMAP);
//        de.requirement = data;
        AppDynamicEventManager.getInstance().dispatchEvent(de);
    }
}
}