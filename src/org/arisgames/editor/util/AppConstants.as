package org.arisgames.editor.util
{
public class AppConstants
{
	public static const APPLICATION_ENVIRONMENT_SERVICES_URL:String = "http://www.arisgames.org/stagingserver1/services/aris/"; //staging
	
	//public static const APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL:String = "http://davembp.local/server/services/aris/uploadhandler.php"; //davembp
	//public static const APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL:String = "http://atsosxdev.doit.wisc.edu/aris/server/services/aris/uploadhandler.php";	//dev
  	public static const APPLICATION_ENVIRONMENT_UPLOAD_SERVER_URL:String = "http://www.arisgames.org/stagingserver1/services/aris/uploadHandler.php"; //staging
	
	//public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAArdp0t4v0pcA_JogLZhjrjBTf4EykMftsP7dwAfDsLsFl_zB7rBTq5-3Hy0k3tU1tgyomozB1YmIfNg"; //davembp
	//public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAA-Z69V9McvCh02XYNV5UHBBQsvlSBtAWfm4N2P3iTGfWOp-UrmRRTU3pFPQwMJB92SZ3plLjvRpMIIw"; //dev
  	public static const APPLICATION_ENVIRONMENT_GOOGLEMAP_KEY:String = "ABQIAAAA-Z69V9McvCh02XYNV5UHBBRloMOfjiI7F4SM41AgXh_4cb6l9xTHRyPNO3mgDcJkTIE742EL8ZoQ_Q"; //staging

    // Dynamic Events
    public static const APPLICATIONDYNAMICEVENT_CURRENTSTATECHANGED:String = "ApplicationDynamicEventCurrentStateChanged";
    public static const APPLICATIONDYNAMICEVENT_REDRAWOBJECTPALETTE:String = "ApplicationDynamicEventRedrawObjectPalette";
    public static const APPLICATIONDYNAMICEVENT_GAMEPLACEMARKSLOADED:String = "ApplicationDynamicEventGamePlacemarksLoaded";
    public static const DYNAMICEVENT_GEOSEARCH:String = "DynamicEventGeoSearch";
    public static const DYNAMICEVENT_PLACEMARKSELECTED:String = "DynamicEventPlaceMarkSelected";
    public static const DYNAMICEVENT_PLACEMARKREQUESTSDELETION:String = "DynamicEventPlaceMarkRequestsDeletion";
    public static const DYNAMICEVENT_EDITOBJECTPALETTEITEM:String = "EditObjectPaletteItem";
    public static const DYNAMICEVENT_CLOSEOBJECTPALETTEITEMEDITOR:String = "CloseObjectPaletteItemEditor";
    public static const DYNAMICEVENT_CLOSEMEDIAPICKER:String = "CloseMediaPicker";
    public static const DYNAMICEVENT_CLOSEMEDIAUPLOADER:String = "CloseMediaUploader";
    public static const DYNAMICEVENT_CLOSEREQUIREMENTSEDITOR:String = "CloseRequirementsEditor";
    public static const DYNAMICEVENT_REFRESHDATAINREQUIREMENTSEDITOR:String = "RefreshDataInRequirementsEditor";
    public static const DYNAMICEVENT_OPENREQUIREMENTSEDITORMAP:String = "OpenRequirementsEditorMap";
    public static const DYNAMICEVENT_CLOSEREQUIREMENTSEDITORMAP:String = "CloseRequirementsEditorMap";
    public static const DYNAMICEVENT_SAVEREQUIREMENTDUETOMAPDATACHANGE:String = "SaveRequirementDueToMapDataChange";
	public static const DYNAMICEVENT_OPENQUESTSMAP:String = "OpenQuestsMap";
	public static const DYNAMICEVENT_CLOSEQUESTSMAP:String = "CloseQuestsMap";
	public static const DYNAMICEVENT_REFRESHDATAINQUESTSEDITOR:String = "RefreshDataInQuestsEditor";
	public static const DYNAMICEVENT_OPENQUESTSEDITOR:String = "OpenQuestsEditor";
	public static const DYNAMICEVENT_CLOSEQUESTSEDITOR:String = "CloseQuestsEditor";
	public static const DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR:String = "DYNAMICEVENT_REFRESHDATAINPLAYERSTATECHANGESEDITOR";
	public static const DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR:String = "DYNAMICEVENT_CLOSEPLAYERSTATECHANGEEDITOR";
	public static const DYNAMICEVENT_REFRESHDATAINCONVERSATIONS:String = "DYNAMICEVENT_DYNAMICEVENT_REFRESHDATAINCONVERSATIONS";
	
    // Placemark Content
    public static const CONTENTTYPE_PAGE:String = "Plaque";
    public static const CONTENTTYPE_CHARACTER:String = "Character";
    public static const CONTENTTYPE_ITEM:String = "Item";
    public static const CONTENTTYPE_QRCODEGROUP:String = "QR Code Group";
    public static const CONTENTTYPE_PAGE_VAL:Number = 0;
    public static const CONTENTTYPE_CHARACTER_VAL:Number = 1;
    public static const CONTENTTYPE_ITEM_VAL:Number = 2;
    public static const CONTENTTYPE_QRCODEGROUP_VAL:Number = 3;
    public static const CONTENTTYPE_PAGE_DATABASE:String = "Node";
    public static const CONTENTTYPE_CHARACTER_DATABASE:String = "Npc";
    public static const CONTENTTYPE_ITEM_DATABASE:String = "Item";
    public static const PLACEMARK_DEFAULT_ERROR_RANGE:Number = 30;

    // Label Constants
    public static const BUTTON_LOGIN:String = "Login!";
    public static const BUTTON_REGISTER:String = "Register!";
    public static const RADIO_FORGOTPASSWORD:String = "Forgot Password";
    public static const RADIO_FORGOTUSERNAME:String = "Forgot Username";

    // Media Types
    public static const MEDIATYPE:String = "Media Types";
    public static const MEDIATYPE_IMAGE:String = "Image";
    public static const MEDIATYPE_AUDIO:String = "Audio";
    public static const MEDIATYPE_VIDEO:String = "Video";
    public static const MEDIATYPE_ICON:String = "Icon";
    public static const MEDIATYPE_UPLOADNEW:String = "Upload New";

	//Player State Changes
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_ITEM:String = "VIEW_ITEM";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_NODE:String = "VIEW_NODE";
	public static const PLAYERSTATECHANGE_EVENTTYPE_VIEW_NPC:String = "VIEW_NPC";
	public static const PLAYERSTATECHANGE_ACTION_GIVEITEM:String = "GIVE_ITEM";
	public static const PLAYERSTATECHANGE_ACTION_GIVEITEM_HUMAN:String = "Give Item";
	public static const PLAYERSTATECHANGE_ACTION_TAKEITEM:String = "TAKE_ITEM";
	public static const PLAYERSTATECHANGE_ACTION_TAKEITEM_HUMAN:String = "Take Item";
	
    // Requirement Types
    public static const REQUIREMENTTYPE_LOCATION:String = "Location";
	public static const REQUIREMENTTYPE_QUESTDISPLAY:String = "QuestDisplay";
	public static const REQUIREMENTTYPE_QUESTCOMPLETE:String = "QuestComplete";
	public static const REQUIREMENTTYPE_NODE:String = "Node";

    // Requirement Options
    public static const REQUIREMENT_PLAYER_HAS_ITEM_DATABASE:String = "PLAYER_HAS_ITEM";
    public static const REQUIREMENT_PLAYER_HAS_ITEM_HUMAN:String = "Player Has At Least Qty of an Item";
    public static const REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_DATABASE:String = "PLAYER_DOES_NOT_HAVE_ITEM";
    public static const REQUIREMENT_PLAYER_DOES_NOT_HAVE_ITEM_HUMAN:String = "Player Has Less Than Qty of an Item";
    public static const REQUIREMENT_PLAYER_VIEWED_ITEM_DATABASE:String = "PLAYER_VIEWED_ITEM";
    public static const REQUIREMENT_PLAYER_VIEWED_ITEM_HUMAN:String = "Player Viewed Item";
    public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_DATABASE:String = "PLAYER_HAS_NOT_VIEWED_ITEM";
    public static const REQUIREMENT_PLAYER_HAS_NOT_VIEWED_ITEM_HUMAN:String = "Player Never Viewed Item";
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
	public static const REQUIREMENT_PLAYER_HAS_COMPLETED_QUEST:String = "Player Has Completed Quest";
	
	public static const REQUIREMENT_BOOLEAN_AND_DATABASE:String = "AND";
	public static const REQUIREMENT_BOOLEAN_AND_HUMAN:String = "All";
	public static const REQUIREMENT_BOOLEAN_OR_DATABASE:String = "OR";
	public static const REQUIREMENT_BOOLEAN_OR_HUMAN:String = "Only this one";
	
    // Defaults
    public static const DEFAULT_ICON_MEDIA_ID_NPC:Number = 1;
    public static const DEFAULT_ICON_MEDIA_ID_ITEM:Number = 2;
    public static const DEFAULT_ICON_MEDIA_ID_PLAQUE:Number = 3;

    /**
     * Constructor
     */
    public function AppConstants()
    {
        super();
    }
}
}