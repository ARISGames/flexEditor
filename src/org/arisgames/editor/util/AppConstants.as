package org.arisgames.editor.util
{
public class AppConstants
{
	//Server URL
	//public static const APPLICATION_ENVIRONMENT_ROOT_URL:String = "http://arisgames.org/stagingserver1"; //For other URL's to append to- Staging
	//public static const APPLICATION_ENVIRONMENT_ROOT_URL:String = "http://Phildos.local/server"; //For other URL's to append to- Phil's Machine
	//public static const APPLICATION_ENVIRONMENT_ROOT_URL:String = "http://atsosxdev.doit.wisc.edu/aris/server"; //For other URL's to append to- Dev
	public static const APPLICATION_ENVIRONMENT_ROOT_URL:String = "http://arisgames.org/qaserver"; //For other URL's to append to- QA

	
	//Server Version
	public static const APPLICATION_ENVIRONMENT_SERVER_VERSION:String = "1_5";
	
	public static const APPLICATION_ENVIRONMENT_JSON_SERVICES_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/json.php/aris_" + APPLICATION_ENVIRONMENT_SERVER_VERSION + ".";
	public static const APPLICATION_ENVIRONMENT_SERVICES_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/services/aris_" + APPLICATION_ENVIRONMENT_SERVER_VERSION + "/"; //staging		
	public static const APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/services/aris_" + APPLICATION_ENVIRONMENT_SERVER_VERSION + "/uploadhandler.php";
	public static const APPLICATION_ENVIRONMENT_GATEWAY_URL:String = APPLICATION_ENVIRONMENT_ROOT_URL+"/gateway.php"; //services-config.xml

	//Google API
	public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAA-Z69V9McvCh02XYNV5UHBBRloMOfjiI7F4SM41AgXh_4cb6l9xTHRyPNO3mgDcJkTIE742EL8ZoQ_Q"; //arisgames.org
	//public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAArdp0t4v0pcA_JogLZhjrjBTf4EykMftsP7dwAfDsLsFl_zB7rBTq5-3Hy0k3tU1tgyomozB1YmIfNg"; //davembp
	//public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAAo0AIYqWK4StlyQiw0FkCnhTFFMM2iSZ1Oq9cs2gegUR1k01AuBShe9g60gh2q1UpWRotcj3RpzpT2A"; //Phil's Machine
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
    public static const DYNAMICEVENT_GEOSEARCH:String = "DynamicEventGeoSearch";
    public static const DYNAMICEVENT_PLACEMARKSELECTED:String = "DynamicEventPlaceMarkSelected";
    public static const DYNAMICEVENT_PLACEMARKREQUESTSDELETION:String = "DynamicEventPlaceMarkRequestsDeletion";
	public static const DYNAMICEVENT_EDITOBJECTPALETTEITEM:String = "EditObjectPaletteItem";
	public static const DYNAMICEVENT_HIGHLIGHTOBJECTPALETTEITEM:String = "HighlightObjectPaletteItem";
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
	public static const DYNAMICEVENT_OPENWEBHOOKSEDITOR:String = "OpenWebHooksEditor";
	public static const DYNAMICEVENT_CLOSEWEBHOOKSEDITOR:String = "CloseWebHooksEditor";
	public static const DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR:String = "DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR";
	public static const DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR:String = "DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR";
	public static const DYNAMICEVENT_REFRESHDATAINCONVERSATIONS:String = "DYNAMICEVENT_DYNAMICEVENT_REFRESHDATAINCONVERSATIONS";
	
    // Placemark Content
    public static const CONTENTTYPE_PAGE:String = "Plaque";
    public static const CONTENTTYPE_CHARACTER:String = "Character";
    public static const CONTENTTYPE_ITEM:String = "Item";
	public static const CONTENTTYPE_WEBPAGE:String = "WebPage";
	public static const CONTENTTYPE_AUGBUBBLE:String = "Panoramic";
    public static const CONTENTTYPE_QRCODEGROUP:String = "QR Code Group";
    public static const CONTENTTYPE_PAGE_VAL:Number = 0;
    public static const CONTENTTYPE_CHARACTER_VAL:Number = 1;
    public static const CONTENTTYPE_ITEM_VAL:Number = 2;
    public static const CONTENTTYPE_QRCODEGROUP_VAL:Number = 3;
	public static const CONTENTTYPE_WEBPAGE_VAL:Number = 4;
	public static const CONTENTTYPE_AUGBUBBLE_VAL:Number = 5;
    public static const CONTENTTYPE_PAGE_DATABASE:String = "Node";
    public static const CONTENTTYPE_CHARACTER_DATABASE:String = "Npc";
	public static const CONTENTTYPE_ITEM_DATABASE:String = "Item";
	public static const CONTENTTYPE_WEBPAGE_DATABASE:String = "WebPage";
	public static const CONTENTTYPE_AUGBUBBLE_DATABASE:String = "AugBubble";
    public static const PLACEMARK_DEFAULT_ERROR_RANGE:Number = 30;
	
	// Default Names (Name of new objects as they are created)
	public static const CONTENTTYPE_CHARACTER_DEFAULT_NAME:String = "Unnamed Character";
	public static const CONTENTTYPE_PAGE_DEFAULT_NAME:String = "Unnamed Plaque";
	public static const CONTENTTYPE_ITEM_DEFAULT_NAME:String = "Unnamed Item";
	public static const CONTENTTYPE_WEBPAGE_DEFAULT_NAME:String = "Unnamed WebPage";
	public static const CONTENTTYPE_AUGBUBBLE_DEFAULT_NAME:String = "Unnamed Panoramic";

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
	
	//Player State Changes
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_ITEM:String = "VIEW_ITEM";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_WEBPAGE:String = "VIEW_WEBPAGE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_AUGBUBBLE:String = "VIEW_AUGBUBBLE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE:String = "VIEW_NODE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_NPC:String = "VIEW_NPC";
	public static const PLAYERSTATECHANGE_EVENTTYPE_RECEIVE_WEBHOOK:String = "RECEIVE_WEBHOOK";
	
	public static const PLAYERSTATECHANGE_ACTION_GIVEITEM:String = "GIVE_ITEM";
	public static const PLAYERSTATECHANGE_ACTION_GIVEITEM_HUMAN:String = "Give Item";
	public static const PLAYERSTATECHANGE_ACTION_TAKEITEM:String = "TAKE_ITEM";
	public static const PLAYERSTATECHANGE_ACTION_TAKEITEM_HUMAN:String = "Take Item";
	
    // Requirement Types
    public static const REQUIREMENTTYPE_LOCATION:String = "Location";
	public static const REQUIREMENTTYPE_QUESTDISPLAY:String = "QuestDisplay";
	public static const REQUIREMENTTYPE_QUESTCOMPLETE:String = "QuestComplete";
	public static const REQUIREMENTTYPE_NODE:String = "Node";
	public static const REQUIREMENTTYPE_WEBHOOK:String = "OutgoingWebHook";


    // Requirement Options
    public static const REQUIREMENT_PLAYER_HAS_ITEM_DATABASE:String = "PLAYER_HAS_ITEM";
    public static const REQUIREMENT_PLAYER_HAS_ITEM_HUMAN:String = "Player Has At Least Qty of an Item";
    public static const REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE:String = "PLAYER_DOES_NOT_HAVE_ITEM";
    public static const REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_HUMAN:String = "Player Has Less Than Qty of an Item";
	public static const REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE:String = "PLAYER_VIEWED_ITEM";
	public static const REQUIREMENT_PLAYER_VIEWED_ITEM_HUMAN:String = "Player Viewed Item";
	public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE:String = "PLAYER_HAS_NOT_VIEWED_ITEM";
	public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_HUMAN:String = "Player Never Viewed Item";
	public static const REQUIREMENT_PLAYER_VIEWED_WEBPAGE_DATABASE:String = "PLAYER_VIEWED_WEBPAGE";
	public static const REQUIREMENT_PLAYER_VIEWED_WEBPAGE_HUMAN:String = "Player Viewed Web Page";
	public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_WEBPAGE_DATABASE:String = "PLAYER_HAS_NOT_VIEWED_WEBPAGE";
	public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_WEBPAGE_HUMAN:String = "Player Never Viewed Web Page";
	public static const REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_DATABASE:String = "PLAYER_VIEWED_AUGBUBBLE";
	public static const REQUIREMENT_PLAYER_VIEWED_AUGBUBBLE_HUMAN:String = "Player Viewed Aug Bubble";
	public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_AUGBUBBLE_DATABASE:String = "PLAYER_HAS_NOT_VIEWED_AUGBUBBLE";
	public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_AUGBUBBLE_HUMAN:String = "Player Never Viewed Aug Bubble";
    public static const REQUIREMENT_PLAYER_VIEWED_NODE_DATABASE:String = "PLAYER_VIEWED_NODE";
    public static const REQUIREMENT_PLAYER_VIEWED_NODE_HUMAN:String = "Player Viewed Plaque/Script";
    public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_DATABASE:String = "PLAYER_HAS_NOT_VIEWED_NODE";
    public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NODE_HUMAN:String = "Player Never Viewed Plaque/Script";
    public static const REQUIREMENT_PLAYER_VIEWED_NPC_DATABASE:String = "PLAYER_VIEWED_NPC";
    public static const REQUIREMENT_PLAYER_VIEWED_NPC_HUMAN:String = "Player Greeted By Character";
    public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_DATABASE:String = "PLAYER_HAS_NOT_VIEWED_NPC";
    public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_NPC_HUMAN:String = "Player Never Greeted By Character";
    public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_DATABASE:String = "PLAYER_HAS_UPLOADED_MEDIA_ITEM";
    public static const REQUIREMENT_PLAYER_HAS_UPLOADED_MEDIA_ITEM_HUMAN:String = "Player Has Uploaded Media Item";
	public static const REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_DATABASE:String = "PLAYER_HAS_COMPLETED_QUEST";
	public static const REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST_HUMAN:String = "Player Has Completed Quest";
	public static const REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_DATABASE:String = "PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK";
	public static const REQUIREMENT_PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK_HUMAN:String = "Player Has Received Incoming Web Hook";

	public static const REQUIREMENT_BOOLEAN_AND_DATABASE:String = "AND";
	public static const REQUIREMENT_BOOLEAN_AND_HUMAN:String = "All";
	public static const REQUIREMENT_BOOLEAN_OR_DATABASE:String = "OR";
	public static const REQUIREMENT_BOOLEAN_OR_HUMAN:String = "Only this one";
	
    // Defaults
    public static const DEFAULT_ICON_MEDIA_ID_NPC:Number = 1;
    public static const DEFAULT_ICON_MEDIA_ID_ITEM:Number = 2;
    public static const DEFAULT_ICON_MEDIA_ID_PLAQUE:Number = 3;
	public static const DEFAULT_ICON_MEDIA_ID_WEBPAGE:Number = 4;
	public static const DEFAULT_ICON_MEDIA_ID_AUGBUBBLE:Number = 5;

	// Palette Tree Stuff
	public static const PALETTE_TREE_SELF_FOLDER_ID:Number = 0;
	public static const PLAYER_GENERATED_MEDIA_FOLDER_ID:Number = -1;
	public static const PLAYER_GENERATED_MEDIA_FOLDER_NAME:String = "New Player Created Items";
	
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