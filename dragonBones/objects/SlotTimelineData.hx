package dragonBones.objects;

/**
 * @private
 */
@:allow(dragonBones) @:final class SlotTimelineData extends TimelineData
{
	public var slot:SlotData;
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		slot = null;
	}
}