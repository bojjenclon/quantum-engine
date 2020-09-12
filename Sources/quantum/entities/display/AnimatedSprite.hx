package quantum.entities.display;

import kha.Image;
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

class AnimatedSprite extends Sprite
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

	public function new(image : Image, frameWidth : Int, frameHeight : Int)
	{
		super(image);

		this.frameWidth = frameWidth;
		this.frameHeight = frameHeight;

		_horizontalFrames = Math.ceil(_image.width / frameWidth);
		_verticalFrames = Math.ceil(_image.height / frameHeight);
	}

	override function renderSelf(g : Graphics)
	{
		// Calculate where we are in the overall image
		var sx = (currentFrame % _horizontalFrames) * frameWidth;
		var sy = Math.floor(currentFrame / _horizontalFrames) * frameHeight;

		g.drawScaledSubImage(_image, sx, sy, frameWidth, frameHeight, globalX, globalY, scaledWidth, scaledHeight);
	}

	override public function update(dt : Float)
	{
		if (!active)
		{
			return;
		}

		var animNeedsUpdate = true;
		if (currentAnimation == null || currentAnimation == "")
		{
			animNeedsUpdate = false;
		}
		else if (!isPlaying)
		{
			animNeedsUpdate = false;
		}

		var anim = animations[currentAnimation];

		if (anim != null && anim.finished)
		{
			animNeedsUpdate = false;
		}

		if (animNeedsUpdate)
		{
			var totalFrames = anim.frames.length;

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

		super.update(dt);
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

	override public function serialize() : String
	{
		var buf = new StringBuf();

		buf.add(super.serialize());

		buf.add(',FrameWidth=$frameWidth');
		buf.add(',FrameHeight=$frameHeight');
		buf.add(',CurrentFrame=$currentFrame');
		buf.add(',CurrentAnimation="$currentAnimation"');

		var animationsString = [];
		for (anim in animations)
		{
			animationsString.push('"${anim.name}"');
		}
		buf.add(',Animations=[${animationsString.join(",")}]');

		return buf.toString();
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
