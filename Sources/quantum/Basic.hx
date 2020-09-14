package quantum;

import quantum.scene.Scene;
import haxe.crypto.Md5;
import quantum.ds.IHashable;
import quantum.ds.UniqueArray;
import uuid.Uuid;

class Basic implements IHashable
{
	public var id(default, null) : String;
	public final tags : UniqueArray<String> = new UniqueArray<String>();
	public var scene(default, set) : Scene;

	public function new()
	{
		id = Uuid.v4();
	}

	public function onAddedToScene(scene : Scene)
	{
		this.scene = scene;
	}

	public function onRemovedFromScene(scene : Scene)
	{
		this.scene = null;
	}

	public function serialize() : String
	{
		var buf = new StringBuf();

		buf.add('Tags=[${tags.join(",")}]');

		return buf.toString();
	}

	public function hash() : String
	{
		return Md5.encode(serialize());
	}

	function set_scene(value : Scene) : Scene
	{
		return scene = value;
	}
}
