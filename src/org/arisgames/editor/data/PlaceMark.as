package org.arisgames.editor.data
{
import org.arisgames.editor.components.PlaceMarker;
import org.arisgames.editor.data.arisserver.Media;
import org.arisgames.editor.data.businessobjects.ObjectPaletteItemBO;
import org.arisgames.editor.util.AppUtils;

[Bindable]
public class PlaceMark
{
    public var id:Number;
    public var latitude:Number;
    public var longitude:Number;
    public var contentType:Number;
    public var contentId:Number;
	public var name:String;
    public var description:String;
	public var errorText:String;
    public var quantity:Number;
    public var errorRange:Number;
    public var hidden:Boolean = false;
	public var highlighted:Boolean = false;
    public var forcedView:Boolean = false;
	public var quickTravel:Boolean = false;	
	public var wiggle:Boolean = false;	
	public var displayAnnotation:Boolean = false;	
	public var qrCode:String;
	public var placeMarker:PlaceMarker;
	public var imageMatchMediaId:Number;
	public var imageMatchMedia:Media;
	public var iconURL:String;
	public var isFountain:Boolean;

	public var objectPalletItemBO:ObjectPaletteItemBO;

    /**
     * Constructor
     */
    public function PlaceMark()
    {
        super();
        name = "PlaceMark At " + new Date().toString();
		
		//Generate a random qr code
		var a:String = "123456789";
		var alphabet:Array = a.split("");
		qrCode = "";
		for (var i:Number = 0; i < 4; i++){
			qrCode += alphabet[Math.floor(Math.random() * alphabet.length)];
		}
		quantity = 1;
    }

    public function getContentTypeForPublicDisplayAsString():String
    {
		//Pretty sure this function NEVER gets called...
        return AppUtils.getContentTypeForAppViewAsString(contentType);
    }

    public function getContentTypeForDataBaseAsString():String
    {
        return AppUtils.getContentTypeForDatabaseAsString(contentType);
    }
}
}