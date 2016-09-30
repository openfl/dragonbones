package dragonBones.objects;

import flash.geom.Point;

/** @private */
class DisplayData
{
	public static var ARMATURE:String = "armature";
	public static var IMAGE:String = "image";

	public var name:String;
	public var type:String;
	public var transform:DBTransform;
	public var pivot:Point;

	public function new()
	{
		transform = new DBTransform();
	}

	public function dispose():Void
	{
		transform = null;
		pivot = null;
	}
}
