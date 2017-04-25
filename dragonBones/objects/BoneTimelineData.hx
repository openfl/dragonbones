package dragonBones.objects;

import dragonBones.geom.Transform;

/**
 * @private
 */
@:final class BoneTimelineData extends TimelineData
{
	public var originalTransform:Transform = new Transform();
	public var bone:BoneData;
	
	@:allow("dragonBones") private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		originalTransform.identity();
		bone = null;
	}
}