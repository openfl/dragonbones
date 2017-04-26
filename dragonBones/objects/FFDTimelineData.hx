package dragonBones.objects;

/**
 * @private
 */
@:allow(dragonBones) class FFDTimelineData extends TimelineData
{
	public var skin:SkinData;
	public var slot:SkinSlotData;
	public var display:DisplayData;
	
	private function new()
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