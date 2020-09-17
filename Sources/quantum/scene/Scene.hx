package quantum.scene;

import quantum.entities.Entity;
import quantum.partials.ICollideable;
import kha.graphics2.Graphics;
import kha.Color;
import haxe.ds.ReadOnlyArray;
import quantum.partials.IRenderable;
import quantum.partials.IUpdateable;
import signals.Signal1;

class Scene
{
	public final onChildAdded : Signal1<Basic> = new Signal1<Basic>();
	public final onChildRemoved : Signal1<Basic> = new Signal1<Basic>();

	public var background : Color = Color.Black;
	public var children(get, never) : ReadOnlyArray<Basic>;
	public var collideables(get, never) : ReadOnlyArray<ICollideable>;

	var _children : Array<Basic>;
	var _renderables : Array<IRenderable>;
	var _updateables : Array<IUpdateable>;
	var _collideables : Array<ICollideable>;

	public function new()
	{
		create();
	}

	function create()
	{
		_children = new Array<Basic>();
		_renderables = new Array<IRenderable>();
		_updateables = new Array<IUpdateable>();
		_collideables = new Array<ICollideable>();
	}

	function childSort(a : Basic, b : Basic) : Int
	{
		return b.priority - a.priority;
	}

	function renderableSort(a : IRenderable, b : IRenderable) : Int
	{
		return b.priority - a.priority;
	}

	function updateableSort(a : IUpdateable, b : IUpdateable) : Int
	{
		return b.priority - a.priority;
	}

	function collideableSort(a : ICollideable, b : ICollideable) : Int
	{
		return b.priority - a.priority;
	}

	public function addChild(child : Basic)
	{
		_children.push(child);
		_children.sort(childSort);

		if (Std.is(child, IRenderable))
		{
			_renderables.push(cast(child, IRenderable));
			_renderables.sort(renderableSort);
		}

		if (Std.is(child, IUpdateable))
		{
			_updateables.push(cast(child, IUpdateable));
			_updateables.sort(updateableSort);
		}

		if (Std.is(child, ICollideable))
		{
			_collideables.push(cast(child, ICollideable));
			_collideables.sort(collideableSort);
		}

		child.onAddedToScene(this);

		onChildAdded.dispatch(child);
	}

	public function removeChild(child : Basic)
	{
		_children.remove(child);

		if (Std.is(child, IRenderable))
		{
			_renderables.remove(cast(child, IRenderable));
			_renderables.sort(renderableSort);
		}

		if (Std.is(child, IUpdateable))
		{
			_updateables.remove(cast(child, IUpdateable));
			_updateables.sort(updateableSort);
		}

		if (Std.is(child, ICollideable))
		{
			_collideables.remove(cast(child, ICollideable));
			_collideables.sort(collideableSort);
		}

		child.onRemovedFromScene(this);

		onChildRemoved.dispatch(child);
	}

	public function reset()
	{
		var child = _children.pop();
		while (child != null)
		{
			onChildRemoved.dispatch(child);
			child = _children.pop();
		}

		create();
	}

	public function filter(predicate : (child : Basic) -> Bool, recurse : Bool = false) : ReadOnlyArray<Basic>
	{
		var filtered : Array<Basic> = new Array<Basic>();

		if (recurse)
		{
			for (child in children)
			{
				filtered = filtered.concat(filterHelper(predicate, child));
			}
		}
		else
		{
			filtered = _children.filter(predicate);
		}

		return filtered;
	}

	function filterHelper(predicate : (child : Basic) -> Bool, basic : Basic) : Array<Basic>
	{
		var filtered : Array<Basic> = new Array<Basic>();

		if (predicate(basic))
		{
			filtered.push(basic);
		}

		if (Std.is(basic, Entity))
		{
			var entity = cast(basic, Entity);

			for (child in entity.children)
			{
				filtered = filtered.concat(filterHelper(predicate, child));
			}
		}

		return filtered;
	}

	public function childrenWithTag(tag : String) : ReadOnlyArray<Basic>
	{
		return _children.filter(function(child : Basic)
		{
			return child.tags.has(tag);
		});
	}

	public function render(g : Graphics)
	{
		g.clear(background);

		for (entity in _renderables)
		{
			entity.render(g);
		}
	}

	public function update(dt : Float)
	{
		for (entity in _updateables)
		{
			entity.update(dt);
		}
	}

	function get_children() : ReadOnlyArray<Basic>
	{
		return _children;
	}

	function get_collideables() : ReadOnlyArray<ICollideable>
	{
		return _collideables;
	}
}
