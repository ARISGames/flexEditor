package org.arisgames.editor.forms
{

import flash.events.MouseEvent;
import flash.net.SharedObject;

import mx.containers.Form;
import mx.containers.FormItem;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.LinkButton;
import mx.controls.TextInput;
import mx.events.FlexEvent;
import mx.rpc.Responder;
import mx.rpc.remoting.mxml.RemoteObject;

import org.arisgames.editor.models.SecurityModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;

public class LoginFormView extends Panel
{
    [Bindable] public var confirm:FormItem;
    [Bindable] public var email:FormItem;
    [Bindable] public var loginForm:Form;
    [Bindable] public var username:TextInput;
    [Bindable] public var password:TextInput;
	[Bindable] public var rememberMe:CheckBox;
    [Bindable] public var confirmPassword:TextInput;
    [Bindable] public var emailAddress:TextInput;

    [Bindable] public var registerLink:LinkButton;
    [Bindable] public var forgotAccountInformationLink:LinkButton;
    [Bindable] public var loginButton:Button;

    [Bindable] public var loginServer:RemoteObject;
	public var clientData:SharedObject;
	
	[Bindable] public var instructions:String = "<b>Note:</b><br />"+
		"To be able to use the games created with this editor,<br />"+
		"you must first change the server settings on your iOS<br />"+
		"device (Settings->ARIS->ServerURL) to: <br />"+
		"<i><font color=\"#910000\">"+AppConstants.APPLICATION_ENVIRONMENT_ROOT_URL+"</font></i>";

    public function LoginFormView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
		rememberMe.selected = false;
        registerLink.addEventListener(MouseEvent.CLICK, onRegisterButtonClick);
        forgotAccountInformationLink.addEventListener(MouseEvent.CLICK, onForgotButtonClick)
        loginButton.addEventListener(MouseEvent.CLICK, onLoginButtonClick);
		loadLocalData();
    }
	
	private function loadLocalData():void{
		clientData = SharedObject.getLocal("ArisUser");
		if(clientData.data.username != undefined){
			if(clientData.data.username != ""){
				username.text = clientData.data.username;
				password.text = clientData.data.password;
				rememberMe.selected = true;
			}	
		}
	}

    private function onRegisterButtonClick(click:MouseEvent):void
    {
        trace("Register Button clicked...");
        var sm:StateModel = StateModel.getInstance();
        if (sm.currentState == StateModel.REGISTERFORACCOUNT)
        {
            StateModel.getInstance().currentState = StateModel.VIEWLOGIN;
        }
        else
        {
            StateModel.getInstance().currentState = StateModel.REGISTERFORACCOUNT;
        }
    }

    private function onForgotButtonClick(click:MouseEvent):void
    {
        trace("Forgot Account Info link clicked...");
        var sm:StateModel = StateModel.getInstance();
        if (sm.currentState == StateModel.VIEWLOGIN)
        {
            sm.currentState = StateModel.FORGOTACCOUNTINFORMATION;
        }
    }

    private function onLoginButtonClick(click:MouseEvent):void
    {
        trace("Login Button clicked...");
		trace("remember login?: "+rememberMe.selected);
        if (loginButton.label == AppConstants.BUTTON_LOGIN)
        {
            trace("It's in login mode, so try to login");
            AppServices.getInstance().login(username.text, password.text, new Responder(handleLogin, handleFault));
        }
        else
        {
            trace("It's in register mode, so try to register.");
            if (password.text != confirmPassword.text)
            {
                Alert.show("Passwords do not match.  Please fix and try again.", "Passwords Do Not Match");
                return;
            }
            AppServices.getInstance().registerAccount(username.text, password.text, emailAddress.text, new Responder(handleRegister, handleFault));
        }
    }

    public function handleLogin(obj:Object):void
    {
        trace("Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad login... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Logging In");
        }
        else
        {
			if(rememberMe.selected){
				trace("remembering login...");
				clientData.data.username = username.text;
				clientData.data.password = password.text;
			}
			else{
				trace("forgetting login...");
				clientData.data.username = "";
				clientData.data.password = "";
			}
			clientData.flush();
            trace("Login was successful");
            SecurityModel.getInstance().login(obj.result.data.editor_id, obj.result.data.read_write_token);
            StateModel.getInstance().currentState = StateModel.VIEWCREATEOROPENGAMEWINDOW;
        }
    }

    public function handleRegister(obj:Object):void
    {
        trace("Result called with obj = " + obj + "; Result = " + obj.result);
        if (obj.result.returnCode != 0)
        {
            trace("Bad registration attempt... let's see what happened.");
            var msg:String = obj.result.returnCodeDescription;
            Alert.show("Error Was: " + msg, "Error While Registering");
        }
        else
        {
            trace("Registration was successfull");
            SecurityModel.getInstance().login(obj.result.data.editor_id, obj.result.data.read_write_token);
            Alert.show("Welcome to the ARIS Game Editor!", "Successfully Registered");
            StateModel.getInstance().currentState = StateModel.VIEWCREATEOROPENGAMEWINDOW;
        }
    }

    public function handleFault(obj:Object):void
    {
        trace("Fault called...");
        Alert.show("Error occurred", "More problems..");
    }  
}
}