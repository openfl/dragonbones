package dragonBones.objects;

import dragonBones.geom.Transform;

/**
 * @private
 */
@:allow(dragonBones) @:final class BoneTimelineData extends TimelineData
{
	public var originalTransform:Transform = new Transform();
	public var bone:BoneData;
	
	@:keep private function new()
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