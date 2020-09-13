package quantum.entities.display;

import kha.graphics2.Graphics;
import quantum.tiled.TiledTileSet;
import quantum.tiled.TiledTileLayer;
import quantum.tiled.TiledMap;
import quantum.partials.IRenderable;

class TiledMapRenderable implements IRenderable
{
	var _tiledMap : TiledMap;

	var _tileLayers : Array<TiledTileLayer> = [];

	public function new(map : TiledMap)
	{
		_tiledMap = map;

		for (layer in map.layers)
		{
			if (Std.is(layer, TiledTileLayer))
			{
				_tileLayers.push(cast(layer, TiledTileLayer));
			}
		}

		for (layer in _tileLayers)
		{
			var ta = layer.tileArray;
			// trace(ta.length);
			for (tile in layer.tiles)
			{
				var tileset : TiledTileSet = getTileset(tile.tilesetID);
				var assetName = '${tileset.imageSource}';
				trace(assetName);
			}
		}
	}

	public function render(g : Graphics)
	{
		// for (layer in _tileLayers)
		// {
		// 	for (tile in layer.tiles)
		// 	{
		// 		var tileset : TiledTileSet = _tiledMap.tilesets[tile.tilesetID];
		// 		var assetName = '${tileset.imageSource}';
		// 		trace(assetName);
		// 	}
		// }
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
}
