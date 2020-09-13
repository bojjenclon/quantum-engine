package quantum.entities.display;

import quantum.tiled.TiledTile;
import quantum.tiled.TiledGroupLayer;
import quantum.tiled.TiledLayer;
import kha.math.FastMatrix3;
import quantum.tiled.TiledObjectLayer;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.Image;
import kha.Color;
import kha.math.FastVector2;
import quantum.tiled.TiledTileSet;
import quantum.tiled.TiledTileLayer;
import quantum.tiled.TiledMap;
import quantum.partials.IRenderable;

typedef ParsedTile =
{
	var tile : TiledTile;
	var image : Image;
	var x : Int;
	var y : Int;
	var tilesetX : Int;
	var tilesetY : Int;
	var tileWidth : Int;
	var tileHeight : Int;
}

typedef ParsedTileLayer =
{
	var layer : TiledTileLayer;
	var tiles : Array<ParsedTile>;
}

class TiledMapEntity extends Entity
{
	static inline final TRUE : String = "true";
	static inline final FALSE : String = "false";

	public var width(get, never) : Int;
	public var height(get, never) : Int;

	public var scaledWidth(get, never) : Float;
	public var scaledHeight(get, never) : Float;

	var _tiledMap : TiledMap;

	var _tileLayers : Array<TiledTileLayer> = new Array<TiledTileLayer>();
	var _objectLayers : Array<TiledObjectLayer> = new Array<TiledObjectLayer>();

	var _parsedLayers : Array<ParsedTileLayer> = new Array<ParsedTileLayer>();
	var _renderableLayers : Array<ParsedTileLayer> = new Array<ParsedTileLayer>();

	static final ASSET_PATH_REGEX : EReg = ~/[\s.,\/\\]/g;

	public function new(map : TiledMap, rootPath : String = "")
	{
		super();

		_tiledMap = map;

		// Organize layers by type
		for (layer in map.layers)
		{
			categorizeLayer(layer);
		}

		// Generate renderable tiles array
		for (layer in _tileLayers)
		{
			var layerWidth = layer.width;
			var layerHeight = layer.height;
			
			var x = 0;
			var y = 0;

			var tilesToRender : Array<ParsedTile> = [];

			for (tile in layer.tiles)
			{
				if (tile != null)
				{
					var tileset : TiledTileSet = getTileset(tile.tilesetID);
					var assetName = getTilesetImagePath(tileset, rootPath);
					var tileId = tile.tileID - tileset.firstGID;

					tilesToRender.push({
						tile: tile,

						image: Assets.images.get(assetName),

						x: x * tileset.tileWidth,
						y: y * tileset.tileHeight,

						tilesetX: Std.int(tileId % tileset.numCols) * tileset.tileWidth,
						tilesetY: Std.int(tileId / tileset.numCols) * tileset.tileHeight,

						tileWidth: tileset.tileWidth,
						tileHeight: tileset.tileHeight
					});
				}

				x++;
				if (x >= layerWidth)
				{
					x = 0;
					y++;
				}
			}

			var parsedLayer = {
				layer: layer,
				
				tiles: tilesToRender
			};

			_parsedLayers.push(parsedLayer);

			var isRenderable = layer.properties.get("render") != FALSE;
			if (isRenderable)
			{
				_renderableLayers.push(parsedLayer);
			}
		}
	}

	override public function render(g : Graphics)
	{
		if (!visible)
		{
			return;
		}

		var center = new FastVector2(scaledWidth / 2, scaledHeight / 2);
		var rad = Math.PI / 180 * trueRotation;

		g.pushTransformation(FastMatrix3.scale(trueScale.x, trueScale.y));
		g.pushRotation(rad, globalX + center.x, globalY + center.y);
		g.pushTranslation(x, y);
		g.pushOpacity(trueAlpha);
		g.color = color;

		for (layer in _renderableLayers)
		{
			for (tile in layer.tiles)
			{
				g.drawSubImage(tile.image, tile.x, tile.y, tile.tilesetX, tile.tilesetY, tile.tileWidth, tile.tileHeight);
			}
		}

		g.color = Color.White;
		g.popOpacity();
		g.popTransformation();
		g.popTransformation();
		g.popTransformation();

		#if debug
		var engine = QuantumEngine.engine;
		if (engine.debugDraw)
		{
			renderDebug(g);
		}
		#end

		renderChildren(g);
	}

	function categorizeLayer(layer : TiledLayer)
	{
		if (Std.is(layer, TiledGroupLayer))
		{
			var groupLayer = cast(layer, TiledGroupLayer);
			for (subLayer in groupLayer.layers)
			{
				// Merge group layer properties into children
				var groupProps = groupLayer.properties;
				for (property in groupProps.keysIterator())
				{
					subLayer.properties.add(property, groupProps.resolve(property));
				}

				categorizeLayer(subLayer);
			}
		}
		if (Std.is(layer, TiledTileLayer))
		{
			_tileLayers.push(cast(layer, TiledTileLayer));
		}
		else if (Std.is(layer, TiledObjectLayer))
		{
			_objectLayers.push(cast(layer, TiledObjectLayer));
		}
	}

	function getTileset(gid : Int) : TiledTileSet
	{
		for (tileset in _tiledMap.tilesets)
		{
			if (tileset.hasGid(gid))
			{
				return tileset;
			}
		}

		return null;
	}

	function getTilesetImagePath(tileset : TiledTileSet, rootPath : String = "") : String
	{
		var imageSource = tileset.imageSource;
		var extStart = imageSource.indexOf(".");
		var cleanImagePath = ASSET_PATH_REGEX.replace(imageSource, "_");
		cleanImagePath = cleanImagePath.substring(0, extStart);

		return '${rootPath}${cleanImagePath}';
	}

	function get_width() : Int
	{
		return _tiledMap.fullWidth;
	}

	function get_height() : Int
	{
		return _tiledMap.fullHeight;
	}

	function get_scaledWidth() : Float
	{
		return width * trueScale.x;
	}

	function get_scaledHeight() : Float
	{
		return height * trueScale.y;
	}
}
