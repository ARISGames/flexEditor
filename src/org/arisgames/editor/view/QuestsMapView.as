package org.arisgames.editor.view
{
	import mx.containers.Box;
	import mx.containers.Canvas
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.effects.Move;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import flash.events.MouseEvent;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	
	/**
	 * 
	 * @author Will Buck
	 */
	public class QuestsMapView extends Canvas
	{
		[Bindable] public var mapArea:Box;
		[Bindable] public var closeQuestsMapButton:Button;
		[Bindable] public var saveQuestsMapButton:Button;
		[Bindable] public var addQuestButton:Button;
		//[Bindable] public var questEditor:QuestsMapQuestEditorView;
		[Bindable] public var questEditShow:Move;
		[Bindable] public var questEditHide:Move;
		// Need a "currently editing quest", as well as an array for the collection of them, as well as other things I'm sure
		private var isEditorVis:Boolean = false;
		
		public function QuestsMapView()
		{
				super();
				this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
		}
		
		private function onComplete(event:FlexEvent):void
		{
			closeQuestsMapButton.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
			saveQuestsMapButton.addEventListener(MouseEvent.CLICK, onSaveButtonClick);
			addQuestButton.addEventListener(MouseEvent.CLICK, onAddQuestButtonClick);
			drawQuestBubble(mapArea.width/2, mapArea.height/2, 10, 5, 0);
		}
		
		private function onCloseButtonClick(event:MouseEvent):void
		{
			var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_CLOSEQUESTSMAP);
			AppDynamicEventManager.getInstance().dispatchEvent(de);
		}
		
		private function onSaveButtonClick(event:MouseEvent):void
		{
			Alert.show("Functionality still in progress, not yet working!");
		}
		
		private function onAddQuestButtonClick(event:MouseEvent):void
		{
			if (!isEditorVis)
			{
				trace("No quest editor currently open, so lets open it up and create a new quest!");
				questEditShow.play();
			}
			else
			{
				trace("Closing currently open quest editor so we can add a new one!");
			}
		}
		
		private function drawQuestBubble(x:Number, y:Number, rad:Number, smallRad:Number, qId:Number):void
		{
			var bubble:QuestsMapQuestBubbleView = new QuestsMapQuestBubbleView(x, y, rad, smallRad, qId);
			this.addChild(bubble);
		}
	}
}