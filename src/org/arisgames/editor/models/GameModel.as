package org.arisgames.editor.models
{
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.rpc.events.ResultEvent;

import org.arisgames.editor.data.Game;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class GameModel
{
    // Singleton Pattern
    public static var instance:GameModel;

    // Data
    [Bindable] public var game:Game;

    public function GameModel()
    {
        if(instance != null) throw new Error("GameModel is a singleton, can only be accessed by calling getInstance() function.");
        instance = this;
        game = new Game();
    }

    public static function getInstance():GameModel
    {
        if(instance == null) instance = new GameModel();
        return instance;
    }

	public function handleFault(obj:Object):void
	{
		trace("Fault called.  The error is: " + obj.fault.faultString);
		Alert.show("Error occurred: " + obj.fault.faultString, "More problems..");
	}
}
}