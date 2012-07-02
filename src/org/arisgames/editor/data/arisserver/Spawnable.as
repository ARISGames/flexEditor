package org.arisgames.editor.data.arisserver
{
public class Spawnable
{
    public var spawnableId:Number;
	public var type:String;
	public var typeId:Number;
	public var amount:Number;
	public var area:Number;
	public var amountRestriction:String;
	public var locationBoundType:String;
	public var latitude:Number;
	public var longitude:Number;
	public var spawnProbability:Number;
	public var spawnRate:Number;
	public var deleteWhenViewed:Boolean;
	public var timeToLive:Number;
	public var errorRange:Number;
	public var forceView:Boolean;
	public var hidden:Boolean;
	public var quickTravel:Boolean;
	public var wiggle:Boolean;	
	public var displayAnnotation:Boolean;	
	public var locationName:String;	

    /**
     * Constructor
     */
    public function Spawnable()
    {
        super();
    }
}
}