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
	public var tradeable:Boolean;
    public var destroyable:Boolean;
	public var isAttribute:Boolean;
	public var maxQty:Number;
	public var weight:Number;
	public var url:String;
	public var type:String;

	

    /**
     * Constructor
     */
    public function Item()
    {
        super();
		
		maxQty = 500;
    }
}
}