package org.arisgames.editor.view
{
  import flash.events.Event;
  import flash.events.MouseEvent;
  
  import mx.collections.ArrayCollection;
  import mx.containers.Panel;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.ComboBox;
  import mx.controls.TextArea;
  import mx.controls.TextInput;
  import mx.events.DynamicEvent;
  import mx.events.FlexEvent;
  import mx.events.ListEvent;
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

	[Bindable] public var newnotiftype:ComboBox;
	[Bindable] public var completenotiftype:ComboBox;
	[Bindable] public var activegofunc:ComboBox;
	[Bindable] public var completegofunc:ComboBox;
	
	[Bindable] public var showRequirementsButton:Button;
	[Bindable] public var completeRequirementsButton:Button;
	
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
		showRequirementsButton.addEventListener(MouseEvent.CLICK, handleShowRequirementsButton);
		completeRequirementsButton.addEventListener(MouseEvent.CLICK, handleCompleteRequirementsButton);
    }
	
	public function setQuest(q:Quest):void
	{
		quest = q;
		this.renderData();
	}
	
	private function firstUpperCase(str:String):String //small helper func
	{
		return str.substr(0, 1).toUpperCase()+str.substr(1, str.length).toLowerCase();
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
		
		activedesc.text        = quest.activeText;
		completedesc.text      = quest.completeText;
		
		newnotiftype.selectedIndex      = quest.activeNotifFullScreen + 0;
		completenotiftype.selectedIndex = quest.completeNotifFullScreen + 0;
		
		activegofunc.selectedItem        = firstUpperCase(quest.activeGoFunc);
		completegofunc.selectedItem      = firstUpperCase(quest.completeGoFunc);
	}

	public function didSelectMediaItem(picker:MediaPickerMX, m:Media):void
	{
		//Don't immediately do anything
	}
	
	public function handleShowRequirementsButton(evt:MouseEvent):void
	{
		this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_QUESTDISPLAY);
	}
	
	public function handleCompleteRequirementsButton(evt:MouseEvent):void
	{
		this.openRequirementsEditor(AppConstants.REQUIREMENTTYPE_QUESTCOMPLETE);
	}
	
	private function openRequirementsEditor(requirementType:String):void
	{
		var requirementsEditor:RequirementsEditorMX = new RequirementsEditorMX();
		requirementsEditor.validateNow();
		
		PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
		PopUpManager.centerPopUp(requirementsEditor);
		requirementsEditor.setVisible(true);
		requirementsEditor.includeInLayout = true;
		requirementsEditor.setRequirementTypeAndId(requirementType, quest.questId);
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
		
		quest.activeNotifFullScreen   = newnotiftype.selectedIndex && true;
		quest.completeNotifFullScreen = completenotiftype.selectedIndex && true;
		
		quest.activeGoFunc        = (activegofunc.value as String).toUpperCase();
		quest.completeGoFunc      = (completegofunc.value as String).toUpperCase();
		
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
