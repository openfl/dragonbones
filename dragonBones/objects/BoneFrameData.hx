package dragonBones.objects
{
import dragonBones.geom.Transform;

/**
 * @private
 */
public final class BoneFrameData extends TweenFrameData
{
	public var tweenScale:Bool;
	public var tweenRotate:Float;
	public inline var transform:Transform = new Transform();
	
	public function BoneFrameData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweenScale = false;
		tweenRotate = 0.0;
		transform.identity();
	}
}
}