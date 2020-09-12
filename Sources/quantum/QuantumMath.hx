package quantum;

class QuantumMath
{
	public static inline var EPSILON : Float = 0.0000001;

	public static inline function clamp(value : Float, min : Float, max : Float) : Float
	{
		if (value < min)
		{
			return min;
		}

		if (value > max)
		{
			return max;
		}

		return value;
	}

	public static inline function equal(a : Float, b : Float, sep : Float = EPSILON) : Bool
	{
		return Math.abs(a - b) <= sep;
	}

	public static inline function sign(value : Float) : Int
	{
		return (value < 0) ? -1 : 1;
	}

	private function new() {}
}
