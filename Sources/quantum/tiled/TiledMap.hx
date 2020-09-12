package quantum.tiled;

import kha.Color;
import kha.Assets;
import haxe.xml.Access;

using StringTools;

/**
 * Based heavily on Flixel's implementation.
 */
class TiledMap
{
	public static function fromString(data : String, ?rootPath : String) : TiledMap
	{
		var xml = Xml.parse(data);
		return new TiledMap(xml, rootPath);
	}

	public var version : String;
	public var orientation : String;

	public var backgroundColor : Color;

	public var width : Int;
	public var height : Int;
	public var tileWidth : Int;
	public var tileHeight : Int;

	public var fullWidth : Int;
	public var fullHeight : Int;

	public var properties : TiledPropertySet = new TiledPropertySet();

	public var tilesets : Map<String, TiledTileSet> = new Map<String, TiledTileSet>();

	public var tilesetArray : Array<TiledTileSet> = [];

	public var layers : Array<TiledLayer> = [];

	var noLoadHash : Map<String, Bool> = new Map<String, Bool>();
	var layerMap : Map<String, TiledLayer> = new Map<String, TiledLayer>();

	var rootPath : String;

	public function new(data : TiledMapAsset, ?rootPath : String)
	{
		if (rootPath != null)
		{
			this.rootPath = rootPath;
		}

		var source = new Access(data);
		source = source.node.map;

		loadAttributes(source);
		loadProperties(source);
		loadTilesets(source);
		loadLayers(source);
	}

	function loadAttributes(source : Access) : Void
	{
		version = (source.att.version != null) ? source.att.version : "unknown";
		orientation = (source.att.orientation != null) ? source.att.orientation : "orthogonal";
		backgroundColor = (source.has.backgroundcolor && source.att.backgroundcolor != null) ? Color.fromString(source.att.backgroundcolor) : Color.Transparent;

		width = Std.parseInt(source.att.width);
		height = Std.parseInt(source.att.height);
		tileWidth = Std.parseInt(source.att.tilewidth);
		tileHeight = Std.parseInt(source.att.tileheight);

		// Calculate the entire size
		fullWidth = width * tileWidth;
		fullHeight = height * tileHeight;
	}

	function loadProperties(source : Access) : Void
	{
		for (node in source.nodes.properties)
		{
			properties.extend(node);
		}

		var noLoadStr = properties.get("noload");
		if (noLoadStr != null)
		{
			var noLoadArr = ~/[,;|]/.split(noLoadStr);

			for (s in noLoadArr)
			{
				noLoadHash.set(s.trim(), true);
			}
		}
	}

	function loadTilesets(source : Access) : Void
	{
		for (node in source.nodes.tileset)
		{
			var name = node.has.name ? node.att.name : "";

			if (!noLoadHash.exists(name))
			{
				var ts = new TiledTileSet(node, rootPath);
				tilesets.set(ts.name, ts);
				tilesetArray.push(ts);
			}
		}
	}

	function loadLayers(source : Access) : Void
	{
		for (el in source.elements)
		{
			if (el.has.name && noLoadHash.exists(el.att.name))
				continue;

			var layer : TiledLayer = switch (el.name.toLowerCase())
			{
				case "group": new TiledGroupLayer(el, this, noLoadHash);
				case "layer": new TiledTileLayer(el, this);
				case "objectgroup": new TiledObjectLayer(el, this);
				case "imagelayer": new TiledImageLayer(el, this);
				case _: null;
			}

			if (layer != null)
			{
				layers.push(layer);
				layerMap.set(layer.name, layer);
			}
		}
	}
}

typedef TiledMapAsset = Xml;
