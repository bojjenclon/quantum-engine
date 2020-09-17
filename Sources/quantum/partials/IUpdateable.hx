package quantum.partials;

interface IUpdateable
{
	public var priority : Int;

	public function update(dt : Float) : Void;
}
