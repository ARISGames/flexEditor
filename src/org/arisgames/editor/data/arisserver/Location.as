package org.arisgames.editor.data.arisserver
{
public class Location
{
    public var locationId:Number;
    public var latitude:Number;
    public var longitude:Number;
    public var name:String;
    public var type:String;
    public var typeId:Number;
    public var iconMediaId:Number;
    public var error:Number;
    public var quantity:Number;
    public var hidden:Boolean;
    public var forceView:Boolean;

    /**
     * Constructor
     */
    public function Location()
    {
        super();
    }
}
}