package dragonBones.objects 
{
/**
 * @private
 */
public class FFDTimelineData extends TimelineData
{
	public var skin:SkinData;
	public var slot:SkinSlotData;
	public var display:DisplayData;
	
	public function FFDTimelineData() 
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		skin = null;
		slot = null;
		display = null;
	}
}

}