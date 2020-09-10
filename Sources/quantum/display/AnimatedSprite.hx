package quantum.display;

import kha.math.FastVector2;
import kha.graphics2.Graphics;

class AnimatedSprite extends Sprite
{
	public var frameWidth(default, null) : Int = 0;
	public var frameHeight(default, null) : Int = 0;

	public var currentFrame : Int = 0;

	var _horizontalFrames : Int = 0;
	var _verticalFrames : Int = 0;

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

	override function get_width() : Int
	{
		return frameWidth;
	}

	override function get_height() : Int
	{
		return frameHeight;
	}
}
