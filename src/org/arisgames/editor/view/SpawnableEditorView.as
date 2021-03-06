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
	
	import org.arisgames.editor.data.arisserver.Spawnable;
	import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	import org.arisgames.editor.view.RequirementsEditorMX;
	
	public class SpawnableEditorView extends Panel
	{
		// Data Object
		public var delegate:Object;
		
		private var spawnable:Spawnable;
		private var objectPaletteItem:ObjectPaletteItemBO;
		private var requirementsEditor:RequirementsEditorMX;
		
		// Params
		[Bindable] public var amount:NumericStepper;
		[Bindable] public var amountRestriction:ComboBox;
		[Bindable] public var minArea:NumericStepper;
		[Bindable] public var maxArea:NumericStepper;
		[Bindable] public var locationBoundType:ComboBox;
		[Bindable] public var mapButtonBox:HBox;
		[Bindable] public var mapButton:Button;
		[Bindable] public var lat:TextInput;
		[Bindable] public var lon:TextInput;
		[Bindable] public var spawnProbability:NumericStepper;
		[Bindable] public var spawnRate:NumericStepper;
		[Bindable] public var locationName:TextInput;
		[Bindable] public var deleteWhenViewed:CheckBox;
		[Bindable] public var timeToLive:NumericStepper;
		[Bindable] public var errorRange:NumericStepper;
		[Bindable] public var forceView:CheckBox;
		[Bindable] public var hidden:CheckBox;
		[Bindable] public var quickTravel:CheckBox;
		[Bindable] public var wiggle:CheckBox;
		[Bindable] public var displayAnnotation:CheckBox;
		
		// GUI
		[Bindable] public var openRequirementsEditorButton:Button;
		[Bindable] public var deleteButton:Button;
		[Bindable] public var closeButton:Button;
		[Bindable] public var selectButton:Button;
				
		public function SpawnableEditorView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("in SpawnableEditorView's handleInit");
			locationBoundType.addEventListener(ListEvent.CHANGE, handleLBTChange);
			deleteButton.addEventListener(MouseEvent.CLICK, handleDeleteButton);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			selectButton.addEventListener(MouseEvent.CLICK, handleSelectButton);
			AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSESPAWNABLESEDITOR, handleCloseButton);
			openRequirementsEditorButton.addEventListener(MouseEvent.CLICK, handleOpenRequirementsButtonClick);
			AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR, closeRequirementsEditor);	
		}
		
		public function setObjectPaletteItem(opi:ObjectPaletteItemBO):void
		{
			trace("setting objectPaletteItem with name = '" + opi.name + "' in ItemEditorPlaqueView");
			objectPaletteItem = opi;
			AppServices.getInstance().getSpawnableForObject(GameModel.getInstance().game.gameId, opi, new Responder(handleLoadingOfSpawnable, handleFault));
		}
		
		private function handleOpenRequirementsButtonClick(evt:MouseEvent):void
		{
			trace("Starting handle Open Requirements Button click.");
			requirementsEditor = new RequirementsEditorMX();
			requirementsEditor.setRequirementTypeAndId(AppConstants.REQUIREMENTTYPE_SPAWNABLE, spawnable.spawnableId);
			
			this.parent.addChild(requirementsEditor);
			// Need to validate the display so that entire component is rendered
			requirementsEditor.validateNow();
			
			PopUpManager.addPopUp(requirementsEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(requirementsEditor);
			requirementsEditor.setVisible(true);
			requirementsEditor.includeInLayout = true;
		}
		
		private function closeRequirementsEditor(evt:DynamicEvent):void
		{
			trace("closeRequirementsEditor called...");
			PopUpManager.removePopUp(requirementsEditor);
			requirementsEditor = null;
		}
		
		private function handleDeleteButton(evt:MouseEvent):void
		{
			trace("SpawnableEditorView: handleDeleteButton()");
			this.delegate.spawnablePopupButton.label = "Make Spawn";
			AppServices.getInstance().deleteSpawnableFromObject(GameModel.getInstance().game.gameId, this.objectPaletteItem, null);
			PopUpManager.removePopUp(this);
		}
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("SpawnableEditorView: handleCloseButton()");
			PopUpManager.removePopUp(this);
		}
		
		private function handleSelectButton(evt:MouseEvent):void
		{
			trace("SpawnableEditorView: handleSaveAndCloseButton()");
			this.populateSpawnableFromForm();
			AppServices.getInstance().saveSpawnableForObject(GameModel.getInstance().game.gameId, this.objectPaletteItem, this.spawnable, new Responder(handleSavingOfSpawnable, handleFault));
			PopUpManager.removePopUp(this);
		}
		
		private function handleSavingOfSpawnable(obj:Object):void
		{
			if(obj.result.returnCode != 0)
				Alert.show("There was an error saving the spawn settings.");
		}
		
		private function handleLoadingOfSpawnable(obj:Object):void
		{
			trace("In handleLoadingOfSpawnables() Result called with obj = " + obj + "; Result = " + obj.result);
			this.spawnable = new Spawnable();
			if (obj.result.returnCode == 1)
			{
				trace("No Spawnable exists for this object- creating one");
				//Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Spawnables");
				AppServices.getInstance().createSpawnableForObject(GameModel.getInstance().game.gameId, this.objectPaletteItem, new Responder(handleLoadingOfSpawnable, handleFault));
			}
			else if(obj.result.returnCode == 0)
			{
				this.spawnable.amount = obj.result.data.amount;
				this.spawnable.amountRestriction = obj.result.data.amount_restriction;
				this.spawnable.minArea = obj.result.data.min_area;
				this.spawnable.maxArea = obj.result.data.max_area;
				this.spawnable.locationName = obj.result.data.location_name;
				this.spawnable.deleteWhenViewed = (obj.result.data.delete_when_viewed == 1 ? true : false);
				this.spawnable.errorRange = obj.result.data.error_range;
				this.spawnable.forceView = (obj.result.data.force_view == 1 ? true : false);
				this.spawnable.hidden = (obj.result.data.hidden == 1 ? true : false);
				this.spawnable.latitude = obj.result.data.latitude;
				this.spawnable.locationBoundType = obj.result.data.location_bound_type;
				this.spawnable.longitude = obj.result.data.longitude;
				this.spawnable.quickTravel = (obj.result.data.allow_quick_travel == 1 ? true : false);
				this.spawnable.spawnableId = obj.result.data.spawnable_id;
				this.spawnable.spawnProbability = obj.result.data.spawn_probability;
				this.spawnable.spawnRate = obj.result.data.spawn_rate;
				this.spawnable.timeToLive = obj.result.data.time_to_live;
				this.spawnable.type = obj.result.data.type;
				this.spawnable.typeId = obj.result.data.type_id;
				this.spawnable.wiggle = (obj.result.data.wiggle == 1 ? true : false);
				this.spawnable.displayAnnotation = (obj.result.data.show_title == 1 ? true : false);
			}
			else
			{
				trace("Error loading Spawnable");
				Alert.show("Error Was: " + obj.result.returnCodeDescription, "Error While Loading Spawnables");
				return;
			}
			
			this.populateFormFromSpawnable();
			trace("Finished with handleLoadingOfSpawnable().");
		}
		
		public function populateFormFromSpawnable():void
		{
			this.amount.value = this.spawnable.amount;
			this.amountRestriction.selectedIndex = (this.spawnable.amountRestriction == "PER_PLAYER" ? 0 : 1);
			this.minArea.value = this.spawnable.minArea;
			this.maxArea.value = this.spawnable.maxArea;
			this.locationName.text = this.spawnable.locationName;
			this.deleteWhenViewed.selected = this.spawnable.deleteWhenViewed;
			this.errorRange.value = this.spawnable.errorRange;
			this.forceView.selected = this.spawnable.forceView;
			this.hidden.selected = this.spawnable.hidden;
			this.lat.text = ""+this.spawnable.latitude;
			this.locationBoundType.selectedIndex = (this.spawnable.locationBoundType == "PLAYER" ? 0 : 1);
			if(this.spawnable.locationBoundType == "LOCATION"){
				this.mapButtonBox.includeInLayout = true;
				this.mapButtonBox.visible = true;
			} 
			else{
				this.mapButtonBox.includeInLayout = false;
				this.mapButtonBox.visible = false;
			} 
			this.lon.text = ""+this.spawnable.longitude;
			this.quickTravel.selected = this.spawnable.quickTravel;
			this.spawnProbability.value = this.spawnable.spawnProbability;
			this.spawnRate.value = this.spawnable.spawnRate;
			this.timeToLive.value = this.spawnable.timeToLive;
			this.wiggle.selected = this.spawnable.wiggle;
			this.displayAnnotation.selected = this.spawnable.displayAnnotation;
		}
		
		public function populateSpawnableFromForm():void
		{
			this.spawnable.amount = this.amount.value;
			this.spawnable.amountRestriction = this.amountRestriction.selectedLabel;
			this.spawnable.minArea = this.minArea.value;
			this.spawnable.maxArea = this.maxArea.value;
			this.spawnable.locationName = this.locationName.text;
			this.spawnable.deleteWhenViewed = this.deleteWhenViewed.selected;
			this.spawnable.errorRange = this.errorRange.value;
			this.spawnable.forceView = this.forceView.selected;
			this.spawnable.hidden = this.hidden.selected;
			this.spawnable.latitude = parseFloat(this.lat.text);
			this.spawnable.locationBoundType = this.locationBoundType.selectedLabel;
			this.spawnable.longitude = parseFloat(this.lon.text);
			this.spawnable.quickTravel = this.quickTravel.selected;
			this.spawnable.spawnProbability = this.spawnProbability.value;
			this.spawnable.spawnRate = this.spawnRate.value;
			this.spawnable.timeToLive = this.timeToLive.value;
			this.spawnable.wiggle = this.wiggle.selected;
			this.spawnable.displayAnnotation = this.displayAnnotation.selected;
		}
		
		public function setLatLon(lat:Number, lon:Number):void
		{
			this.spawnable.latitude = lat;
			this.spawnable.longitude = lon;
			this.lat.text = ""+lat;
			this.lon.text = ""+lon;
		}
		
		public function handleLBTChange(obj:Object):void
		{
			if(this.locationBoundType.selectedIndex == 1){
				this.mapButtonBox.includeInLayout = true;
				this.mapButtonBox.visible = true;
			} 
			else{
				this.mapButtonBox.includeInLayout = false;
				this.mapButtonBox.visible = false;

			} 
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems Loading Media");
		}
	}
}