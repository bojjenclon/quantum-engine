package quantum;

import kha.Font;
import differ.shapes.Circle;
import differ.shapes.Polygon;
import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.Scaler;
import kha.System;
import kha.input.KeyCode;
import quantum.entities.display.AnimatedSprite;
import quantum.entities.display.Sprite;
import quantum.scene.Scene;
import quantum.ui.DebugUI;
import quantum.ui.IUI;
import quantum.debug.KhaDrawer;
import signals.Signal1;

class QuantumEngine
{
	public static final engine : QuantumEngine = new QuantumEngine();

	public final onSceneChanged : Signal1<Scene> = new Signal1<Scene>();

	public var width(default, null) : Int = 800;
	public var height(default, null) : Int = 600;

	public var timer(default, null) : Timer;

	public var scene(default, set) : Scene;

	#if debug
	public var debugUI(default, null) : DebugUI;

	public var debugDraw(default, null) : Bool = false;
	#end

	var _initialized : Bool = false;
	var _fps : Float = 1 / 60;
	var _accumulator : Float = 0;
	var _backBuffer : Image;
	#if debug
	var _uiBuffer : Image;
	#end

	var sprite : Sprite;
	var sub : Sprite;
	var anim : AnimatedSprite;

	// Hack until notifyOnResize works for all targets
	var _winWidth : Int;
	var _winHeight : Int;

	#if debug
	var _debugFont : Font;
	#end

	private function new() {}

	#if debug
	public function initialize(width : Int = 800, height : Int = 600, debugFont : Font)
	#else
	public function initialize(width : Int = 800, height : Int = 600)
	#end
	{
		this.width = width;
		this.height = height;
		
		#if debug
		_debugFont = debugFont;
		#end

		Assets.loadEverything(loadingFinished);
	}

	function loadingFinished()
	{
		_initialized = true;

		_backBuffer = Image.createRenderTarget(width, height);

		timer = new Timer();

		#if debug
		debugUI = new DebugUI(_debugFont);

		debugUI.onDebugDrawCheckChanged.add(onDebugDrawCheckChanged);
		#end

		onResize(System.windowWidth(0), System.windowHeight(0));

		var input = Input.instance;
		input.initialize();

		#if debug
		input.register("debugMenu", KeyCode.BackQuote);
		#end

		// Doesn't currently work for all targets, so
		// for now we use a hack.
		// Window
		// 	.get(0)
		// 	.notifyOnResize(onResize);

		System.notifyOnFrames(function(framebuffers)
		{
			render(framebuffers[0]);
		});
	}

	function render(framebuffer : Framebuffer)
	{
		if (!_initialized)
		{
			return;
		}

		// Resize hack until notifyOnResize works on all targets
		var curWinWidth = System.windowWidth(0);
		var curWinHeight = System.windowHeight(0);

		if (curWinWidth != _winWidth || curWinHeight != _winHeight)
		{
			onResize(curWinWidth, curWinHeight);
		}

		var gBuffer = _backBuffer.g2;

		#if debug
		var shapeDrawer = KhaDrawer.drawer;
		shapeDrawer.g = gBuffer;
		#end

		gBuffer.begin();

		if (scene != null)
		{
			scene.render(gBuffer);
		}

		gBuffer.end();

		#if debug
		var gUI = _uiBuffer.g2;

		gUI.begin();
		gUI.clear(Color.Transparent);
		gUI.end();

		debugUI.render(gUI);
		#end

		var gMain = framebuffer.g2;

		gMain.begin();
		Scaler.scale(_backBuffer, framebuffer, System.screenRotation);
		#if debug
		gMain.drawImage(_uiBuffer, 0, 0);
		#end
		gMain.end();

		update();
	}

	function update()
	{
		var dt = timer.update();
		var input = Input.instance;

		// https://gafferongames.com/post/fix_your_timestep/
		_accumulator += dt;
		while (_accumulator >= _fps)
		{
			#if debug
			if (input.justPressed("debugMenu"))
			{
				debugUI.visible = !debugUI.visible;
			}
			#end

			if (scene != null)
			{
				scene.update(dt);
			}

			input.update();

			_accumulator -= _fps;
		}
	}

	function onResize(windowWidth : Int, windowHeight : Int)
	{
		_winWidth = windowWidth;
		_winHeight = windowHeight;

		var scaleRect = Scaler.targetRect(width, height, _winWidth, _winHeight, System.screenRotation);

		#if debug
		_uiBuffer = Image.createRenderTarget(_winWidth, _winHeight);

		debugUI.scale(scaleRect.scaleFactor);
		#end
	}

	#if debug
	function onDebugDrawCheckChanged(value : Bool)
	{
		debugDraw = value;
	}
	#end

	function set_scene(value : Scene) : Scene
	{
		scene = value;

		onSceneChanged.dispatch(scene);

		return scene;
	}
}
