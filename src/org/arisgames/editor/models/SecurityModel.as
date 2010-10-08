package org.arisgames.editor.models
{
public class SecurityModel
{
    private static var instance:SecurityModel;

    private var userId:Number;
    
    /**
     * Singleton Constructor
     */
    public function SecurityModel()
    {
        if (instance != null)
        {
            throw new Error("This is a Singleton class.  Please use SecurityModel.getInstance() to work with this class.");
        }
        instance = this;
    }

    public static function getInstance():SecurityModel
    {
        if (instance == null)
        {
            instance = new SecurityModel();
        }
        return instance;
    }

    public function getUserId():Number
    {
        return userId;
    }

    public function login(uid:Number):void
    {
        trace("Logging in user with Id = " + uid);
        if (!isNaN(uid))
        {
            userId = uid;
        }
        else
        {
            throw new Error("User Id passed into to SecurityModel.login() was either NULL or Not A Number.");
        }
    }

    public function logout():void
    {
        trace("Logging out user.");
        userId = NaN;
        StateModel.getInstance().currentState = StateModel.VIEWLOGIN;
    }
}
}