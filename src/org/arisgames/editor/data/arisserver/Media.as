package org.arisgames.editor.data.arisserver
{
import org.arisgames.editor.util.AppConstants;

public class Media
{
    public var mediaId:Number;
    public var name:String;
    public var type:String;
    public var urlPath:String;
    public var fileName:String;
    public var isDefault:Boolean;

    /**
     * Constructor
     */
    public function Media()
    {
        super();
    }

    public function isIcon():Number
    {
        if (type != null && type == AppConstants.MEDIATYPE_ICON)
        {
            return 1;
        }
        return 0;
    }
}
}