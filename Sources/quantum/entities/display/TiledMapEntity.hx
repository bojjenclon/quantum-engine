package quantum.entities.display;

import quantum.tiled.TiledObjectLayer;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.Image;
import quantum.tiled.TiledTileSet;
import quantum.tiled.TiledTileLayer;
import quantum.tiled.TiledMap;
import quantum.partials.IRenderable;

private typedef RenderableTile =
{
	var image : Image;
	var x : Int;
	var y : Int;
	var tilesetX : Int;
	var tilesetY : Int;
	var tileWidth : Int;
	var tileHeight : Int;
}

private typedef RenderableTileLayer =
{
	var tiles : Array<RenderableTile>;
}

class TiledMapEntity extends Entity
{
	var _tiledMap : TiledMap;

	var _tileLayers : Array<TiledTileLayer> = new Array<TiledTileLayer>();
	var _objectLayers : Array<TiledObjectLayer> = new Array<TiledObjectLayer>();

	var _renderableLayers : Array<RenderableTileLayer> = [];

	static final ASSET_PATH_REGEX : EReg = ~/[\s.,\/\\]/g;

	public function new(map : TiledMap, rootPath : String = "")
	{
		super();

		_tiledMap = map;

		// Organize layers by type
		for (layer in map.layers)
		{
			if (Std.is(layer, TiledTileLayer))
			{
				_tileLayers.push(cast(layer, TiledTileLayer));
			}
			else if (Std.is(layer, TiledObjectLayer))
			{
				_objectLayers.push(cast(layer, TiledObjectLayer));
			}
		}

		// Generate renderable tiles array
		for (layer in _tileLayers)
		{
			var layerWidth = layer.width;
			var layerHeight = layer.height;
			
			var x = 0;
			var y = 0;

			var tilesToRender : Array<RenderableTile> = [];

			for (tile in layer.tiles)
			{
				if (tile != null)
				{
					var tileset : TiledTileSet = getTileset(tile.tilesetID);
					var assetName = getTilesetImagePath(tileset, rootPath);
					var tileId = tile.tileID - tileset.firstGID;

					tilesToRender.push({
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

			_renderableLayers.push({
				tiles: tilesToRender
			});
		}
	}

	override public function render(g : Graphics)
	{
		for (layer in _renderableLayers)
		{
			for (tile in layer.tiles)
			{
				g.drawSubImage(tile.image, tile.x, tile.y, tile.tilesetX, tile.tilesetY, tile.tileWidth, tile.tileHeight);
			}
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
}
