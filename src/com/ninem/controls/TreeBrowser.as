////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 9mmedia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.ninem.controls
{
	import com.ninem.controls.treebrowserclasses.DefaultDetailRenderer;
	import com.ninem.controls.treebrowserclasses.TreeBrowserList;
	import com.ninem.events.TreeBrowserEvent;
	
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.containers.HBox;
	import mx.controls.List;
	import mx.controls.Tree;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.ResizeEvent;
	import flash.events.MouseEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 * Dispatched when the user selects an item from one of the columns.
	 *
	 * @eventType com.ninem.events.TreeBrowserEvent
	 */
	[Event(name="nodeSelected", type="com.ninem.events.TreeBrowserEvent")]
	

	/**
	 * Dispatched when the user double-clicks an item from one of the columns.
	 *
	 * @eventType flash.events.MouseEvent
	 */
	[Event(name="doubleClick", type="flash.events.MouseEvent")]
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  Sets the styleName of the List controls used for the columns.
	 *
	 *  @default undefined
	 */
	[Style(name="columnStyleName", type="String", inherit="no")]
	
	/**
	 *  Sets the speed of scroll tweening when columns are added or removed. The
	 *  speed is set in terms of milliseconds per pixel moved.
	 *
	 *  @default 3
	 */
	[Style(name="scrollTweenRate", type="Number", inherit="no")]
	
	/**
	 *  Specifies the default icon for a leaf item.
	 *  In MXML, you can use the following syntax to set this property:
	 *  <code>defaultLeafIcon="&#64;Embed(source='c.jpg');"</code>
	 *
	 *  @default uses the default from the Tree component
	 */
	[Style(name="defaultLeafIcon", type="Class", format="EmbeddedFile", inherit="no")]

	/**
	 *  Specifies the folder open icon for a branch item of the tree.
	 *  In MXML, you can use the following syntax to set this property:
	 *  <code>folderOpenIcon="&#64;Embed(source='a.jpg');"</code>
	 *
	 *  @default uses the default from the Tree component
	 */
	[Style(name="folderOpenIcon", type="Class", format="EmbeddedFile", inherit="no")]

	/**
	 *  Specifies the folder closed icon for a branch item of the tree.
	 *  In MXML, you can use the following syntax to set this property:
	 *  <code>folderClosedIcon="&#64;Embed(source='b.jpg');"</code>
	 *
	 *  @default uses the default from the Tree component
	 */
	[Style(name="folderClosedIcon", type="Class", format="EmbeddedFile", inherit="no")]

	
	/**
	 * TreeBrowser is a control for navigating through a hierarchical data structure (tree). It displays
	 * each level of the object hierarchy as a column containing a list of all its children. It can 
	 * also optionally display information about a selected leaf node of the tree in a customizable
	 * pane.
	 * 
	 * @author 9mmedia
	 * @see http://www.9mmedia.com
	 */
	public class TreeBrowser extends HBox
	{	
		private var _columnWidth:int = 200;
	    private var columnWidthChanged:Boolean = false;
		private var _showDetails:Boolean = false;
		private var _rootModel:ICollectionView;
		private var _hasRoot:Boolean = false;
		private var _showRoot:Boolean = true;
		private var dataProviderChanged:Boolean;
		private var showRootChanged:Boolean = false;
		private var _selectedItem:Object;
	    private var _iconField:String = "icon";
	    private var iconFieldChanged:Boolean = false;
	    private var _iconFunction:Function;
	    private var iconFunctionChanged:Boolean = false;
	    private var _labelField:String = "label";
	    private var labelFieldChanged:Boolean = false;
	    private var _labelFunction:Function;
	    private var labelFunctionChanged:Boolean = false;
		private var storedValue:Number;
		private var tween:AnimateProperty;
	    private var _dataDescriptor:ITreeDataDescriptor = new DefaultDataDescriptor();
	    private var _detailRenderer:IFactory = new ClassFactory(DefaultDetailRenderer);
		// this is included only so that we have access to default tree styles
		private var tree:Tree;
		
		/**
		 * @private
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TreeBrowser");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.scrollTweenRate = 3;
			}
			
			StyleManager.setStyleDeclaration("TreeBrowser", selector, false);
		}
		initializeStyles();

		public function TreeBrowser()
		{
			super();
			setStyle("horizontalGap", 0);
			addEventListener(ResizeEvent.RESIZE, onResize);
		}
		
	   [Inspectable(category="Data")]
	
	    /**
	     *  TreeBrowser delegates to the data descriptor for information about the data.
	     *  This data is then used to parse and move about the data source.
	     *  <p>When you specify this property as an attribute in MXML you must
	     *  use a reference to the data descriptor, not the string name of the
	     *  descriptor. Use the following format for the property:</p>
	     *
	     * <pre>&lt;mx:Tree id="tree" dataDescriptor="{new MyCustomTreeDataDescriptor()}"/&gt;></pre>
	     *
	     *  <p>Alternatively, you can specify the property in MXML as a nested
	     *  subtag, as the following example shows:</p>
	     *
	     * <pre>&lt;mx:Tree&gt;
	     * &lt;mx:dataDescriptor&gt;
	     * &lt;myCustomTreeDataDescriptor&gt;</pre>
	     *
	     * <p>The default value is an internal instance of the
	     *  DefaultDataDescriptor class.</p>
	     *
	     */
	    public function set dataDescriptor(value:ITreeDataDescriptor):void
	    {
	        _dataDescriptor = value;
	    }
	
	    /**
	     *  Returns the current ITreeDataDescriptor.
	     *
	     *   @default DefaultDataDescriptor
	     */
	    public function get dataDescriptor():ITreeDataDescriptor
	    {
	        return ITreeDataDescriptor(_dataDescriptor);
	    }

	    /**
	     *  Sets the visibility of the root item.
	     *
	     *  If the dataProvider data has a root node, and this is set to 
	     *  <code>false</code>, the TreeBrowser control does not display the root item. 
	     *  Only the decendants of the root item are displayed.  
	     * 
	     *  This flag has no effect on non-rooted dataProviders, such as List and Array. 
	     *
	     *  @default true
	     *  @see #hasRoot
	     */
	    public function get showRoot():Boolean
	    {
	        return _showRoot;
	    }
	
	    /**
	     *  @private
	     */
	    public function set showRoot(value:Boolean):void
	    {
	        if (_showRoot != value)
	        {
	            _showRoot = value;
	            showRootChanged = true;
	            invalidateProperties();
	        }
	    }
	    
	    /**
	    * Sets the visibility of the details pane when a leaf node is selected.
	    * 
	    * @default false
	    */
	    public function get showDetails():Boolean{
	    	return _showDetails;
	    }
	    
	    /**
	    * @private
	    */
	    public function set showDetails(value:Boolean):void{
	    	_showDetails = value;
	    }
	    
	    /**
	    * Sets the renderer used to display the details pane for a selected leaf node.
	    * 
	    * @default DefaultDetailRenderer
	    */
	    public function get detailRenderer():IFactory{
	    	return _detailRenderer;
	    }
	    
	    /**
	     *  @private
	     */
	    public function set detailRenderer(value:IFactory):void{
	    	_detailRenderer = value;
	    }
	    
	    /**
	     *  The name of the field in the data provider object that determines what to 
	     *  display as the icon. By default, the list class does not try to display 
	     *  icons with the text in the rows.  However, by specifying an icon 
	     *  field, you can specify a graphic that is created and displayed as an 
	     *  icon in the row.  This property is ignored by DataGrid.
	     *
	     *  <p>The renderers will look in the data provider object for a property of 
	     *  the name supplied as the iconField.  If the value of the property is a 
	     *  Class, it will instantiate that class and expect it to be an instance 
	     *  of an IFlexDisplayObject.  If the value of the property is a String, 
	     *  it will look to see if a Class exists with that name in the application, 
	     *  and if it can't find one, it will also look for a property on the 
	     *  document with that name and expect that property to map to a Class.</p>
	     *
	     *  @default null
	     */
	    public function get iconField():String
	    {
	        return _iconField;
	    }
	
	    /**
	     *  @private
	     */
	    public function set iconField(value:String):void
	    {
	        _iconField = value;
	        iconFieldChanged = true;
	        invalidateProperties();
	    }
	
	    /**
	     *  A user-supplied function to run on each item to determine its icon.  
	     *  By default the list does not try to display icons with the text 
	     *  in the rows.  However, by specifying an icon function, you can specify 
	     *  a Class for a graphic that will be created and displayed as an icon 
	     *  in the row.  This property is ignored by DataGrid.
	     *
	     *  <p>The iconFunction takes a single argument which is the item
	     *  in the data provider and returns a Class.</p>
	     * 
	     *  <blockquote>
	     *  <code>iconFunction(item:Object):Class</code>
	     *  </blockquote>
	     * 
	     *  @default null
	     */
	    public function get iconFunction():Function
	    {
	        return _iconFunction;
	    }
	
	    /**
	     *  @private
	     */
	    public function set iconFunction(value:Function):void
	    {
	        _iconFunction = value;
			iconFunctionChanged = true;
			invalidateProperties();
	    }
	
	    /**
	     *  The name of the field in the data provider items to display as the label. 
	     *  By default the list looks for a property named <code>label</code> 
	     *  on each item and displays it.
	     *  However, if the data objects do not contain a <code>label</code> 
	     *  property, you can set the <code>labelField</code> property to
	     *  use a different property in the data object. An example would be 
	     *  "FullName" when viewing a set of people names fetched from a database.
	     *
	     *  @default "label"
	     */
	    public function get labelField():String
	    {
	        return _labelField;
	    }
	
	    /**
	     *  @private
	     */
	    public function set labelField(value:String):void
	    {
	        _labelField = value;
	        labelFieldChanged = true;
	        invalidateProperties();
	    }
	
	    /**
	     *  A user-supplied function to run on each item to determine its label.  
	     *  By default, the list looks for a property named <code>label</code> 
	     *  on each data provider item and displays it.
	     *  However, some data sets do not have a <code>label</code> property
	     *  nor do they have another property that can be used for displaying.
	     *  An example is a data set that has lastName and firstName fields
	     *  but you want to display full names.
	     *
	     *  <p>You can supply a <code>labelFunction</code> that finds the 
	     *  appropriate fields and returns a displayable string. The 
	     *  <code>labelFunction</code> is also good for handling formatting and 
	     *  localization. </p>
	     *
	     *  <p>For most components, the label function takes a single argument
	     *  which is the item in the data provider and returns a String.</p>
	     *  <pre>
	     *  myLabelFunction(item:Object):String</pre>
	     *
	     *  <p>The method signature for the DataGrid and DataGridColumn classes is:</p>
	     *  <pre>
	     *  myLabelFunction(item:Object, column:DataGridColumn):String</pre>
	     * 
	     *  <p>where <code>item</code> contains the DataGrid item object, and
	     *  <code>column</code> specifies the DataGrid column.</p>
	     *
	     *  @default null
	     */
	    public function get labelFunction():Function
	    {
	        return _labelFunction;
	    }
	
	    /**
	     *  @private
	     */
	    public function set labelFunction(value:Function):void
	    {
	        _labelFunction = value;
	        labelFunctionChanged = true;
	        invalidateProperties();
	    }
	    
	    /**
	    * Sets the width of the columns displayed in the TreeBrowser.
	    * 
	    * @default 150
	    */
	    public function get columnWidth():int{
	    	return _columnWidth;
	    }
	    
	    /**
	     *  @private
	     */
	    public function set columnWidth(value:int):void{
	    	_columnWidth = value;
	    	columnWidthChanged = true;
	    	invalidateDisplayList();
	    }

 	    /**
	     *  @private
	     */
	    public function get dataProvider():Object
	    {
	        if (_rootModel)
	            return _rootModel;
	
	        return null;
	    }
	    
	   public function set dataProvider(value:Object):void
	    {
	        // handle strings and xml
	        if (typeof(value)=="string")
	            value = new XML(value);
	        else if (value is XMLNode)
	            value = new XML(XMLNode(value).toString());
	        else if (value is XMLList)
	            value = new XMLListCollection(value as XMLList);
	        
	        if (value is XML)
	        {
	            _hasRoot = true;
	            var xl:XMLList = new XMLList();
	            xl += value;
	            _rootModel = new XMLListCollection(xl);
	        }
	        //if already a collection dont make new one
	        else if (value is ICollectionView)
	        {
	            _rootModel = ICollectionView(value);
	            if (_rootModel.length == 1)
	            	_hasRoot = true;
	        }
	        else if (value is Array)
	        {
	            _rootModel = new ArrayCollection(value as Array);
	        }
	        //all other types get wrapped in an ArrayCollection
	        else if (value is Object)
	        {
	            _hasRoot = true;
	            // convert to an array containing this one item
	            var tmp:Array = [];
	            tmp.push(value);
	            _rootModel = new ArrayCollection(tmp);
	        }
	        else
	        {
	            _rootModel = new ArrayCollection();
	        }
	        //flag for processing in commitProps
	        dataProviderChanged = true;
	        invalidateProperties();
	        invalidateDisplayList();
	    }
	
	    /**
	     *  A reference to the selected item in the data provider.
	     * 
	     *  @default null
	     */
	    public function get selectedItem():Object{
	    	return _selectedItem;
	    }
	    
	    /**
	     *  @private
	     * 
	     *  adds or removes columns to match the current width of the component
	     */
		private function updateColumns(currentWidth:Number):void{
			var w:Number = currentWidth;
			var columnsChanged:Boolean = false;
			if(w > 0){
				var column:UIComponent;
				// this is in a loop so that it can support variable-width columns (not currently implemented)
				for(var i:int=0; i<numChildren; i++){
					column = getChildAt(i) as UIComponent;
					w -= column.width;
				}
				// if there is room remaining, add columns to fill
				if(w > 0){
					while (w > 0){
						addChild(createColumn());
						w -= columnWidth;
						columnsChanged = true
					}
				}else{
					// there are more columns than can fit; remove empty ones
					for(i=numChildren-1; i>=0; i--){
						column = getChildAt(i) as UIComponent;
						if(column.x > currentWidth && column is TreeBrowserList && !(TreeBrowserList(column).dataProvider && TreeBrowserList(column).dataProvider.length > 0)){
							removeChild(column);
							columnsChanged = true;
						}else{
							// break as soon as we hit a column that is visible or has data
							break;
						}
					}
				}
				checkScrollBar();
			}
		}
		
	    /**
	     *  @private
	     *  creates a new TreeBrowserList instance for a column
	     */
		private function createColumn():TreeBrowserList{
			var list:TreeBrowserList = new TreeBrowserList();
			list.percentHeight = 100;
			list.width = list.minWidth = columnWidth - 2; // subtracting 2 to account for column border
			list.doubleClickEnabled = doubleClickEnabled;
			list.dataDescriptor = _dataDescriptor;
			// use a change listener to capture selection change
			list.addEventListener(ListEvent.CHANGE, selectionChangeHandler);
			// change listener doesn't fire when a selected item is clicked on again, so use click listener as well
			list.addEventListener(ListEvent.ITEM_CLICK, selectionChangeHandler);
			if(doubleClickEnabled) list.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			list.styleName = getStyle("columnStyleName");
			if(iconField) list.iconField = iconField;
			if(iconFunction!=null) list.iconFunction = iconFunction;
			if(labelField) list.labelField = labelField;
			if(labelFunction!=null) list.labelFunction = labelFunction;
			
			return list;
 		}
		
	    /**
	     *  @private
	     *  creates a new TreeBrowserList instance for a column
	     */
		private function selectionChangeHandler(event:ListEvent):void{
			if(tween && tween.isPlaying) return;
			var column:TreeBrowserList = event.currentTarget as TreeBrowserList;
			var index:int = getChildIndex(column);
			var children:ICollectionView;
			_selectedItem = column.selectedItem;
			if(_selectedItem){
				children = _dataDescriptor.getChildren(column.selectedItem, _rootModel);
				if(children.length > 0 || showDetails){
					// item clicked has children or we are displaying object details
					var nextColumn:UIComponent;
					if(index < numChildren - 1){
						// if item clicked is not in the last column
						nextColumn = getChildAt(index + 1) as UIComponent;
						if(children.length == 0){
							if(nextColumn is TreeBrowserList){
								nextColumn = createDetailRenderer();
								removeChildAt(index + 1);
								addChildAt(nextColumn, index + 1);
							}
						}else{
							if(!(nextColumn is TreeBrowserList)){
								removeChildAt(index + 1);
								nextColumn = createColumn();
								addChildAt(nextColumn, index + 1);
							}
						}
						// reset the columns after the next one, if there are any
						if(index < numChildren - 2)
							clearColumns(index + 2, true);
						else if(index == numChildren - 2) 
							scrollToEnd();
					}else{
						// item clicked is in the last column, new column needs to be added
						if(children.length == 0)
							nextColumn = createDetailRenderer();
						else
							nextColumn = createColumn();
						addChild(nextColumn);
						// need to wait until display has updated to scroll
						addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
					}
					if(nextColumn is TreeBrowserList)
						TreeBrowserList(nextColumn).dataProvider = children;
					else
						IListItemRenderer(nextColumn).data = column.selectedItem;
				}else{
					// item clicked has no children, clear all columns after this one
					if(index < numChildren - 1)
						clearColumns(index + 1, true);
				}
			}else{
				// selectedItem is null, item must have been deselected by control-clicking
				clearColumns(index + 1, true);
				if(index > 0){
					_selectedItem = TreeBrowserList(getChildAt(index - 1)).selectedItem;
					children = _dataDescriptor.getChildren(_selectedItem, _rootModel);
				}
			}
			var browserEvent:TreeBrowserEvent = new TreeBrowserEvent(TreeBrowserEvent.NODE_SELECTED);
			browserEvent.isBranch = children != null && children.length > 0;
			browserEvent.item = _selectedItem;
			dispatchEvent(browserEvent);
		}
		
		private function doubleClickHandler(event:MouseEvent):void{
			event.stopPropagation();
			dispatchEvent(event.clone());
		}
		
	    /**
	     *  @private
	     *  creates an instance of detailRenderer for displaying details pane
	     */
		private function createDetailRenderer():UIComponent{
			var renderer:UIComponent = detailRenderer.newInstance() as UIComponent;
			renderer.width = columnWidth - 2;
			renderer.percentHeight = 100;
			return renderer;
		}
		
		private function onUpdateComplete(event:FlexEvent):void{
			removeEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
			scrollToEnd();
		}
		
	    /**
	     *  @private
	     *  scrolls to show the last column
	     */
		private function scrollToEnd():void{
			var scrollTweenRate:Number = getStyle("scrollTweenRate");
			if(!tween) tween = new AnimateProperty(this);
			tween.addEventListener(EffectEvent.EFFECT_END, onScrollToEndFinished);
			tween.property = "horizontalScrollPosition";
			tween.toValue = maxHorizontalScrollPosition;
			tween.duration = scrollTweenRate * (maxHorizontalScrollPosition - horizontalScrollPosition);
			tween.play([this]);
		}
		
		private function onScrollToEndFinished(event:EffectEvent):void{
			tween.removeEventListener(EffectEvent.EFFECT_END, onScrollToEndFinished);
			checkScrollBar(); 
		}
		
		
		/**
		 *  @private
		 *  removes or clears data from all columns after startIndex
		 *  if useTween is true, it will scroll first and then remove columns
		 *  otherwise columns are cleared immediately
		 */
		private function clearColumns(startIndex:int, useTween:Boolean=false):void{
			var column:UIComponent;
			var removeCount:int = 0;
			for(var i:int=startIndex; i<numChildren; i++){
				column = getChildAt(i) as UIComponent;
				if(column is TreeBrowserList){
					TreeBrowserList(column).dataProvider = null;
				}else{
					removeChildAt(i);
					column = createColumn();
					addChildAt(column, i);
				}
				removeCount++;
				if(column.x > width){
					if(!useTween) 
						removeChildAt(i);
				}
			}
			if(useTween && removeCount > 0){
				var scrollTweenRate:Number = getStyle("scrollTweenRate");
				if(!tween) tween = new AnimateProperty(this);
				tween.addEventListener(EffectEvent.EFFECT_END, onRemoveTweenFinished);
				tween.property = "horizontalScrollPosition";
				storedValue = startIndex;
				// calculate scrollposition of column that will now be last
				var toValue:Number = Math.max((numChildren - removeCount) * (columnWidth - 2) - width, 0);
				tween.toValue = toValue;
				tween.duration = scrollTweenRate * (horizontalScrollPosition - toValue);
				tween.play([this]);
			}
		}
		
		private function onRemoveTweenFinished(event:EffectEvent):void{
			tween.removeEventListener(EffectEvent.EFFECT_END, onRemoveTweenFinished);
			clearColumns(storedValue);
			checkScrollBar(); 
		}
		
		private function onResize(event:ResizeEvent):void{
	    	updateColumns(width);
		}
		
		/**
		 *  @private
		 *  checks to see if scrollbar should be enabled or not
		 */
		private function checkScrollBar():void{
	    	var column:UIComponent = getChildAt(numChildren-1) as UIComponent;
	    	if(!(column is TreeBrowserList) || (TreeBrowserList(column).dataProvider && TreeBrowserList(column).dataProvider.length > 0))
	    		horizontalScrollPolicy = ScrollPolicy.AUTO;
	    	else
	    		horizontalScrollPolicy = ScrollPolicy.OFF;
		}
		
	    /**
	     *  @private
	     *  helper function to make a property change to all columns
	     */
	     private function updateColumnProperty(propName:String, newValue:Object):void{
	     	var column:UIComponent;
	     	for(var i:int=0; i<numChildren; i++){
	     		column = getChildAt(i) as UIComponent;
	     		if(column is TreeBrowserList) column[propName] = newValue;
	     	}
	     }
	     
	    /**
	     *  @private
	     *  helper function to make a style change to all columns
	     */
	     private function updateColumnStyle(styleProp:String, newValue:Object):void{
	     	var column:UIComponent;
	     	for(var i:int=0; i<numChildren; i++){
	     		column = getChildAt(i) as UIComponent;
	     		if(column is TreeBrowserList) column.setStyle(styleProp, newValue);
	     	}
	     }
	     
	    /**
	     *  @private
	     */
		override protected function measure():void{
			super.measure();
			measuredMinWidth = columnWidth;
		}
		
	    /**
	     *  @private
	     */
	     override protected function commitProperties():void{
	     	super.commitProperties();
	     	if(iconFieldChanged){
	     		updateColumnProperty("iconField", iconField);
	     		iconFieldChanged = false;
	     	}
	     	if(iconFunctionChanged){
	     		updateColumnProperty("iconFunction", iconFunction);
	     		iconFunctionChanged = false;
	     	}
	     	if(labelFieldChanged){
	     		updateColumnProperty("labelField", labelField);
	     		labelFieldChanged = false;
	     	}
	     	if(labelFunctionChanged){
	     		updateColumnProperty("labelFunction", labelFunction);
	     		labelFunctionChanged = false;
	     	}
	     }
	     
	    /**
	     *  @private
	     */
	    override protected function updateDisplayList(w:Number, h:Number):void{
	    	super.updateDisplayList(w, h);
	    		
	        if (showRootChanged)
	        {
	            if (!_hasRoot)
	                showRootChanged = false;            
	        }
	        
	        if (dataProviderChanged || showRootChanged)
	        {
	            var tmpCollection:ICollectionView;
	            
                var rootItem:* = _rootModel.createCursor().current;
	            if (_rootModel && !_showRoot && _hasRoot)
	            {
	                if (rootItem != null &&
	                    _dataDescriptor.isBranch(rootItem, _rootModel) &&
	                    _dataDescriptor.hasChildren(rootItem, _rootModel))
	                {
	                    tmpCollection = _dataDescriptor.getChildren(rootItem, _rootModel);
	                }
	            }
	            
	            var firstColumn:List = getChildAt(0) as List;
	            firstColumn.dataProvider = tmpCollection ? tmpCollection : rootItem;
	            firstColumn.validateNow();

	            dataProviderChanged = false;
	            showRootChanged = false;
	        }
	     	if(columnWidthChanged){
	     		updateColumnProperty("width", columnWidth-2);
	     		updateColumns(w);
	     		columnWidthChanged = false;
	     	}
	    }
	    
	   /**
	     *  @private
	     */
	    override public function styleChanged(styleProp:String):void{
	    	if(styleProp==null || styleProp=="columnStyleName" || styleProp=="defaultLeafIcon" || styleProp=="folderOpenIcon" || styleProp=="folderClosedIcon"){
		    	var propName:String;
		    	if(styleProp == "columnStyleName") propName = "styleName";
		    	else propName = styleProp;
	    		updateColumnStyle(propName, getStyle(styleProp));
	    	}
	    	super.styleChanged(styleProp);
	    }
	}
}