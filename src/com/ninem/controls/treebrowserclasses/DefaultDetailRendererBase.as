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
	import mx.utils.ObjectUtil;
	import mx.containers.Canvas;
	import mx.controls.DataGrid;

	/**
	 * DefaultDetailRenderer provides a simple listing of an objects properties 
	 * for use in the details pane of the TreeBrowser
	 * 
	 * @author 9mmedia
	 */
	public class DefaultDetailRendererBase extends Canvas
	{
		public var propTable:DataGrid;
		private var dataChanged:Boolean;
		
		public function DefaultDetailRendererBase(){
			super();
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			dataChanged = true;
			invalidateProperties();
		}
		
		private function renderData():void{
			var props:Array = ObjectUtil.getClassInfo(data).properties;
			var propData:Array = [];
			for each(var prop:String in props){
				propData.push({property:prop, value:data[prop].toString()});
			}
			propTable.dataProvider = propData;
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			if(dataChanged){
				renderData();
				dataChanged = false;
			}
		}
	}
}