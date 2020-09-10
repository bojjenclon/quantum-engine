package quantum.display;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import signals.Signal1;

typedef Animation =
{
	var name : String;
	var frames : Array<Int>;
	var speed : Float;
	var loop : Bool;
	var finished : Bool;
}

class AnimatedSprite extends Sprite implements IUpdateable
{
	public final onAnimationChanged : Signal1<String> = new Signal1<String>();
	public final onAnimationFinished : Signal1<String> = new Signal1<String>();

	public var frameWidth(default, null) : Int = 0;
	public var frameHeight(default, null) : Int = 0;

	public var currentFrame : Int = 0;

	public final animations : Map<String, Animation> = new Map<String, Animation>();
	public var currentAnimation(default, null) : String;
	public var isPlaying : Bool = true;

	var _horizontalFrames : Int = 0;
	var _verticalFrames : Int = 0;

	var _animFrame : Int = 0;
	var _timeOnFrame : Float = 0;

	public function new(imageName : String, frameWidth : Int, frameHeight : Int)
	{
		super(imageName);

		this.frameWidth = frameWidth;
		this.frameHeight = frameHeight;

		_horizontalFrames = Math.ceil(_image.width / frameWidth);
		_verticalFrames = Math.ceil(_image.height / frameHeight);
	}

	override public function render(g : Graphics)
	{
		var center = new FastVector2(scaledWidth / 2, scaledHeight / 2);
		var rad = Math.PI / 180 * rotation;

		// Calculate where we are in the overall image
		var sx = (currentFrame % _horizontalFrames) * frameWidth;
		var sy = Math.floor(currentFrame / _horizontalFrames) * frameHeight;

		// Rotate about the origin
		g.pushRotation(rad, x + center.x, y + center.y);
		g.pushOpacity(alpha);

		g.drawScaledSubImage(_image, sx, sy, frameWidth, frameHeight, x, y, scaledWidth, scaledHeight);

		g.popOpacity();
		g.popTransformation();
	}

	public function addAnimation(name : String, frames : Array<Int>, speed : Float = 0.1, loop : Bool = true)
	{
		animations.set(name, {
			name: name,
			frames: frames,
			loop: loop,
			speed: speed,
			finished: false
		});
	}

	public function play(name : String, force : Bool = false)
	{
		if (currentAnimation == name && !force)
		{
			return;
		}

		currentAnimation = name;
		_animFrame = 0;
		_timeOnFrame = 0;

		var anim = animations[currentAnimation];
		currentFrame = anim.frames[_animFrame];

		isPlaying = true;

		onAnimationChanged.dispatch(currentAnimation);
	}

	public function resume()
	{
		isPlaying = true;
	}

	public function pause()
	{
		isPlaying = false;
	}

	public function update(dt : Float)
	{
		if (currentAnimation == null || currentAnimation == "")
		{
			return;
		}
		else if (!isPlaying)
		{
			return;
		}

		var anim = animations[currentAnimation];
		var totalFrames = anim.frames.length;

		if (anim.finished)
		{
			return;
		}

		_timeOnFrame += dt;
		if (_timeOnFrame >= anim.speed)
		{
			_animFrame++;
			if (_animFrame >= totalFrames)
			{
				_animFrame = anim.loop ? _animFrame % totalFrames : totalFrames - 1;
				anim.finished = !anim.loop;

				if (anim.finished)
				{
					onAnimationFinished.dispatch(currentAnimation);
				}
			}

			currentFrame = anim.frames[_animFrame];

			_timeOnFrame = 0;
		}
	}

	override function get_width() : Int
	{
		return frameWidth;
	}

	override function get_height() : Int
	{
		return frameHeight;
	}
}
