package org.arisgames.editor.data
{
import org.arisgames.editor.util.AppUtils;

[Bindable]
public class PlaceMark
{
    public var id:Number;
    public var latitude:Number;
    public var longitude:Number;
    public var contentType:Number;
    public var contentId:Number;
    public var name:String;
    public var description:String;
    public var quantity:Number;
    public var errorRange:Number;
    public var hidden:Boolean = false;
    public var forcedView:Boolean = false;

    /**
     * Constructor
     */
    public function PlaceMark()
    {
        super();
        name = "PlaceMark At " + new Date().toString();
    }

    public function getContentTypeForPublicDisplayAsString():String
    {
        return AppUtils.getContentTypeForAppViewAsString(contentType);
    }

    public function getContentTypeForDataBaseAsString():String
    {
        return AppUtils.getContentTypeForDatabaseAsString(contentType);
    }
}
}