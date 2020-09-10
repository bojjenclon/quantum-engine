package quantum;

import haxe.crypto.Md5;
import quantum.ds.IHashable;
import quantum.ds.UniqueArray;

class Basic implements IHashable
{
	public final tags : UniqueArray<String> = new UniqueArray<String>();

	public function serialize() : String
	{
		var buf = new StringBuf();

		buf.add('Tags=[${tags.join(",")}]');

		return buf.toString();
	}

	public function hash() : String
	{
		return Md5.encode(serialize());
	}
}
