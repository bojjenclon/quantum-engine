package quantum;

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

	var _fps = 1 / 60;
	var sprite : Sprite;
	var anim : AnimatedSprite;

	private function new() {}

	public function initialize()
	{
		Assets.loadEverything(function()
		{
			sprite = new Sprite("tex");
			sprite.x = 64;
			sprite.scale.x = 4;
			sprite.scale.y = 2;

			anim = new AnimatedSprite("player", 32, 32);
			anim.x = 128;
			anim.y = 256;

			var keyboard = Keyboard.get();
			keyboard.notify(onKeyDown, onKeyUp);

			Scheduler.addTimeTask(function()
			{
				update();
			}, 0, _fps);

			System.notifyOnFrames(function(framebuffers)
			{
				render(framebuffers[0]);
			});
		});
	}

	function update() {}

	function render(framebuffer : Framebuffer)
	{
		var g = framebuffer.g2;

		g.begin();

		sprite.render(g);
		anim.render(g);

		g.end();
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
