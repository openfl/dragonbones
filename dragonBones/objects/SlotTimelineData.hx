package dragonBones.objects;

/**
 * @private
 */
@:final class SlotTimelineData extends TimelineData
{
	public var slot:SlotData;
	
	@:allow("dragonBones") private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		slot = null;
	}
}