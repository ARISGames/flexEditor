package org.arisgames.editor.data.arisserver
{
public class Item
{
    public var itemId:Number;
    public var name:String;
    public var description:String;
    public var iconMediaId:Number;
    public var mediaId:Number;
    public var dropable:Boolean;
    public var destroyable:Boolean;

    /**
     * Constructor
     */
    public function Item()
    {
        super();
    }
}
}