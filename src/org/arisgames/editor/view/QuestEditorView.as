package org.arisgames.editor.view
{
  import flash.events.Event;
  import flash.events.MouseEvent;

  import mx.containers.Panel;
  import mx.controls.Alert;
  import mx.controls.Button;
  import mx.controls.DataGrid;
  import mx.events.DataGridEvent;
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
    [Bindable] public var quest:Quest;

    [Bindable] public var dg:DataGrid;
    [Bindable] public var addQuestButton:Button;
    [Bindable] public var closeButton:Button;

    public function QuestEditorView()
    {
      super();
      this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
    }

    private function handleInit(event:FlexEvent):void
    {
      closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
    }

	public function didSelectMediaItem(picker:MediaPickerMX, m:Media):void
	{
		
	}

    private function handleUpdateQuestSave(obj:Object):void
    {
      if(obj.result.returnCode != 0) Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Updating Quest");
    }

    private function handleCloseButton(evt:MouseEvent):void
    {
      var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEQUESTSEDITOR);
      AppDynamicEventManager.getInstance().dispatchEvent(de);
    }

    public function handleFault(obj:Object):void
    {
      Alert.show("Error occurred: " + obj.message, "Problems In Quests Editor");
    }
  }
}
