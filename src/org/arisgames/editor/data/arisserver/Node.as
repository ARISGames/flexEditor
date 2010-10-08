package org.arisgames.editor.data.arisserver
{
public class Node
{
    public var nodeId:Number;
    public var title:String;
    public var text:String;
    public var iconMediaId:Number;
    public var mediaId:Number;
    public var opt1Text:String;
    public var opt1NodeId:Number;
    public var opt2Text:String;
    public var opt2NodeId:Number;
    public var opt3Text:String;
    public var opt3NodeId:Number;
    public var qaCorrectAnswer:String;
    public var qaIncorrectNodeId:Number;
    public var qaCorrectNodeId:Number;

    /**
     * Constructor
     */
    public function Node()
    {
        super();
    }
}
}