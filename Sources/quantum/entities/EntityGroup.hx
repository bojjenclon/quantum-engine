package quantum.entities;

import quantum.partials.IRenderable;
import quantum.partials.IUpdateable;
import kha.graphics2.Graphics;

private class EntityGroupIterator
{
	var _group : EntityGroup;
	var _idx : Int;

	public function new(array : EntityGroup)
	{
		_group = array;
		_idx = 0;
	}

	public function hasNext() : Bool
	{
		return _idx < _group.children.length;
	}

	public function next() : Entity
	{
		return _group.children[_idx++];
	}
}

/**
 * Simple object used to logically group entities.
 */
class EntityGroup extends Basic implements IUpdateable implements IRenderable
{
	public var children : Array<Entity> = new Array<Entity>();

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

	public function iterator() : EntityGroupIterator
	{
		return new EntityGroupIterator(this);
	}
}
