package org.arisgames.editor.data
{
import mx.collections.ArrayCollection;

[Bindable]
public class Game
{
    public var gameId:int;
    public var name:String;
    public var description:String;
    public var placeMarks:ArrayCollection;
    public var gameObjects:ArrayCollection;
    
    public function Game()
    {
        super();
        placeMarks = new ArrayCollection();
        gameObjects = new ArrayCollection();
    }
}
}