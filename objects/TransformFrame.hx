package dragonBones.objects;

import openfl.geom.ColorTransform;
import openfl.geom.Point;

/** @private */
class TransformFrame extends Frame
{
	//NaN:no tween, 10:auto tween, [-1, 0):ease in, 0:line easing, (0, 1]:ease out, (1, 2]:ease in out
	public var tweenEasing:Float;
	public var tweenRotate:Int;
	public var tweenScale:Bool;
	public var displayIndex:Int;
	public var visible:Bool;
	public var zOrder:Float;

	public var global:DBTransform;
	public var transform:DBTransform;
	public var pivot:Point;
	public var color:ColorTransform;
	public var scaleOffset:Point;


	public function new()
	{
		super();

		tweenEasing = 10;
		tweenRotate = 0;
		tweenScale = true;
		displayIndex = 0;
		visible = true;
		zOrder = Math.NaN;

		global = new DBTransform();
		transform = new DBTransform();
		pivot = new Point();
		scaleOffset = new Point();
	}

	override public function dispose():Void
	{
		super.dispose();
		global = null;
		transform = null;
		pivot = null;
		scaleOffset = null;
		color = null;
	}
}

