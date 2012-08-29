package org.arisgames.editor.data.businessobjects
{
import mx.collections.ArrayCollection;

import org.arisgames.editor.data.arisserver.AugBubble;
import org.arisgames.editor.data.arisserver.CustomMap;
import org.arisgames.editor.data.arisserver.Item;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.arisserver.NPC;
import org.arisgames.editor.data.arisserver.Node;
import org.arisgames.editor.data.arisserver.PlayerNote;
import org.arisgames.editor.data.arisserver.WebPage;
import org.arisgames.editor.util.IconUtility;

public class ObjectPaletteItemBO
{
    // id and objectId MUST NOT be initialized, due to down stream processing checks
    public var id:Number;
    public var objectId:Number;
    public var objectType:String;
    public var name:String;
    public var iconMediaId:Number;
    public var mediaId:Number;
	public var alignMediaId:Number;
    public var iconMedia:Media;
    public var media:Media;
	public var alignMedia:Media;
	public var isSpawnable:Boolean;
	public var isHidden:Boolean = false;
	
    // Relationship Display Information
    //public var children:ObjectPaletteItemChildrenArray;
	public var children:ArrayCollection;
	
    // Content
    public var parentContentFolderId:Number = 0;
    public var previousContentId:Number = 0;

    // Folder
    public var parentFolderId:Number = 0;
    public var previousFolderId:Number = 0;
	public var isOpen:Boolean = false;
	public var isClientContentFolder:Boolean = false; // DO NOT SAVE THIS FOLDER if this is true...
	
    // Specific Data
    public var character:NPC;
    public var item:Item;
    public var page:Node;
	public var webPage:WebPage;
	public var augBubble:AugBubble;
	public var customMap:CustomMap;
	public var playerNote:PlayerNote;


    /**
     * Constructor
     * @param isFolder True if is Folder / False If Just Item
     */
    public function ObjectPaletteItemBO(isFolder:Boolean)
    {
        super();
		this.isHidden = false;
        if (isFolder)
        {
			//children = new ObjectPaletteItemChildrenArray(this);
            children = new ArrayCollection();
        }
    }

    public function isFolder():Boolean
    {
        if (children == null)
        {
            return false;
        }
        return true;
    }	
	
    public function get iconPath():Object
    {
		if(this.isHidden)
			return IconUtility.getClass("http://dev.arisgames.org/server/gamedata/0/hidden.png", 20, 20);

        if (!isFolder() && iconMedia != null)
        {
            var url:String = iconMedia.urlPath + iconMedia.fileName;
            //trace("iconPath being returned = '" + url + "'");
            return IconUtility.getClass(url, 20, 20);
        }
        trace("iconMedia is null, so returning NULL for iconPath.");
		return null;
    }

    public function set iconPath(value:Object):void
    {
        trace("setIconPath() called with value = '" + value + "'; this value will not be persisted.");
//        iconPath = value;
    }
}
}