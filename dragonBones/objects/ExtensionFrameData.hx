package dragonBones.objects;

import openfl.Vector;
	
/**
 * @private
 */
@:final class ExtensionFrameData extends TweenFrameData
{
	public inline var tweens:Vector<Float> = new Vector<Float>();
	
	private function new() {}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweens.fixed = false;
		tweens.length = 0;
	}
}