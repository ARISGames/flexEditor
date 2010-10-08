package org.arisgames.editor.models
{
import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.PlaceMark;

public class GameModel
{
    // Singleton Pattern
    public static var instance:GameModel;

    // Data
    [Bindable] public var game:Game;
    [Bindable] public var currentPlaceMark:PlaceMark;

    /**
     * Singleton constructor... will throw error if accessed directly
     */
    public function GameModel()
    {
        if (instance != null)
        {
            throw new Error("GameModel is a singleton, can only be accessed by calling getInstance() function.");
        }
        instance = this;
        game = new Game();
    }

    public static function getInstance():GameModel
    {
        if (instance == null)
        {
            instance = new GameModel();
        }
        return instance;
    }

    public function addPlaceMark(pm:PlaceMark):void
    {
        if (!game.placeMarks.contains(pm))
        {
            game.placeMarks.addItem(pm);
        }
    }

    public function removePlaceMark(pm:PlaceMark):void
    {
        var index:int = game.placeMarks.getItemIndex(pm);
        if (index != -1)
        {
            game.placeMarks.removeItemAt(index);    
        }
    }
}
}