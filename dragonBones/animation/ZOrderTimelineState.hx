package dragonBones.animation;

import dragonBones.objects.ZOrderFrameData;


/**
 * @private
 */
@:final class ZOrderTimelineState extends TimelineState
{
	private function new(){}
	
	override private function _onArriveAtFrame():Void
	{
		super._onArriveAtFrame();
		
		_armature._sortZOrder(cast(_currentFrame, ZOrderFrameData).zOrder);            
	}
}