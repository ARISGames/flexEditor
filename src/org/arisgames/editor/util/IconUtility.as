// Based on the Open Sourced work of Ben Stucki - http://blog.benstucki.net/?p=42

package org.arisgames.editor.util
{
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import mx.containers.accordionClasses.AccordionHeader;
import mx.controls.tabBarClasses.Tab;
import mx.core.BitmapAsset;
import mx.core.UIComponent;

public class IconUtility extends BitmapAsset
{
    private static var loaderData:Object;

    /**
     * Used to associate run-time graphics with a target
     * @param source A url to a JPG, PNG or GIF file you wish to be loaded and displayed
     * @param width Defines the width of the graphic when displayed
     * @param height Defines the height of the graphic when displayed
     * @return A reference to the IconUtility class which may be treated as a BitmapAsset
     * @example &lt;mx:Button id="button" icon="{IconUtility.getClass(button, 'http://www.yourdomain.com/images/test.jpg')}" /&gt;
     */
    public static function getClass( source:String, width:Number = NaN, height:Number = NaN ):Class {
        var loader:Loader = new Loader();
        loader.load(new URLRequest(source as String), new LoaderContext(true));
        loaderData = { source:loader, width:width, height:height };
        return IconUtility;
    }

    /**
     * @private
     */
    public function IconUtility():void {
        addEventListener(Event.ADDED, addedHandler, false, 0, true)
    }

    private function addedHandler(event:Event):void {
        if(parent) {
            if(parent is AccordionHeader) {
                var header:AccordionHeader = parent as AccordionHeader;
                getData(header.data);
            } else if(parent is Tab) {
                var tab:Tab = parent as Tab;
                getData(tab.data);
            } else {
                getData(parent);
            }
        }
    }

    private function getData(object:Object):void {
        var data:Object = loaderData;
        if(data) {
            var source:Object = data.source;
            if(data.width > 0 && data.height > 0) {
                bitmapData = new BitmapData(data.width, data.height, true, 0x00FFFFFF);
            }
            if(source is Loader) {
                var loader:Loader = source as Loader;
                if(!loader.content) {
                    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
                } else {
                    displayLoader(loader);
                }
            }
        }
    }

    private function displayLoader( loader:Loader ):void {
        if(!bitmapData) {
            bitmapData = new BitmapData(loader.content.width, loader.content.height, true, 0x00FFFFFF);
        }
        bitmapData.draw(loader, new Matrix(bitmapData.width/loader.width, 0, 0, bitmapData.height/loader.height, 0, 0));
        if(parent is UIComponent) {
            var component:UIComponent = parent as UIComponent;
            component.invalidateSize();
        }
    }

    private function completeHandler(event:Event):void {
        if(event && event.target && event.target is LoaderInfo) {
            displayLoader(event.target.loader as Loader);
        }
    }
}
}