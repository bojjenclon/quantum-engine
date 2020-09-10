package quantum.partials;

import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;

interface ICollideable
{
	public var colliders(get, never) : ReadOnlyArray<Shape>;
}
