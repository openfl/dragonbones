package dragonBones.objects
{
import openfl.geom.ColorTransform;

/**
 * @private
 */
public final class SlotFrameData extends TweenFrameData
{
	public static inline var DEFAULT_COLOR:ColorTransform = new ColorTransform();
	
	public static function generateColor():ColorTransform
	{
		return new ColorTransform();
	}
	
	public var displayIndex:Int;
	public var color:ColorTransform;
	
	public function SlotFrameData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		displayIndex = 0;
		color = null;
	}
}
}