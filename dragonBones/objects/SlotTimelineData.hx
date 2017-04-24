package dragonBones.objects
{
/**
 * @private
 */
public final class SlotTimelineData extends TimelineData
{
	public var slot:SlotData;
	
	public function SlotTimelineData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		slot = null;
	}
}
}