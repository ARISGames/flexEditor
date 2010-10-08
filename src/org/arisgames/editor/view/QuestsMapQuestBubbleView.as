package org.arisgames.editor.view
{
	import mx.containers.VBox;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	
	/**
	 * 
	 * @author Will Buck
	 */
	public class QuestsMapQuestBubbleView extends UIComponent
	{
		public var questId:Number;
		
		public var xCenter:Number;
		public var yCenter:Number;
		public var largeRadius:Number;
		public var smallRadius:Number;
		
		public var questCircle:Sprite;
		public var addQuestCircle:Sprite;
		public var deleteQuestCircle:Sprite;
		
		public function QuestsMapQuestBubbleView(x:Number, y:Number, rad:Number, smallRad:Number, qId:Number)
		{
			super();
			xCenter = x;
			yCenter = y;
			largeRadius = rad;
			smallRadius = smallRad;
			questId = qId;
			questCircle = new Sprite();
			addQuestCircle = new Sprite();
			deleteQuestCircle = new Sprite();
			questCircle.addEventListener(MouseEvent.CLICK, onQuestCircleClick);
			addQuestCircle.addEventListener(MouseEvent.CLICK, onAddCircleClick);
			deleteQuestCircle.addEventListener(MouseEvent.CLICK, onDeleteCircleClick);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			drawQuestCircle();
			drawAddCircle();
			drawDeleteCircle();
		}
		
		private function drawQuestCircle():void
		{
			questCircle.graphics.beginFill(0xFFFFFF);
			questCircle.graphics.drawCircle(xCenter, yCenter, largeRadius);
			this.addChild(questCircle);
		}
		
		private function drawAddCircle():void
		{
			addQuestCircle.graphics.beginFill(0x00FF00);
			addQuestCircle.graphics.drawCircle(xCenter + largeRadius, yCenter - largeRadius/2, smallRadius);
			this.addChild(addQuestCircle);
		}
		
		private function drawDeleteCircle():void
		{
			deleteQuestCircle.graphics.beginFill(0xFF0000);
			deleteQuestCircle.graphics.drawCircle(xCenter + largeRadius, yCenter + largeRadius/2, smallRadius);
			this.addChild(deleteQuestCircle);
		}
		
		private function onQuestCircleClick(event:MouseEvent):void
		{
			trace("In the quest opening handler of questId: " + questId);
		}
		
		private function onAddCircleClick(event:MouseEvent):void
		{
			trace("In the quest add child handler of questId: " + questId);
		}
		
		private function onDeleteCircleClick(event:MouseEvent):void
		{
			trace("In the quest delete handler of questId: " + questId);
		}
	}
}