package dragonBones.objects;

import openfl.geom.Point;

class RectangleData implements IAreaData
{
	public var _name:String;

	public var width:Float;
	public var height:Float;
	public var transform:DBTransform;
	public var pivot:Point;

	public function new()
	{
		width = 0;
		height = 0;
		transform = new DBTransform();
		pivot = new Point();
	}

	public var name(get, set):String;
	public function get_name():String {
		return _name;
	}
	public function set_name(name:String):String {
		_name = name;
		return _name;
	}
	public function dispose():Void
	{
		transform = null;
		pivot = null;
	}
}
