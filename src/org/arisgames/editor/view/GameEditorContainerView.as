package org.arisgames.editor.view
{
import mx.containers.Canvas;
import mx.effects.Move;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;

import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;

public class GameEditorContainerView extends Canvas
{
    [Bindable] public var gameEditorObjectEditor:GameEditorObjectEditorView;
	[Bindable] public var questsMap:QuestsMapView;
    [Bindable] public var panelOut:Move; // WB" "OUT" actually means "out onto display"
    [Bindable] public var panelIn:Move;  // WB "IN" actually means "into the toolbox, no longer displaying"
	[Bindable] public var mapShow:Move;
	[Bindable] public var mapHide:Move;
    private var isItemEditorVis:Boolean = false;
	private var isQuestsMapVis:Boolean = false;

    /**
     * Constructor
     */
    public function GameEditorContainerView()
    {
        super();
        this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit)
    }

    private function handleInit(event:FlexEvent):void
    {
        trace("handling container init")
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_EDITOBJECTPALETTEITEM, handleItemEditEventRequest);
        AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR, handleCloseItemEditorEventRequest);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_OPENQUESTSMAP, handleOpenQuestsMapRequest);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEQUESTSMAP, handleCloseQuestsMapRequest);
    }

    private function handleItemEditEventRequest(event:DynamicEvent):void
    {
        var opi:ObjectPaletteItemBO = event.objectPaletteItem;

        trace("Got handleItemEditEventRequest with object name = '" + opi.name + "'; Icon Media Id = '" + opi.iconMediaId + "'; Media Id = '" + opi.mediaId + "'; Icon Media Object = '" + opi.iconMedia + "'; Media Object = '" + opi.media + "'; Is Folder? = '" + opi.isFolder() + "'");
        if(!isItemEditorVis)
        {
            trace("editor is currently hidden, so assign the new object and drop it down for the user to use.");
            gameEditorObjectEditor.setObjectPaletteItem(opi);

            panelOut.play(); // WB" "OUT" actually means "out onto display"
            isItemEditorVis = true;
        }
        else
        {
            panelIn.play(); // WB "IN" actually means "into the toolbox, no longer displaying"
            isItemEditorVis = false;

            trace("editor is currently down, check to see if this is a new object request");
            if (gameEditorObjectEditor.getObjectPaletteItem() == opi)
            {
                trace("It's the same object, so just retract the editor.");
            }
            else
            {
                trace("This is a new object, so roll out the editor again with the new item.");
                gameEditorObjectEditor.setObjectPaletteItem(opi);

                panelOut.play(); // WB" "OUT" actually means "out onto display"
                isItemEditorVis = true;
            }
        }
    }

    private function handleCloseItemEditorEventRequest(event:DynamicEvent):void
    {
        trace("Got handleCloseItemEditorEventRequest....")
        if (!isItemEditorVis)
        {
            trace("The panel's already hidden so dont do anything...");
        }
        else
        {
            trace("Closing the panel.");
            panelIn.play();  // WB "IN" actually means "into the toolbox, no longer displaying"
            isItemEditorVis = false;
        }
    }
	
	private function handleOpenQuestsMapRequest(event:DynamicEvent):void 
	{
		if (!isQuestsMapVis)
		{
			trace("QuestsMap is currently hidden, so show it!");
			mapShow.play();
			isQuestsMapVis = true;
		}
		else 
		{
			trace("QuestsMap is already visible, so clicking the button again should close it!");
			mapHide.play();
			isQuestsMapVis = false;
		}
	}
	
	private function handleCloseQuestsMapRequest(event:DynamicEvent):void 
	{
		if (!isQuestsMapVis)
		{
			trace("Quests map already hidden, so don't try to close again!");
		}
		else
		{
			trace("Closing the QuestsMap");
			mapHide.play();
			isQuestsMapVis = false;
		}
	}
}
}