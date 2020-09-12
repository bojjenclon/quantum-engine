package quantum.tiled;

import quantum.tiled.TiledLayer.TiledLayerType;
import kha.Color;
import haxe.xml.Access;

class TiledObjectLayer extends TiledLayer
{
	public var objects : Array<TiledObject>;
	public var color : Color;

	public function new(source : Access, parent : TiledMap)
	{
		super(source, parent);
		type = TiledLayerType.OBJECT;
		objects = new Array<TiledObject>();
		color = source.has.color ? Color.fromString(source.att.color) : Color.Transparent;
		loadObjects(source);
	}

	function loadObjects(source : Access) : Void
	{
		for (node in source.nodes.object)
		{
			objects.push(new TiledObject(node, this));
		}
	}
}
