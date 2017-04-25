package dragonBones.objects;

import openfl.geom.ColorTransform;

/**
 * @private
 */
@:final class SlotFrameData extends TweenFrameData
{
	public static var DEFAULT_COLOR:ColorTransform = new ColorTransform();
	
	public static function generateColor():ColorTransform
	{
		return new ColorTransform();
	}
	
	public var displayIndex:Int;
	public var color:ColorTransform;
	
	@:allow("dragonBones") private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		displayIndex = 0;
		color = null;
	}
}