package dragonBones.objects;

/**
 * @private
 */
class FFDTimelineData extends TimelineData
{
	public var skin:SkinData;
	public var slot:SkinSlotData;
	public var display:DisplayData;
	
	@:allow("dragonBones") private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		skin = null;
		slot = null;
		display = null;
	}
}