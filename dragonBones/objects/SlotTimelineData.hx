package dragonBones.objects;

/**
 * @private
 */
@:final class SlotTimelineData extends TimelineData
{
	public var slot:SlotData;
	
	private function new() {}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		slot = null;
	}
}