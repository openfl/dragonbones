package dragonBones.animation
{
import dragonBones.core.dragonBones_internal;
import dragonBones.objects.ZOrderFrameData;


/**
 * @private
 */
public final class ZOrderTimelineState extends TimelineState
{
	public function ZOrderTimelineState()
	{
		super(this);
	}
	
	override private function _onArriveAtFrame():Void
	{
		super._onArriveAtFrame();
		
		_armature._sortZOrder((_currentFrame as ZOrderFrameData).zOrder);            
	}
}
}