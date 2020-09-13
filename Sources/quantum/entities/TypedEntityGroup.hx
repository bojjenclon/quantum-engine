package quantum.entities;

import quantum.partials.IRenderable;
import quantum.partials.IUpdateable;
import kha.graphics2.Graphics;

private class EntityGroupIterator<T:Entity>
{
	var _group : TypedEntityGroup<T>;
	var _idx : Int;

	public function new(array : TypedEntityGroup<T>)
	{
		_group = array;
		_idx = 0;
	}

	public function hasNext() : Bool
	{
		return _idx < _group.children.length;
	}

	public function next() : T
	{
		return _group.children[_idx++];
	}
}

/**
 * Simple object used to logically group entities.
 */
class TypedEntityGroup<T:Entity> extends Basic implements IUpdateable implements IRenderable
{
	public var children : Array<T> = new Array<T>();

	public function render(g : Graphics)
	{
		for (child in children)
		{
			child.render(g);
		}
	}

	public function update(dt : Float)
	{
		for (child in children)
		{
			child.update(dt);
		}
	}

	public function iterator() : EntityGroupIterator<T>
	{
		return new EntityGroupIterator<T>(this);
	}
}
