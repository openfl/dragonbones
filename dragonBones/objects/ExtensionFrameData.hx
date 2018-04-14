package dragonBones.objects;

import openfl.Vector;
	
/**
 * @private
 */
@:allow(dragonBones) @:final class ExtensionFrameData extends TweenFrameData
{
	public var tweens:Vector<Float> = new Vector<Float>();
	
	private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweens.fixed = false;
		tweens.length = 0;
	}
}