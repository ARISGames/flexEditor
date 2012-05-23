package org.arisgames.editor.forms
{
import flash.events.MouseEvent;
import mx.containers.Panel;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.LinkButton;
import mx.controls.RadioButtonGroup;
import mx.controls.TextInput;
import mx.events.FlexEvent;
import mx.rpc.Responder;

import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.services.AppServices;
import org.arisgames.editor.util.AppConstants;

public class ForgotAccountInformationFormView extends Panel
{
    [Bindable] public var backToLoginButton:LinkButton;
    [Bindable] public var retrieveDataButton:Button;
    [Bindable] public var forgotWhatRadioGroup:RadioButtonGroup;
    [Bindable] public var emailAddress:TextInput;

    /**
     * Constructor
     */
    public function ForgotAccountInformationFormView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        backToLoginButton.addEventListener(MouseEvent.CLICK, onBackToLoginClick);
        retrieveDataButton.addEventListener(MouseEvent.CLICK, onRetrieveDataClick);
    }

    private function onBackToLoginClick(event:MouseEvent):void
    {
        StateModel.getInstance().currentState = StateModel.VIEWLOGIN;        
    }

    private function onRetrieveDataClick(event:MouseEvent):void
    {
        if (emailAddress.text == null || emailAddress.text.length < 1)
        {
            Alert.show("Please enter the account's email address in order to recover username or password.", "Missing Email Address");
            return;
        }

        if (forgotWhatRadioGroup.selectedValue == AppConstants.RADIO_FORGOTPASSWORD)
        {
            AppServices.getInstance().resetPassword(emailAddress.text, new Responder(handleForgotPassword, handleFault));
        }
        else
        {
            AppServices.getInstance().remindOfUsername(emailAddress.text, new Responder(handleForgotUsername, handleFault));
        }
    }

    private function handleForgotUsername(obj:Object):void
    {
        trace("handleForgotUsername called with event: " + obj);
        Alert.show("Your username has been emailed to the email address on file for this account.", "Username Emailed");
    }

    private function handleForgotPassword(obj:Object):void
    {
        trace("handleForgotPassword called with event: " + obj);
        Alert.show("An email has been sent with instructions to change your password.", "Password Reset");
    }

    private function handleFault(obj:Object):void
    {
        Alert.show("An error occurred: " + obj.fault.faultString, "Error Occurred");
    }
}
}