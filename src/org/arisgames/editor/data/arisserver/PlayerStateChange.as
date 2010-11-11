package org.arisgames.editor.data.arisserver	
{
	import org.arisgames.editor.util.AppConstants;
	import mx.controls.Alert;
	import mx.events.DynamicEvent;
	import mx.rpc.Responder;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;

	public class PlayerStateChange
	{
		public var playerStateChangeId:Number;
		public var eventType:String; //Needs to be PLAYERSTATECHANGE_EVENTTYPE_
		public var eventDetail:Number; //Usally the Id of the thing
		public var action:String; //Needs to be PLAYERSTATECHANGE_ACTION_
		public var _actionDetail:Number; //Usally the Id of the thing
		public var actionAmount:Number; //The amount to give or take
		
		public var actionDetailHuman:String; //This is the computed name of the thing

		
		public function PlayerStateChange()
		{
			super();
		}

		public function get actionHuman():String
		{
			if (action != null)
			{
				return AppUtils.convertActionDatabaseLabelToHumanLabel(action);
			}
			else
			{
				return "";
			}
		}
		
		public function set actionHuman(str:String):void
		{
			action = AppUtils.convertActionHumanLabelToDatabaseLabel(str);
		}		
		
		
		public function get actionDetail():Number {
			return _actionDetail;
		}

		public function set actionDetail(id:Number):void
		{
			trace("PlayerStateChange: set actionDetail(" + id + ") called");
			_actionDetail = id;
			
			// Update EventDetailHuman
			if (id < 1)
			{
				trace("PlayerStateChange: setActionDetail(< 1), can't load any objects based off of it.");
				return;
			}
			
			trace("PlayerStateChange: going to load an item for item id:" + _actionDetail);
			AppServices.getInstance().getItemById(GameModel.getInstance().game.gameId, _actionDetail, new Responder(handleDataLoad, handleFault));
			
		}
		
		private function handleDataLoad(obj:Object):void
		{
			trace("PlayerStateChange handleDataLoad()...");
			if (obj.result.returnCode != 0)
			{
				trace("Bad handle loading EventDetailHuman attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading EventDetailHuman");
			}
			else
			{
				this.actionDetailHuman = obj.result.data.name;
				trace("PlayerStateChange now has eventDetailHuman:" + actionDetailHuman + " for PSC:" + this.playerStateChangeId);
				
				var de:DynamicEvent = new DynamicEvent(AppConstants.DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR);
				AppDynamicEventManager.getInstance().dispatchEvent(de);
			}
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems With Requirement Data");
		}
		
		
	}
}