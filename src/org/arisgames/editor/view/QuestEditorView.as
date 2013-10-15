package org.arisgames.editor.view
{
  import flash.events.Event;
  import flash.events.MouseEvent;

  import mx.containers.Panel;
  import mx.controls.Alert;
  import mx.controls.TextInput;
  import mx.controls.TextArea;
  import mx.controls.Button;
  import mx.controls.ComboBox;
  import mx.events.DynamicEvent;
  import mx.events.ListEvent;
  import mx.events.FlexEvent;
  import mx.managers.PopUpManager;
  import mx.rpc.Responder;
  import mx.collections.ArrayCollection;

  import org.arisgames.editor.data.arisserver.Quest;
  import org.arisgames.editor.data.arisserver.Media;
  import org.arisgames.editor.components.MediaPickerMX;
  import org.arisgames.editor.models.GameModel;
  import org.arisgames.editor.services.AppServices;
  import org.arisgames.editor.util.AppConstants;
  import org.arisgames.editor.util.AppDynamicEventManager;

  public class QuestEditorView extends Panel
  {
    public var quest:Quest;
	
	[Bindable] public var questname:TextInput;

	[Bindable] public var activeMedia:MediaPickerMX;
	[Bindable] public var activeIconMedia:MediaPickerMX;
	[Bindable] public var activeNotifMedia:MediaPickerMX;
	[Bindable] public var completeMedia:MediaPickerMX;
	[Bindable] public var completeIconMedia:MediaPickerMX;
	[Bindable] public var completeNotifMedia:MediaPickerMX;
	
	[Bindable] public var activedesc:TextArea;
	[Bindable] public var completedesc:TextArea;
	[Bindable] public var activenotifdesc:TextArea;
	[Bindable] public var completenotifdesc:TextArea;

	[Bindable] public var newnotiftype:ComboBox;
	[Bindable] public var completenotiftype:ComboBox;
	[Bindable] public var activegofunc:ComboBox;
	[Bindable] public var completegofunc:ComboBox;
	[Bindable] public var activenotifgofunc:ComboBox;
	[Bindable] public var completenotifgofunc:ComboBox;
	[Bindable] public var activenotifshowdismiss:ComboBox;
	[Bindable] public var completenotifshowdismiss:ComboBox;
	
	[Bindable] public var saveButton:Button;
	[Bindable] public var closeButton:Button;

    public function QuestEditorView()
    {
      super();
      this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
		closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
		saveButton.addEventListener(MouseEvent.CLICK, handleSaveButton);
    }
	
	public function setQuest(q:Quest):void
	{
		quest = q;
		this.renderData();
	}
	
	private function renderData():void
	{
		questname.text = quest.title;
		
		activeMedia.setMediaId(quest.activeMediaId);
		activeIconMedia.setMediaId(quest.activeIconMediaId);
		activeNotifMedia.setMediaId(quest.activeNotifMediaId);
		completeMedia.setMediaId(quest.completeMediaId);
		completeIconMedia.setMediaId(quest.completeIconMediaId);
		completeNotifMedia.setMediaId(quest.completeNotifMediaId);
		
		activedesc.text = quest.activeText;
		completedesc.text = quest.completeText;
		activenotifdesc.text = quest.activeNotifText;
		completenotifdesc.text = quest.completeNotifText;
		
		newnotiftype.selectedIndex = quest.activeNotifFullScreen as int;
		completenotiftype.selectedIndex = quest.completeNotifFullScreen as int;
		
		activegofunc.selectedItem = quest.activeGoFunc;
		completegofunc.selectedItem = quest.completeGoFunc;
		activenotifgofunc.selectedItem = quest.activeNotifGoFunc;
		completenotifgofunc.selectedItem = quest.completeNotifGoFunc;
		
		activenotifshowdismiss.selectedIndex = quest.activeNotifShowDismiss as int;
		completenotifshowdismiss.selectedIndex = quest.completeNotifShowDismiss as int;
	}

	public function didSelectMediaItem(picker:MediaPickerMX, m:Media):void
	{
		//Don't immediately do anything
	}
	
	private function saveQuest():void
	{
		quest.title = questname.text;

		if(activeMedia.media)        quest.activeMediaId        = activeMedia.media.mediaId;        else quest.activeMediaId        = 0;
		if(activeIconMedia.media)    quest.activeIconMediaId    = activeIconMedia.media.mediaId;    else quest.activeIconMediaId    = 0;
		if(activeNotifMedia.media)   quest.activeNotifMediaId   = activeNotifMedia.media.mediaId;   else quest.activeNotifMediaId   = 0;
		if(completeMedia.media)      quest.completeMediaId      = completeMedia.media.mediaId;      else quest.completeMediaId      = 0;
		if(completeIconMedia.media)  quest.completeIconMediaId  = completeIconMedia.media.mediaId;  else quest.completeIconMediaId  = 0;
		if(completeNotifMedia.media) quest.completeNotifMediaId = completeNotifMedia.media.mediaId; else quest.completeNotifMediaId = 0;
		
		quest.activeText        = activedesc.text;
		quest.completeText      = completedesc.text;
		quest.activeNotifText   = activenotifdesc.text;
		quest.completeNotifText = completenotifdesc.text;
		
		quest.activeNotifFullScreen   = newnotiftype.value;
		quest.completeNotifFullScreen = completenotiftype.value;
		
		quest.activeGoFunc        = activegofunc.value as String;
		quest.completeGoFunc      = completegofunc.value as String;
		quest.activeNotifGoFunc   = activenotifgofunc.value as String;
		quest.completeNotifGoFunc = completenotifgofunc.value as String;
		
		quest.activeNotifShowDismiss   = activenotifshowdismiss.value;
		quest.completeNotifShowDismiss = completenotifshowdismiss.value;
		
		AppServices.getInstance().saveQuest(GameModel.getInstance().game.gameId, quest, new Responder(handleUpdateQuestSave, handleFault));
	}
	
	private function closeSelf():void
	{
		AppDynamicEventManager.getInstance().dispatchEvent(new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEQUESTEDITOR));
		PopUpManager.removePopUp(this);
	}

    private function handleUpdateQuestSave(obj:Object):void
    {
      if(obj.result.returnCode != 0) Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Updating Quest");
	  this.closeSelf();
    }

	private function handleSaveButton(evt:MouseEvent):void
	{
		this.saveQuest();
	}
	
    private function handleCloseButton(evt:MouseEvent):void
    {
		this.closeSelf();
	}

    public function handleFault(obj:Object):void
    {
      Alert.show("Error occurred: " + obj.message, "Problems In Quests Editor");
    }
  }
}
