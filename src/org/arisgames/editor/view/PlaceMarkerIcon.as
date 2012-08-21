/*
* Copyright 2008 Google Inc. 
* Licensed under the Apache License, Version 2.0:
*  http://www.apache.org/licenses/LICENSE-2.0
*/
package org.arisgames.editor.view {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import mx.messaging.AbstractConsumer;


public class PlaceMarkerIcon extends Sprite {
  	//[Embed('play.png')] private var TestImg:Class;
  	public static const boxHeight:uint = 20;
 	public static const pointWidth:uint = 10;
  	public static const pointHeight:uint = 15;
  	public static const cornerRadius:uint = 5;
	public static const textMargin:uint = 5;
	
	public var labelMc:TextField;
	private var container:Shape;
	private var format:TextFormat;
	private var ct:ColorTransform;
	public var isHighlighted:Boolean;
	public var isHidden:Boolean;
	public var bmp:Bitmap;
	
	
	public var ldr:Loader;
  
  public function PlaceMarkerIcon(label:String) {
	  super();
	  isHighlighted = false;
	  isHidden = false;
	  
	  ldr= new Loader();
	  ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, handleNewIcon);
	  
	  //Label
	  labelMc = new TextField();
	  format = new TextFormat();
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
	container = new Shape();
	ct = new ColorTransform();
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
	unHighlight(); //For consistency...
	  
	//Image
	//addChild(new TestImg());
  	
    labelMc.x = topLeftX;
    labelMc.y = topLeftY + 2;
    addChild(labelMc);
    cacheAsBitmap = true;
  }
  //0x6D838E = bg blue
  //0xFFE96E = folder yellow
  //0xFFFF55 = bright yellow
  //0xF2EFE9 = google maps bg gray
  //0x99B3CC = google maps ocean blue
  //0xB5D29C = google maps grass green
  //0x000000 = black
  //0xFFFFFF = white
  public function highlight():void {
	  trace("Highlighting...");
	  isHighlighted = true;
	  ct.color = 0xFFFFFF;//FFE96E;
	  container.transform.colorTransform = ct;
	  container.alpha = 10;
	  labelMc.textColor = 0x000000;
  }
  
  public function unHighlight():void {
	  trace("Unhighlighting...");
	  isHighlighted = false;
	  ct.color = 0x000000;
	  container.transform.colorTransform = ct;
	  container.alpha = 1;
	  labelMc.textColor = 0xFFFFFF;
  }
  
  public function hide():void
  {
	  this.isHidden = true;
  }
  
  public function unHide():void
  {
	  this.isHidden = false;
  }
  public function select():void {
	  trace("I'm selected");
	  ct.color = 0x6D838E;
	  container.transform.colorTransform = ct;
	  container.alpha = 10;
	  labelMc.textColor = 0xFFFFFF;
  }
  
  public function deSelect():void {
	  trace("I'm not selected");
	  if(isHighlighted){
		  highlight();
	  }
	  else{
		  unHighlight();
	  }
  }
  
  public function setNewIcon(url:String):void {
	  if(url)
	  	ldr.load(new URLRequest(url));
  }
  
  public function handleNewIcon(evt:Event):void {
	  //Delete below line once fully implemented
	  return;
	  
	  
	  if(bmp)
	  	removeChild(bmp);
	  bmp = ldr.content as Bitmap;
	  bmp.x = -16;
	  bmp.y = 0;
	  var tempW:int = bmp.width;
	  bmp.width = 32;
	  bmp.height *= (bmp.width/tempW)
	  addChild(bmp);
  }
  
}

}
