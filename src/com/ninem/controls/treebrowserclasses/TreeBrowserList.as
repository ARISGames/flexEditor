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

package com.ninem.controls.treebrowserclasses
{
	import mx.controls.List;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.styles.StyleManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.controls.listClasses.IListItemRenderer;
	
	import org.arisgames.editor.util.AppConstants;

	/**
	 * TreeBrowserList is a subclass of the standard List component that sets
	 * icons and labels properly for use in the TreeBrowser
	 * 
	 * @author 9mmedia
	 */
	public class TreeBrowserList extends List
	{
		private var _dataDescriptor:ITreeDataDescriptor;
		
		public function TreeBrowserList()
		{
			super();
		}
		
	    /**
	     *  @private
	     */
		public function get dataDescriptor():ITreeDataDescriptor{
			return _dataDescriptor;
		}
		
		public function set dataDescriptor(value:ITreeDataDescriptor):void{
			_dataDescriptor = value;
		}
		
	    /**
	     *  @private
	     */
		override public function itemToLabel(data:Object):String{
			if(data is XML && labelField){
				return data.@[labelField];
			}else{
				return super.itemToLabel(data);
			}
		}
		
	    /**
	     *  @private
	     */
		private function isItemOpen(item:Object):Boolean{
			return item == selectedItem;
		}
		
	    /**
	     *  @private
	     */
		private function isBranch(item:Object):Boolean{
			return _dataDescriptor.isBranch(item);
		}
		
	    /**
	     *  @private
	     */
		override protected function selectItem(item:IListItemRenderer, shiftKey:Boolean, ctrlKey:Boolean, transition:Boolean=true):Boolean{
			var val:Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
			updateList();
			return val;
		}
		
	    /**
	     *  @private
	     */
		override public function itemToIcon(item:Object):Class{
	       if (item == null)
	        {
	            return null;
	        }
	
	        var icon:*;
	        var open:Boolean = isItemOpen(item);
	        var branch:Boolean = isBranch(item);
			var iconClass:Class;
	   		var treeCss:CSSStyleDeclaration = StyleManager.getStyleDeclaration("Tree");
			
			if (iconFunction != null)
	        {
	            return iconFunction(item)
	        }
	        else if (branch)
	        {
	        	var nameString:String = open ? "folderOpenIcon" : "folderClosedIcon";
	        	iconClass = getStyle(nameString);
	        	if(!iconClass) iconClass = treeCss.getStyle(nameString); 
	            return iconClass;
	        }
	        else
	        //let's check the item itself
	        {
	            if (item is XML)
	            {
	                try
	                {

						if(item.@icon == AppConstants.MEDIATREEICON_SEPARATOR)
							icon = AppConstants.MEDIATREEICON_SEPARATOR;
						else if(item.@icon == AppConstants.MEDIATREEICON_UPLOAD)
							icon = AppConstants.MEDIATREEICON_UPLOAD;
	                    if (item[iconField].length() != 0)
						{
	                       icon = String(item[iconField]);
						}
						
	                }
	                catch(e:Error)
	                {
	                }
	            }
	            else if (item is Object)
	            {
	                try
	                {
	                    if (iconField && item[iconField])
	                        icon = item[iconField];
	                    else if (item.icon)
	                        icon = item.icon;
	                }
	                catch(e:Error)
	                {
	                }
	            }
	        }
			
			//icon = null;
			
	        //set default leaf icon if nothing else was found
	        if (icon == null){
				//Uncomment below to bring back default leaf icons
	            //icon = getStyle("defaultLeafIcon");
				//if(!icon) icon = treeCss.getStyle("defaultLeafIcon");
	        }
	        //convert to the correct type and class
	        if (icon is Class)
	        {
	            return icon;
	        }
	        else if (icon is String)
	        {
	            iconClass = Class(systemManager.getDefinitionByName(String(icon)));
	            if (iconClass)
	                return iconClass;
	
	            return document[icon];
	        }
	        else
	        {
	            return Class(icon);
	        }
			
			return Class(icon);
		}
		
	}
}