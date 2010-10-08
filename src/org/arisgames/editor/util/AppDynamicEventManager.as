package org.arisgames.editor.util
{
import flash.events.EventDispatcher;

public class AppDynamicEventManager extends EventDispatcher
{
    // Singleton Pattern
    public static var instance:AppDynamicEventManager;

    /**
     * Singleton Constructor
     */
    public function AppDynamicEventManager()
    {
        if (instance != null)
        {
            throw new Error("AppDynamicEventManager is a singleton, can only be accessed by calling getInstance() function.");
        }
        instance = this;
    }

    public static function getInstance():AppDynamicEventManager
    {
        if (instance == null)
        {
            instance = new AppDynamicEventManager();
        }
        return instance;
    }
}
}