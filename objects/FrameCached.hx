package dragonBones.objects;

import openfl.geom.Matrix;

/** @private */
class FrameCached
{
	public var transform:DBTransform;
	public var matrix:Matrix;

	public function new()
	{

	}

	public function dispose():Void
	{
		transform = null;
		matrix = null;
	}
}
