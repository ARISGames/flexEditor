package org.arisgames.editor
{
import mx.core.Application;
import mx.events.FlexEvent;

import org.arisgames.editor.forms.LoginFormView;
import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.models.StateModel;
import org.arisgames.editor.util.AppUtils;
import org.arisgames.editor.view.ARISNewsMX;
import org.arisgames.editor.view.GameEditorMapView;

public class MainView extends Application
{
    public var loginForm:LoginFormView;
    public var gameEditor:GameEditorMapView;
	public var newsView:ARISNewsMX;

    [Bindable] public var gameModel:GameModel;
    [Bindable] public var stateModel:StateModel;

    public function MainView()
    {
        super();
        gameModel = GameModel.getInstance();
        stateModel = StateModel.getInstance();
        stateModel.currentState = StateModel.VIEWLOGIN;
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        trace("onComplete fired...");
        AppUtils.getInstance().setMainView(this);
    }
}
}