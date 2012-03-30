package org.arisgames.editor.view
{
import mx.containers.Canvas;
import mx.effects.Move;
import mx.events.DynamicEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.util.AppConstants;
import org.arisgames.editor.util.AppDynamicEventManager;
import org.arisgames.editor.util.AppUtils;

public class GameEditorContainerView extends Canvas
{
    [Bindable] public var gameEditorObjectEditor:ObjectEditorView;
	//[Bindable] public var questsMap:QuestsMapView; 
	[Bindable] public var questsEditor:QuestsEditorView;
	[Bindable] public var webHooksEditor:WebHooksEditorView;
	[Bindable] public var noteTagsEditor:NoteTagsEditorView;

    [Bindable] public var panelOut:Move; // WB" "OUT" actually means "out onto display"
    [Bindable] public var panelIn:Move;  // WB "IN" actually means "into the toolbox, no longer displaying"
	[Bindable] public var mapShow:Move;
	[Bindable] public var mapHide:Move;
    private var isItemEditorVis:Boolean = false;
	private var isQuestsMapVis:Boolean = false;
	private var isQuestsEditorVis:Boolean = false;
	private var isWebHooksEditorVis:Boolean = false;
	private var isNoteTagsEditorVis:Boolean = false;

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
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_OPENQUESTSEDITOR, handleOpenQuestsEditorRequest);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_OPENWEBHOOKSEDITOR, handleOpenWebHooksEditorRequest);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_OPENNOTETAGSEDITOR, handleOpenNoteTagsEditorRequest);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEQUESTSEDITOR, handleCloseQuestsEditorRequest);		
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSEWEBHOOKSEDITOR, handleCloseWebHooksEditorRequest);
		AppDynamicEventManager.getInstance().addEventListener(AppConstants.DYNAMICEVENT_CLOSENOTETAGSEDITOR, handleCloseNoteTagsEditorRequest);
		
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
	
	private function handleOpenQuestsEditorRequest(event:DynamicEvent):void 
	{
		trace("GameEditorContainer: handleOpenQuestsEditorRequest() was called");
		if (!isQuestsEditorVis)
		{
			trace("QuestsEditor is currently hidden, so show it!");
			isQuestsEditorVis = true;
			questsEditor = new QuestsEditorMX();
			this.parent.addChild(questsEditor);
			
			// Need to validate the display so that entire component is rendered
			questsEditor.validateNow();
			
			PopUpManager.addPopUp(questsEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(questsEditor);
			questsEditor.setVisible(true);
			questsEditor.includeInLayout = true;			
		}
		else 
		{
			trace("QuestsEditor is already visible, so clicking the button again should close it!");
			isQuestsEditorVis = false;
		}
	}	
	
	
	private function handleOpenWebHooksEditorRequest(event:DynamicEvent):void 
	{
		trace("GameEditorContainer: handleOpenWebHooksEditorRequest() was called");
		if (!isWebHooksEditorVis)
		{
			trace("WebHooksEditor is currently hidden, so show it!");
			isWebHooksEditorVis = true;
			webHooksEditor = new WebHooksEditorMX();
			this.parent.addChild(webHooksEditor);
			
			// Need to validate the display so that entire component is rendered
			webHooksEditor.validateNow();
			
			PopUpManager.addPopUp(webHooksEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(webHooksEditor);
			webHooksEditor.setVisible(true);
			webHooksEditor.includeInLayout = true;			
		}
		else 
		{
			trace("WebHookEditor is already visible, so clicking the button again should close it!");
			isWebHooksEditorVis = false;
		}
	}	
	
	private function handleOpenNoteTagsEditorRequest(event:DynamicEvent):void 
	{
		trace("GameEditorContainer: handleOpenNoteTagsEditorRequest() was called");
		if (!isNoteTagsEditorVis)
		{
			trace("NoteTagsEditor is currently hidden, so show it!");
			isNoteTagsEditorVis = true;
			noteTagsEditor = new NoteTagsEditorMX();
			this.parent.addChild(noteTagsEditor);
			
			// Need to validate the display so that entire component is rendered
			noteTagsEditor.validateNow();
			
			PopUpManager.addPopUp(noteTagsEditor, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(noteTagsEditor);
			noteTagsEditor.setVisible(true);
			noteTagsEditor.includeInLayout = true;			
		}
		else 
		{
			trace("NoteTagsEditor is already visible, so clicking the button again should close it!");
			isNoteTagsEditorVis = false;
		}
	}
	
	private function handleCloseQuestsEditorRequest(event:DynamicEvent):void 
	{
		trace("GameEditorContainer: handleCloseQuestsEditorRequest() was called");

		if (!isQuestsEditorVis)
		{
			trace("Quests Editor already hidden, so don't try to close again!");
		}
		else
		{
			trace("Closing the QuestsEditor");
			PopUpManager.removePopUp(questsEditor);
			questsEditor = null;			
			isQuestsEditorVis = false;
		}
	}	
	
	
	private function handleCloseWebHooksEditorRequest(event:DynamicEvent):void 
	{
		trace("GameEditorContainer: handleCloseWebHooksEditorRequest() was called");
		
		if (!isWebHooksEditorVis)
		{
			trace("WebHooks Editor already hidden, so don't try to close again!");
		}
		else
		{
			trace("Closing the WebHooksEditor");
			PopUpManager.removePopUp(webHooksEditor);
			webHooksEditor = null;			
			isWebHooksEditorVis = false;
		}
	}	
	
	private function handleCloseNoteTagsEditorRequest(event:DynamicEvent):void 
	{
		trace("GameEditorContainer: handleCloseNoteTagsEditorRequest() was called");
		
		if (!isNoteTagsEditorVis)
		{
			trace("NoteTags Editor already hidden, so don't try to close again!");
		}
		else
		{
			trace("Closing the NoteTagsEditor");
			PopUpManager.removePopUp(noteTagsEditor);
			noteTagsEditor = null;			
			isNoteTagsEditorVis = false;
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