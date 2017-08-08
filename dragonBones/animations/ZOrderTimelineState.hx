package dragonBones.animations;

import dragonBones.objects.ZOrderFrameData;


/**
 * @private
 */
@:allow(dragonBones) @:final class ZOrderTimelineState extends TimelineState
{
	private function new()
	{
		super();
	}
	
	override private function _onArriveAtFrame():Void
	{
		super._onArriveAtFrame();
		
		_armature._sortZOrder(cast(_currentFrame, ZOrderFrameData).zOrder);            
	}
}