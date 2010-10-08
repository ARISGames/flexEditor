package org.arisgames.editor.models
{

import flash.events.EventDispatcher;
import mx.events.DynamicEvent;
import org.arisgames.editor.util.AppConstants;

public class StateModel extends EventDispatcher
{
    // Singleton Pattern
    public static var instance:StateModel;

    public static var FORGOTACCOUNTINFORMATION:String = "ForgotAccountInformation";
    public static var REGISTERFORACCOUNT:String = "RegisterForAccount";
    public static var VIEWLOGIN:String = "ViewLogin";
    public static var VIEWGAMEEDITOR:String = "ViewGameEditor";
    public static var VIEWGAMEEDITORPLACEMARKEDITOR:String = "ViewGameEditorPlaceMarkEditor";
    public static var VIEWCREATEOROPENGAMEWINDOW:String = "ViewCreateOrOpenGameWindow";

    // State Persistence
    private var _currentState:String = "";
    [Bindable] public var previousState:String;

    /**
     * Singleton Constructor
     */
    public function StateModel()
    {
        if (instance != null)
        {
            throw new Error("StateModel is a singleton, can only be accessed by calling getInstance() function.");
        }
        instance = this;
    }

    public static function getInstance():StateModel
    {
        if (instance == null)
        {
            instance = new StateModel();
        }
        return instance;
    }


    [Bindable] public function get currentState():String
    {
        return _currentState;
    }

    public function set currentState(value:String):void
    {
        trace("current state to be updated from '" + _currentState + "' to new state ='" + value + "'");
        _currentState = value;
        if (value == StateModel.VIEWGAMEEDITORPLACEMARKEDITOR)
        {
            trace("current state was changed to view placemark editor, so firing an app dynamic event so that the editor will update itself");
            var evt:DynamicEvent = new DynamicEvent(AppConstants.APPLICATIONDYNAMICEVENT_CURRENTSTATECHANGED);
            dispatchEvent(evt);
        }
    }
}
}