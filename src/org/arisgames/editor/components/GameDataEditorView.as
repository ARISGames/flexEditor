package org.arisgames.editor.components
{
import flash.events.MouseEvent;
import mx.containers.ApplicationControlBar;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.Label;
import mx.controls.TextInput;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;

import org.arisgames.editor.models.GameModel;
import org.arisgames.editor.util.AppConstants;

public class GameDataEditorView extends VBox
{
    [Bindable] public var gameName:Label;
    [Bindable] public var gameDescription:Label;

    public function GameDataEditorView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
    }

    private function onComplete(event:FlexEvent): void
    {
        gameName.text = GameModel.getInstance().game.name;
        gameDescription.text = GameModel.getInstance().game.description;
    }
}
}