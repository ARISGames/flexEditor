package org.arisgames.editor.components
{
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.ComboBox;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.events.FlexEvent;
	import mx.rpc.Responder;
	import org.arisgames.editor.data.arisserver.Requirement;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	
	public class PlayerStateChangesEditorActionRendererView extends VBox implements IDropInListItemRenderer
	{
		// GUI
		[Bindable] public var cbo:ComboBox;
		[Bindable] public var possibleObjects:ArrayCollection;
		
		private var _listData:DataGridListData;
		// Define a property for returning the new value to the cell.
		[Bindable] public var value:Object;
		
		/**
		 * Constructor
		 */
		public function PlayerStateChangesEditorActionRendererView()
		{
			super();
			trace("PlayerStateChangesEditorActionRendererView's constructor");
			
			possibleObjects = new ArrayCollection();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("PlayerStateChangesEditorActionRendererView's handleInit");
			this.loadPossibleItems();
		}
		
		override public function get data():Object
		{
			return super.data;
		}
		
		override public function set data(value:Object):void
		{
			trace("set data called with value = '" + value + "'; what will be assigned = '" + value[_listData.dataField] + "'");
			cbo.data = value[_listData.dataField];
			//textLabel.text = value[_listData.dataField];
			this.updateComboBoxSelectedItem();
		}
		
		public function get listData():BaseListData
		{
			trace("getListData called.  Returning = '" + _listData + "'");
			return _listData;
		}
		
		public function set listData(value:BaseListData):void
		{
			trace("setListData() called with value = '" + value + "'");
			_listData = DataGridListData(value);
		}
		
		public function get text():String
		{
			
			if (value != null)
			{
				trace("Value doesn't equal null, so return a value.  value = '" + value.toString() + "'");            
				return value.toString();
			}
			trace("No Text To Return");
			return "No Text To Return";
		}
		
		public function set text(value:String):void
		{
			trace("set text() called with value = '" + value + "'");
		}
		
		public function loadPossibleItems():void
		{
			trace("loadPossibleItems() called");
			
			var to:Object;
			
			to = new Object();
			to.label = AppConstants.PLAYERSTATECHANGE_ACTION_GIVEITEM_HUMAN;
			to.data = AppConstants.PLAYERSTATECHANGE_ACTION_GIVEITEM;
			possibleObjects.addItem(to);
			
			to = new Object();
			to.label = AppConstants.PLAYERSTATECHANGE_ACTION_TAKEITEM_HUMAN;
			to.data = AppConstants.PLAYERSTATECHANGE_ACTION_TAKEITEM;
			possibleObjects.addItem(to);
			
			possibleObjects.refresh();
			this.updateComboBoxSelectedItem();
		}
		
	
		private function updateComboBoxSelectedItem():void
		{
			trace("in updateComboBoxSelectedItem(), looking for Object to match = '" + cbo.data + "'");
			for (var j:Number = 0; j < possibleObjects.length; j++)
			{
				var o:Object = possibleObjects.getItemAt(j);
				trace("j = '" + j + "'; cbo.data = '" + cbo.data + "'; Object Id (o.data) = '" + o.data + "'; Object's Human Label (o.label) = '" + o.label + "'");
				if (cbo.data == o.label || cbo.data == o.data)
				{
					trace("Found the Object that matched, now setting ComboBox's selectedItem to it.");
					cbo.selectedItem = o;
					return;
				}
			}
		}
	}
}