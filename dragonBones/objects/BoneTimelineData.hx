package dragonBones.objects
{
import dragonBones.geom.Transform;

/**
 * @private
 */
public final class BoneTimelineData extends TimelineData
{
	public inline var originalTransform:Transform = new Transform();
	public var bone:BoneData;
	
	public function BoneTimelineData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		originalTransform.identity();
		bone = null;
	}
}
}