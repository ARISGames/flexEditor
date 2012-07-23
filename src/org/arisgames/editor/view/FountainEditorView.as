package org.arisgames.editor.view
{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.NumericStepper;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.data.PlaceMark;
	import org.arisgames.editor.data.arisserver.Fountain;
	import org.arisgames.editor.data.arisserver.Location;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	public class FountainEditorView extends Panel
	{
		// Data Object
		public var delegate:Object;
		
		private var fountain:Fountain;
		//private var location:Location;
		private var location:PlaceMark;
		
		// Params
		[Bindable] public var maxAmount:NumericStepper;
		[Bindable] public var spawnProbability:NumericStepper;
		[Bindable] public var spawnRate:NumericStepper;
		
		// GUI
		[Bindable] public var deleteButton:Button;
		[Bindable] public var closeButton:Button;
		[Bindable] public var selectButton:Button;
				
		/**
		 * Constructor
		 */
		public function FountainEditorView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("in FountainEditorView's handleInit");
			deleteButton.addEventListener(MouseEvent.CLICK, handleDeleteButton);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			selectButton.addEventListener(MouseEvent.CLICK, handleSelectButton);
			AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEFOUNTAINEDITOR, handleCloseButton);
		}
		
		public function setLocation(l:PlaceMark):void
		{
			this.location = l;
			this.location.isFountain = true;
			AppServices.getInstance().getFountainForLocation(GameModel.getInstance().game.gameId, l, new Responder(handleLoadingOfFountain, handleFault));
		}
		
		private function handleDeleteButton(evt:MouseEvent):void
		{
			trace("FountainEditorView: handleDeleteButton()");
			this.delegate.fountainPopupButton.label = "Automate";
			this.location.isFountain = false;
			AppServices.getInstance().deleteFountainFromLocation(GameModel.getInstance().game.gameId, this.location, null);
			PopUpManager.removePopUp(this);
		}
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("FountainEditorView: handleCloseButton()");
			PopUpManager.removePopUp(this);
		}
		
		private function handleSelectButton(evt:MouseEvent):void
		{
			trace("FountainEditorView: handleSaveAndCloseButton()");
			this.populateFountainFromForm();
			AppServices.getInstance().saveFountainForLocation(GameModel.getInstance().game.gameId, this.location, this.fountain, new Responder(handleSavingOfFountain, handleFault));
			PopUpManager.removePopUp(this);
		}
		
		private function handleSavingOfFountain(obj:Object):void
		{
			if(obj.result.returnCode != 0)
				Alert.show("There was an error saving the fountain settings.");
		}
		
		private function handleLoadingOfFountain(obj:Object):void
		{
			trace("In handleLoadingOfFountain() Result called with obj = " + obj + "; Result = " + obj.result);
			this.fountain = new Fountain();
			if (obj.result.returnCode == 1)
			{
				trace("No Fountain exists for this location- creating one");
				//Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Spawnables");
				AppServices.getInstance().createFountainForLocation(GameModel.getInstance().game.gameId, this.location, new Responder(handleLoadingOfFountain, handleFault));
			}
			else if(obj.result.returnCode == 0)
			{
				this.fountain.fountainId = obj.result.data.fountain_id;
				this.fountain.locationId = obj.result.data.location_id;
				this.fountain.spawnProbability = obj.result.data.spawn_probability;
				this.fountain.spawnRate = obj.result.data.spawn_rate;
				this.fountain.maxAmount = obj.result.data.max_amount;
				this.populateFormFromFountain();
			}
			else
			{
				trace("Error loading Fountain");
				Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Fountain");
				return;
			}
			
			trace("Finished with handleLoadingOfFountain().");
		}
		
		public function populateFormFromFountain():void
		{
			this.maxAmount.value = this.fountain.maxAmount;
			this.spawnProbability.value = this.fountain.spawnProbability;
			this.spawnRate.value = this.fountain.spawnRate;
		}
		
		public function populateFountainFromForm():void
		{
			this.fountain.maxAmount = this.maxAmount.value;
			this.fountain.spawnProbability = this.spawnProbability.value;
			this.fountain.spawnRate = this.spawnRate.value;			
		}
	
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems Loading Media");
		}
	}
}