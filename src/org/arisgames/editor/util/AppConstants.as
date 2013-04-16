package org.arisgames.editor.util
{
public class AppConstants
{
	//Server URL
	public static const APPLICATION_ENVIRONMENT_ROOT_URL:String = "http://arisgames.org/server"; //For other URL's to append to
	
	//Server Version
	public static const APPLICATION_ENVIRONMENT_SERVER_VERSION:String = "v2";
	
	public static const APPLICATION_ENVIRONMENT_JSON_SERVICES_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/json.php/" + APPLICATION_ENVIRONMENT_SERVER_VERSION + ".";
	public static const APPLICATION_ENVIRONMENT_SERVICES_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/services/" + APPLICATION_ENVIRONMENT_SERVER_VERSION + "/"; //staging		
	public static const APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/services/" + APPLICATION_ENVIRONMENT_SERVER_VERSION + "/uploadHandler.php";
	public static const APPLICATION_ENVIRONMENT_GATEWAY_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gateway.php"; //services-config.xml

	//Google API
	public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAA-Z69V9McvCh02XYNV5UHBBRloMOfjiI7F4SM41AgXh_4cb6l9xTHRyPNO3mgDcJkTIE742EL8ZoQ_Q"; //arisgames.org
	//public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAArdp0t4v0pcA_JogLZhjrjBTf4EykMftsP7dwAfDsLsFl_zB7rBTq5-3Hy0k3tU1tgyomozB1YmIfNg"; //davembp
	//public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAA-Z69V9McvCh02XYNV5UHBBQsvlSBtAWfm4N2P3iTGfWOp-UrmRRTU3pFPQwMJB92SZ3plLjvRpMIIw"; //atsosxdev

	//Image Reference URL's
	public static const IMG_DEFAULT_ICON_SIZE_REFERENCE_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gamedata/img_size/img_size_48x48.png";
	public static const IMG_DEFAULT_IMAGE_SIZE_REFERENCE_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gamedata/img_size/img_size_gt320x416.png";
	public static const IMG_DEFAULT_PANO_SIZE_REFERENCE_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gamedata/img_size/img_size_REQ1024x1024.png";
	public static const IMG_DEFAULT_ALIGN_SIZE_REFERENCE_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gamedata/img_size/img_size_320x416.png";
	public static const IMG_DEFAULT_PLAQUE_SIZE_REFERENCE_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gamedata/img_size/img_size_320x320.png";
	public static const IMG_DEFAULT_SPLASH_SIZE_REFERENCE_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gamedata/img_size/img_size_300x200.png";
	
    // Dynamic Events
    public static const APPLICATIONDYNAMICEVENT_CURRENTSTATECHANGED:String = "ApplicationDynamicEventCurrentStateChanged";
    public static const APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE:String = "ApplicationDynamicEventRedrawObjectPalette";
    public static const APPLICATIONDYNAMICEVENT_GAMEPLACEMARKSLOADED:String = "ApplicationDynamicEventGamePlacemarksLoaded";
	public static const APPLICATIONDYNAMICEVENT_CENTERMAP:String = "DYNAMICEVENT_CENTERMAP";
	public static const DYNAMICEVENT_GEOSEARCH:String = "DynamicEventGeoSearch";
    public static const DYNAMICEVENT_PLACEMARKSELECTED:String = "DynamicEventPlaceMarkSelected";
    public static const DYNAMICEVENT_PLACEMARKREQUESTSDELETION:String = "DynamicEventPlaceMarkRequestsDeletion";
	public static const DYNAMICEVENT_EDITOBJECTPALETTEITEM:String = "EditObjectPaletteItem";
	public static const DYNAMICEVENT_OBJECTPALETTEITEMICONSET:String = "ObjectPaletteItemIconSetSoSetItsLocationsIcons";
	public static const DYNAMICEVENT_HIGHLIGHTOBJECTPALETTEITEM:String = "HighlightObjectPaletteItem";
	public static const DYNAMICEVENT_HIDEOBJECTPALETTEITEM:String = "HighlightObjectPaletteItem";
    public static const DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR:String = "CloseObjectPaletteItemEditor";
    public static const DYNAMICEVENT_CLOSEMEDIAPICKER:String = "CloseMediaPicker";
    public static const DYNAMICEVENT_CLOSEMEDIAUPLOADER:String = "CloseMediaUploader";
    public static const DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR:String = "CloseRequirementsEditor";
	public static const DYNAMICEVENT_CLOSEIMAGEMATCHEDITOR:String = "CloseImageMatchEditor";
    public static const DYNAMICEVENT_REFRESHDATAINREQUIREMENTSEDITOR:String = "RefreshDataInRequirementsEditor";
    public static const DYNAMICEVENT_OPENREQUIREMENTSEDITORMAP:String = "OpenRequirementsEditorMap";
    public static const DYNAMICEVENT_CLOSEREQUIREMENTSEDITORMAP:String = "CloseRequirementsEditorMap";
    public static const DYNAMICEVENT_SAVEREQUIREMENTDUETOMAPDATACHANGE:String = "SaveRequirementDueToMapDataChange";
	public static const DYNAMICEVENT_OPENQUESTSMAP:String = "OpenQuestsMap";
	public static const DYNAMICEVENT_CLOSEQUESTSMAP:String = "CloseQuestsMap";
	public static const DYNAMICEVENT_REFRESHDATAINQUESTSEDITOR:String = "RefreshDataInQuestsEditor";
	public static const DYNAMICEVENT_OPENQUESTSEDITOR:String = "OpenQuestsEditor";
	public static const DYNAMICEVENT_CLOSEQUESTSEDITOR:String = "CloseQuestsEditor";
	public static const DYNAMICEVENT_CLOSESPAWNABLESEDITOR:String = "CloseSpawnablesEditor";
	public static const DYNAMICEVENT_CLOSEFOUNTAINEDITOR:String = "CloseFountainEditor";
	public static const DYNAMICEVENT_OPENWEBHOOKSEDITOR:String = "OpenWebHooksEditor";
	public static const DYNAMICEVENT_CLOSEWEBHOOKSEDITOR:String = "CloseWebHooksEditor";
	public static const DYNAMICEVENT_OPENCUSTOMMAPSEDITOR:String = "OpenCustomMapsEditor";
	public static const DYNAMICEVENT_CLOSECUSTOMMAPSEDITOR:String = "CloseCustomMapsEditor";
	public static const DYNAMICEVENT_OPENNOTETAGSEDITOR:String = "OpenNoteTagsEditor";
	public static const DYNAMICEVENT_CLOSENOTETAGSEDITOR:String = "CloseNoteTagsEditor";
	public static const DYNAMICEVENT_OPENITEMTAGSEDITOR:String = "OpenItemTagsEditor";
	public static const DYNAMICEVENT_CLOSEITEMTAGSEDITOR:String = "CloseItemTagsEditor";
	public static const DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR:String = "DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR";
	public static const DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR:String = "DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR";
	public static const DYNAMICEVENT_REFRESHDATAINCONVERSATIONS:String = "DYNAMICEVENT_DYNAMICEVENT_REFRESHDATAINCONVERSATIONS";
	
    // Placemark Content
    public static const CONTENTTYPE_PAGE:String = "Plaque";
    public static const CONTENTTYPE_CHARACTER:String = "Character";
    public static const CONTENTTYPE_ITEM:String = "Item";
	public static const CONTENTTYPE_WEBPAGE:String = "WebPage";
	public static const CONTENTTYPE_AUGBUBBLE:String = "Panoramic";
	public static const CONTENTTYPE_PLAYER_NOTE:String = "PlayerNote";
    public static const CONTENTTYPE_QRCODEGROUP:String = "QR Code Group";
    public static const CONTENTTYPE_PAGE_VAL:Number = 0;
    public static const CONTENTTYPE_CHARACTER_VAL:Number = 1;
    public static const CONTENTTYPE_ITEM_VAL:Number = 2;
    public static const CONTENTTYPE_QRCODEGROUP_VAL:Number = 3;
	public static const CONTENTTYPE_WEBPAGE_VAL:Number = 4;
	public static const CONTENTTYPE_AUGBUBBLE_VAL:Number = 5;
	public static const CONTENTTYPE_PLAYER_NOTE_VAL:Number = 7;
    public static const CONTENTTYPE_PAGE_DATABASE:String = "Node";
    public static const CONTENTTYPE_CHARACTER_DATABASE:String = "Npc";
	public static const CONTENTTYPE_ITEM_DATABASE:String = "Item";
	public static const CONTENTTYPE_WEBPAGE_DATABASE:String = "WebPage";
	public static const CONTENTTYPE_AUGBUBBLE_DATABASE:String = "AugBubble";
	public static const CONTENTTYPE_PLAYER_NOTE_DATABASE:String = "PlayerNote";
    public static const PLACEMARK_DEFAULT_ERROR_RANGE:Number = 30;
	
	// Default Names (Name of new objects as they are created)
	public static const CONTENTTYPE_CHARACTER_DEFAULT_NAME:String = "Unnamed Character";
	public static const CONTENTTYPE_PAGE_DEFAULT_NAME:String = "Unnamed Plaque";
	public static const CONTENTTYPE_ITEM_DEFAULT_NAME:String = "Unnamed Item";
	public static const CONTENTTYPE_WEBPAGE_DEFAULT_NAME:String = "Unnamed WebPage";
	public static const CONTENTTYPE_AUGBUBBLE_DEFAULT_NAME:String = "Unnamed Panoramic";
	public static const CONTENTTYPE_PLAYER_NOTE_DEFAULT_NAME:String = "Unnamed Player Note";

    // Label Constants
    public static const BUTTON_LOGIN:String = "Login!";
    public static const BUTTON_REGISTER:String = "Register!";
    public static const RADIO_FORGOTPASSWORD:String = "Forgot Password";
    public static const RADIO_FORGOTUSERNAME:String = "Forgot Username";

	// Max allowed upload size for media...............MB....KB....Bytes
	public static const MAX_VIDEO_UPLOAD_SIZE:Number = 10 * 1024 * 1024; //In bytes
	public static const MAX_IMAGE_UPLOAD_SIZE:Number = 2  * 1024 * 1024; //In bytes
	
    // Media Types
    public static const MEDIATYPE:String = "Media Types";
    public static const MEDIATYPE_IMAGE:String = "Image";
    public static const MEDIATYPE_AUDIO:String = "Audio";
    public static const MEDIATYPE_VIDEO:String = "Video";
    public static const MEDIATYPE_ICON:String = "Icon";
	public static const MEDIATYPE_SEPARATOR:String = " ";
    public static const MEDIATYPE_UPLOADNEW:String = "  ";
	
	// Media-tree-icon Types
	public static const MEDIATREEICON_SEPARATOR:String = "separatorIcon";
	public static const MEDIATREEICON_UPLOAD:String = "uploadIcon";

	//Item Types
	public static const ITEM_TYPE_NORMAL:String = "NORMAL";
	public static const ITEM_TYPE_ATTRIBUTE:String = "ATTRIB";
	public static const ITEM_TYPE_URL:String = "URL";
	public static const ITEM_TYPE_NOTE:String = "NOTE";

	//Player State Changes
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_ITEM:String = "VIEW_ITEM";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_WEBPAGE:String = "VIEW_WEBPAGE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_AUGBUBBLE:String = "VIEW_AUGBUBBLE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_PLAYER_NOTE:String = "VIEW_PLAYER_NOTE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE:String = "VIEW_NODE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_NPC:String = "VIEW_NPC";
	public static const PLAYERSTATECHANGE_EVENTTYPE_RECEIVE_WEBHOOK:String = "RECEIVE_WEBHOOK";
	
	public static const PLAYERSTATECHANGE_ACTION_GIVEITEM:String = "GIVE_ITEM";
	public static const PLAYERSTATECHANGE_ACTION_GIVEITEM_HUMAN:String = "Give Item";
	public static const PLAYERSTATECHANGE_ACTION_TAKEITEM:String = "TAKE_ITEM";
	public static const PLAYERSTATECHANGE_ACTION_TAKEITEM_HUMAN:String = "Take Item";
	
    // Requirement Types (what are the requirements for)
    public static const REQUIREMENTTYPE_LOCATION:String = "Location";
	public static const REQUIREMENTTYPE_SPAWNABLE:String = "Spawnable";
	public static const REQUIREMENTTYPE_QUESTDISPLAY:String = "QuestDisplay";
	public static const REQUIREMENTTYPE_QUESTCOMPLETE:String = "QuestComplete";
	public static const REQUIREMENTTYPE_NODE:String = "Node";
	public static const REQUIREMENTTYPE_WEBHOOK:String = "OutgoingWebHook";
	public static const REQUIREMENTTYPE_CUSTOMMAP:String = "CustomMap";

    // Requirement Options
	public static const REQUIREMENT_NOT_OP_TRUE_HUMAN:String = "Player Has";
	public static const REQUIREMENT_NOT_OP_TRUE_DATABASE:String = "DO";
	public static const REQUIREMENT_NOT_OP_FALSE_HUMAN:String = "Player Has Not";
	public static const REQUIREMENT_NOT_OP_FALSE_DATABASE:String = "NOT";
	public static const REQUIREMENT_PLAYER_HAS_ITEM_DATABASE:String = "PLAYER_HAS_ITEM";
	public static const REQUIREMENT_PLAYER_HAS_ITEM_HUMAN:String = "At Least Qty of an Item";    
	public static const REQUIREMENT_PLAYER_HAS_TAGGED_ITEM_DATABASE:String = "PLAYER_HAS_TAGGED_ITEM";
	public static const REQUIREMENT_PLAYER_HAS_TAGGED_ITEM_HUMAN:String = "At Least Qty of Items With Tag";
	public static const REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE:String = "PLAYER_VIEWED_ITEM";
	public static const REQUIREMENT_PLAYER_VIEWED_ITEM_HUMAN:String = "Viewed Item";
	public static const REQUIREMENT_PLAYER_VIEWED_WEBPAGE_DATABASE:String = "PLAYER_VIEWED_WEBPAGE";
	public static const REQUIREMENT_PLAYER_VIEWED_WEBPAGE_HUMAN:String = "Viewed Web Page";
	public static const REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_DATABASE:String = "PLAYER_VIEWED_AUGBUBBLE";
	public static const REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_HUMAN:String = "Viewed Panoramic";
	public static const REQUIREMENT_PLAYER_VIEWED_PLAYER_NOTE_DATABASE:String = "PLAYER_VIEWED_PLAYER_NOTE";
	public static const REQUIREMENT_PLAYER_VIEWED_PLAYER_NOTE_HUMAN:String = "Viewed Player Note";
    public static const REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE:String = "PLAYER_VIEWED_NODE";
    public static const REQUIREMENT_PLAYER_VIEWED_NODE_HUMAN:String = "Viewed Plaque/Script";
    public static const REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE:String = "PLAYER_VIEWED_NPC";
    public static const REQUIREMENT_PLAYER_VIEWED_NPC_HUMAN:String = "Greeted Character";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE:String = "PLAYER_HAS_UPLOADED_MEDIA_ITEM";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_HUMAN:String = "Created Note With Media Near";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_DATABASE:String = "PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE_HUMAN:String = "Created Note With Image Near";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_DATABASE:String = "PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO_HUMAN:String = "Created Note With Audio Near";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_DATABASE:String = "PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO";
	public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO_HUMAN:String = "Created Note With Video Near";
	public static const REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_DATABASE:String = "PLAYER_HAS_COMPLETED_QUEST";
	public static const REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_HUMAN:String = "Completed Quest";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_DATABASE:String = "PLAYER_HAS_NOTE";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_HUMAN:String = "Created A Note";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_DATABASE:String = "PLAYER_HAS_NOTE_WITH_TAG";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_WITH_TAG_HUMAN:String = "Created A Note With Tag";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_DATABASE:String = "PLAYER_HAS_NOTE_WITH_LIKES";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_WITH_LIKES_HUMAN:String = "Created A Note With (qty) Likes";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_DATABASE:String = "PLAYER_HAS_NOTE_WITH_COMMENTS";
	public static const REQUIREMENT_PLAYER_HAS_NOTE_WITH_COMMENTS_HUMAN:String = "Created A Note With (qty) Comments";
	public static const REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_DATABASE:String = "PLAYER_HAS_GIVEN_NOTE_COMMENTS";
	public static const REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_LIKES_DATABASE:String = "PLAYER_HAS_GIVEN_NOTE_LIKES";
	public static const REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_COMMENTS_HUMAN:String = "Given (qty) Comments On Notes";
	public static const REQUIREMENT_PLAYER_HAS_GIVEN_NOTE_LIKES_HUMAN:String = "Given (qty) Likes On Notes";
	public static const REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_DATABASE:String = "PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK";
	public static const REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_HUMAN:String = "Received Incoming Web Hook";

	public static const REQUIREMENT_BOOLEAN_AND_DATABASE:String = "AND";
	public static const REQUIREMENT_BOOLEAN_AND_HUMAN:String = "All";
	public static const REQUIREMENT_BOOLEAN_OR_DATABASE:String = "OR";
	public static const REQUIREMENT_BOOLEAN_OR_HUMAN:String = "Only this one";
	
	// Tab Bar Server Type
	public static const TAB_BAR_TYPE_QUESTS:String = "QUESTS";
	public static const TAB_BAR_TYP_GPSE:String = "GPS";
	public static const TAB_BAR_TYPE_INVENTORY:String = "INVENTORY";
	public static const TAB_BAR_TYPE_QR:String = "QR";
	public static const TAB_BAR_TYPE_PLAYER:String = "PLAYER";
	public static const TAB_BAR_TYPE_CAMERA:String = "CAMERA";
	public static const TAB_BAR_TYPE_MICROPHONE:String = "MICROPHONE";
	public static const TAB_BAR_TYPE_NOTE:String = "NOTE";
	public static const TAB_BAR_TYPE_PICKGAME:String = "PICKGAME";
	public static const TAB_BAR_TYPE_LOGOUT:String = "LOGOUT";
	public static const TAB_BAR_TYPE_STARTOVER:String = "STARTOVER";
	
    // Defaults
    public static const DEFAULT_ICON_MEDIA_ID_NPC:Number = 1;
    public static const DEFAULT_ICON_MEDIA_ID_ITEM:Number = 2;
    public static const DEFAULT_ICON_MEDIA_ID_PLAQUE:Number = 3;
	public static const DEFAULT_ICON_MEDIA_ID_WEBPAGE:Number = 4;
	public static const DEFAULT_ICON_MEDIA_ID_AUGBUBBLE:Number = 5;
	public static const DEFAULT_ICON_MEDIA_ID_PLAYER_NOTE:Number = 5;

	// Palette Tree Stuff
	public static const PALETTE_TREE_SELF_FOLDER_ID:Number = 0;
	public static const PLAYER_GENERATED_MEDIA_FOLDER_ID:Number = -1;
	public static const PLAYER_GENERATED_MEDIA_FOLDER_NAME:String = "Player Created Notes";
	
	// Media Picker Stuff
	public static const MEDIA_PICKER:Number = 0;
	public static const ICON_PICKER:Number = 1;
	public static const ALIGNMENT_PICKER:Number = 2;

    /**
     * Constructor
     */
    public function AppConstants()
    {
        super();
    }
}
}