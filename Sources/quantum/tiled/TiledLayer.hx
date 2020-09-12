package quantum.tiled;

import haxe.xml.Access;

class TiledLayer
{
	public var type : TiledLayerType;
	public var map : TiledMap;
	public var name : String;
	public var opacity : Float;
	public var visible : Bool;
	public var properties : TiledPropertySet;

	public var offsetX : Float;

	public var offsetY : Float;

	function new(source : Access, parent : TiledMap)
	{
		properties = new TiledPropertySet();
		map = parent;
		name = source.att.name;
		visible = (source.has.visible && source.att.visible == "0") ? false : true;
		opacity = (source.has.opacity) ? Std.parseFloat(source.att.opacity) : 1.0;
		offsetX = (source.has.offsetx) ? Std.parseFloat(source.att.offsetx) : 0.0;
		offsetY = (source.has.offsety) ? Std.parseFloat(source.att.offsety) : 0.0;

		loadProperties(source);
	}

	function loadProperties(source : Access) : Void
	{
		for (node in source.nodes.properties)
		{
			properties.extend(node);
		}
	}
}

enum TiledLayerType
{
	TILE;
	OBJECT;
	IMAGE;
	GROUP;
}
