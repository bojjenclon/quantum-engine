package quantum.tiled;

typedef TileAnimationData =
{
	var tileID : Int;
	var duration : Float;
}

class TiledTilePropertySet extends TiledPropertySet
{
	public var tileID : Int;
	public var animationFrames : Array<TileAnimationData>;

	public var tileObjects : Array<TiledObject>;

	public function new(tileID : Int)
	{
		super();
		this.tileID = tileID;
		animationFrames = new Array();
		tileObjects = new Array();
	}

	public function addAnimationFrame(tileID : Int, duration : Float) : Void
	{
		animationFrames.push({tileID: tileID, duration: duration});
	}

	public function addTileObject(tileObject : TiledObject) : Void
	{
		tileObjects.push(tileObject);
	}
}
