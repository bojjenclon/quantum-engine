package quantum;

import kha.Scaler;
import kha.Image;
import kha.input.KeyCode;
import kha.input.Keyboard;
import quantum.entities.display.IRenderable;
import quantum.entities.display.Sprite;
import quantum.entities.display.AnimatedSprite;
import quantum.scene.Scene;
import kha.Assets;
import kha.Scheduler;
import kha.System;
import kha.Framebuffer;
import signals.Signal1;

class QuantumEngine
{
	public static final engine : QuantumEngine = new QuantumEngine();

	public final onSceneChanged : Signal1<Scene> = new Signal1<Scene>();

	public var width(default, null) : Int = 800;
	public var height(default, null) : Int = 600;

	public var scene(default, set) : Scene;

	var _initialized : Bool = false;
	var _fps : Float = 1 / 60;
	var _accumulator : Float = 0;
	var _backBuffer : Image;
	var _timer : Timer;

	var sprite : Sprite;
	var anim : AnimatedSprite;

	private function new() {}

	public function initialize(width : Int = 800, height : Int = 600)
	{
		this.width = width;
		this.height = height;

		Assets.loadEverything(loadingFinished);
	}

	function loadingFinished()
	{
		_initialized = true;

		_backBuffer = Image.createRenderTarget(width, height);

		_timer = new Timer();

		sprite = new Sprite("tex");
		sprite.x = 64;
		sprite.y = 32;
		sprite.scale.x = 4;
		sprite.scale.y = 2;
		sprite.alpha = 0.5;

		var sub = new Sprite("tex");
		sub.x = 64;
		sub.y = 96;
		sub.alpha = 0.5; // Equates to 0.5 * 0.5
		sprite.addChild(sub);

		anim = new AnimatedSprite("player", 32, 32);
		anim.x = 128;
		anim.y = 256;

		anim.addAnimation("idle", [0], 0, false);
		anim.addAnimation("run", [1, 2, 3, 4], 0.15, true);
		anim.addAnimation("jump", [5, 6, 7, 8, 9], 0.15, false);
		anim.addAnimation("air", [10], 0, false);
		anim.play("run");

		scene = new Scene();
		scene.addChild(sprite);
		scene.addChild(anim);

		var keyboard = Keyboard.get();
		keyboard.notify(onKeyDown, onKeyUp);

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

		var gBuffer = _backBuffer.g2;

		gBuffer.begin();

		if (scene != null)
		{
			scene.render(gBuffer);
		}

		gBuffer.end();

		var gMain = framebuffer.g2;

		gMain.begin();
		Scaler.scale(_backBuffer, framebuffer, System.screenRotation);
		gMain.end();

		update();
	}

	function update()
	{
		var dt = _timer.update();

		// https://gafferongames.com/post/fix_your_timestep/
		_accumulator += dt;
		while (_accumulator >= _fps)
		{
			if (scene != null)
			{
				scene.update(dt);
			}

			_accumulator -= _fps;
		}
	}

	function onKeyDown(keyCode : KeyCode) {}

	function onKeyUp(keyCode : KeyCode)
	{
		if (keyCode == KeyCode.One)
		{
			anim.currentFrame++;
		}
		else if (keyCode == KeyCode.Two)
		{
			sprite.rotation += 5;
			anim.rotation += 5;
		}
	}

	function set_scene(value : Scene) : Scene
	{
		scene = value;

		onSceneChanged.dispatch(scene);

		return scene;
	}
}
