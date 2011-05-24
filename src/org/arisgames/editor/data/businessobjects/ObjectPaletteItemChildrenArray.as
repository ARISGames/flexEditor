package org.arisgames.editor.data.businessobjects
{
	import mx.collections.ArrayCollection;

	/*
	This object is created for the very specific purpose of being the "children" array for ObjectPaletteItemBO's (The items on
	the left side of the screen) in ARIS. The reason this is necessary is due to the tree structure from which PaletteTree extends.
	The items are saved to the server with "parent id's" to determine heirarchichal structure. They are used by the tree item by referring
	to a "children" array. The problem arises in that the Parent ID still needs to be set so it can save to the server correctly. We do that
	here, in the overridden "addItem" function. When the data is loaded, it is ordered appropriatedly and the child arrays are populated based 
	on the parent ID's of the children, to conform to the tree's structure.
	*/
	public class ObjectPaletteItemChildrenArray extends ArrayCollection
	{
		public var parent:ObjectPaletteItemBO;
		
		public function ObjectPaletteItemChildrenArray(parent:ObjectPaletteItemBO)
		{
			super();
			this.parent = parent;

		}
		
		public override function addItem(object:Object):void{
			trace("ObjectPaletteItemChildrenArray: Object being added to child in tree");
			var paletteItem:ObjectPaletteItemBO = object as ObjectPaletteItemBO;
			trace("Object being added: " + paletteItem.name + ", Id of object being added: " + paletteItem.id);
			trace("Object being added to " + parent.name + ", Id of object being added to: " + parent.id);
			paletteItem.parentFolderId = parent.id;
			super.addItem(object);
		}
		
	}
}