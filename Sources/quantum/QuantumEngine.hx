package quantum;

import quantum.display.IRenderable;
import kha.Scaler;
import kha.Image;
import kha.input.KeyCode;
import kha.input.Keyboard;
import quantum.display.Sprite;
import quantum.display.AnimatedSprite;
import kha.Assets;
import kha.Scheduler;
import kha.System;
import kha.Framebuffer;

class QuantumEngine
{
	public static final engine : QuantumEngine = new QuantumEngine();

	public var width(default, null) : Int = 800;
	public var height(default, null) : Int = 600;

	var _initialized : Bool = false;
	var _fps : Float = 1 / 60;
	var _accumulator : Float = 0;
	var _backBuffer : Image;
	var _timer : Timer;

	final _renderables : Array<IRenderable> = new Array<IRenderable>();
	final _updateables : Array<IUpdateable> = new Array<IUpdateable>();

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
		sprite.scale.x = 4;
		sprite.scale.y = 2;

		anim = new AnimatedSprite("player", 32, 32);
		anim.x = 128;
		anim.y = 256;

		anim.addAnimation("idle", [0], 0, false);
		anim.addAnimation("run", [1, 2, 3, 4], 0.15, true);
		anim.addAnimation("jump", [5, 6, 7, 8, 9], 0.15, false);
		anim.addAnimation("air", [10], 0, false);
		anim.play("run");

		_renderables.push(sprite);
		_renderables.push(anim);

		_updateables.push(anim);

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

		for (entity in _renderables)
		{
			entity.render(gBuffer);
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
			for (entity in _updateables)
			{
				entity.update(dt);
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
}
