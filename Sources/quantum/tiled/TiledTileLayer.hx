package quantum.tiled;

import haxe.zip.Uncompress;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.io.UInt8Array;
import kha.internal.BytesBlob;
import haxe.xml.Access;
import quantum.tiled.TiledLayer.TiledLayerType;

class TiledTileLayer extends TiledLayer
{
	public var x : Int;
	public var y : Int;
	public var width : Int;
	public var height : Int;
	public var tiles : Array<TiledTile>;

	public var encoding(get, null) : String;
	public var csvData(get, null) : String;
	public var tileArray(get, null) : Array<Int>;

	var xmlData : Access;

	static inline var BASE64_CHARS : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	public function new(source : Access, parent : TiledMap)
	{
		super(source, parent);
		type = TiledLayerType.TILE;
		x = (source.has.x) ? Std.parseInt(source.att.x) : 0;
		y = (source.has.y) ? Std.parseInt(source.att.y) : 0;
		width = Std.parseInt(source.att.width);
		height = Std.parseInt(source.att.height);

		tiles = new Array<TiledTile>();

		// load tile GIDs
		xmlData = source.node.data;
		if (xmlData == null)
		{
			throw "Error loading TiledLayer level data";
		}
	}

	function getByteArrayData() : Bytes
	{
		var result : Bytes = null;

		if (encoding == "base64")
		{
			var chunk : String = xmlData.innerData;
			var compressed : Bool = false;

			result = Base64.decode(chunk);

			if (xmlData.has.compression)
			{
				switch (xmlData.att.compression)
				{
					case "zlib":
						compressed = true;
					default:
						throw "TiledLayer - data compression type not supported!";
				}
			}

			if (compressed)
			{
				result = Uncompress.run(result);
			}
		}
		else
		{
			throw "Must use base64 encoding in order to get tileArray data.";
		}

		return result;
	}

	function resolveTile(globalTileId : Int) : Int
	{
		var tile : TiledTile = new TiledTile(globalTileId);

		var tilesetID : Int = tile.tilesetID;
		for (tileset in map.tilesets)
		{
			if (tileset.hasGid(tilesetID))
			{
				tiles.push(tile);
				return tilesetID;
			}
		}
		tiles.push(null);
		return 0;
	}

	function get_encoding() : String
	{
		if (encoding == null)
		{
			encoding = xmlData.att.encoding;
		}
		return encoding;
	}

	function get_csvData() : String
	{
		if (csvData == null)
		{
			if (xmlData.att.encoding == "csv")
			{
				csvData = StringTools.ltrim(xmlData.innerData);
			}
			else
			{
				throw "Must use CSV encoding in order to get CSV data.";
			}
		}
		return csvData;
	}

	function get_tileArray() : Array<Int>
	{
		if (tileArray == null)
		{
			tileArray = new Array<Int>();

			if (encoding == "csv")
			{
				var endline : String = csvData.indexOf("\r\n") != -1 ? "\r\n" : "\n";
				var rows : Array<String> = csvData.split(endline);

				for (row in rows)
				{
					var cells : Array<String> = row.split(",");
					for (cell in cells)
					{
						if (cell != "")
						{
							tileArray.push(Std.parseInt(cell));
						}
					}
				}
			}
			else
			{
				var mapData : Bytes = getByteArrayData();

				if (mapData == null)
				{
					throw "Must use Base64 encoding (with or without zlip compression) in order to get 1D Array.";
				}

				var i = 0;
				while (i < Std.int(mapData.length))
				{
					tileArray.push(resolveTile(mapData.getInt32(i)));
				}
			}
		}

		return tileArray;
	}
}
