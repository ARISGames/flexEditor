/*
* Copyright 2008 Google Inc. 
* Licensed under the Apache License, Version 2.0:
*  http://www.apache.org/licenses/LICENSE-2.0
*/
package org.arisgames.editor.view {

import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;


public class PlaceMarkerIcon extends Sprite {
  	[Embed('play.png')] private var TestImg:Class;
  	public static const boxHeight:uint = 20;
 	public static const pointWidth:uint = 10;
  	public static const pointHeight:uint = 15;
  	public static const cornerRadius:uint = 5;
	public static const textMargin:uint = 5;
	
	public var labelMc:TextField;
  
  public function PlaceMarkerIcon(label:String) {
	  super();
	  
	  //Label
	  labelMc = new TextField();
	  var format:TextFormat = new TextFormat();
	  format.color = 0xFFFFFF;
	  format.size = 12;
	  format.font = "Arial";
	  labelMc.autoSize = TextFieldAutoSize.LEFT;
	  labelMc.selectable = false;
	  labelMc.border = false;
	  labelMc.defaultTextFormat = format;
	  labelMc.mouseEnabled = false;
	  labelMc.width = boxWidth;
	  labelMc.height = 20;
	  labelMc.text = label;
	  
	  var boxWidth:uint = labelMc.width;

	  //Container Shape
	var container:Shape = new Shape();
	container.graphics.beginFill(0x000000, 0.5);
	container.graphics.lineStyle(1, 0x000000, .75);
	container.graphics.moveTo(0, 0);
	
	var curX:int;
	var curY:int;
	var topLeftX:int;
	var topLeftY:int;
	var topRightX:int;
	var topRightY:int;
	
	//To top left of point
	curX = -pointWidth/2; 
	curY = -pointHeight; 
	container.graphics.lineTo(curX, curY);
	
	//To bottom left of box
	curX = curX - (boxWidth/2 - pointWidth/2); 
	container.graphics.lineTo(curX,curY);
	
	//To top left of box
	curY = curY - boxHeight;
	topLeftX = curX; topLeftY = curY;
	container.graphics.lineTo(curX,curY);
	
	//To top right of box
	curX = curX + boxWidth;
	topRightX = curX; topRightY = curY;
	container.graphics.lineTo(curX,curY);
 
	//To bottom right of box
	curY = curY + boxHeight;
	container.graphics.lineTo(curX,curY);

	//To top right of point
	curX = curX - (boxWidth/2 - pointWidth/2);
	container.graphics.lineTo(curX,curY);

	//Close to the bottom of the point
	container.graphics.lineTo(0,0);
	
	container.graphics.endFill();
	this.addChild(container);  
	  
	//Image
	//addChild(new TestImg());
  	
    labelMc.x = topLeftX;
    labelMc.y = topLeftY + 2;
    addChild(labelMc);
    cacheAsBitmap = true;
  }
  
}

}
