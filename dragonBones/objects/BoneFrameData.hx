package dragonBones.objects;

import dragonBones.geom.Transform;

/**
 * @private
 */
@:final class BoneFrameData extends TweenFrameData
{
	public var tweenScale:Bool;
	public var tweenRotate:Float;
	public var transform:Transform = new Transform();
	
	private function new() {}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweenScale = false;
		tweenRotate = 0.0;
		transform.identity();
	}
}