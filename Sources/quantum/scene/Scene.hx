package quantum.scene;

import kha.Color;
import haxe.ds.ReadOnlyArray;
import kha.graphics2.Graphics;
import quantum.entities.display.IRenderable;
import signals.Signal1;

class Scene
{
	public final onChildAdded : Signal1<Basic> = new Signal1<Basic>();
	public final onChildRemoved : Signal1<Basic> = new Signal1<Basic>();

	public var background : Color = Color.Black;
	public var children(get, never) : ReadOnlyArray<Basic>;

	final _children : Array<Basic> = new Array<Basic>();
	final _renderables : Array<IRenderable> = new Array<IRenderable>();
	final _updateables : Array<IUpdateable> = new Array<IUpdateable>();

	public function new() {}

	public function addChild(child : Basic)
	{
		_children.push(child);

		if (Std.is(child, IRenderable))
		{
			_renderables.push(cast(child, IRenderable));
		}

		if (Std.is(child, IUpdateable))
		{
			_updateables.push(cast(child, IUpdateable));
		}

		onChildAdded.dispatch(child);
	}

	public function removeChild(child : Basic)
	{
		_children.remove(child);

		if (Std.is(child, IRenderable))
		{
			_renderables.remove(cast(child, IRenderable));
		}

		if (Std.is(child, IUpdateable))
		{
			_updateables.remove(cast(child, IUpdateable));
		}

		onChildRemoved.dispatch(child);
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
}
