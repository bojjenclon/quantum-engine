package quantum.entities;

import quantum.partials.IRenderable;
import quantum.partials.IUpdateable;
import kha.graphics2.Graphics;
import haxe.ds.ReadOnlyArray;
import signals.Signal1;

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
	public final onChildAdded : Signal1<T> = new Signal1<T>();
	public final onChildRemoved : Signal1<T> = new Signal1<T>();

	public var children(get, never) : ReadOnlyArray<T>;

	var _children : Array<T> = new Array<T>();

	public function render(g : Graphics)
	{
		for (child in _children)
		{
			child.render(g);
		}
	}

	public function update(dt : Float)
	{
		for (child in _children)
		{
			child.update(dt);
		}
	}

	function childSort(a : Entity, b : Entity) : Int
	{
		return b.priority - a.priority;
	}

	public function addChild(child : T) : T
	{
		_children.push(child);
		_children.sort(childSort);

		onChildAdded.dispatch(child);

		return child;
	}

	public function removeChild(child : T) : T
	{
		_children.remove(child);
		_children.sort(childSort);

		onChildRemoved.dispatch(child);

		return child;
	}

	public function clear()
	{
		var child = _children.pop();
		while (child != null)
		{
			onChildRemoved.dispatch(child);
			child = _children.pop();
		}
	}

	public function iterator() : EntityGroupIterator<T>
	{
		return new EntityGroupIterator<T>(this);
	}

	function get_children() : ReadOnlyArray<T>
	{
		return _children;
	}
}
